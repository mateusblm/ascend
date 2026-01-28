enum AttributeType { strength, intelligence, vitality, agility }

class Quest {
  final String id;
  final String title;
  final AttributeType rewardAttribute;
  final int xpReward;
  bool isCompleted;

  Quest({
    required this.id,
    required this.title,
    required this.rewardAttribute,
    required this.xpReward,
    this.isCompleted = false,
  });
}