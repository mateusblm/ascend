import 'package:isar/isar.dart';

part 'quest_model.g.dart';

enum AttributeType { strength, intelligence, vitality, agility }

@Collection()
class Quest {
  Id isarId = Isar.autoIncrement; // Primary Key

  final String id; // Seu ID de string (ex: '1', '2')
  final String title;
  
  @enumerated
  final AttributeType rewardAttribute;
  
  final int xpReward;
  final bool isCompleted;

  // Snapshot do estado do jogador antes da recompensa ser aplicada.
  // Usado para reverter completamente ao desfazer uma quest.
  final int? preRewardLevel;
  final int? preRewardXp;
  final int? preRewardMaxXp;
  final int? preRewardStatPoints;
  final int? preRewardStrength;
  final int? preRewardIntelligence;
  final int? preRewardVitality;
  final int? preRewardAgility;

  Quest({
    this.isarId = Isar.autoIncrement,
    required this.id,
    required this.title,
    required this.rewardAttribute,
    required this.xpReward,
    this.isCompleted = false,
    this.preRewardLevel,
    this.preRewardXp,
    this.preRewardMaxXp,
    this.preRewardStatPoints,
    this.preRewardStrength,
    this.preRewardIntelligence,
    this.preRewardVitality,
    this.preRewardAgility,
  });

  /// Indica se esta quest possui um snapshot pré-recompensa válido.
  bool get hasPreRewardSnapshot => preRewardLevel != null;

  Quest copyWith({
    bool? isCompleted,
    int? preRewardLevel,
    int? preRewardXp,
    int? preRewardMaxXp,
    int? preRewardStatPoints,
    int? preRewardStrength,
    int? preRewardIntelligence,
    int? preRewardVitality,
    int? preRewardAgility,
    bool clearPreRewardSnapshot = false,
  }) {
    return Quest(
      isarId: isarId,
      id: id,
      title: title,
      rewardAttribute: rewardAttribute,
      xpReward: xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
      preRewardLevel: clearPreRewardSnapshot ? null : (preRewardLevel ?? this.preRewardLevel),
      preRewardXp: clearPreRewardSnapshot ? null : (preRewardXp ?? this.preRewardXp),
      preRewardMaxXp: clearPreRewardSnapshot ? null : (preRewardMaxXp ?? this.preRewardMaxXp),
      preRewardStatPoints: clearPreRewardSnapshot ? null : (preRewardStatPoints ?? this.preRewardStatPoints),
      preRewardStrength: clearPreRewardSnapshot ? null : (preRewardStrength ?? this.preRewardStrength),
      preRewardIntelligence: clearPreRewardSnapshot ? null : (preRewardIntelligence ?? this.preRewardIntelligence),
      preRewardVitality: clearPreRewardSnapshot ? null : (preRewardVitality ?? this.preRewardVitality),
      preRewardAgility: clearPreRewardSnapshot ? null : (preRewardAgility ?? this.preRewardAgility),
    );
  }
}