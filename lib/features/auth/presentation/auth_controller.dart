import 'dart:async';

import 'package:ascend/core/analytics/analytics_service.dart';
import 'package:ascend/core/crash/crash_reporting_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/auth_state.dart';

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.read(analyticsProvider),
    ref.read(crashReportingProvider),
  );
});

class AuthController extends StateNotifier<AuthState> {
  AuthController([AppAnalytics? analytics, AppCrashReporter? crashReporter])
    : _analytics = analytics ?? const NoopAppAnalytics(),
      _crashReporter = crashReporter ?? const NoopAppCrashReporter(),
      super(AuthInitial()) {
    final user = _auth.currentUser;
    if (user != null) {
      state = _successStateFor(user);
      _lastTrackedUid = user.uid;
      unawaited(_analytics.setUserId(user.uid));
      unawaited(_crashReporter.setUserId(user.uid));
      unawaited(_analytics.logAuthLoginSucceeded(restoredSession: true));
    }

    _subscription = _auth.authStateChanges().listen((user) {
      if (user == null) {
        if (_lastTrackedUid != null) {
          unawaited(_analytics.logAuthSignedOut());
          unawaited(_analytics.setUserId(null));
          unawaited(_crashReporter.setUserId(null));
        }
        _lastTrackedUid = null;
        _loginFlowInProgress = false;
        state = AuthInitial();
        return;
      }

      state = _successStateFor(user);
      if (_lastTrackedUid != user.uid) {
        unawaited(_analytics.setUserId(user.uid));
        unawaited(_crashReporter.setUserId(user.uid));
        unawaited(
          _analytics.logAuthLoginSucceeded(
            restoredSession: !_loginFlowInProgress,
          ),
        );
        _lastTrackedUid = user.uid;
      }
      _loginFlowInProgress = false;
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AppAnalytics _analytics;
  final AppCrashReporter _crashReporter;
  late final StreamSubscription<User?> _subscription;

  String? _lastTrackedUid;
  bool _loginFlowInProgress = false;

  Future<void> signInWithGoogle() async {
    state = AuthLoading();
    _loginFlowInProgress = true;
    await _analytics.logAuthLoginStarted();

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _loginFlowInProgress = false;
        await _analytics.logAuthLoginCancelled();
        state = AuthInitial();
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      _loginFlowInProgress = false;
      await _analytics.logAuthLoginFailed(reason: e.runtimeType.toString());
      state = AuthFailure('Falha ao entrar: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  AuthSuccess _successStateFor(User user) {
    return AuthSuccess(
      uid: user.uid,
      displayName: user.displayName ?? 'Jogador',
      photoUrl: user.photoURL ?? '',
      email: user.email,
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
