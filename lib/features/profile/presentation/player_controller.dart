import 'package:ascend/core/database/isar_provider.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final playerProvider = StateNotifierProvider<PlayerNotifier, Player>((ref) {
  final isar = ref.watch(isarProvider);
  final savedPlayer = isar.players.where().findFirstSync();
  final currentUser = FirebaseAuth.instance.currentUser;

  return PlayerNotifier(
    isar,
    savedPlayer ??
        Player(
          name: currentUser?.displayName ?? 'Jogador',
          level: 1,
          xp: 0,
          maxXp: 100,
          statPoints: 0,
          attributes: PlayerAttributes(),
          lastResetDate: DateTime.now(),
        ),
  );
});

class PlayerNotifier extends StateNotifier<Player> {
  PlayerNotifier(this._isar, super.state);

  final Isar _isar;

  void _saveToDb() {
    _isar.writeTxnSync(() {
      _isar.players.putSync(state);
    });
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  int _daysBetween(DateTime from, DateTime to) {
    return _dateOnly(to).difference(_dateOnly(from)).inDays;
  }

  List<DateTime> _upsertActivityDate(List<DateTime> activityHistory, DateTime completionDate) {
    final normalizedDate = _dateOnly(completionDate);
    final updatedHistory = activityHistory.where((entry) => _dateOnly(entry) != normalizedDate).toList()
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
      strength: state.attributes.strength + (attribute == AttributeType.strength ? 1 : 0),
      intelligence: state.attributes.intelligence + (attribute == AttributeType.intelligence ? 1 : 0),
      vitality: state.attributes.vitality + (attribute == AttributeType.vitality ? 1 : 0),
      agility: state.attributes.agility + (attribute == AttributeType.agility ? 1 : 0),
    );

    _applyXpReward(
      xpReward,
      attributes: newAttrs,
      onLevelUp: onLevelUp,
    );
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
          intelligence: quest.preRewardIntelligence ?? state.attributes.intelligence,
          vitality: quest.preRewardVitality ?? state.attributes.vitality,
          agility: quest.preRewardAgility ?? state.attributes.agility,
        ),
      );
    } else {
      // Fallback para quests antigas sem snapshot (subtração simples, não reverte level-up)
      final newXp = (state.xp - quest.xpReward).clamp(0, state.maxXp);
      final attribute = quest.rewardAttribute;

      final newAttrs = PlayerAttributes(
        strength: (state.attributes.strength - (attribute == AttributeType.strength ? 1 : 0)).clamp(10, 999),
        intelligence: (state.attributes.intelligence - (attribute == AttributeType.intelligence ? 1 : 0))
            .clamp(10, 999),
        vitality: (state.attributes.vitality - (attribute == AttributeType.vitality ? 1 : 0)).clamp(10, 999),
        agility: (state.attributes.agility - (attribute == AttributeType.agility ? 1 : 0)).clamp(10, 999),
      );

      state = state.copyWith(
        xp: newXp,
        attributes: newAttrs,
      );
    }

    _saveToDb();
  }

  void upgradeAttribute(AttributeType type) {
    if (state.statPoints <= 0) return;

    final newAttrs = PlayerAttributes(
      strength: state.attributes.strength + (type == AttributeType.strength ? 1 : 0),
      intelligence: state.attributes.intelligence + (type == AttributeType.intelligence ? 1 : 0),
      vitality: state.attributes.vitality + (type == AttributeType.vitality ? 1 : 0),
      agility: state.attributes.agility + (type == AttributeType.agility ? 1 : 0),
    );

    state = state.copyWith(
      statPoints: state.statPoints - 1,
      attributes: newAttrs,
    );

    _saveToDb();
  }

  void recordQuestCompletion({
    DateTime? completedAt,
    bool countsForCompetitive = false,
  }) {
    final completionDate = completedAt ?? DateTime.now();
    final lastCompletion = state.lastQuestCompletionDate;
    final updatedHistory = _upsertActivityDate(state.activityHistory, completionDate);
    final updatedCompetitiveHistory = countsForCompetitive
        ? _upsertActivityDate(state.competitiveActivityHistory, completionDate)
        : state.competitiveActivityHistory;

    if (lastCompletion != null && _daysBetween(lastCompletion, completionDate) == 0) {
      final historyChanged = updatedHistory.length != state.activityHistory.length;
      final competitiveHistoryChanged =
          updatedCompetitiveHistory.length != state.competitiveActivityHistory.length;

      if (historyChanged || competitiveHistoryChanged) {
        state = state.copyWith(
          activityHistory: updatedHistory,
          competitiveActivityHistory: updatedCompetitiveHistory,
          lastCompetitiveQuestCompletionDate: countsForCompetitive
              ? completionDate
              : state.lastCompetitiveQuestCompletionDate,
        );
        _saveToDb();
      }
      return;
    }

    final streak = switch (lastCompletion) {
      null => 1,
      _ when _daysBetween(lastCompletion, completionDate) == 1 => state.currentStreak + 1,
      _ => 1,
    };

    state = state.copyWith(
      currentStreak: streak,
      bestStreak: streak > state.bestStreak ? streak : state.bestStreak,
      lastQuestCompletionDate: completionDate,
      activityHistory: updatedHistory,
      competitiveActivityHistory: updatedCompetitiveHistory,
      lastCompetitiveQuestCompletionDate: countsForCompetitive
          ? completionDate
          : state.lastCompetitiveQuestCompletionDate,
    );

    _saveToDb();
  }

  void handleDailyReset(DateTime now) {
    final lastCompletion = state.lastQuestCompletionDate;
    var nextStreak = state.currentStreak;

    if (lastCompletion != null && _daysBetween(lastCompletion, now) > 1) {
      nextStreak = 0;
    }

    state = state.copyWith(
      lastResetDate: now,
      currentStreak: nextStreak,
    );

    _saveToDb();
  }

  void completeOnboarding(AwakeningPath focus) {
    state = state.copyWith(
      primaryFocus: focus,
      hasCompletedOnboarding: true,
    );

    _saveToDb();
  }

  void updatePrimaryFocus(AwakeningPath focus) {
    state = state.copyWith(primaryFocus: focus);
    _saveToDb();
  }

  bool claimWeeklyBossReward(
    WeeklyBossDefinition weeklyBoss, {
    void Function(int level)? onLevelUp,
  }) {
    if (!weeklyBoss.isCompleted(state, competitiveOnly: true) ||
        weeklyBoss.isClaimedThisWeek(state)) {
      return false;
    }

    _applyXpReward(
      weeklyBoss.rewardXp,
      bonusStatPoints: weeklyBoss.rewardStatPoints,
      onLevelUp: onLevelUp,
    );

    state = state.copyWith(weeklyBossLastClaimedAt: DateTime.now());
    _saveToDb();
    return true;
  }

  void markWeeklyBossClaimedNow() {
    state = state.copyWith(weeklyBossLastClaimedAt: DateTime.now());
    _saveToDb();
  }
}
