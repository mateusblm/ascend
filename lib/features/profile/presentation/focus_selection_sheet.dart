import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FocusSelectionSheet extends ConsumerStatefulWidget {
  const FocusSelectionSheet({
    super.key,
    required this.currentFocus,
  });

  final AwakeningPath currentFocus;

  @override
  ConsumerState<FocusSelectionSheet> createState() => _FocusSelectionSheetState();
}

class _FocusSelectionSheetState extends ConsumerState<FocusSelectionSheet> {
  late AwakeningPath _selectedFocus = widget.currentFocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ALTERAR FOCO',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          const Text(
            'Isso muda apenas a sua direcao principal. As quests atuais continuam como estao.',
            style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 20),
          ...AwakeningPath.values.map((focus) {
            final isSelected = focus == _selectedFocus;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _selectedFocus = focus),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.neonBlue.withOpacity(0.1) : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.neonBlue : Colors.white10,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              focus.label,
                              style: TextStyle(
                                color: isSelected ? AppColors.neonBlue : Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              focus.description,
                              style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? AppColors.neonBlue : Colors.white24,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonBlue,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _applyFocusChange,
              child: const Text(
                'CONFIRMAR FOCO',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _applyFocusChange() {
    ref.read(playerProvider.notifier).updatePrimaryFocus(_selectedFocus);
    Navigator.of(context).pop();
  }
}
