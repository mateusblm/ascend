import 'package:ascend/features/quests/data/quest_sync_repository.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseia quest antiga sem meta de força com defaults seguros', () {
    final quest = parseQuestSyncData({
      'title': 'Supino',
      'rewardAttribute': 'strength',
      'xpReward': 12,
    }, uid: 'u1', questId: 'q1');
    expect(quest.targetStrengthSets, 0);
    expect(quest.targetStrengthRepetitions, 0);
    expect(quest.targetStrengthLoadKg, isNull);
  });
  test(
    'inventario do cliente nao reenvia ocorrencias recorrentes do backend',
    () {
      final fontes = questSourcesForInventorySync([
        Quest(
          id: 'manual',
          title: 'Passo manual',
          rewardAttribute: AttributeType.strength,
          xpReward: 12,
        ),
        Quest(
          id: 'recorrente',
          title: 'Rotina',
          recurrenceId: 'recorrencia-1',
          rewardAttribute: AttributeType.vitality,
          xpReward: 12,
        ),
      ]);

      expect(fontes, hasLength(1));
      expect(fontes.single['id'], 'manual');
    },
  );

  test('serializa meta de força no payload do inventário', () {
    final fonte = questSourcesForInventorySync([
      Quest(
        id: 'supino',
        title: 'Supino reto',
        mode: QuestMode.guided,
        executionType: 'strengthSets',
        targetStrengthSets: 4,
        targetStrengthRepetitions: 8,
        targetStrengthLoadKg: 60,
        rewardAttribute: AttributeType.strength,
        xpReward: 12,
      ),
    ]).single;
    expect(fonte['targetStrengthSets'], 4);
    expect(fonte['targetStrengthRepetitions'], 8);
    expect(fonte['targetStrengthLoadKg'], 60);
  });

  test('interpreta a data de conclusao retornada pelo backend', () {
    final concluidaEm = DateTime(2026, 7, 16, 9, 12);
    final quest = parseQuestSyncData(
      {
        'title': 'Corrida livre',
        'completedAt': {
          'seconds':
              concluidaEm.toUtc().millisecondsSinceEpoch ~/
              Duration.millisecondsPerSecond,
          'nanos': 0,
        },
        'isCompleted': true,
      },
      uid: 'usuario-1',
      questId: 'quest-1',
    );

    expect(quest.isCompleted, isTrue);
    expect(quest.completedAt, isNotNull);
    expect(quest.completedAt!.year, concluidaEm.year);
    expect(quest.completedAt!.month, concluidaEm.month);
    expect(quest.completedAt!.day, concluidaEm.day);
  });
}
