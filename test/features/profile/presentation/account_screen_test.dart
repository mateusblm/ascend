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
  testWidgets('AccountScreen shows connected account and support surfaces', (
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
          playerProvider.overrideWith(
            (ref) => _TestPlayerNotifier(
              Player(
                ownerUid: 'uid-1',
                name: 'Hunter',
                level: 6,
                xp: 40,
                maxXp: 100,
                attributes: PlayerAttributes(),
                lastResetDate: DateTime(2026, 4, 21),
                primaryFocus: AwakeningPath.study,
                hasCompletedOnboarding: true,
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: AccountScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hunter'), findsWidgets);
    expect(find.text('hunter@example.com'), findsWidgets);
    expect(find.text('support@ascend.app'), findsOneWidget);
    expect(find.text('Pedido manual com revisao operacional'), findsOneWidget);
    expect(find.text('SAIR DA CONTA'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('PRIVACIDADE'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('PRIVACIDADE'));
    await tester.pumpAndSettle();

    expect(find.text('Politica de privacidade'), findsOneWidget);
    expect(
      find.textContaining('Ascend coleta somente os dados necessarios'),
      findsOneWidget,
    );
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
          playerProvider.overrideWith(
            (ref) => _TestPlayerNotifier(
              Player(
                ownerUid: 'uid-1',
                name: 'Hunter',
                level: 6,
                xp: 40,
                maxXp: 100,
                attributes: PlayerAttributes(),
                lastResetDate: DateTime(2026, 4, 21),
                hasCompletedOnboarding: true,
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: AccountScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('SAIR DA CONTA'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('SAIR DA CONTA'));
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
  Future<void> signOut() async {
    signOutCalls += 1;
    state = AuthInitial();
  }
}

class _FakeIsar implements Isar {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
