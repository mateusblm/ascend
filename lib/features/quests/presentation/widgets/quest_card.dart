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
    final accent = quest.isCompleted
        ? AppColors.questAccent
        : quest.isCompetitive
        ? AppColors.neonBlue
        : AppColors.questAccent;
    final badgeColor = quest.isCompetitive
        ? AppColors.neonBlue
        : AppColors.questAccent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: quest.isCompleted
              ? AppColors.questAccent.withValues(alpha: 0.24)
              : AppColors.borderSubtle,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _QuestChip(
                          label: quest.isCompetitive ? 'Arena' : 'Base',
                          color: badgeColor,
                        ),
                        _QuestChip(
                          label: _verificationLabel(quest),
                          color: AppColors.arenaAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      quest.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        decoration: quest.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _RewardPill(
                xpReward: quest.xpReward,
                attribute: quest.rewardAttribute.name.toUpperCase(),
              ),
            ],
          ),
          if (helperText != null) ...[
            const SizedBox(height: 10),
            Text(
              helperText!,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: primaryActionEnabled ? onPrimaryAction : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent.withValues(alpha: 0.16),
                    foregroundColor: accent,
                    disabledBackgroundColor: Colors.white.withValues(
                      alpha: 0.05,
                    ),
                    disabledForegroundColor: Colors.white38,
                  ),
                  child: Text(
                    primaryActionLabel ??
                        (quest.isCompleted ? 'Concluida' : 'Marcar'),
                  ),
                ),
              ),
              if (secondaryActionLabel != null && onSecondaryAction != null) ...[
                const SizedBox(width: 10),
                TextButton(
                  onPressed: onSecondaryAction,
                  child: Text(secondaryActionLabel!),
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
      QuestVerificationMode.manual => 'Check simples',
      QuestVerificationMode.timer => '${quest.targetDurationMinutes} min',
      QuestVerificationMode.timerWithReflection =>
        '${quest.targetDurationMinutes} min + resposta',
    };
  }
}

class _QuestChip extends StatelessWidget {
  const _QuestChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RewardPill extends StatelessWidget {
  const _RewardPill({
    required this.xpReward,
    required this.attribute,
  });

  final int xpReward;
  final String attribute;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '+$xpReward XP',
            style: const TextStyle(
              color: AppColors.questAccent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            attribute,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
