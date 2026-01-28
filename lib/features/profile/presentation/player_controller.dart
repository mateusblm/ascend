import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/player_model.dart';
import '../../quests/domain/quest_model.dart';

final playerProvider = StateNotifierProvider<PlayerNotifier, Player>((ref) {
  return PlayerNotifier();
});

class PlayerNotifier extends StateNotifier<Player> {
  PlayerNotifier()
      : super(Player(
          name: "MATEUS",
          level: 1,
          xp: 0,
          maxXp: 100,
          attributes: {
            AttributeType.strength: 10,
            AttributeType.intelligence: 10,
            AttributeType.vitality: 10,
            AttributeType.agility: 10,
          },
        ));

  void addReward(int xpReward, AttributeType attribute) {
    int newXp = state.xp + xpReward;
    int newLevel = state.level;
    int newMaxXp = state.maxXp;

    // Lógica de Level Up
    while (newXp >= newMaxXp) {
      newLevel++;
      newXp -= newMaxXp;
      newMaxXp = (newMaxXp * 1.2).toInt(); // Escalonamento de dificuldade
    }

    final updatedAttributes = Map<AttributeType, int>.from(state.attributes);
    updatedAttributes[attribute] = (updatedAttributes[attribute] ?? 0) + 1;

    state = state.copyWith(
      level: newLevel,
      xp: newXp,
      maxXp: newMaxXp,
      attributes: updatedAttributes,
    );
  }

  void removeReward(int xpReward, AttributeType attribute) {
    int newXp = state.xp - xpReward;
    if (newXp < 0) newXp = 0;

    final updatedAttributes = Map<AttributeType, int>.from(state.attributes);
    if ((updatedAttributes[attribute] ?? 0) > 0) {
      updatedAttributes[attribute] = updatedAttributes[attribute]! - 1;
    }

    state = state.copyWith(
      xp: newXp,
      attributes: updatedAttributes,
    );
  }
}