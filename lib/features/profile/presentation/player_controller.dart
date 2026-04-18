import 'package:ascend/core/database/isar_provider.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final playerProvider = StateNotifierProvider<PlayerNotifier, Player>((ref) {
  final isar = ref.watch(isarProvider);
  final savedPlayer = isar.players.where().findFirstSync();

  return PlayerNotifier(
    isar,
    savedPlayer ??
        Player(
          name: 'MATEUS',
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

  void addReward(
    int xpReward,
    AttributeType attribute, {
    void Function(int level)? onLevelUp,
  }) {
    final oldLevel = state.level;
    var currentXp = state.xp + xpReward;
    var currentLevel = state.level;
    var currentMaxXp = state.maxXp;
    var currentStatPoints = state.statPoints;

    while (currentXp >= currentMaxXp) {
      currentXp -= currentMaxXp;
      currentLevel++;
      currentStatPoints += 5;
      currentMaxXp = (currentMaxXp * 1.2).toInt();
    }

    final newAttrs = PlayerAttributes(
      strength: state.attributes.strength + (attribute == AttributeType.strength ? 1 : 0),
      intelligence: state.attributes.intelligence + (attribute == AttributeType.intelligence ? 1 : 0),
      vitality: state.attributes.vitality + (attribute == AttributeType.vitality ? 1 : 0),
      agility: state.attributes.agility + (attribute == AttributeType.agility ? 1 : 0),
    );

    state = state.copyWith(
      level: currentLevel,
      xp: currentXp,
      maxXp: currentMaxXp,
      statPoints: currentStatPoints,
      attributes: newAttrs,
    );

    _saveToDb();

    if (currentLevel > oldLevel && onLevelUp != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        onLevelUp(currentLevel);
      });
    }
  }

  void removeReward(int xpReward, AttributeType attribute) {
    final newXp = (state.xp - xpReward).clamp(0, state.maxXp);

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

  void recordQuestCompletion([DateTime? completedAt]) {
    final completionDate = completedAt ?? DateTime.now();
    final lastCompletion = state.lastQuestCompletionDate;
    final updatedHistory = _upsertActivityDate(state.activityHistory, completionDate);

    if (lastCompletion != null && _daysBetween(lastCompletion, completionDate) == 0) {
      if (updatedHistory.length != state.activityHistory.length) {
        state = state.copyWith(activityHistory: updatedHistory);
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
}
