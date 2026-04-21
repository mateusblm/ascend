import 'dart:async';

import 'package:ascend/core/analytics/analytics_service.dart';
import 'package:ascend/core/crash/crash_reporting_service.dart';
import 'package:ascend/core/database/isar_provider.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/profile/presentation/rank_progression_provider.dart';
import 'package:ascend/features/quests/data/competitive_quest_authority_repository.dart';
import 'package:ascend/features/quests/domain/competitive_quest_template.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/domain/quest_suggestion.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final competitiveQuestAuthorityRepositoryProvider =
    Provider<CompetitiveQuestAuthorityRepository>((ref) {
      return CompetitiveQuestAuthorityRepository(
        functions: FirebaseFunctions.instanceFor(region: 'southamerica-east1'),
        crashReporter: ref.read(crashReportingProvider),
      );
    });

final questProvider = StateNotifierProvider<QuestNotifier, List<Quest>>((ref) {
  return QuestNotifier(
    ref,
    ref.watch(isarProvider),
    analytics: ref.read(analyticsProvider),
    competitiveAuthority: ref.read(competitiveQuestAuthorityRepositoryProvider),
  );
});

List<Quest> starterQuestsForFocus(AwakeningPath focus) {
  final competitiveTemplates = templatesForFocus(
    focus,
  ).take(2).map((template) => template.toQuest()).toList();

  final personalQuest = switch (focus) {
    AwakeningPath.discipline => _buildStarterPersonalQuest(
      id: 'discipline-personal',
      title: 'Arrumar a cama ao acordar',
      rewardAttribute: AttributeType.vitality,
      xpReward: personalQuestDefaultXp,
    ),
    AwakeningPath.study => _buildStarterPersonalQuest(
      id: 'study-personal',
      title: 'Organizar material de estudo',
      rewardAttribute: AttributeType.intelligence,
      xpReward: personalQuestDefaultXp,
    ),
    AwakeningPath.training => _buildStarterPersonalQuest(
      id: 'training-personal',
      title: 'Separar roupa e agua para o treino',
      rewardAttribute: AttributeType.vitality,
      xpReward: personalQuestDefaultXp,
    ),
    AwakeningPath.health => _buildStarterPersonalQuest(
      id: 'health-personal',
      title: 'Bater a meta de agua do dia',
      rewardAttribute: AttributeType.vitality,
      xpReward: personalQuestDefaultXp,
    ),
    AwakeningPath.productivity => _buildStarterPersonalQuest(
      id: 'productivity-personal',
      title: 'Definir a tarefa critica do dia',
      rewardAttribute: AttributeType.agility,
      xpReward: personalQuestDefaultXp,
    ),
  };

  return [...competitiveTemplates, personalQuest];
}

