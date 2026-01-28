import '../../quests/domain/quest_model.dart';

class Player {
  final String name;
  final int level;
  final int xp;
  final int maxXp;
  final Map<AttributeType, int> attributes;

  Player({
    required this.name,
    required this.level,
    required this.xp,
    required this.maxXp,
    required this.attributes,
  });

  // No Dart/Flutter, como os estados são imutáveis, usamos o copyWith 
  // para criar uma nova instância alterada (similar ao @Builder do Lombok)
  Player copyWith({
    int? level,
    int? xp,
    int? maxXp,
    Map<AttributeType, int>? attributes,
  }) {
    return Player(
      name: name,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      maxXp: maxXp ?? this.maxXp,
      attributes: attributes ?? this.attributes,
    );
  }
}