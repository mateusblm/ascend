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
      if (player?.hasCompletedOnboarding == true) {
        _seedInitialQuests(player!.primaryFocus);
      } else {
        state = [];
      }
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

  void _seedInitialQuests(AwakeningPath focus) {
    final initialQuests = _starterQuestsFor(focus);

    _isar.writeTxnSync(() => _isar.quests.putAllSync(initialQuests));
    state = initialQuests;
  }

  List<Quest> _starterQuestsFor(AwakeningPath focus) {
    return switch (focus) {
      AwakeningPath.discipline => [
          _buildStarterQuest('discipline-1', 'Arrumar a cama ao acordar', AttributeType.vitality, 20),
          _buildStarterQuest('discipline-2', 'Fazer 15 minutos de foco total', AttributeType.intelligence, 30),
          _buildStarterQuest('discipline-3', 'Revisar metas do dia', AttributeType.agility, 25),
        ],
      AwakeningPath.study => [
          _buildStarterQuest('study-1', 'Estudar por 30 minutos', AttributeType.intelligence, 35),
          _buildStarterQuest('study-2', 'Anotar 3 aprendizados do dia', AttributeType.intelligence, 25),
          _buildStarterQuest('study-3', 'Resolver 1 exercicio dificil', AttributeType.agility, 30),
        ],
      AwakeningPath.training => [
          _buildStarterQuest('training-1', 'Treino rapido de 20 minutos', AttributeType.strength, 35),
          _buildStarterQuest('training-2', 'Alongamento e mobilidade', AttributeType.vitality, 25),
          _buildStarterQuest('training-3', 'Caminhada energica de 15 minutos', AttributeType.agility, 30),
        ],
      AwakeningPath.health => [
          _buildStarterQuest('health-1', 'Beber 2L de agua', AttributeType.vitality, 25),
          _buildStarterQuest('health-2', 'Dormir no horario alvo', AttributeType.vitality, 35),
          _buildStarterQuest('health-3', 'Fazer uma refeicao sem ultraprocessados', AttributeType.strength, 30),
        ],
      AwakeningPath.productivity => [
          _buildStarterQuest('productivity-1', 'Concluir a tarefa mais importante do dia', AttributeType.intelligence, 40),
          _buildStarterQuest('productivity-2', 'Executar 2 blocos de foco sem distração', AttributeType.agility, 30),
          _buildStarterQuest('productivity-3', 'Encerrar o dia com inbox zerada', AttributeType.vitality, 25),
        ],
    };
  }

  Quest _buildStarterQuest(String id, String title, AttributeType rewardAttribute, int xpReward) {
    return Quest(
      id: id,
      title: title,
      rewardAttribute: rewardAttribute,
      xpReward: xpReward,
    );
  }

  void applyStarterKit(AwakeningPath focus) {
    if (state.isNotEmpty) return;
    _seedInitialQuests(focus);
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
