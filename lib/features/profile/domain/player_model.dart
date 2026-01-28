import 'package:isar/isar.dart';
import '../../quests/domain/quest_model.dart';

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
  final int statPoints; // Campo que causou o erro
  final PlayerAttributes attributes;
  final DateTime lastResetDate;

  Player({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.level,
    required this.xp,
    required this.maxXp,
    this.statPoints = 0, // Valor default para novos registros
    required this.attributes,
    required this.lastResetDate,
  });

  Player copyWith({
    int? level,
    int? xp,
    int? maxXp,
    int? statPoints,
    PlayerAttributes? attributes,
    DateTime? lastResetDate,
  }) {
    return Player(
      id: this.id,
      name: this.name,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      maxXp: maxXp ?? this.maxXp,
      statPoints: statPoints ?? this.statPoints,
      attributes: attributes ?? this.attributes,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }
}