import 'dart:async';

import 'package:ascend/core/analytics/analytics_service.dart';
import 'package:ascend/core/crash/crash_reporting_service.dart';
import 'package:ascend/core/database/isar_provider.dart';
import 'package:ascend/features/auth/data/active_session_repository.dart';
import 'package:ascend/features/auth/domain/auth_state.dart';
import 'package:ascend/features/auth/presentation/auth_controller.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/profile/presentation/rank_progression_provider.dart';
import 'package:ascend/features/quests/data/competitive_evidence_provider_adapter.dart';
import 'package:ascend/features/quests/data/health_connect_evidence_provider_adapter.dart';
import 'package:ascend/features/quests/data/competitive_quest_authority_repository.dart';
import 'package:ascend/features/quests/data/quest_sync_repository.dart';
import 'package:ascend/features/quests/domain/competitive_quest_evidence.dart';
import 'package:ascend/features/quests/domain/competitive_quest_template.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/domain/quest_suggestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final competitiveQuestAuthorityRepositoryProvider =
    Provider<CompetitiveQuestAuthorityRepository>((ref) {
      return CompetitiveQuestAuthorityRepository(
        functions: FirebaseFunctions.instanceFor(region: 'southamerica-east1'),
        crashReporter: ref.read(crashReportingProvider),
      );
    });

final competitiveEvidenceProviderAdapterProvider =
    Provider<CompetitiveEvidenceProviderAdapter>((ref) {
      const useHealthConnect = bool.fromEnvironment(
        'ASCEND_USE_HEALTH_CONNECT',
      );
      if (useHealthConnect && defaultTargetPlatform == TargetPlatform.android) {
        return const HealthConnectCompetitiveEvidenceProviderAdapter();
      }
      return const MockCompetitiveEvidenceProviderAdapter();
    });

final questSyncRepositoryProvider = Provider<QuestSyncRepository>((ref) {
  return QuestSyncRepository(
    FirebaseFirestore.instance,
    sessionRepository: ActiveSessionRepository(),
  );
});

