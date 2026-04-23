import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/core/widgets/reveal_block.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FocusSelectionSheet extends ConsumerStatefulWidget {
  const FocusSelectionSheet({super.key, required this.currentFocus});

  final AwakeningPath currentFocus;

  @override
  ConsumerState<FocusSelectionSheet> createState() =>
      _FocusSelectionSheetState();
}

class _FocusSelectionSheetState extends ConsumerState<FocusSelectionSheet> {
  late AwakeningPath _selectedFocus = widget.currentFocus;

  @override
  Widget build(BuildContext context) {
    final preview = starterQuestsForFocus(_selectedFocus);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RevealBlock(
              child: Text('Alterar foco', style: textTheme.headlineMedium),
            ),
            const SizedBox(height: 8),
            RevealBlock(
              delay: const Duration(milliseconds: 70),
              child: Text(
                'Isso muda sua direcao daqui para frente. O que ja esta na sua lista continua igual.',
                style: textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 18),
            ...AwakeningPath.values.map((focus) {
              final isSelected = focus == _selectedFocus;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => setState(() => _selectedFocus = focus),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            isSelected
                                ? AppColors.planAccent.withValues(alpha: 0.10)
                                : AppColors.surface.withValues(alpha: 0.96),
                            AppColors.surfaceStrong.withValues(alpha: 0.78),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.planAccent.withValues(alpha: 0.22)
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
                                    color: isSelected
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
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: isSelected
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
            const SizedBox(height: 8),
            RevealBlock(
              delay: const Duration(milliseconds: 120),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceStrong.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderStrong),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preview rapido', style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Se voce usar ${_displayFocusLabel(_selectedFocus)}, estas quests entram no kit inicial:',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    ...preview
                        .take(2)
                        .map(
                          (quest) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '• ${quest.title}',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _applyFocusChange,
                child: const Text('Usar esse foco'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFocusChange() {
    ref.read(playerProvider.notifier).updatePrimaryFocus(_selectedFocus);
    Navigator.of(context).pop();
  }
}

String _displayFocusLabel(AwakeningPath focus) {
  final raw = focus.label.toLowerCase();
  return '${raw[0].toUpperCase()}${raw.substring(1)}';
}
