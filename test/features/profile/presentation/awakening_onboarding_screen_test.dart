import 'package:ascend/features/profile/presentation/awakening_onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'AwakeningOnboardingScreen keeps focus selection and next action visible',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AwakeningOnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Primeira semana'), findsOneWidget);
      expect(find.text('Escolha seu foco'), findsOneWidget);
      expect(find.text('Entrar em Quests com esse kit'), findsOneWidget);
      expect(find.text('Disciplina'), findsAtLeastNWidgets(1));
      await tester.scrollUntilVisible(
        find.text('Seu kit inicial'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Seu kit inicial'), findsOneWidget);
      expect(
        find.textContaining('Disciplina entra com um kit curto'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('Primeiro passo recomendado'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Primeiro passo recomendado'), findsOneWidget);
      expect(find.text('Arrumar a cama ao acordar'), findsAtLeastNWidgets(1));
      expect(find.text('Base primeiro'), findsOneWidget);
    },
  );
}