final questProvider = StateNotifierProvider<QuestNotifier, List<Quest>>((ref) {
  final notifier = QuestNotifier(
    ref,
    ref.watch(isarProvider),
    analytics: ref.read(analyticsProvider),
    competitiveAuthority: ref.read(competitiveQuestAuthorityRepositoryProvider),
    evidenceProviderAdapter: ref.read(
      competitiveEvidenceProviderAdapterProvider,
    ),
    auth: FirebaseAuth.instance,
    questSyncRepository: ref.read(questSyncRepositoryProvider),
    enableCloudSync: true,
  );

  ref.onDispose(notifier.dispose);
  return notifier;
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
  insufficientEvidence,
  evidenceRejected,
  duplicateEvidence,
}

class QuestNotifier extends StateNotifier<List<Quest>> {
  QuestNotifier(
    this.ref,
    this._isar, {
    AppAnalytics? analytics,
    CompetitiveQuestAuthorityRepository? competitiveAuthority,
    CompetitiveEvidenceProviderAdapter? evidenceProviderAdapter,
    FirebaseAuth? auth,
    QuestSyncRepository? questSyncRepository,
    bool enableCloudSync = false,
  }) : _analytics = analytics ?? const NoopAppAnalytics(),
       _competitiveAuthority = competitiveAuthority,
       _evidenceProviderAdapter =
           evidenceProviderAdapter ??
           const MockCompetitiveEvidenceProviderAdapter(),
       _auth = enableCloudSync ? (auth ?? FirebaseAuth.instance) : auth,
       _questSyncRepository = questSyncRepository,
       super([]) {
    if (enableCloudSync) {
      _bindCloudQuests();
    } else {
      _initLocal();
    }
  }

  final Ref ref;
  final Isar _isar;
  final AppAnalytics _analytics;
  final CompetitiveQuestAuthorityRepository? _competitiveAuthority;
  final CompetitiveEvidenceProviderAdapter _evidenceProviderAdapter;
  final FirebaseAuth? _auth;
  final QuestSyncRepository? _questSyncRepository;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<Quest>>? _remoteQuestSubscription;
  String? _activeUid;
  bool _isApplyingRemoteSnapshot = false;
  bool _handledMissingRemoteForActiveUser = false;

  void _initLocal() {
    final savedQuests = _isar.quests.where().findAllSync();
    final player = ref.read(playerProvider);

    if (savedQuests.isEmpty) {
      if (player.hasCompletedOnboarding) {
        _seedInitialQuests(player.primaryFocus);
      } else {
        state = [];
      }
      return;
    }

    state = savedQuests;
  }

  void _bindCloudQuests() {
    final auth = _auth;
    if (auth == null) {
      _initLocal();
      return;
    }

    _authSubscription = auth.authStateChanges().listen(_handleAuthChanged);
    unawaited(_handleAuthChanged(auth.currentUser));
  }

  Future<void> _handleAuthChanged(User? user) async {
    await _remoteQuestSubscription?.cancel();
    _remoteQuestSubscription = null;
    _handledMissingRemoteForActiveUser = false;
    _activeUid = user?.uid;

    if (user == null) {
      state = const <Quest>[];
      return;
    }

    final cachedQuests = _loadCachedQuestsForUid(user.uid);
    final legacyQuests = cachedQuests.isEmpty
        ? _loadLegacyCachedQuests()
        : const <Quest>[];
    final seededQuests = cachedQuests.isNotEmpty ? cachedQuests : legacyQuests;
    if (seededQuests.isNotEmpty) {
      _replaceLocalState(seededQuests, syncRemote: false);
    } else {
      state = const <Quest>[];
    }

    final repository = _questSyncRepository;
    final remoteInitialized = repository == null
        ? false
        : await repository.hasInitializedSnapshot(user.uid);

    _remoteQuestSubscription = repository?.watchQuests(user.uid).listen((
      remoteQuests,
    ) {
      if (remoteQuests.isNotEmpty) {
        _applyRemoteQuests(remoteQuests);
        return;
      }

      if (remoteInitialized) {
        _applyRemoteQuests(const <Quest>[]);
        return;
      }

      if (_handledMissingRemoteForActiveUser) {
        return;
      }
      _handledMissingRemoteForActiveUser = true;

      if (shouldUploadQuestCacheWhenRemoteMissing(state)) {
        unawaited(_pushRemoteQuests(state));
      }
    });
  }

  void _applyRemoteQuests(List<Quest> remoteQuests) {
    _isApplyingRemoteSnapshot = true;
    _replaceLocalState(remoteQuests, syncRemote: false);
    _isApplyingRemoteSnapshot = false;
  }

  List<Quest> _loadCachedQuestsForUid(String uid) {
    final quests = _isar.quests.where().findAllSync();
    return quests
        .where((quest) => quest.ownerUid == uid)
        .toList(growable: false);
  }

  List<Quest> _loadLegacyCachedQuests() {
    final quests = _isar.quests.where().findAllSync();
    return quests
        .where((quest) => quest.ownerUid == null)
        .toList(growable: false);
  }

  Future<void> _pushRemoteQuests(List<Quest> quests) async {
    final uid = _activeUid;
    final repository = _questSyncRepository;
    if (uid == null || repository == null || _isApplyingRemoteSnapshot) {
      return;
    }

    try {
      await repository.replaceQuests(
        uid: uid,
        quests: quests
            .map((quest) => quest.copyWith(ownerUid: uid))
            .toList(growable: false),
      );
    } on ActiveSessionConflictException {
      unawaited(ref.read(authProvider.notifier).handleActiveSessionConflict());
    } catch (_) {
      // Temporary backend failures should not block the local quest flow.
    }
  }

  void _replaceLocalState(List<Quest> quests, {bool syncRemote = true}) {
    final uid = _activeUid;
    final normalized = quests
        .map((quest) => quest.copyWith(ownerUid: uid ?? quest.ownerUid))
        .toList(growable: false);
    final byId = <String, Quest>{
      for (final quest in _isar.quests.where().findAllSync())
        if (uid == null || quest.ownerUid == uid) quest.id: quest,
    };

    final normalizedWithIds = normalized
        .map((quest) {
          final existing = byId[quest.id];
          if (existing == null || existing.isarId == quest.isarId) {
            return quest;
          }

          return quest.copyWith()..isarId = existing.isarId;
        })
        .toList(growable: false);

    _isar.writeTxnSync(() {
      final existingForUser = _isar.quests
          .where()
          .findAllSync()
          .where((quest) {
            if (uid == null) {
              return quest.ownerUid == null;
            }
            return quest.ownerUid == uid;
          })
          .toList(growable: false);
      final nextIds = normalizedWithIds.map((quest) => quest.id).toSet();

      for (final quest in existingForUser) {
        if (!nextIds.contains(quest.id)) {
          _isar.quests.deleteSync(quest.isarId);
        }
      }

      _isar.quests.putAllSync(normalizedWithIds);
    });

    state = normalizedWithIds;

    if (syncRemote) {
      unawaited(_pushRemoteQuests(normalizedWithIds));
    }
  }

  void ensureDailyReset() {
    _checkDailyReset(ref.read(playerProvider));
  }

  void _checkDailyReset(Player player) {
    final now = DateTime.now();
    if (!isDailyResetDue(lastReset: player.lastResetDate, now: now)) return;

    _isar.writeTxnSync(() {
      final resetQuests = state
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
      _isar.quests.putAllSync(
        resetQuests
            .map(
              (quest) => quest.copyWith(ownerUid: _activeUid ?? quest.ownerUid),
            )
            .toList(growable: false),
      );
    });

    ref.read(playerProvider.notifier).handleDailyReset(now);
    state = state
        .map(
          (q) => q.copyWith(
            isCompleted: false,
            verificationStatus: QuestVerificationStatus.none,
            clearPreRewardSnapshot: true,
            clearVerificationProgress: true,
          ),
        )
        .toList(growable: false);
    unawaited(_pushRemoteQuests(state));
  }

  void _seedInitialQuests(AwakeningPath focus) {
    final initialQuests = starterQuestsForFocus(focus)
        .map((quest) => quest.copyWith(ownerUid: _activeUid))
        .toList(growable: false);

    _replaceLocalState(initialQuests);
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

  void addQuest(String title, AttributeType attribute, int xp) {
    addPersonalQuest(title, attribute, xp);
  }

  void addPersonalQuest(String title, AttributeType attribute, int xp) {
    final newQuest = Quest(
      ownerUid: _activeUid,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      rewardAttribute: attribute,
      xpReward: normalizePersonalQuestXp(xp),
      category: QuestCategory.personal,
      verificationMode: QuestVerificationMode.manual,
      verificationStatus: QuestVerificationStatus.none,
    );

    _replaceLocalState([...state, newQuest]);
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
          quest.id.startsWith('${template.id}-'),
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

    final newQuest = template.toQuest().copyWith(ownerUid: _activeUid);
    _replaceLocalState([...state, newQuest]);
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
      try {
        final session = await _competitiveAuthority.startQuestSession(
          quest: quest,
        );
        startedAt = session.startedAt;
      } on ActiveSessionConflictException {
        unawaited(
          ref.read(authProvider.notifier).handleActiveSessionConflict(),
        );
        return QuestCompletionResult.invalidFlow;
      } on FirebaseFunctionsException catch (error) {
        if (error.code == 'failed-precondition' &&
            error.message?.contains('sessao ainda nao foi iniciada') == true) {
          _persistQuestUpdate(quest.copyWith(clearVerificationProgress: true));
          return QuestCompletionResult.invalidFlow;
        }
        rethrow;
      }
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

  Future<QuestCompletionResult> toggleQuest(
    String id, {
    void Function(int level)? onLevelUp,
  }) async {
    final quest = _findQuest(id);
    if (quest == null) return QuestCompletionResult.notFound;
    if (quest.isCompetitive) return QuestCompletionResult.invalidFlow;

    final uid = _activeUid;
    final repository = _questSyncRepository;
    final authState = ref.read(authProvider);
    final fallbackName = authState is AuthSuccess
        ? authState.displayName
        : ref.read(playerProvider).name;

    if (uid == null || repository == null) {
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
        return QuestCompletionResult.success;
      }

      _undoCompletion(quest);
      return QuestCompletionResult.success;
    }

    try {
      final result = !quest.isCompleted
          ? await repository.completePersonalQuest(
              uid: uid,
              fallbackName: fallbackName,
              quest: quest,
            )
          : await repository.revokePersonalQuestCompletion(
              uid: uid,
              fallbackName: fallbackName,
              quest: quest,
            );
      _applyAuthoritativeQuestMutation(result.quest, syncRemote: false);
      ref
          .read(playerProvider.notifier)
          .applyAuthoritativeProfile(result.player, onLevelUp: onLevelUp);
      _logQuestMutationResult(result.quest, result.player);
      return switch (result.status) {
        PersonalQuestMutationStatus.alreadyCompleted =>
          QuestCompletionResult.alreadyCompleted,
        _ => QuestCompletionResult.success,
      };
    } on ActiveSessionConflictException {
      unawaited(ref.read(authProvider.notifier).handleActiveSessionConflict());
      return QuestCompletionResult.invalidFlow;
    }
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

    final template = officialTemplateForQuest(quest);
    final requirement = template?.verificationRequirement;
    if (requirement == null) {
      unawaited(
        _analytics.logCompetitiveQuestBlocked(
          reason: 'missing_verification_requirement',
          verificationMode: quest.verificationMode.name,
          templateType: quest.templateType.name,
        ),
      );
      return QuestCompletionResult.invalidFlow;
    }

    final evidence = await _evidenceProviderAdapter.buildEvidence(
      quest: quest,
      requirement: requirement,
      startedAt: quest.verificationStartedAt ?? now,
      completedAt: now,
      reflection: reflectionAnswer?.trim(),
    );
    final decision = evaluateCompetitiveQuestEvidence(
      quest: quest,
      requirement: requirement,
      evidence: evidence,
      now: now,
    );
    if (!decision.accepted) {
      unawaited(
        _analytics.logCompetitiveQuestBlocked(
          reason:
              'insufficient_evidence_${decision.status.name}_${decision.riskFlags.map((flag) => flag.name).join('_')}',
          verificationMode: quest.verificationMode.name,
          templateType: quest.templateType.name,
        ),
      );
      return decision.status == VerificationDecisionStatus.rejected
          ? QuestCompletionResult.evidenceRejected
          : QuestCompletionResult.insufficientEvidence;
    }

    DateTime completedAt = now;
    if (_competitiveAuthority != null) {
      final uid = _activeUid;
      if (uid == null) {
        return QuestCompletionResult.invalidFlow;
      }
      final authState = ref.read(authProvider);
      final fallbackName = authState is AuthSuccess
          ? authState.displayName
          : ref.read(playerProvider).name;

      try {
        final verification = await _competitiveAuthority.verifyQuestCompletion(
          quest: quest,
          uid: uid,
          fallbackName: fallbackName,
          evidence: evidence,
          reflectionAnswer: reflectionAnswer?.trim(),
        );
        completedAt = verification.completedAt;
        _applyAuthoritativeQuestMutation(verification.quest, syncRemote: false);
        ref
            .read(playerProvider.notifier)
            .applyAuthoritativeProfile(
              verification.player,
              onLevelUp: onLevelUp,
            );
        _logQuestMutationResult(verification.quest, verification.player);
        return QuestCompletionResult.success;
      } on ActiveSessionConflictException {
        unawaited(
          ref.read(authProvider.notifier).handleActiveSessionConflict(),
        );
        return QuestCompletionResult.invalidFlow;
      } on FirebaseFunctionsException catch (error) {
        final mappedResult = _competitiveVerificationFailureResult(error);
        if (mappedResult != null) {
          return mappedResult;
        }
        rethrow;
      }
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

  QuestCompletionResult? _competitiveVerificationFailureResult(
    FirebaseFunctionsException error,
  ) {
    final message = error.message ?? '';
    if (error.code != 'failed-precondition') return null;

    if (message.contains('duplicateSourceActivityId')) {
      return QuestCompletionResult.duplicateEvidence;
    }
    if (message.contains('Evidencia competitiva insuficiente')) {
      if (message.contains(CompetitiveRiskFlag.impossiblePace.name) ||
          message.contains(CompetitiveRiskFlag.invalidProvider.name) ||
          message.contains(CompetitiveRiskFlag.completedBeforeStart.name) ||
          message.contains(CompetitiveRiskFlag.staleEvidence.name)) {
        return QuestCompletionResult.evidenceRejected;
      }
      return QuestCompletionResult.insufficientEvidence;
    }
    return null;
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
          ownerUid: _activeUid,
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

    _replaceLocalState([...state, ...newQuests]);
    unawaited(_analytics.logSuggestedWeekAdded(addedCount: newQuests.length));
    return newQuests.length;
  }

  void deleteQuest(String id) {
    _replaceLocalState(
      state.where((quest) => quest.id != id).toList(growable: false),
    );
  }

  Quest? _findQuest(String id) {
    final index = state.indexWhere((q) => q.id == id);
    if (index == -1) return null;
    return state[index];
  }

  void _persistQuestUpdate(Quest updatedQuest, {bool syncRemote = true}) {
    final index = state.indexWhere((q) => q.id == updatedQuest.id);
    if (index == -1) return;
    final newState = [...state];
    newState[index] = updatedQuest.copyWith(ownerUid: _activeUid);
    _replaceLocalState(newState, syncRemote: syncRemote);
  }

  void _applyAuthoritativeQuestMutation(
    Quest updatedQuest, {
    bool syncRemote = false,
  }) {
    _persistQuestUpdate(updatedQuest, syncRemote: syncRemote);
  }

  void _logQuestMutationResult(Quest quest, Player updatedPlayer) {
    if (quest.countsTowardCompetitive) {
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
        category: quest.category.name,
        verificationMode: quest.verificationMode.name,
        xpReward: quest.xpReward,
        countsTowardRank: quest.countsTowardCompetitive,
        levelAfter: updatedPlayer.level,
        templateType: quest.templateType.name,
      ),
    );
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
    _logQuestMutationResult(questWithSnapshot, updatedPlayer);
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

  @override
  void dispose() {
    _authSubscription?.cancel();
    _remoteQuestSubscription?.cancel();
    super.dispose();
  }
}
