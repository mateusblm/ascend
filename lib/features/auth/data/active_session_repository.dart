import 'dart:math';

import 'package:ascend/core/config/java_backend_config.dart';
import 'package:ascend/features/auth/data/java_session_backend_client.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActiveSessionConflictException implements Exception {
  const ActiveSessionConflictException();
}

bool isActiveSessionConflictError(Object error) {
  if (error is ActiveSessionConflictException) {
    return true;
  }
  if (error is JavaSessionBackendException && error.isActiveSessionConflict) {
    return true;
  }

  return false;
}

class ActiveSessionRepository {
  ActiveSessionRepository({
    FirebaseAuth? auth,
    JavaSessionBackendClient? javaBackendClient,
    Future<String?> Function()? idTokenProvider,
    Future<SharedPreferences>? preferences,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _javaBackendClient =
           javaBackendClient ??
           (JavaBackendConfig.isEnabled
               ? JavaSessionBackendClient(baseUrl: JavaBackendConfig.baseUrl)
               : null),
       _idTokenProvider = idTokenProvider,
       _preferencesFuture = preferences ?? SharedPreferences.getInstance();

  static const String _sessionIdKey = 'active_device_session_id';

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
    final deviceSessionId = await this.deviceSessionId();
    final deviceLabel = _deviceLabel();
    final javaBackendClient = _javaBackendClientObrigatorio(name);
    final idToken = await _idTokenObrigatorio(name);

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
    } on JavaSessionBackendException catch (error) {
      if (error.isActiveSessionConflict) {
        throw const ActiveSessionConflictException();
      }
      rethrow;
    }
  }

  Future<String> _idTokenObrigatorio(String acao) async {
    final provider = _idTokenProvider;
    final idToken = provider != null
        ? await provider()
        : await _auth.currentUser?.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Token Firebase ausente para $acao.');
    }
    return idToken;
  }

  JavaSessionBackendClient _javaBackendClientObrigatorio(String acao) {
    final javaBackendClient = _javaBackendClient;
    if (javaBackendClient == null) {
      throw StateError('Backend Java nao configurado para $acao.');
    }
    return javaBackendClient;
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
