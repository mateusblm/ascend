import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/core/widgets/reveal_block.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AwakeningOnboardingScreen extends ConsumerStatefulWidget {
  const AwakeningOnboardingScreen({super.key});

  @override
  ConsumerState<AwakeningOnboardingScreen> createState() =>
      _AwakeningOnboardingScreenState();
}

class _AwakeningOnboardingScreenState
    extends ConsumerState<AwakeningOnboardingScreen> {
  AwakeningPath _selectedFocus = AwakeningPath.discipline;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final starterKit = starterQuestsForFocus(_selectedFocus);
    final competitiveCount = starterKit
        .where((quest) => quest.isCompetitive)
        .length;
    final personalCount = starterKit.length - competitiveCount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.backgroundElevated,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    RevealBlock(
                      child: _OnboardingHero(
                        focusLabel: _displayFocusLabel(_selectedFocus),
                        competitiveCount: competitiveCount,
                        personalCount: personalCount,
                      ),
                    ),
                    const SizedBox(height: 18),
                    RevealBlock(
                      delay: const Duration(milliseconds: 80),
                      child: _FocusSection(
                        selectedFocus: _selectedFocus,
                        onSelect: (focus) =>
                            setState(() => _selectedFocus = focus),
                      ),
                    ),
                    const SizedBox(height: 18),
                    RevealBlock(
                      delay: const Duration(milliseconds: 150),
                      child: _StarterKitPanel(
                        focusLabel: _displayFocusLabel(_selectedFocus),
                        starterKit: starterKit,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RevealBlock(
                      delay: const Duration(milliseconds: 220),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceStrong.withValues(
                            alpha: 0.76,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.borderStrong),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Depois disso', style: textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                              'Voce entra direto em Quests com seu kit pronto. Depois pode ajustar foco, criar quests novas e explorar o app com calma.',
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceStrong.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.borderStrong),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StarterMetric(
                      label: 'Foco',
                      value: _displayFocusLabel(_selectedFocus),
                      accent: AppColors.planAccent,
                    ),
                    _StarterMetric(
                      label: 'Arena',
                      value: '$competitiveCount quest(s)',
                      accent: AppColors.arenaAccent,
                    ),
                    _StarterMetric(
                      label: 'Base',
                      value: '$personalCount quest(s)',
                      accent: AppColors.questAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _completeOnboarding,
                    child: const Text('Montar minha primeira semana'),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Voce pode trocar esse foco depois.',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _completeOnboarding() {
    ref.read(playerProvider.notifier).completeOnboarding(_selectedFocus);
    ref.read(questProvider.notifier).applyStarterKit(_selectedFocus);
  }
}

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero({
    required this.focusLabel,
    required this.competitiveCount,
    required this.personalCount,
  });

  final String focusLabel;
  final int competitiveCount;
  final int personalCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.planAccent.withValues(alpha: 0.10),
            AppColors.surface.withValues(alpha: 0.96),
            AppColors.surfaceMuted.withValues(alpha: 0.98),
          ],
        ),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Primeira semana',
            style: textTheme.labelMedium?.copyWith(color: AppColors.planAccent),
          ),
          const SizedBox(height: 10),
          Text(
            'Escolha o foco do seu inicio',
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 30,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Voce escolhe a direcao e o app monta um kit curto para ja entrar em movimento.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroPill(label: focusLabel, accent: AppColors.planAccent),
              _HeroPill(
                label: '$competitiveCount para Arena',
                accent: AppColors.arenaAccent,
              ),
              _HeroPill(
                label: '$personalCount para Base',
                accent: AppColors.questAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusSection extends StatelessWidget {
  const _FocusSection({required this.selectedFocus, required this.onSelect});

  final AwakeningPath selectedFocus;
  final ValueChanged<AwakeningPath> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Escolha seu foco', style: textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          'Isso define o kit inicial. Depois voce pode ajustar com calma.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        ...AwakeningPath.values.map((focus) {
          final selected = focus == selectedFocus;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => onSelect(focus),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        selected
                            ? AppColors.planAccent.withValues(alpha: 0.10)
                            : AppColors.surface.withValues(alpha: 0.96),
                        AppColors.surfaceStrong.withValues(alpha: 0.78),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: selected
                          ? AppColors.planAccent.withValues(alpha: 0.24)
                          : AppColors.borderStrong,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _displayFocusLabel(focus),
                              style: textTheme.titleMedium?.copyWith(
                                color: selected
                                    ? AppColors.planAccent
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              focus.description,
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: selected
                            ? AppColors.planAccent
                            : AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _StarterKitPanel extends StatelessWidget {
  const _StarterKitPanel({required this.focusLabel, required this.starterKit});

  final String focusLabel;
  final List<Quest> starterKit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.questAccent.withValues(alpha: 0.08),
            AppColors.surface.withValues(alpha: 0.96),
            AppColors.surfaceStrong.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Seu kit inicial', style: textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            '$focusLabel entra com um kit curto: duas quests para abrir pressao competitiva e uma para sustentar a base.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ...starterKit.map(
            (quest) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _StarterQuestTile(quest: quest),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarterMetric extends StatelessWidget {
  const _StarterMetric({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StarterQuestTile extends StatelessWidget {
  const _StarterQuestTile({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context) {
    final accent = quest.isCompetitive
        ? AppColors.arenaAccent
        : AppColors.questAccent;
    final tag = quest.isCompetitive ? 'Arena' : 'Base';
    final verification = switch (quest.verificationMode) {
      QuestVerificationMode.manual => 'Livre',
      QuestVerificationMode.timer => '${quest.targetDurationMinutes} min',
      QuestVerificationMode.timerWithReflection =>
        '${quest.targetDurationMinutes} min + resposta',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroPill(label: tag, accent: accent),
              _HeroPill(label: verification, accent: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            quest.title,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${quest.xpReward} XP • ${_attributeLabel(quest.rewardAttribute)}',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _displayFocusLabel(AwakeningPath focus) {
  final raw = focus.label.toLowerCase();
  return '${raw[0].toUpperCase()}${raw.substring(1)}';
}

String _attributeLabel(AttributeType attribute) {
  return switch (attribute) {
    AttributeType.strength => 'Forca',
    AttributeType.intelligence => 'Inteligencia',
    AttributeType.vitality => 'Vitalidade',
    AttributeType.agility => 'Agilidade',
  };
}
