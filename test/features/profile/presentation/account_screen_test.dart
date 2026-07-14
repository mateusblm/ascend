import 'package:ascend/features/auth/domain/auth_state.dart';
import 'package:ascend/features/auth/presentation/auth_controller.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/account_screen.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  testWidgets('AccountScreen exposes trust-critical panels and dialogs', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            (ref) => _FakeAuthController(
              AuthSuccess(
                uid: 'uid-1',
                displayName: 'Hunter',
                photoUrl: '',
                email: 'hunter@example.com',
              ),
            ),
          ),
          playerProvider.overrideWith((ref) => _TestPlayerNotifier(_player())),
        ],
        child: const MaterialApp(home: AccountScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('account-profile-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('account-privacy-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('account-support-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('account-session-panel')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('account-privacy-button')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('account-privacy-button')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Politica de privacidade'), findsOneWidget);
  });

  testWidgets('AccountScreen triggers sign out through auth controller', (
    tester,
  ) async {
    final authController = _FakeAuthController(
      AuthSuccess(
        uid: 'uid-1',
        displayName: 'Hunter',
        photoUrl: '',
        email: 'hunter@example.com',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => authController),
          playerProvider.overrideWith((ref) => _TestPlayerNotifier(_player())),
        ],
        child: const MaterialApp(home: AccountScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('account-sign-out-button')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('account-sign-out-button')));
    await tester.pumpAndSettle();

    expect(authController.signOutCalls, 1);
  });
}

class _TestPlayerNotifier extends PlayerNotifier {
  _TestPlayerNotifier(Player state) : super(_FakeIsar(), state);
}

class _FakeAuthController extends StateNotifier<AuthState>
    implements AuthController {
  _FakeAuthController(super.state);

  int signOutCalls = 0;

  @override
  Future<void> handleActiveSessionConflict() async {}

  @override
  Future<void> refreshActiveSession() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInAsTester() async {}

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
    state = AuthInitial();
  }
}

class _FakeIsar implements Isar {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Player _player() {
  return Player(
    ownerUid: 'uid-1',
    name: 'Hunter',
    level: 6,
    xp: 40,
    maxXp: 100,
    attributes: PlayerAttributes(),
    lastResetDate: DateTime(2026, 4, 21),
    primaryFocus: AwakeningPath.study,
    hasCompletedOnboarding: true,
  );
}
