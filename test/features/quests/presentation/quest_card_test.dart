import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/widgets/quest_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'QuestCard keeps competitive primary action interactive without render errors',
    (tester) async {
      var primaryCalls = 0;
      final quest = Quest(
        id: 'competitive-1',
        title: 'Sessao profunda de estudo',
        rewardAttribute: AttributeType.intelligence,
        xpReward: 14,
        category: QuestCategory.competitive,
        verificationMode: QuestVerificationMode.timer,
        verificationStatus: QuestVerificationStatus.ready,
        targetDurationMinutes: 25,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestCard(
              quest: quest,
              helperText: 'Inicie no app e feche 25 min para contar.',
              onPrimaryAction: () => primaryCalls += 1,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final primaryFinder = find.byKey(
        const ValueKey('quest-card-primary-competitive-1'),
      );
      expect(
        find.byKey(const ValueKey('quest-card-competitive-1')),
        findsOneWidget,
      );
      expect(primaryFinder, findsOneWidget);
      expect(tester.widget<FilledButton>(primaryFinder).onPressed, isNotNull);

      await tester.tap(primaryFinder);
      expect(primaryCalls, 1);
    },
  );

  testWidgets(
    'QuestCard exposes secondary action for completed personal quests',
    (tester) async {
      var secondaryCalls = 0;
      final quest = Quest(
        id: 'personal-1',
        title: 'Revisar metas do dia',
        rewardAttribute: AttributeType.agility,
        xpReward: 12,
        isCompleted: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestCard(
              quest: quest,
              helperText:
                  'Quest pessoal: ajuda no progresso geral, mas não entra no rank.',
              onPrimaryAction: () {},
              primaryActionLabel: 'Concluida',
              primaryActionEnabled: false,
              onSecondaryAction: () => secondaryCalls += 1,
              secondaryActionLabel: 'Desfazer',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final primaryFinder = find.byKey(
        const ValueKey('quest-card-primary-personal-1'),
      );
      final secondaryFinder = find.byKey(
        const ValueKey('quest-card-secondary-personal-1'),
      );
      expect(primaryFinder, findsOneWidget);
      expect(tester.widget<FilledButton>(primaryFinder).onPressed, isNull);
      expect(secondaryFinder, findsOneWidget);

      await tester.tap(secondaryFinder);
      expect(secondaryCalls, 1);
    },
  );
}
