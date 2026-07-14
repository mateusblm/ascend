import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/awakening_onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'AwakeningOnboardingScreen exposes focus selection, starter kit and first action',
    (tester) async {
      _setLargeSurface(tester);
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AwakeningOnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('onboarding-focus-section')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('onboarding-primary-cta')),
        findsOneWidget,
      );

      for (final focus in AwakeningPath.values) {
        expect(
          find.byKey(ValueKey('onboarding-focus-${focus.name}')),
          findsOneWidget,
        );
      }

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('onboarding-focus-health')),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const ValueKey('onboarding-focus-health')));
      await tester.pumpAndSettle();

      await _dragUntilVisible(
        tester,
        find.byKey(const ValueKey('onboarding-starter-kit')),
      );
      await _dragUntilVisible(
        tester,
        find.byKey(const ValueKey('onboarding-first-action')),
      );
      expect(
        find.byKey(const ValueKey('onboarding-first-action')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey('onboarding-starter-quest-health-inicial'),
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      expect(
        find.text('Bater a meta de agua do dia', skipOffstage: false),
        findsAtLeastNWidgets(1),
      );
    },
  );
}

Future<void> _dragUntilVisible(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 12 && finder.evaluate().isEmpty; i++) {
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await tester.pumpAndSettle();
  }
}

void _setLargeSurface(WidgetTester tester) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1080, 2200);
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
