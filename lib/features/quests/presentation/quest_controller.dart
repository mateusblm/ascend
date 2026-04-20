import 'package:ascend/core/database/isar_provider.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/quests/domain/competitive_quest_template.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/domain/quest_suggestion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final questProvider = StateNotifierProvider<QuestNotifier, List<Quest>>((ref) {
  return QuestNotifier(ref, ref.watch(isarProvider));
});

bool isDailyResetDue({
  required DateTime lastReset,
  required DateTime now,
}) {
  return now.year != lastReset.year ||
      now.month != lastReset.month ||
      now.day != lastReset.day;
}

enum QuestCompletionResult {
  success,
  notFound,
  alreadyCompleted,
  invalidFlow,
  timerStillRunning,
  missingReflection,
}

class QuestNotifier extends StateNotifier<List<Quest>> {
  QuestNotifier(this.ref, this._isar) : super([]) {
    _init();
  }

  final Ref ref;
  final Isar _isar;

  void _init() {
    final savedQuests = _isar.quests.where().findAllSync();
    final player = _isar.players.where().findFirstSync();

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

  void ensureDailyReset() {
    _checkDailyReset(ref.read(playerProvider));
  }

  void _checkDailyReset(Player player) {
    final now = DateTime.now();
    if (!isDailyResetDue(lastReset: player.lastResetDate, now: now)) return;

    _isar.writeTxnSync(() {
      final allQuests = _isar.quests.where().findAllSync();
      final resetQuests = allQuests
          .map(
            (q) => q.copyWith(
              isCompleted: false,
              verificationStatus: q.isCompetitive
                  ? QuestVerificationStatus.none
                  : QuestVerificationStatus.none,
              clearPreRewardSnapshot: true,
              clearVerificationProgress: true,
            ),
          )
          .toList();
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
    final competitiveTemplates = templatesForFocus(focus)
        .take(2)
        .map((template) => template.toQuest())
        .toList();

    final personalQuest = switch (focus) {
      AwakeningPath.discipline => _buildPersonalQuest(
          id: 'discipline-personal',
          title: 'Arrumar a cama ao acordar',
          rewardAttribute: AttributeType.vitality,
          xpReward: personalQuestDefaultXp,
        ),
      AwakeningPath.study => _buildPersonalQuest(
          id: 'study-personal',
          title: 'Organizar material de estudo',
          rewardAttribute: AttributeType.intelligence,
          xpReward: personalQuestDefaultXp,
        ),
      AwakeningPath.training => _buildPersonalQuest(
          id: 'training-personal',
          title: 'Separar roupa e agua para o treino',
          rewardAttribute: AttributeType.vitality,
          xpReward: personalQuestDefaultXp,
        ),
      AwakeningPath.health => _buildPersonalQuest(
          id: 'health-personal',
          title: 'Bater a meta de agua do dia',
          rewardAttribute: AttributeType.vitality,
          xpReward: personalQuestDefaultXp,
        ),
      AwakeningPath.productivity => _buildPersonalQuest(
          id: 'productivity-personal',
          title: 'Definir a tarefa critica do dia',
          rewardAttribute: AttributeType.agility,
          xpReward: personalQuestDefaultXp,
        ),
    };

    return [...competitiveTemplates, personalQuest];
  }

  Quest _buildPersonalQuest({
    required String id,
    required String title,
    required AttributeType rewardAttribute,
    required int xpReward,
  }) {
    return Quest(
      id: id,
      title: title,
      rewardAttribute: rewardAttribute,
      xpReward: normalizePersonalQuestXp(xpReward),
      category: QuestCategory.personal,
      verificationMode: QuestVerificationMode.manual,
      verificationStatus: QuestVerificationStatus.none,
    );
  }

  void applyStarterKit(AwakeningPath focus) {
    if (state.isNotEmpty) return;
    _seedInitialQuests(focus);
  }

  void toggleQuest(String id, {void Function(int level)? onLevelUp}) {
    final quest = _findQuest(id);
    if (quest == null || quest.isCompetitive) return;

    if (!quest.isCompleted) {
      _applyCompletion(
        quest.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
          verifiedAt: DateTime.now(),
          verificationStatus: QuestVerificationStatus.verified,
        ),
        onLevelUp: onLevelUp,
      );
      return;
    }

    _undoCompletion(quest);
  }

  void addQuest(String title, AttributeType attribute, int xp) {
    addPersonalQuest(title, attribute, xp);
  }

  void addPersonalQuest(String title, AttributeType attribute, int xp) {
    final newQuest = Quest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      rewardAttribute: attribute,
      xpReward: normalizePersonalQuestXp(xp),
      category: QuestCategory.personal,
      verificationMode: QuestVerificationMode.manual,
      verificationStatus: QuestVerificationStatus.none,
    );

    _isar.writeTxnSync(() {
      _isar.quests.putSync(newQuest);
    });

    state = [...state, newQuest];
  }

  bool addCompetitiveTemplate(CompetitiveQuestTemplate template) {
    final alreadyExists = state.any(
      (quest) =>
          quest.isCompetitive &&
          !quest.isCompleted &&
          quest.templateType == template.templateType,
    );
    if (alreadyExists) return false;

    final newQuest = template.toQuest();
    _isar.writeTxnSync(() {
      _isar.quests.putSync(newQuest);
    });

    state = [...state, newQuest];
    return true;
  }

  QuestCompletionResult startCompetitiveQuest(String id) {
    final quest = _findQuest(id);
    if (quest == null) return QuestCompletionResult.notFound;
    if (!quest.isCompetitive || quest.isCompleted) {
      return QuestCompletionResult.invalidFlow;
    }
    if (!quest.requiresTimer) return QuestCompletionResult.invalidFlow;

    final updatedQuest = quest.copyWith(
      verificationStatus: QuestVerificationStatus.inProgress,
      verificationStartedAt: DateTime.now(),
    );
    _persistQuestUpdate(updatedQuest);
    return QuestCompletionResult.success;
  }

  QuestCompletionResult completeCompetitiveQuest(
    String id, {
    String? reflectionAnswer,
    void Function(int level)? onLevelUp,
  }) {
    final quest = _findQuest(id);
    if (quest == null) return QuestCompletionResult.notFound;
    if (!quest.isCompetitive || quest.isCompleted) {
      return QuestCompletionResult.invalidFlow;
    }

    final now = DateTime.now();
    if (quest.requiresTimer) {
      if (quest.verificationStartedAt == null ||
          quest.verificationStatus != QuestVerificationStatus.inProgress) {
        return QuestCompletionResult.invalidFlow;
      }

      final elapsedMinutes = now
          .difference(quest.verificationStartedAt!)
          .inMinutes;
      if (elapsedMinutes < quest.targetDurationMinutes) {
        return QuestCompletionResult.timerStillRunning;
      }
    }

    if (quest.requiresReflection &&
        (reflectionAnswer == null || reflectionAnswer.trim().isEmpty)) {
      return QuestCompletionResult.missingReflection;
    }

    final updatedQuest = quest.copyWith(
      isCompleted: true,
      verificationStatus: QuestVerificationStatus.verified,
      completedAt: now,
      verifiedAt: now,
      reflectionAnswer: reflectionAnswer?.trim(),
    );
    _applyCompletion(updatedQuest, onLevelUp: onLevelUp);
    return QuestCompletionResult.success;
  }

  int addSuggestedQuests(List<QuestSuggestion> suggestions) {
    if (suggestions.isEmpty) return 0;

    final existingTitles = state.map((quest) => _normalizeTitle(quest.title)).toSet();
    final newQuests = <Quest>[];

    for (final suggestion in suggestions) {
      final normalizedTitle = _normalizeTitle(suggestion.title);
      if (existingTitles.contains(normalizedTitle)) continue;

      existingTitles.add(normalizedTitle);
      newQuests.add(
        Quest(
          id: '${DateTime.now().microsecondsSinceEpoch}-${newQuests.length}',
          title: suggestion.title,
          rewardAttribute: suggestion.rewardAttribute,
          xpReward: normalizePersonalQuestXp(suggestion.xpReward),
          category: QuestCategory.personal,
          verificationMode: QuestVerificationMode.manual,
          verificationStatus: QuestVerificationStatus.none,
        ),
      );
    }

    if (newQuests.isEmpty) return 0;

    _isar.writeTxnSync(() {
      _isar.quests.putAllSync(newQuests);
    });

    state = [...state, ...newQuests];
    return newQuests.length;
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

  Quest? _findQuest(String id) {
    final index = state.indexWhere((q) => q.id == id);
    if (index == -1) return null;
    return state[index];
  }

  void _persistQuestUpdate(Quest updatedQuest) {
    _isar.writeTxnSync(() {
      _isar.quests.putSync(updatedQuest);
    });

    final index = state.indexWhere((q) => q.id == updatedQuest.id);
    if (index == -1) return;
    final newState = [...state];
    newState[index] = updatedQuest;
    state = newState;
  }

  void _applyCompletion(Quest completedQuest, {void Function(int level)? onLevelUp}) {
    final player = ref.read(playerProvider);
    final questWithSnapshot = completedQuest.copyWith(
      preRewardLevel: player.level,
      preRewardXp: player.xp,
      preRewardMaxXp: player.maxXp,
      preRewardStatPoints: player.statPoints,
      preRewardStrength: player.attributes.strength,
      preRewardIntelligence: player.attributes.intelligence,
      preRewardVitality: player.attributes.vitality,
      preRewardAgility: player.attributes.agility,
    );

    _persistQuestUpdate(questWithSnapshot);

    ref.read(playerProvider.notifier).addReward(
          questWithSnapshot.xpReward,
          questWithSnapshot.rewardAttribute,
          onLevelUp: onLevelUp,
        );
    ref.read(playerProvider.notifier).recordQuestCompletion(
          completedAt: questWithSnapshot.completedAt,
          countsForCompetitive: questWithSnapshot.countsTowardCompetitive,
        );
  }

  void _undoCompletion(Quest quest) {
    final updatedQuest = quest.copyWith(
      isCompleted: false,
      verificationStatus: quest.isCompetitive
          ? QuestVerificationStatus.none
          : QuestVerificationStatus.none,
      clearPreRewardSnapshot: true,
      clearVerificationProgress: true,
    );

    _persistQuestUpdate(updatedQuest);
    ref.read(playerProvider.notifier).undoReward(quest);
  }

  String _normalizeTitle(String value) => value.trim().toLowerCase();
}
