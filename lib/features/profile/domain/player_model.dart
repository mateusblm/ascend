import 'package:isar/isar.dart';

part 'player_model.g.dart';

@embedded
class PlayerAttributes {
  int strength;
  int intelligence;
  int vitality;
  int agility;

  PlayerAttributes({
    this.strength = 10,
    this.intelligence = 10,
    this.vitality = 10,
    this.agility = 10,
  });
}

@Collection()
class Player {
  Id id = Isar.autoIncrement;

  final String name;
  final int level;
  final int xp;
  final int maxXp;
  final int statPoints;
  final PlayerAttributes attributes;
  final DateTime lastResetDate;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastQuestCompletionDate;

  Player({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.level,
    required this.xp,
    required this.maxXp,
    this.statPoints = 0,
    required this.attributes,
    required this.lastResetDate,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastQuestCompletionDate,
  });

  Player copyWith({
    int? level,
    int? xp,
    int? maxXp,
    int? statPoints,
    PlayerAttributes? attributes,
    DateTime? lastResetDate,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastQuestCompletionDate,
    bool clearLastQuestCompletionDate = false,
  }) {
    return Player(
      id: id,
      name: name,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      maxXp: maxXp ?? this.maxXp,
      statPoints: statPoints ?? this.statPoints,
      attributes: attributes ?? this.attributes,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastQuestCompletionDate: clearLastQuestCompletionDate
          ? null
          : (lastQuestCompletionDate ?? this.lastQuestCompletionDate),
    );
  }
}
