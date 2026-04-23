import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/quests/domain/competitive_quest_template.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddQuestModal extends ConsumerStatefulWidget {
  const AddQuestModal({super.key});

  @override
  ConsumerState<AddQuestModal> createState() => _AddQuestModalState();
}

class _AddQuestModalState extends ConsumerState<AddQuestModal> {
  final _controller = TextEditingController();
  AttributeType _selectedAttribute = AttributeType.strength;
  QuestCategory _selectedCategory = QuestCategory.personal;
  CompetitiveQuestTemplate? _selectedTemplate;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final templates = templatesForFocus(player.primaryFocus);
    _selectedTemplate ??= templates.first;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nova quest',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Escolha entre uma quest pessoal para manter o ritmo ou um modelo de arena para progresso competitivo.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ModeChip(
                label: 'Pessoal',
                selected: _selectedCategory == QuestCategory.personal,
                onTap: () => setState(
                  () => _selectedCategory = QuestCategory.personal,
                ),
              ),
              _ModeChip(
                label: 'Competitiva',
                selected: _selectedCategory == QuestCategory.competitive,
                onTap: () => setState(
                  () => _selectedCategory = QuestCategory.competitive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_selectedCategory == QuestCategory.personal)
            _buildPersonalForm()
          else
            _buildCompetitiveForm(templates),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (_selectedCategory == QuestCategory.personal) {
                  if (_controller.text.trim().isEmpty) return;
                  ref.read(questProvider.notifier).addPersonalQuest(
                        _controller.text.trim(),
                        _selectedAttribute,
                        personalQuestDefaultXp,
                      );
                } else {
                  final template = _selectedTemplate;
                  if (template == null) return;
                  final added = ref
                      .read(questProvider.notifier)
                      .addCompetitiveTemplate(template);
                  if (!added) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Voce ja tem uma quest parecida em aberto.',
                        ),
                      ),
                    );
                    return;
                  }
                }
                Navigator.pop(context);
              },
              child: Text(
                _selectedCategory == QuestCategory.personal
                    ? 'Criar quest pessoal'
                    : 'Adicionar quest competitiva',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Nome da quest',
            hintText: 'Ex.: treino de 30 minutos',
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Atributo de recompensa',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Quests pessoais mantem o level e a consistencia, sem contar para o rank.',
          style: TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<AttributeType>(
          value: _selectedAttribute,
          dropdownColor: AppColors.backgroundElevated,
          items: AttributeType.values.map((attr) {
            return DropdownMenuItem(
              value: attr,
              child: Text(attr.name.toUpperCase()),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedAttribute = val!),
          decoration: const InputDecoration(
            labelText: 'Atributo',
          ),
        ),
      ],
    );
  }

  Widget _buildCompetitiveForm(List<CompetitiveQuestTemplate> templates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modelos de arena',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...templates.map(
          (template) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => setState(() => _selectedTemplate = template),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedTemplate == template
                      ? AppColors.neonBlue.withValues(alpha: 0.12)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _selectedTemplate == template
                        ? AppColors.neonBlue.withValues(alpha: 0.30)
                        : AppColors.borderSubtle,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            template.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _selectedTemplate == template
                                  ? AppColors.neonBlue
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          _selectedTemplate == template
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: _selectedTemplate == template
                              ? AppColors.neonBlue
                              : AppColors.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      template.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TemplateChip(
                          label: template.verificationLabel,
                          color: AppColors.neonBlue,
                        ),
                        _TemplateChip(
                          label: '+${template.xpReward} XP',
                          color: AppColors.questAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.neonBlue : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.neonBlue.withValues(alpha: 0.14)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppColors.neonBlue.withValues(alpha: 0.24)
                  : AppColors.borderSubtle,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppColors.neonBlue,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  const _TemplateChip({
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
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
