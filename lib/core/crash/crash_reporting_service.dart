import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final crashReportingProvider = Provider<AppCrashReporter>((ref) {
  return buildAppCrashReporter();
});

AppCrashReporter buildAppCrashReporter() {
  try {
    if (Firebase.apps.isEmpty) {
      return const NoopAppCrashReporter();
    }
    return FirebaseAppCrashReporter(FirebaseCrashlytics.instance);
  } catch (_) {
    return const NoopAppCrashReporter();
  }
}

abstract class AppCrashReporter {
  const AppCrashReporter();

  Future<void> initialize();

  Future<void> setUserId(String? uid);

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    bool fatal = false,
  });

  Future<void> recordFlutterFatal(FlutterErrorDetails details);
}

class NoopAppCrashReporter extends AppCrashReporter {
  const NoopAppCrashReporter();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> setUserId(String? uid) async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {}

  @override
  Future<void> recordFlutterFatal(FlutterErrorDetails details) async {}
}

class FirebaseAppCrashReporter extends AppCrashReporter {
  FirebaseAppCrashReporter(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> initialize() async {
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  @override
  Future<void> setUserId(String? uid) async {
    await _crashlytics.setUserIdentifier(uid ?? '');
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  @override
  Future<void> recordFlutterFatal(FlutterErrorDetails details) async {
    await _crashlytics.recordFlutterFatalError(details);
  }
}

class CrashReportingObserver extends ProviderObserver {
  CrashReportingObserver(this._crashReporter);

  final AppCrashReporter _crashReporter;

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    unawaited(
      _crashReporter.recordError(
        error,
        stackTrace,
        reason: 'riverpod:${provider.name ?? provider.runtimeType}',
        fatal: false,
      ),
    );
  }
}
