import 'dart:async';

import 'package:ascend/core/analytics/analytics_service.dart';
import 'package:ascend/core/database/isar_provider.dart';
import 'package:ascend/features/auth/data/active_session_repository.dart';
import 'package:ascend/features/profile/data/player_profile_repository.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final playerProfileRepositoryProvider = Provider<PlayerProfileRepository>((
  ref,
) {
  return PlayerProfileRepository(sessionRepository: ActiveSessionRepository());
});

final playerProvider = StateNotifierProvider<PlayerNotifier, Player>((ref) {
  final notifier = PlayerNotifier(
    ref.watch(isarProvider),
    Player.initial(
      name: FirebaseAuth.instance.currentUser?.displayName ?? 'Jogador',
    ),
    analytics: ref.read(analyticsProvider),
    auth: FirebaseAuth.instance,
    profileRepository: ref.read(playerProfileRepositoryProvider),
    enableCloudSync: true,
  );

  ref.onDispose(notifier.dispose);
  return notifier;
});

class PlayerNotifier extends StateNotifier<Player> {
  PlayerNotifier(
    this._isar,
    super.state, {
    AppAnalytics? analytics,
    FirebaseAuth? auth,
    PlayerProfileRepository? profileRepository,
    Future<Player> Function({
      required String uid,
      required String fallbackName,
      required AttributeType attribute,
    })?
    allocateAttributePointOverride,
    bool enableLocalPersistence = true,
    bool enableCloudSync = false,
  }) : _analytics = analytics ?? const NoopAppAnalytics(),
       _auth = enableCloudSync ? (auth ?? FirebaseAuth.instance) : auth,
       _profileRepository = profileRepository,
       _allocateAttributePointOverride = allocateAttributePointOverride,
       _enableLocalPersistence = enableLocalPersistence {
    if (enableCloudSync) {
      _bindCloudProfile();
    }
  }

  final Isar _isar;
  final AppAnalytics _analytics;
  final FirebaseAuth? _auth;
  final PlayerProfileRepository? _profileRepository;
  final Future<Player> Function({
    required String uid,
    required String fallbackName,
    required AttributeType attribute,
  })?
  _allocateAttributePointOverride;
  final bool _enableLocalPersistence;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<Player?>? _remoteProfileSubscription;
  String? _activeUid;
  bool _isApplyingRemoteSnapshot = false;
  bool _handledMissingRemoteForActiveUser = false;
  bool _attributeAllocationInFlight = false;

  void _bindCloudProfile() {
    final auth = _auth;
    if (auth == null) {
      return;
    }

    _authSubscription = auth.authStateChanges().listen(_handleAuthChanged);
    unawaited(_handleAuthChanged(auth.currentUser));
  }

  Future<void> _handleAuthChanged(User? user) async {
    await _remoteProfileSubscription?.cancel();
    _remoteProfileSubscription = null;
    _handledMissingRemoteForActiveUser = false;
    _activeUid = user?.uid;

    if (user == null) {
      state = Player.initial(name: 'Jogador');
      return;
    }

    final fallbackName = _fallbackNameFor(user);
    final cachedPlayer = _loadCachedPlayerForUid(user.uid);
    final legacyPlayer = cachedPlayer == null
        ? _loadLegacyCachedPlayer()
        : null;
    final seededPlayer =
        cachedPlayer ??
        legacyPlayer ??
        Player.initial(name: fallbackName, ownerUid: user.uid);

    state = _normalizedPlayerForUser(
      seededPlayer,
      uid: user.uid,
      fallbackName: fallbackName,
    );
    _saveToDb(syncRemote: false);

    _remoteProfileSubscription = _profileRepository
        ?.watchProfile(uid: user.uid, fallbackName: fallbackName)
        .listen((remotePlayer) {
          if (remotePlayer != null) {
            _applyRemoteProfile(remotePlayer);
            return;
          }

          if (_handledMissingRemoteForActiveUser) {
            return;
          }
          _handledMissingRemoteForActiveUser = true;

          if (shouldUploadPlayerProfileWhenRemoteMissing(
            state,
            fallbackName: fallbackName,
          )) {
            unawaited(_pushRemoteProfile(state));
          }
        });
  }

  Player _normalizedPlayerForUser(
    Player player, {
    required String uid,
    required String fallbackName,
  }) {
    final normalizedName = player.name.trim().isEmpty
        ? fallbackName
        : player.name.trim();
    return player.copyWith(ownerUid: uid, name: normalizedName);
  }

