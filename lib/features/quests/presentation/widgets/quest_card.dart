import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter/material.dart';

class QuestCard extends StatelessWidget {
  const QuestCard({
    super.key,
    required this.quest,
    required this.onPrimaryAction,
    this.primaryActionLabel,
    this.primaryActionEnabled = true,
    this.onSecondaryAction,
    this.secondaryActionLabel,
    this.helperText,
  });

  final Quest quest;
  final VoidCallback onPrimaryAction;
  final String? primaryActionLabel;
  final bool primaryActionEnabled;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionLabel;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final accent = quest.isCompetitive ? AppColors.neonBlue : Colors.white70;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: quest.isCompleted
            ? Colors.green.withValues(alpha: 0.10)
            : AppColors.surface,
        border: Border.all(
          color: quest.isCompleted
              ? Colors.greenAccent
              : accent.withValues(alpha: 0.45),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        decoration: quest.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _QuestChip(
                          label: quest.isCompetitive ? 'COMPETITIVA' : 'PESSOAL',
                          color: quest.isCompetitive
                              ? AppColors.neonBlue
                              : Colors.white70,
                        ),
                        _QuestChip(
                          label: _verificationLabel(quest),
                          color: Colors.amberAccent,
                        ),
                        _QuestChip(
                          label:
                              '+${quest.xpReward} XP | ${quest.rewardAttribute.name.toUpperCase()}',
                          color: Colors.greenAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (helperText != null) ...[
            const SizedBox(height: 10),
            Text(
              helperText!,
              style: const TextStyle(
                fontSize: 11.5,
                color: Colors.white60,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton(
                onPressed: primaryActionEnabled ? onPrimaryAction : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: quest.isCompleted
                      ? Colors.greenAccent
                      : AppColors.neonBlue,
                  side: BorderSide(
                    color: (quest.isCompleted
                            ? Colors.greenAccent
                            : AppColors.neonBlue)
                        .withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  primaryActionLabel ??
                      (quest.isCompleted ? 'CONCLUIDA' : 'MARCAR'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (secondaryActionLabel != null && onSecondaryAction != null) ...[
                const SizedBox(width: 10),
                TextButton(
                  onPressed: onSecondaryAction,
                  child: Text(
                    secondaryActionLabel!,
                    style: const TextStyle(color: Colors.white60),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _verificationLabel(Quest quest) {
    return switch (quest.verificationMode) {
      QuestVerificationMode.manual => 'CHECK',
      QuestVerificationMode.timer =>
        '${quest.targetDurationMinutes} MIN',
      QuestVerificationMode.timerWithReflection =>
        '${quest.targetDurationMinutes} MIN + RESPOSTA',
    };
  }
}

class _QuestChip extends StatelessWidget {
  const _QuestChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