Quest _buildStarterPersonalQuest({
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

bool isDailyResetDue({required DateTime lastReset, required DateTime now}) {
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
  QuestNotifier(
    this.ref,
    this._isar, {
    AppAnalytics? analytics,
    CompetitiveQuestAuthorityRepository? competitiveAuthority,
  }) : _analytics = analytics ?? const NoopAppAnalytics(),
       _competitiveAuthority = competitiveAuthority,
       super([]) {
    _init();
  }

  final Ref ref;
  final Isar _isar;
  final AppAnalytics _analytics;
  final CompetitiveQuestAuthorityRepository? _competitiveAuthority;

  void _init() {
    final savedQuests = _isar.quests.where().findAllSync();
    final player = ref.read(playerProvider);

    if (savedQuests.isEmpty) {
      if (player.hasCompletedOnboarding) {
        _seedInitialQuests(player.primaryFocus);
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
    final initialQuests = starterQuestsForFocus(focus);

    _isar.writeTxnSync(() => _isar.quests.putAllSync(initialQuests));
    state = initialQuests;
  }

  void applyStarterKit(AwakeningPath focus) {
    if (state.isNotEmpty) return;
    final starterKit = starterQuestsForFocus(focus);
    _seedInitialQuests(focus);
    final competitiveCount = starterKit
        .where((quest) => quest.isCompetitive)
        .length;
    final personalCount = starterKit.length - competitiveCount;
    unawaited(
      _analytics.logStarterKitApplied(
        focus: focus.name,
        totalCount: starterKit.length,
        competitiveCount: competitiveCount,
        personalCount: personalCount,
      ),
    );
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
    unawaited(
      _analytics.logQuestCreated(
        category: newQuest.category.name,
        verificationMode: newQuest.verificationMode.name,
        xpReward: newQuest.xpReward,
      ),
    );
  }

  bool addCompetitiveTemplate(CompetitiveQuestTemplate template) {
    final alreadyExists = state.any(
      (quest) =>
          quest.isCompetitive &&
          !quest.isCompleted &&
          quest.templateType == template.templateType,
    );
    if (alreadyExists) {
      unawaited(
        _analytics.logCompetitiveQuestBlocked(
          reason: 'duplicate_template',
          verificationMode: template.verificationMode.name,
          templateType: template.templateType.name,
        ),
      );
      return false;
    }

    final newQuest = template.toQuest();
    _isar.writeTxnSync(() {
      _isar.quests.putSync(newQuest);
    });

    state = [...state, newQuest];
    unawaited(
      _analytics.logQuestCreated(
        category: newQuest.category.name,
        verificationMode: newQuest.verificationMode.name,
        xpReward: newQuest.xpReward,
        templateType: newQuest.templateType.name,
      ),
    );
    return true;
  }

  Future<QuestCompletionResult> startCompetitiveQuest(String id) async {
    final quest = _findQuest(id);
    if (quest == null) return QuestCompletionResult.notFound;
    if (!quest.isCompetitive || quest.isCompleted) {
      unawaited(
        _analytics.logCompetitiveQuestBlocked(
          reason: 'invalid_start_state',
          verificationMode: quest.verificationMode.name,
          templateType: quest.templateType.name,
        ),
      );
      return QuestCompletionResult.invalidFlow;
    }
    if (!quest.requiresTimer) {
      unawaited(
        _analytics.logCompetitiveQuestBlocked(
          reason: 'timer_not_required',
          verificationMode: quest.verificationMode.name,
          templateType: quest.templateType.name,
        ),
      );
      return QuestCompletionResult.invalidFlow;
    }

    DateTime startedAt = DateTime.now();
    if (_competitiveAuthority != null) {
      final session = await _competitiveAuthority.startQuestSession(
        quest: quest,
      );
      startedAt = session.startedAt;
    }

    final updatedQuest = quest.copyWith(
      verificationStatus: QuestVerificationStatus.inProgress,
      verificationStartedAt: startedAt,
    );
    _persistQuestUpdate(updatedQuest);
    unawaited(
      _analytics.logCompetitiveQuestStarted(
        verificationMode: updatedQuest.verificationMode.name,
        targetDurationMinutes: updatedQuest.targetDurationMinutes,
        templateType: updatedQuest.templateType.name,
      ),
    );
    return QuestCompletionResult.success;
  }

  Future<QuestCompletionResult> completeCompetitiveQuest(
    String id, {
    String? reflectionAnswer,
    void Function(int level)? onLevelUp,
  }) async {
    final quest = _findQuest(id);
    if (quest == null) return QuestCompletionResult.notFound;
    if (!quest.isCompetitive || quest.isCompleted) {
      unawaited(
        _analytics.logCompetitiveQuestBlocked(
          reason: 'invalid_completion_state',
          verificationMode: quest.verificationMode.name,
          templateType: quest.templateType.name,
        ),
      );
      return QuestCompletionResult.invalidFlow;
    }

    final now = DateTime.now();
    if (quest.requiresTimer) {
      if (quest.verificationStartedAt == null ||
          quest.verificationStatus != QuestVerificationStatus.inProgress) {
        unawaited(
          _analytics.logCompetitiveQuestBlocked(
            reason: 'timer_not_started',
            verificationMode: quest.verificationMode.name,
            templateType: quest.templateType.name,
          ),
        );
        return QuestCompletionResult.invalidFlow;
      }

      final elapsedMinutes = now
          .difference(quest.verificationStartedAt!)
          .inMinutes;
      if (elapsedMinutes < quest.targetDurationMinutes) {
        unawaited(
          _analytics.logCompetitiveQuestBlocked(
            reason: 'timer_too_short',
            verificationMode: quest.verificationMode.name,
            templateType: quest.templateType.name,
          ),
        );
        return QuestCompletionResult.timerStillRunning;
      }
    }

    if (quest.requiresReflection &&
        (reflectionAnswer == null || reflectionAnswer.trim().isEmpty)) {
      unawaited(
        _analytics.logCompetitiveQuestBlocked(
          reason: 'missing_reflection',
          verificationMode: quest.verificationMode.name,
          templateType: quest.templateType.name,
        ),
      );
      return QuestCompletionResult.missingReflection;
    }

    DateTime completedAt = now;
    if (_competitiveAuthority != null) {
      final verification = await _competitiveAuthority.verifyQuestCompletion(
        quest: quest,
        reflectionAnswer: reflectionAnswer?.trim(),
      );
      completedAt = verification.completedAt;
    }

    final updatedQuest = quest.copyWith(
      isCompleted: true,
      verificationStatus: QuestVerificationStatus.verified,
      completedAt: completedAt,
      verifiedAt: completedAt,
      reflectionAnswer: reflectionAnswer?.trim(),
    );
    _applyCompletion(updatedQuest, onLevelUp: onLevelUp);
    return QuestCompletionResult.success;
  }

  int addSuggestedQuests(List<QuestSuggestion> suggestions) {
    if (suggestions.isEmpty) return 0;

    final existingTitles = state
        .map((quest) => _normalizeTitle(quest.title))
        .toSet();
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
    unawaited(_analytics.logSuggestedWeekAdded(addedCount: newQuests.length));
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

  void _applyCompletion(
    Quest completedQuest, {
    void Function(int level)? onLevelUp,
  }) {
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

    ref
        .read(playerProvider.notifier)
        .addReward(
          questWithSnapshot.xpReward,
          questWithSnapshot.rewardAttribute,
          onLevelUp: onLevelUp,
        );
    ref
        .read(playerProvider.notifier)
        .recordQuestCompletion(
          completedAt: questWithSnapshot.completedAt,
          countsForCompetitive: questWithSnapshot.countsTowardCompetitive,
        );
    final updatedPlayer = ref.read(playerProvider);
    if (questWithSnapshot.countsTowardCompetitive) {
      final repository = ref.read(rankProgressionRepositoryProvider);
      unawaited(repository.syncCompetitiveState(updatedPlayer));
      unawaited(
        repository.syncCompetitiveIntegrity(
          player: updatedPlayer,
          quests: state,
        ),
      );
    }
    unawaited(
      _analytics.logQuestCompleted(
        category: questWithSnapshot.category.name,
        verificationMode: questWithSnapshot.verificationMode.name,
        xpReward: questWithSnapshot.xpReward,
        countsTowardRank: questWithSnapshot.countsTowardCompetitive,
        levelAfter: updatedPlayer.level,
        templateType: questWithSnapshot.templateType.name,
      ),
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