  String _fallbackNameFor(User user) {
    final displayName = user.displayName?.trim();
    if (displayName == null || displayName.isEmpty) {
      return 'Jogador';
    }
    return displayName;
  }

  void _applyRemoteProfile(Player remotePlayer) {
    _isApplyingRemoteSnapshot = true;
    state = remotePlayer;
    _saveToDb(syncRemote: false);
    _isApplyingRemoteSnapshot = false;
  }

  Player? _loadCachedPlayerForUid(String uid) {
    if (!_enableLocalPersistence) {
      return null;
    }
    final players = _isar.players.where().findAllSync();
    for (final player in players) {
      if (player.ownerUid == uid) {
        return player;
      }
    }
    return null;
  }

  Player? _loadLegacyCachedPlayer() {
    if (!_enableLocalPersistence) {
      return null;
    }
    final players = _isar.players.where().findAllSync();
    for (final player in players) {
      if (player.ownerUid == null) {
        return player;
      }
    }
    return null;
  }

  Future<void> _pushRemoteProfile(Player nextState) async {
    final uid = _activeUid;
    final repository = _profileRepository;
    if (uid == null || repository == null || _isApplyingRemoteSnapshot) {
      return;
    }

    try {
      final quests = _isar.quests
          .where()
          .findAllSync()
          .where((quest) => quest.ownerUid == uid)
          .toList(growable: false);
      await repository.upsertProfile(
        uid: uid,
        player: nextState.copyWith(ownerUid: uid),
        quests: quests,
      );
    } on ActiveSessionConflictException {
      // Auth heartbeat and resume checks handle session conflicts centrally.
    } catch (_) {
      // Temporary backend failures should not block the local profile flow.
    }
  }

