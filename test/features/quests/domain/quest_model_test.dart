import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserva o vinculo da Jornada ao atualizar uma missao', () {
    final quest = Quest(
      id: 'quest-1',
      title: 'Escrever introducao',
      journeyId: 'jornada-1',
      rewardAttribute: AttributeType.intelligence,
      xpReward: 12,
    );

    expect(quest.copyWith(isCompleted: true).journeyId, 'jornada-1');
    expect(quest.copyWith(clearJourney: true).journeyId, isNull);
  });

  test('mantem o ciclo de vida sem alterar a conclusao', () {
    final quest = Quest(
      id: 'quest-2',
      title: 'Revisar rota',
      rewardAttribute: AttributeType.vitality,
      xpReward: 12,
    );
    final reagendada = quest.copyWith(plannedFor: DateTime(2026, 7, 20));
    final arquivada = reagendada.copyWith(isArchived: true);

    expect(reagendada.plannedFor, DateTime(2026, 7, 20));
    expect(arquivada.isArchived, isTrue);
    expect(arquivada.isCompleted, isFalse);
  });
}
