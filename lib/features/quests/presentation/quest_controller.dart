import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/quest_model.dart';
import '../../profile/presentation/player_controller.dart';

// O Provider captura o 'ref' e o injeta no construtor do Notifier
final questProvider = StateNotifierProvider<QuestNotifier, List<Quest>>((ref) {
  return QuestNotifier(ref); // Passamos o ref aqui
});

class QuestNotifier extends StateNotifier<List<Quest>> {
  final Ref ref; // Referência necessária para acessar outros providers

  QuestNotifier(this.ref) : super([
    Quest(id: '1', title: 'Treino de Flexões', rewardAttribute: AttributeType.strength, xpReward: 50),
    Quest(id: '2', title: 'Estudar Dart por 30min', rewardAttribute: AttributeType.intelligence, xpReward: 30),
    Quest(id: '3', title: 'Beber 2L de Água', rewardAttribute: AttributeType.vitality, xpReward: 20),
  ]);

  void toggleQuest(String id) {
    // 1. Localizamos a quest original para saber seus dados de recompensa
    final questOriginal = state.firstWhere((q) => q.id == id);
    final wasCompleted = questOriginal.isCompleted;

    // 2. Atualizamos o estado da lista de forma imutável
    state = [
      for (final q in state)
        if (q.id == id)
          Quest(
            id: q.id,
            title: q.title,
            rewardAttribute: q.rewardAttribute,
            xpReward: q.xpReward,
            isCompleted: !q.isCompleted,
          )
        else
          q,
    ];

    // 3. Comunicação entre Controllers (Injeção de Dependência via Riverpod)
    if (!wasCompleted) {
      // Se não estava completa e agora está: ganha recompensa
      ref.read(playerProvider.notifier).addReward(
            questOriginal.xpReward,
            questOriginal.rewardAttribute,
          );
    } else {
      // Se estava completa e desmarcou: remove recompensa
      ref.read(playerProvider.notifier).removeReward(
            questOriginal.xpReward,
            questOriginal.rewardAttribute,
          );
    }
  }
}