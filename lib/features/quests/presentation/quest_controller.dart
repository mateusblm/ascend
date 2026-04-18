import 'package:ascend/core/database/isar_provider.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final questProvider = StateNotifierProvider<QuestNotifier, List<Quest>>((ref) {
  return QuestNotifier(ref, ref.watch(isarProvider));
});

class QuestNotifier extends StateNotifier<List<Quest>> {
  QuestNotifier(this.ref, this._isar) : super([]) {
    _init();
  }

  final Ref ref;
  final Isar _isar;

  void _init() {
    final savedQuests = _isar.quests.where().findAllSync();
    final player = _isar.players.where().findFirstSync();

    if (player != null) {
      _checkDailyReset(player);
    }

    if (savedQuests.isEmpty) {
      _seedInitialQuests();
    } else {
      state = _isar.quests.where().findAllSync();
    }
  }

  void _checkDailyReset(Player player) {
    final now = DateTime.now();
    final lastReset = player.lastResetDate;
    final isDifferentDay =
        now.year != lastReset.year || now.month != lastReset.month || now.day != lastReset.day;

    if (!isDifferentDay) return;

    _isar.writeTxnSync(() {
      final allQuests = _isar.quests.where().findAllSync();
      final resetQuests = allQuests.map((q) => q.copyWith(isCompleted: false)).toList();
      _isar.quests.putAllSync(resetQuests);
    });

    ref.read(playerProvider.notifier).handleDailyReset(now);
    state = _isar.quests.where().findAllSync();
  }

  void _seedInitialQuests() {
    final initialQuests = [
      Quest(id: '1', title: 'Treino de flexoes', rewardAttribute: AttributeType.strength, xpReward: 50),
      Quest(
        id: '2',
        title: 'Estudar Dart por 30 minutos',
        rewardAttribute: AttributeType.intelligence,
        xpReward: 30,
      ),
      Quest(id: '3', title: 'Beber 2L de agua', rewardAttribute: AttributeType.vitality, xpReward: 20),
    ];

    _isar.writeTxnSync(() => _isar.quests.putAllSync(initialQuests));
    state = initialQuests;
  }

  void toggleQuest(String id, {void Function(int level)? onLevelUp}) {
    final index = state.indexWhere((q) => q.id == id);
    if (index == -1) return;

    final questOriginal = state[index];
    final wasCompleted = questOriginal.isCompleted;
    final updatedQuest = questOriginal.copyWith(isCompleted: !wasCompleted);

    _isar.writeTxnSync(() {
      _isar.quests.putSync(updatedQuest);
    });

    final newState = [...state];
    newState[index] = updatedQuest;
    state = newState;

    if (!wasCompleted) {
      ref.read(playerProvider.notifier).addReward(
            updatedQuest.xpReward,
            updatedQuest.rewardAttribute,
            onLevelUp: onLevelUp,
          );
      ref.read(playerProvider.notifier).recordQuestCompletion();
      return;
    }

    ref.read(playerProvider.notifier).removeReward(
          updatedQuest.xpReward,
          updatedQuest.rewardAttribute,
        );
  }

  void addQuest(String title, AttributeType attribute, int xp) {
    final newQuest = Quest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      rewardAttribute: attribute,
      xpReward: xp,
      isCompleted: false,
    );

    _isar.writeTxnSync(() {
      _isar.quests.putSync(newQuest);
    });

    state = [...state, newQuest];
  }

  void deleteQuest(String id) {
    _isar.writeTxnSync(() {
      final questToDelete = _isar.quests.filter().idEqualTo(id).findFirstSync();
      if (questToDelete != null) {
        _isar.quests.deleteSync(questToDelete.isarId);
      }
    });

    state = state.where((q) => q.id != id).toList();
  }
}
