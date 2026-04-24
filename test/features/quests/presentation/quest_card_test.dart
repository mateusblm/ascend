import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/widgets/quest_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'QuestCard renders competitive reward and helper copy without crashing',
    (tester) async {
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
              onPrimaryAction: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sessao profunda de estudo'), findsOneWidget);
      expect(find.text('+14 XP'), findsOneWidget);
      expect(find.text('Inteligência'), findsOneWidget);
      expect(find.text('Arena'), findsOneWidget);
      expect(find.text('25 min'), findsOneWidget);
    },
  );

  testWidgets('QuestCard renders completed personal quest with readable state', (
    tester,
  ) async {
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
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Revisar metas do dia'), findsOneWidget);
    expect(find.text('+12 XP'), findsOneWidget);
    expect(find.text('Agilidade'), findsOneWidget);
    expect(find.text('Base'), findsOneWidget);
    expect(find.text('Concluida'), findsOneWidget);
  });
}
