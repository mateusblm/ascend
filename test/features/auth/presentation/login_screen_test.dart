import 'package:ascend/features/auth/domain/auth_state.dart';
import 'package:ascend/features/auth/presentation/auth_controller.dart';
import 'package:ascend/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LoginScreen exposes primary auth surfaces and CTA', (
    tester,
  ) async {
    final controller = _FakeAuthController(AuthInitial());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith((ref) => controller)],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('login-hero')), findsOneWidget);
    expect(find.byKey(const ValueKey('login-auth-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('login-google-button')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('login-google-button')));
    await tester.tap(find.byKey(const ValueKey('login-google-button')));
    expect(controller.signInCalls, 1);
  });

  testWidgets('LoginScreen renders auth failure inside feedback surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            (ref) => _FakeAuthController(AuthFailure('Falha ao entrar.')),
          ),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('login-error-panel')), findsOneWidget);
    expect(find.text('Falha ao entrar.'), findsOneWidget);
  });
}

class _FakeAuthController extends StateNotifier<AuthState>
    implements AuthController {
  _FakeAuthController(super.state);

  int signInCalls = 0;

  @override
  Future<void> handleActiveSessionConflict() async {}

  @override
  Future<void> refreshActiveSession() async {}

  @override
  Future<void> signInWithGoogle() async {
    signInCalls += 1;
  }

  @override
  Future<void> signOut() async {}
}
