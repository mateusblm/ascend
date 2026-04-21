import 'dart:async';

import 'package:ascend/core/analytics/analytics_service.dart';
import 'package:ascend/core/crash/crash_reporting_service.dart';
import 'package:ascend/features/auth/data/active_session_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/auth_state.dart';

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    analytics: ref.read(analyticsProvider),
    crashReporter: ref.read(crashReportingProvider),
    sessionRepository: ActiveSessionRepository(),
  );
});

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    AppAnalytics? analytics,
    AppCrashReporter? crashReporter,
    ActiveSessionRepository? sessionRepository,
  }) : _analytics = analytics ?? const NoopAppAnalytics(),
       _crashReporter = crashReporter ?? const NoopAppCrashReporter(),
       _sessionRepository = sessionRepository,
       super(AuthInitial()) {
    final user = _auth.currentUser;
    if (user != null) {
      state = _successStateFor(user);
      _lastTrackedUid = user.uid;
      unawaited(_analytics.setUserId(user.uid));
      unawaited(_crashReporter.setUserId(user.uid));
      unawaited(_analytics.logAuthLoginSucceeded(restoredSession: true));
      unawaited(_establishActiveSession(enforceConflictSignOut: true));
    }

    _subscription = _auth.authStateChanges().listen((user) {
      if (user == null) {
        _stopSessionHeartbeat();
        if (_lastTrackedUid != null) {
          unawaited(_analytics.logAuthSignedOut());
          unawaited(_analytics.setUserId(null));
          unawaited(_crashReporter.setUserId(null));
        }
        _lastTrackedUid = null;
        _loginFlowInProgress = false;
        final failureMessage = _pendingSignOutFailureMessage;
        _pendingSignOutFailureMessage = null;
        state = failureMessage == null
            ? AuthInitial()
            : AuthFailure(failureMessage);
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
      unawaited(_establishActiveSession(enforceConflictSignOut: true));
    });
  }

  static const Duration _sessionHeartbeatInterval = Duration(minutes: 1);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AppAnalytics _analytics;
  final AppCrashReporter _crashReporter;
  final ActiveSessionRepository? _sessionRepository;
  late final StreamSubscription<User?> _subscription;

  String? _lastTrackedUid;
  bool _loginFlowInProgress = false;
  Timer? _sessionHeartbeat;
  String? _pendingSignOutFailureMessage;

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
    _stopSessionHeartbeat();
    await _sessionRepository?.releaseActiveSession();
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
    _stopSessionHeartbeat();
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _establishActiveSession({
    required bool enforceConflictSignOut,
  }) async {
    final sessionRepository = _sessionRepository;
    if (sessionRepository == null || _auth.currentUser == null) {
      return;
    }

    try {
      await sessionRepository.registerActiveSession();
      _startSessionHeartbeat();
    } on ActiveSessionConflictException {
      if (!enforceConflictSignOut) {
        return;
      }
      await _forceSignOutDueToConflict();
    } catch (error, stackTrace) {
      await _crashReporter.recordError(
        error,
        stackTrace,
        reason: 'auth_active_session_register',
        fatal: false,
      );
    }
  }

  void _startSessionHeartbeat() {
    _sessionHeartbeat?.cancel();
    _sessionHeartbeat = Timer.periodic(_sessionHeartbeatInterval, (_) {
      unawaited(_establishActiveSession(enforceConflictSignOut: true));
    });
  }

  void _stopSessionHeartbeat() {
    _sessionHeartbeat?.cancel();
    _sessionHeartbeat = null;
  }

  Future<void> _forceSignOutDueToConflict() async {
    _pendingSignOutFailureMessage =
        'Essa conta ja esta ativa em outro dispositivo.';
    _stopSessionHeartbeat();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
