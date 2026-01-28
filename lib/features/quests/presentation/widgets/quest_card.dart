import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback onToggle;

  const QuestCard({super.key, required this.quest, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: quest.isCompleted ? Colors.green.withOpacity(0.1) : AppColors.surface,
        border: Border.all(
          color: quest.isCompleted ? Colors.green : AppColors.neonBlue.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Checkbox(
            value: quest.isCompleted,
            onChanged: (_) => onToggle(),
            activeColor: Colors.green,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: TextStyle(
                    fontSize: 16,
                    decoration: quest.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  "+${quest.xpReward} XP | RECOMPENSA: ${quest.rewardAttribute.name.toUpperCase()}",
                  style: const TextStyle(fontSize: 10, color: AppColors.neonBlue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}