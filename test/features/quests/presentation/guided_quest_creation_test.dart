import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:ascend/features/quests/presentation/widgets/add_quest_modal.dart';
import 'package:flutter/material.dart';
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
      targetStrengthSets: 4,
      targetStrengthRepetitions: 8,
      targetStrengthLoadKg: 60,
    );

    expect(quest.mode, QuestMode.guided);
    expect(quest.activityCategoryId, 'corpoMovimento');
    expect(quest.activityModalityId, 'musculacao');
    expect(quest.activityId, 'supino-reto');
    expect(quest.executionType, 'strengthSets');
    expect(quest.activitySchemaVersion, 1);
    expect(quest.journeyId, 'jornada-1');
    expect(quest.targetStrengthSets, 4);
    expect(quest.targetStrengthRepetitions, 8);
    expect(quest.targetStrengthLoadKg, 60);
  });

  test('categorias guiadas possuem icones representativos', () {
    expect(
      activityCategoryIconFor('corpoMovimento'),
      Icons.fitness_center_rounded,
    );
    expect(
      activityCategoryIconFor('leituraConhecimento'),
      Icons.menu_book_rounded,
    );
    expect(
      activityCategoryIconFor('financas'),
      Icons.account_balance_wallet_outlined,
    );
  });
}
