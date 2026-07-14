import 'package:ascend/features/jornadas/domain/jornada.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calcula o progresso apenas com missoes da Jornada', () {
    final jornada = Jornada(
      id: 'jornada-1', titulo: 'TCC', objetivo: 'Entregar',
      status: StatusJornada.ativa, criadaEm: DateTime(2026),
    );
    final quests = [
      Quest(id: '1', title: 'Ler', journeyId: 'jornada-1', rewardAttribute: AttributeType.intelligence, xpReward: 12),
      Quest(id: '2', title: 'Escrever', journeyId: 'jornada-1', isCompleted: true, rewardAttribute: AttributeType.intelligence, xpReward: 12),
      Quest(id: '3', title: 'Treinar', rewardAttribute: AttributeType.vitality, xpReward: 12),
    ];
    final progresso = calcularProgressoJornada(jornada, quests);
    expect(progresso.total, 2);
    expect(progresso.concluidas, 1);
    expect(progresso.percentual, 50);
  });
}
