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
}
