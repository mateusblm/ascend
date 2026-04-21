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
    final starterKit = starterQuestsForFocus(_selectedFocus);
    final competitiveCount = starterKit.where((quest) => quest.isCompetitive).length;
    final personalCount = starterKit.length - competitiveCount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RevealBlock(child: _OnboardingHero()),
              const SizedBox(height: 20),
              RevealBlock(
                delay: const Duration(milliseconds: 70),
                child: _buildHowItWorksCard(competitiveCount, personalCount),
              ),
              const SizedBox(height: 18),
              RevealBlock(
                delay: const Duration(milliseconds: 130),
                child: _buildFocusSection(),
              ),
              const SizedBox(height: 18),
              RevealBlock(
                delay: const Duration(milliseconds: 190),
                child: _buildStarterKitSection(starterKit),
              ),
              const SizedBox(height: 18),
              RevealBlock(
                delay: const Duration(milliseconds: 250),
                child: _buildNextStepCard(),
              ),
              const SizedBox(height: 24),
              RevealBlock(
                delay: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonBlue,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _completeOnboarding,
                    child: const Text(
                      'MONTAR MINHA PRIMEIRA SEMANA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorksCard(int competitiveCount, int personalCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMO SUA SEMANA COMECA',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Voce escolhe um foco e o app monta um comeco simples para te colocar em movimento sem pesar.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StarterMetric(
                  label: 'PARA O RANK',
                  value: '$competitiveCount quest(s)',
                  accent: AppColors.neonBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StarterMetric(
                  label: 'PARA O LEVEL',
                  value: '$personalCount quest(s)',
                  accent: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFocusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ESCOLHA SEU FOCO',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Isso define por onde sua primeira semana comeca. Depois voce pode mudar.',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        ...AwakeningPath.values.map((focus) {
          final selected = focus == _selectedFocus;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => setState(() => _selectedFocus = focus),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.neonBlue.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected ? AppColors.neonBlue : Colors.white10,
                    width: selected ? 1.4 : 1,
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
                            focus.label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: selected ? AppColors.neonBlue : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            focus.description,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12.5,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected ? AppColors.neonBlue : Colors.white24,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStarterKitSection(List<Quest> starterKit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.neonBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonBlue.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KIT INICIAL: ${_selectedFocus.label}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Voce vai comecar com um kit curto: duas quests para subir seu ritmo no rank e uma para fortalecer seu dia.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
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

  Widget _buildNextStepCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'O QUE ACONTECE DEPOIS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '1. Voce recebe seu kit inicial.',
            style: TextStyle(color: Colors.white70, fontSize: 12.5),
          ),
          SizedBox(height: 6),
          Text(
            '2. As quests de rank comecam a abrir sua subida.',
            style: TextStyle(color: Colors.white70, fontSize: 12.5),
          ),
          SizedBox(height: 6),
          Text(
            '3. As quests pessoais continuam fortalecendo seu level e seu ritmo da semana.',
            style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.45),
          ),
        ],
      ),
    );
  }

  void _completeOnboarding() {
    ref.read(playerProvider.notifier).completeOnboarding(_selectedFocus);
    ref.read(questProvider.notifier).applyStarterKit(_selectedFocus);
  }
}

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'COMECO DA JORNADA',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Vamos montar sua primeira semana de um jeito simples: escolher foco, receber um kit inicial e comecar sem precisar entender tudo de uma vez.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white60,
            height: 1.5,
          ),
        ),
      ],
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
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white54,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: accent,
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
    final accent = quest.isCompetitive ? AppColors.neonBlue : Colors.white70;
    final verification = switch (quest.verificationMode) {
      QuestVerificationMode.manual => 'Livre',
      QuestVerificationMode.timer => '${quest.targetDurationMinutes} min',
      QuestVerificationMode.timerWithReflection =>
        '${quest.targetDurationMinutes} min + resposta',
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuestPill(
                label: quest.isCompetitive ? 'COMPETITIVA' : 'PESSOAL',
                color: accent,
              ),
              _QuestPill(
                label: verification,
                color: Colors.amberAccent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            quest.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            quest.isCompetitive
                ? 'Ajuda no seu rank e no desafio da semana.'
                : 'Ajuda no seu level e no ritmo do dia.',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestPill extends StatelessWidget {
  const _QuestPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
