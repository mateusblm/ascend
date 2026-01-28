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

  Quest({
    this.isarId = Isar.autoIncrement,
    required this.id,
    required this.title,
    required this.rewardAttribute,
    required this.xpReward,
    this.isCompleted = false,
  });

  Quest copyWith({bool? isCompleted}) {
    return Quest(
      isarId: this.isarId,
      id: id,
      title: title,
      rewardAttribute: rewardAttribute,
      xpReward: xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}