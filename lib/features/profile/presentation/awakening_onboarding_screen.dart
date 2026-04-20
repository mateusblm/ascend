import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'COMECO DA JORNADA',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Escolha por onde voce quer comecar. Vamos montar um kit inicial de quests para combinar com o seu momento.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView.separated(
                  itemCount: AwakeningPath.values.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final focus = AwakeningPath.values[index];
                    final selected = focus == _selectedFocus;

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _selectedFocus = focus),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.neonBlue.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? AppColors.neonBlue
                                : Colors.white10,
                            width: selected ? 1.4 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    focus.label,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      color: selected
                                          ? AppColors.neonBlue
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                                Icon(
                                  selected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: selected
                                      ? AppColors.neonBlue
                                      : Colors.white24,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              focus.description,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonBlue,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'COMECAR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.4,
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

  void _completeOnboarding() {
    ref.read(playerProvider.notifier).completeOnboarding(_selectedFocus);
    ref.read(questProvider.notifier).applyStarterKit(_selectedFocus);
  }
}
