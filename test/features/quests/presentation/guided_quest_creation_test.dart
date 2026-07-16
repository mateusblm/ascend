import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('criação guiada persiste os IDs e o esquema publicados no catálogo', () {
    final quest = guidedQuestFromCatalog(
      id: 'guided-1',
      ownerUid: 'uid-1',
      title: 'Supino reto',
      rewardAttribute: AttributeType.strength,
      categoryId: 'corpoMovimento',
      modalityId: 'musculacao',
      activityId: 'supino-reto',
      executionType: 'strengthSets',
      schemaVersion: 1,
      jornadaId: 'jornada-1',
      plannedFor: DateTime(2026, 7, 17, 8),
    );

    expect(quest.mode, QuestMode.guided);
    expect(quest.activityCategoryId, 'corpoMovimento');
    expect(quest.activityModalityId, 'musculacao');
    expect(quest.activityId, 'supino-reto');
    expect(quest.executionType, 'strengthSets');
    expect(quest.activitySchemaVersion, 1);
    expect(quest.journeyId, 'jornada-1');
  });
}
