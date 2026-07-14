import 'package:ascend/features/notifications/ritual_rota_service.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seleciona apenas a proxima missao pendente para o ritual', () {
    final proxima = nextPendingQuestForRitual([
      Quest(id: 'arquivada', title: 'Arquivada', isArchived: true, rewardAttribute: AttributeType.vitality, xpReward: 12),
      Quest(id: 'amanha', title: 'Amanhã', plannedFor: DateTime(2026, 7, 15), rewardAttribute: AttributeType.vitality, xpReward: 12),
      Quest(id: 'hoje', title: 'Hoje', plannedFor: DateTime(2026, 7, 14), rewardAttribute: AttributeType.vitality, xpReward: 12),
    ]);

    expect(proxima?.id, 'hoje');
  });
}
