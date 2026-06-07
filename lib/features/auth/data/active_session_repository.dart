import 'dart:math';

import 'package:ascend/core/config/java_backend_config.dart';
import 'package:ascend/features/auth/data/java_session_backend_client.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActiveSessionConflictException implements Exception {
  const ActiveSessionConflictException();
}

bool isActiveSessionConflictError(Object error) {
  if (error is! FirebaseFunctionsException) {
    return false;
  }

  final details = error.details;
  if (details is Map && details['reason'] == 'active_session_conflict') {
    return true;
  }

  return error.code == 'failed-precondition' &&
      error.message != null &&
      error.message!.toLowerCase().contains('sessao ativa');
}

class ActiveSessionRepository {
  ActiveSessionRepository({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
    JavaSessionBackendClient? javaBackendClient,
    Future<String?> Function()? idTokenProvider,
    Future<SharedPreferences>? preferences,
  }) : _functions =
           functions ??
           FirebaseFunctions.instanceFor(region: 'southamerica-east1'),
       _auth = auth ?? FirebaseAuth.instance,
       _javaBackendClient =
           javaBackendClient ??
           (JavaBackendConfig.isEnabled
               ? JavaSessionBackendClient(baseUrl: JavaBackendConfig.baseUrl)
               : null),
       _idTokenProvider = idTokenProvider,
       _preferencesFuture = preferences ?? SharedPreferences.getInstance();

  static const String _sessionIdKey = 'active_device_session_id';

  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;
  final JavaSessionBackendClient? _javaBackendClient;
  final Future<String?> Function()? _idTokenProvider;
  final Future<SharedPreferences> _preferencesFuture;

  Future<String> deviceSessionId() async {
    final preferences = await _preferencesFuture;
    final current = preferences.getString(_sessionIdKey);
    if (current != null && current.isNotEmpty) {
      return current;
    }

    final generated = _generateDeviceSessionId();
    await preferences.setString(_sessionIdKey, generated);
    return generated;
  }

  Future<void> registerActiveSession() async {
    await _callSessionFunction('registerActiveSession');
  }

  Future<void> releaseActiveSession() async {
    try {
      await _callSessionFunction('releaseActiveSession');
    } catch (_) {
      // Ignore release failures during local logout cleanup.
    }
  }

  Future<void> _callSessionFunction(String name) async {
    final callable = _functions.httpsCallable(name);
    final deviceSessionId = await this.deviceSessionId();
    final deviceLabel = _deviceLabel();
    final javaBackendClient = _javaBackendClient;
    final idToken = await _currentIdToken();

    if (javaBackendClient != null && idToken != null && idToken.isNotEmpty) {
      try {
        if (name == 'registerActiveSession') {
          await javaBackendClient.registerActiveSession(
            idToken: idToken,
            deviceSessionId: deviceSessionId,
            deviceLabel: deviceLabel,
          );
        } else {
          await javaBackendClient.releaseActiveSession(
            idToken: idToken,
            deviceSessionId: deviceSessionId,
            deviceLabel: deviceLabel,
          );
        }
        return;
      } on JavaSessionBackendException catch (error) {
        if (error.isActiveSessionConflict) {
          throw const ActiveSessionConflictException();
        }
        if (error.isBusinessRuleFailure) {
          rethrow;
        }
      }
    }

    try {
      await callable.call(<String, dynamic>{
        'deviceSessionId': deviceSessionId,
        'deviceLabel': deviceLabel,
      });
    } catch (error) {
      if (isActiveSessionConflictError(error)) {
        throw const ActiveSessionConflictException();
      }
      rethrow;
    }
  }

  Future<String?> _currentIdToken() async {
    final provider = _idTokenProvider;
    if (provider != null) {
      return provider();
    }
    return _auth.currentUser?.getIdToken();
  }

  String _generateDeviceSessionId() {
    final random = Random.secure();
    final entropy = List<int>.generate(4, (_) => random.nextInt(1 << 32));
    final suffix = entropy.map((value) => value.toRadixString(16)).join();
    return '${DateTime.now().microsecondsSinceEpoch}-$suffix';
  }

  String _deviceLabel() {
    if (kIsWeb) {
      return 'web';
    }

    return defaultTargetPlatform.name;
  }
}
