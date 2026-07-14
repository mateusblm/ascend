import 'package:ascend/features/jornadas/domain/jornada.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calcula o progresso apenas com missoes da Jornada', () {
    final jornada = Jornada(
      id: 'jornada-1',
      titulo: 'TCC',
      objetivo: 'Entregar',
      status: StatusJornada.ativa,
      criadaEm: DateTime(2026),
    );
    final quests = [
      Quest(
        id: '1',
        title: 'Ler',
        journeyId: 'jornada-1',
        rewardAttribute: AttributeType.intelligence,
        xpReward: 12,
      ),
      Quest(
        id: '2',
        title: 'Escrever',
        journeyId: 'jornada-1',
        isCompleted: true,
        rewardAttribute: AttributeType.intelligence,
        xpReward: 12,
      ),
      Quest(
        id: '3',
        title: 'Treinar',
        rewardAttribute: AttributeType.vitality,
        xpReward: 12,
      ),
    ];
    final progresso = calcularProgressoJornada(jornada, quests);
    expect(progresso.total, 2);
    expect(progresso.concluidas, 1);
    expect(progresso.percentual, 50);
  });

  test(
    'identifica marco vinculado a missao sem confundi-lo com marco manual',
    () {
      const manual = MarcoCapitulo(
        id: 'm-1',
        titulo: 'Planejar',
        concluido: false,
        indiceOrdem: 0,
      );
      const vinculado = MarcoCapitulo(
        id: 'm-2',
        titulo: 'Executar',
        questId: 'q-1',
        concluido: false,
        indiceOrdem: 1,
      );

      expect(manual.vinculadoAMissao, isFalse);
      expect(vinculado.vinculadoAMissao, isTrue);
    },
  );

  test('revisa apenas ajustes da rota vinculada', () {
    final jornada = Jornada(
      id: 'jornada-1',
      titulo: 'TCC',
      objetivo: 'Entregar',
      status: StatusJornada.ativa,
      criadaEm: DateTime(2026),
    );
    final revisao = revisarRotaJornada(jornada, [
      Quest(
        id: 'q-1',
        title: 'Rascunho',
        journeyId: 'jornada-1',
        occursOn: DateTime(2026, 7, 14),
        plannedFor: DateTime(2026, 7, 16),
        rewardAttribute: AttributeType.intelligence,
        xpReward: 12,
      ),
      Quest(
        id: 'q-2',
        title: 'Leitura',
        journeyId: 'jornada-1',
        isArchived: true,
        rewardAttribute: AttributeType.intelligence,
        xpReward: 12,
      ),
      Quest(
        id: 'q-3',
        title: 'Outra rota',
        isArchived: true,
        rewardAttribute: AttributeType.vitality,
        xpReward: 12,
      ),
    ]);
    expect(revisao.totalDeAjustes, 2);
    expect(revisao.precisaDeAjuste, isTrue);
  });
}
