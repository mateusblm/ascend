import 'package:ascend/features/quests/data/quest_sync_repository.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('inventario do cliente nao reenvia ocorrencias recorrentes do backend', () {
    final fontes = questSourcesForInventorySync([
      Quest(id: 'manual', title: 'Passo manual', rewardAttribute: AttributeType.strength, xpReward: 12),
      Quest(id: 'recorrente', title: 'Rotina', recurrenceId: 'recorrencia-1', rewardAttribute: AttributeType.vitality, xpReward: 12),
    ]);

    expect(fontes, hasLength(1));
    expect(fontes.single['id'], 'manual');
  });
}
