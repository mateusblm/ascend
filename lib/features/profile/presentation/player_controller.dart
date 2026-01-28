import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../main.dart'; 
import '../domain/player_model.dart';
import '../../quests/domain/quest_model.dart';

final playerProvider = StateNotifierProvider<PlayerNotifier, Player>((ref) {
  final savedPlayer = isar.players.where().findFirstSync();
  
  return PlayerNotifier(savedPlayer ?? Player(
    name: "MATEUS",
    level: 1,
    xp: 0,
    maxXp: 100,
    statPoints: 0, // Inicializa com 0 pontos para distribuir
    attributes: PlayerAttributes(),
    lastResetDate: DateTime.now(),
  ));
});

class PlayerNotifier extends StateNotifier<Player> {
  PlayerNotifier(super.state);

  void _saveToDb() {
    isar.writeTxnSync(() {
      isar.players.putSync(state);
    });
  }

  /// ADICIONA RECOMPENSA (CORRIGIDO)
 void addReward(int xpReward, AttributeType attribute, {Function(int)? onLevelUp}) {
  int oldLevel = state.level;
  int currentXp = state.xp + xpReward;
  int currentLevel = state.level;
  int currentMaxXp = state.maxXp;
  int currentStatPoints = state.statPoints;

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
    // Pequeno delay de 300ms para a animação da lista de quests terminar
    Future.delayed(const Duration(milliseconds: 300), () {
      onLevelUp(currentLevel);
    });
  }
}

  /// REMOVE RECOMPENSA (CORRIGIDO)
  void removeReward(int xpReward, AttributeType attribute) {
    // Garante que o XP não fique negativo
    int newXp = (state.xp - xpReward).clamp(0, state.maxXp);

    // Decrementa atributo respeitando o limite base de 10
    final newAttrs = PlayerAttributes(
      strength: (state.attributes.strength - (attribute == AttributeType.strength ? 1 : 0)).clamp(10, 999),
      intelligence: (state.attributes.intelligence - (attribute == AttributeType.intelligence ? 1 : 0)).clamp(10, 999),
      vitality: (state.attributes.vitality - (attribute == AttributeType.vitality ? 1 : 0)).clamp(10, 999),
      agility: (state.attributes.agility - (attribute == AttributeType.agility ? 1 : 0)).clamp(10, 999),
    );

    state = state.copyWith(
      xp: newXp,
      attributes: newAttrs,
    );

    _saveToDb();
  }

  /// DISTRIBUIÇÃO MANUAL DE PONTOS
  void upgradeAttribute(AttributeType type) {
    if (state.statPoints > 0) {
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
  }

  void debugResetPlayer() {
    state = Player(
      name: "MATEUS",
      level: 1,
      xp: 0,
      maxXp: 100,
      statPoints: 0,
      attributes: PlayerAttributes(),
      lastResetDate: DateTime.now(),
    );
    _saveToDb();
  }
}