import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/core/theme/ascend_design_tokens.dart';
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
    final categoryAccent = quest.isCompetitive
        ? AppColors.arenaAccent
        : AppColors.questAccent;
    final accent = quest.isCompleted
        ? Color.lerp(categoryAccent, Colors.white, 0.12) ?? categoryAccent
        : categoryAccent;
    final surfaceBase = quest.isCompleted
        ? AppColors.surfaceMuted
        : AppColors.surfaceStrong;
    final surfaceGlow = quest.isCompleted
        ? Colors.white.withValues(alpha: 0.015)
        : accent.withValues(alpha: 0.06);
    final missionLabel = quest.isCompetitive
        ? 'CONTRATO DE ARENA'
        : 'MISSÃO DE BASE';
    final primaryLabel =
        primaryActionLabel ?? (quest.isCompleted ? 'Arquivada' : 'Concluir');

    return AnimatedContainer(
      key: ValueKey('quest-card-${quest.id}'),
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [surfaceGlow, surfaceBase, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent.withValues(alpha: quest.isCompleted ? 0.24 : 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: accent.withValues(alpha: quest.isCompleted ? 0.06 : 0.12),
            blurRadius: 18,
            spreadRadius: -8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(left: 0, top: 0, bottom: 0, child: _MissionRail(accent)),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 74,
              height: 1,
              color: accent.withValues(alpha: 0.46),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                                label: missionLabel,
                                color: accent,
                                icon: quest.isCompetitive
                                    ? Icons.shield_rounded
                                    : Icons.track_changes_rounded,
                              ),
                              _QuestChip(
                                label: _verificationLabel(quest),
                                color: AppColors.textSecondary,
                                icon: Icons.verified_user_outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            quest.title,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              color: AppColors.textPrimary,
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
                      attribute: _attributeLabel(quest.rewardAttribute),
                      accent: accent,
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
                      child: FilledButton.icon(
                        key: ValueKey('quest-card-primary-${quest.id}'),
                        onPressed: primaryActionEnabled
                            ? onPrimaryAction
                            : null,
                        icon: Icon(
                          quest.isCompleted
                              ? Icons.inventory_2_rounded
                              : quest.isCompetitive
                              ? Icons.play_arrow_rounded
                              : Icons.done_rounded,
                          size: 18,
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(42),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          backgroundColor: accent.withValues(alpha: 0.16),
                          foregroundColor: accent,
                          disabledBackgroundColor: Colors.white.withValues(
                            alpha: 0.05,
                          ),
                          disabledForegroundColor: Colors.white38,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        label: Text(
                          primaryLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (secondaryActionLabel != null &&
                        onSecondaryAction != null) ...[
                      const SizedBox(width: 10),
                      TextButton(
                        key: ValueKey('quest-card-secondary-${quest.id}'),
                        onPressed: onSecondaryAction,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(secondaryActionLabel!),
                      ),
                    ],
                  ],
                ),
              ],
            ),
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

  String _attributeLabel(AttributeType attribute) {
    return switch (attribute) {
      AttributeType.strength => 'Força',
      AttributeType.intelligence => 'Inteligência',
      AttributeType.vitality => 'Vitalidade',
      AttributeType.agility => 'Agilidade',
    };
  }
}

class _QuestChip extends StatelessWidget {
  const _QuestChip({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionRail extends StatelessWidget {
  const _MissionRail(this.accent);

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accent, accent.withValues(alpha: 0.28), Colors.transparent],
        ),
      ),
    );
  }
}

class _RewardPill extends StatelessWidget {
  const _RewardPill({
    required this.xpReward,
    required this.attribute,
    required this.accent,
  });

  final int xpReward;
  final String attribute;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AscendDesignTokens.radiusControl),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '+$xpReward XP',
            style: TextStyle(
              color: accent,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            attribute,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
