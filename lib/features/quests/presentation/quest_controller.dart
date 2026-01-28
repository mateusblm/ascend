import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../main.dart'; 
import '../domain/quest_model.dart';
import '../../profile/presentation/player_controller.dart';

final questProvider = StateNotifierProvider<QuestNotifier, List<Quest>>((ref) {
  return QuestNotifier(ref);
});

class QuestNotifier extends StateNotifier<List<Quest>> {
  final Ref ref;

  QuestNotifier(this.ref) : super([]) {
    _init();
  }

  void _init() {
    final savedQuests = isar.quests.where().findAllSync();
    final player = isar.players.where().findFirstSync();
    
    if (player != null) {
      _checkDailyReset(player);
    }

    if (savedQuests.isEmpty) {
      _seedInitialQuests();
    } else {
      state = isar.quests.where().findAllSync();
    }
  }

  void _checkDailyReset(Player player) {
    final now = DateTime.now();
    final lastReset = player.lastResetDate;

    final isDifferentDay = now.year != lastReset.year || 
                          now.month != lastReset.month || 
                          now.day != lastReset.day;

    if (isDifferentDay) {
      isar.writeTxnSync(() {
        final allQuests = isar.quests.where().findAllSync();
        final resetQuests = allQuests.map((q) => q.copyWith(isCompleted: false)).toList();
        isar.quests.putAllSync(resetQuests);

        final updatedPlayer = player.copyWith(lastResetDate: now);
        isar.players.putSync(updatedPlayer);
      });
      state = isar.quests.where().findAllSync();
    }
  }

  void _seedInitialQuests() {
    final initialQuests = [
      Quest(id: '1', title: 'Treino de Flexões', rewardAttribute: AttributeType.strength, xpReward: 50),
      Quest(id: '2', title: 'Estudar Dart por 30min', rewardAttribute: AttributeType.intelligence, xpReward: 30),
      Quest(id: '3', title: 'Beber 2L de Água', rewardAttribute: AttributeType.vitality, xpReward: 20),
    ];
    
    isar.writeTxnSync(() => isar.quests.putAllSync(initialQuests));
    state = initialQuests;
  }

  void toggleQuest(String id, {Function(int)? onLevelUp}) {
    final index = state.indexWhere((q) => q.id == id);
    if (index == -1) return;

    final questOriginal = state[index];
    final wasCompleted = questOriginal.isCompleted;
    final updatedQuest = questOriginal.copyWith(isCompleted: !wasCompleted);

    isar.writeTxnSync(() {
      isar.quests.putSync(updatedQuest);
    });

    // Atualiza a lista local
    final newState = [...state];
    newState[index] = updatedQuest;
    state = newState;

    // Chamada direta para o Player - A segurança agora está no WidgetsBinding do addReward
    if (!wasCompleted) {
      ref.read(playerProvider.notifier).addReward(
        updatedQuest.xpReward,
        updatedQuest.rewardAttribute,
        onLevelUp: onLevelUp,
      );
    } else {
      ref.read(playerProvider.notifier).removeReward(
        updatedQuest.xpReward,
        updatedQuest.rewardAttribute,
      );
    }
  }

  void addQuest(String title, AttributeType attribute, int xp) {
    final newQuest = Quest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      rewardAttribute: attribute,
      xpReward: xp,
      isCompleted: false,
    );

    isar.writeTxnSync(() {
      isar.quests.putSync(newQuest);
    });

    state = [...state, newQuest];
  }

  void deleteQuest(String id) {
    isar.writeTxnSync(() {
      final questToDelete = isar.quests.filter().idEqualTo(id).findFirstSync();
      if (questToDelete != null) {
        isar.quests.deleteSync(questToDelete.isarId);
      }
    });
    state = state.where((q) => q.id != id).toList();
  }
}