  void _saveToDb({bool syncRemote = false}) {
    final localState = state.copyWith(ownerUid: _activeUid ?? state.ownerUid);
    if (!_enableLocalPersistence) {
      state = localState;
      if (syncRemote) {
        unawaited(_pushRemoteProfile(localState));
      }
      return;
    }
    final existing = _activeUid == null
        ? null
        : _loadCachedPlayerForUid(_activeUid!);
    if (existing != null && existing.id != localState.id) {
      localState.id = existing.id;
    }

    _isar.writeTxnSync(() {
      _isar.players.putSync(localState);
    });

    state = localState;

    if (syncRemote) {
      unawaited(_pushRemoteProfile(localState));
    }
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  int _daysBetween(DateTime from, DateTime to) {
    return _dateOnly(to).difference(_dateOnly(from)).inDays;
  }

  List<DateTime> _upsertActivityDate(
    List<DateTime> activityHistory,
    DateTime completionDate,
  ) {
    final normalizedDate = _dateOnly(completionDate);
    final updatedHistory =
        activityHistory
            .where((entry) => _dateOnly(entry) != normalizedDate)
            .toList()
          ..add(normalizedDate)
          ..sort();

    return updatedHistory;
  }

  void _applyXpReward(
    int xpReward, {
    int bonusStatPoints = 0,
    PlayerAttributes? attributes,
    void Function(int level)? onLevelUp,
  }) {
    final oldLevel = state.level;
    var currentXp = state.xp + xpReward;
    var currentLevel = state.level;
    var currentMaxXp = state.maxXp;
    var currentStatPoints = state.statPoints + bonusStatPoints;

    while (currentXp >= currentMaxXp) {
      currentXp -= currentMaxXp;
      currentLevel++;
      currentStatPoints += 5;
      currentMaxXp = (currentMaxXp * 1.2).toInt();
    }

    state = state.copyWith(
      level: currentLevel,
      xp: currentXp,
      maxXp: currentMaxXp,
      statPoints: currentStatPoints,
      attributes: attributes ?? state.attributes,
    );

    _saveToDb();

    if (currentLevel > oldLevel && onLevelUp != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        onLevelUp(currentLevel);
      });
    }
  }

  void addReward(
    int xpReward,
    AttributeType attribute, {
    void Function(int level)? onLevelUp,
  }) {
    final newAttrs = PlayerAttributes(
      strength:
          state.attributes.strength +
          (attribute == AttributeType.strength ? 1 : 0),
      intelligence:
          state.attributes.intelligence +
          (attribute == AttributeType.intelligence ? 1 : 0),
      vitality:
          state.attributes.vitality +
          (attribute == AttributeType.vitality ? 1 : 0),
      agility:
          state.attributes.agility +
          (attribute == AttributeType.agility ? 1 : 0),
    );

    _applyXpReward(xpReward, attributes: newAttrs, onLevelUp: onLevelUp);
  }

  /// Reverte completamente uma recompensa de quest usando o snapshot pré-recompensa.
  /// Se o snapshot não existir, faz fallback para subtração simples (sem reverter level-up).
  void undoReward(Quest quest) {
    if (quest.hasPreRewardSnapshot) {
      state = state.copyWith(
        level: quest.preRewardLevel,
        xp: quest.preRewardXp,
        maxXp: quest.preRewardMaxXp,
        statPoints: quest.preRewardStatPoints,
        attributes: PlayerAttributes(
          strength: quest.preRewardStrength ?? state.attributes.strength,
          intelligence:
              quest.preRewardIntelligence ?? state.attributes.intelligence,
          vitality: quest.preRewardVitality ?? state.attributes.vitality,
          agility: quest.preRewardAgility ?? state.attributes.agility,
        ),
      );
    } else {
      // Fallback para quests antigas sem snapshot (subtração simples, não reverte level-up)
      final newXp = (state.xp - quest.xpReward).clamp(0, state.maxXp);
      final attribute = quest.rewardAttribute;

      final newAttrs = PlayerAttributes(
        strength:
            (state.attributes.strength -
                    (attribute == AttributeType.strength ? 1 : 0))
                .clamp(10, 999),
        intelligence:
            (state.attributes.intelligence -
                    (attribute == AttributeType.intelligence ? 1 : 0))
                .clamp(10, 999),
        vitality:
            (state.attributes.vitality -
                    (attribute == AttributeType.vitality ? 1 : 0))
                .clamp(10, 999),
        agility:
            (state.attributes.agility -
                    (attribute == AttributeType.agility ? 1 : 0))
                .clamp(10, 999),
      );

      state = state.copyWith(xp: newXp, attributes: newAttrs);
    }

    _saveToDb();
  }

  void applyAuthoritativeProfile(
    Player nextPlayer, {
    void Function(int level)? onLevelUp,
  }) {
    final oldLevel = state.level;
    _applyRemoteProfile(nextPlayer);
    if (nextPlayer.level > oldLevel && onLevelUp != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        onLevelUp(nextPlayer.level);
      });
    }
  }

  Future<void> upgradeAttribute(
    AttributeType type, {
    void Function(int level)? onLevelUp,
  }) async {
    if (state.statPoints <= 0 || _attributeAllocationInFlight) return;
    final uid = _activeUid;
    final repository = _profileRepository;
    if (uid == null ||
        (repository == null && _allocateAttributePointOverride == null)) {
      return;
    }
    final previousState = state;
    final optimisticAttributes = _copyAttributes(previousState.attributes);

    switch (type) {
      case AttributeType.strength:
        optimisticAttributes.strength++;
        break;
      case AttributeType.intelligence:
        optimisticAttributes.intelligence++;
        break;
      case AttributeType.vitality:
        optimisticAttributes.vitality++;
        break;
      case AttributeType.agility:
        optimisticAttributes.agility++;
        break;
    }

    try {
      _attributeAllocationInFlight = true;
      state = previousState.copyWith(
        statPoints: previousState.statPoints - 1,
        attributes: optimisticAttributes,
      );
      _saveToDb(syncRemote: false);
      final allocateAttributePoint =
          _allocateAttributePointOverride ??
          ({
            required String uid,
            required String fallbackName,
            required AttributeType attribute,
          }) => repository!.allocateAttributePoint(
            uid: uid,
            fallbackName: fallbackName,
            attribute: attribute,
          );
      final updated = await allocateAttributePoint(
        uid: uid,
        fallbackName: state.name,
        attribute: type,
      );
      applyAuthoritativeProfile(updated, onLevelUp: onLevelUp);
    } on ActiveSessionConflictException {
      state = previousState;
      _saveToDb(syncRemote: false);
      // Auth heartbeat and resume checks handle session conflicts centrally.
    } catch (_) {
      state = previousState;
      _saveToDb(syncRemote: false);
      rethrow;
    } finally {
      _attributeAllocationInFlight = false;
    }
  }

  PlayerAttributes _copyAttributes(PlayerAttributes source) {
    return PlayerAttributes(
      strength: source.strength,
      intelligence: source.intelligence,
      vitality: source.vitality,
      agility: source.agility,
    );
  }

  void debugSetActiveUid(String? uid) {
    _activeUid = uid;
  }

  Future<void> updateName(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    final normalizedName = trimmed.length > 40
        ? trimmed.substring(0, 40)
        : trimmed;
    if (normalizedName == state.name) return;

    state = state.copyWith(name: normalizedName);
    _saveToDb();
    await _pushProfileSettings();
  }

  void recordQuestCompletion({DateTime? completedAt}) {
    final completionDate = completedAt ?? DateTime.now();
    final lastCompletion = state.lastQuestCompletionDate;
    final updatedHistory = _upsertActivityDate(
      state.activityHistory,
      completionDate,
    );
    if (lastCompletion != null &&
        _daysBetween(lastCompletion, completionDate) == 0) {
      final historyChanged =
          updatedHistory.length != state.activityHistory.length;
      if (historyChanged) {
        state = state.copyWith(activityHistory: updatedHistory);
        _saveToDb();
      }
      return;
    }

    final streak = switch (lastCompletion) {
      null => 1,
      _ when _daysBetween(lastCompletion, completionDate) == 1 =>
        state.currentStreak + 1,
      _ => 1,
    };

    state = state.copyWith(
      currentStreak: streak,
      bestStreak: streak > state.bestStreak ? streak : state.bestStreak,
      lastQuestCompletionDate: completionDate,
      activityHistory: updatedHistory,
    );

    _saveToDb();
  }

  Future<void> handleDailyReset(DateTime now) async {
    final lastCompletion = state.lastQuestCompletionDate;
    var nextStreak = state.currentStreak;

    if (lastCompletion != null && _daysBetween(lastCompletion, now) > 1) {
      nextStreak = 0;
    }

    state = state.copyWith(lastResetDate: now, currentStreak: nextStreak);

    _saveToDb();
    await _pushProfileSettings();
  }

  Future<void> completeOnboarding(AwakeningPath focus) async {
    final starterKit = starterQuestsForFocus(focus);

    state = state.copyWith(primaryFocus: focus, hasCompletedOnboarding: true);

    _saveToDb();
    await _pushProfileSettings();
    unawaited(
      _analytics.logOnboardingCompleted(
        focus: focus.name,
        starterKitSize: starterKit.length,
        competitiveQuestCount: 0,
        personalQuestCount: starterKit.length,
      ),
    );
  }

  Future<void> updatePrimaryFocus(AwakeningPath focus) async {
    final previousFocus = state.primaryFocus;
    state = state.copyWith(primaryFocus: focus);
    _saveToDb();
    await _pushProfileSettings();
    unawaited(
      _analytics.logFocusChanged(from: previousFocus.name, to: focus.name),
    );
  }

  Future<void> _pushProfileSettings() async {
    final uid = _activeUid;
    final repository = _profileRepository;
    final currentUser = _auth?.currentUser;
    if (uid == null || repository == null || currentUser == null) {
      return;
    }

    try {
      final updated = await repository.updateProfileSettings(
        uid: uid,
        fallbackName: _fallbackNameFor(currentUser),
        name: state.name,
        primaryFocus: state.primaryFocus,
        hasCompletedOnboarding: state.hasCompletedOnboarding,
        lastResetDate: state.lastResetDate,
      );
      _applyRemoteProfile(updated);
    } on ActiveSessionConflictException {
      // Auth heartbeat and resume checks handle session conflicts centrally.
    } catch (_) {
      // Settings failures should not erase local cache state.
    }
  }

  Future<bool> resgatarBossPessoalSemanal(
    WeeklyBossDefinition weeklyBoss, {
    void Function(int level)? onLevelUp,
  }) async {
    if (!weeklyBoss.isCompleted(state) || weeklyBoss.isClaimedThisWeek(state)) {
      return false;
    }
    final uid = _activeUid;
    final repositorio = _profileRepository;
    final usuario = _auth?.currentUser;
    if (uid == null || repositorio == null || usuario == null) return false;
    final atualizado = await repositorio.resgatarBossPessoalSemanal(
      uid: uid,
      fallbackName: _fallbackNameFor(usuario),
    );
    applyAuthoritativeProfile(atualizado, onLevelUp: onLevelUp);
    unawaited(
      _analytics.logWeeklyBossClaimed(
        bossId: 'personal-weekly',
        rank: 'personal',
        status: 'claimed',
      ),
    );
    return true;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _remoteProfileSubscription?.cancel();
    super.dispose();
  }
}
