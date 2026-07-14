import 'package:ascend/core/navigation/navigation_provider.dart';
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
    final firstRecommendedQuest = starterKit.first;
    final personalCount = starterKit.length;

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
                        personalCount: personalCount,
                        firstActionTitle: firstRecommendedQuest.title,
                      ),
                    ),
                    const SizedBox(height: 18),
                    RevealBlock(
                      delay: const Duration(milliseconds: 80),
                      child: _FocusSection(
                        key: const ValueKey('onboarding-focus-section'),
                        selectedFocus: _selectedFocus,
                        onSelect: (focus) =>
                            setState(() => _selectedFocus = focus),
                      ),
                    ),
                    const SizedBox(height: 18),
                    RevealBlock(
                      delay: const Duration(milliseconds: 150),
                      child: _StarterKitPanel(
                        key: const ValueKey('onboarding-starter-kit'),
                        focusLabel: _displayFocusLabel(_selectedFocus),
                        starterKit: starterKit,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RevealBlock(
                      delay: const Duration(milliseconds: 200),
                      child: _FirstRecommendedActionPanel(
                        key: const ValueKey('onboarding-first-action'),
                        quest: firstRecommendedQuest,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RevealBlock(
                      delay: const Duration(milliseconds: 260),
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
                              'Ao confirmar, voce entra direto em Quests com seu kit pronto. A ideia e fechar a primeira quest de Base antes de mexer no resto.',
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
                      label: 'Kit',
                      value: '$personalCount quests',
                      accent: AppColors.questAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const ValueKey('onboarding-primary-cta'),
                    onPressed: _completeOnboarding,
                    child: const Text('Entrar em Quests com esse kit'),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Voce pode trocar esse foco depois sem perder o que ja iniciou.',
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
    ref.read(navigationProvider.notifier).state = 1;
  }
}

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero({
    required this.focusLabel,
    required this.personalCount,
    required this.firstActionTitle,
  });

  final String focusLabel;
  final int personalCount;
  final String firstActionTitle;

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
            'Voce escolhe a direcao e o app monta um kit curto para ja entrar em movimento. O primeiro passo recomendado sai pronto: $firstActionTitle.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroPill(label: focusLabel, accent: AppColors.planAccent),
              _HeroPill(
                label: '$personalCount quests iniciais',
                accent: AppColors.questAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FirstRecommendedActionPanel extends StatelessWidget {
  const _FirstRecommendedActionPanel({super.key, required this.quest});

  final Quest quest;

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
            AppColors.questAccent.withValues(alpha: 0.12),
            AppColors.surface.withValues(alpha: 0.98),
            AppColors.surfaceStrong.withValues(alpha: 0.84),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.questAccent.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Primeiro passo recomendado',
            style: textTheme.titleLarge?.copyWith(color: AppColors.questAccent),
          ),
          const SizedBox(height: 8),
          Text(
            quest.title,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comece pequeno. Fechar uma quest pessoal primeiro reduz friccao, marca seu ritmo inicial e ja mostra seu personagem evoluindo.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroPill(label: 'Base primeiro', accent: AppColors.questAccent),
              _HeroPill(
                label: '${quest.xpReward} XP',
                accent: AppColors.planAccent,
              ),
              _HeroPill(
                label: _attributeLabel(quest.rewardAttribute),
                accent: AppColors.neonBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusSection extends StatelessWidget {
  const _FocusSection({
    super.key,
    required this.selectedFocus,
    required this.onSelect,
  });

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
                key: ValueKey('onboarding-focus-${focus.name}'),
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
  const _StarterKitPanel({
    super.key,
    required this.focusLabel,
    required this.starterKit,
  });

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
            '$focusLabel entra com um kit curto de quests casuais para gerar o primeiro ganho ainda hoje.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ...starterKit.map(
            (quest) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _StarterQuestTile(
                key: ValueKey('onboarding-starter-quest-${quest.id}'),
                quest: quest,
              ),
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
  const _StarterQuestTile({super.key, required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.questAccent;
    const tag = 'Base';
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
