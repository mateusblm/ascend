import 'package:ascend/features/quests/data/quest_sync_repository.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
