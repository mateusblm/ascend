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
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final templates = templatesForFocus(player.primaryFocus);
    _selectedTemplate ??= templates.first;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
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
            'NOVA QUEST',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quests competitivas contam para rank e boss. Quests pessoais ajudam no seu progresso geral com XP mais leve.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white60,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ModeChip(
                label: 'PESSOAL',
                selected: _selectedCategory == QuestCategory.personal,
                onTap: () => setState(
                  () => _selectedCategory = QuestCategory.personal,
                ),
              ),
              _ModeChip(
                label: 'COMPETITIVA',
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
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonBlue,
              ),
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
                          'Voce ja tem uma quest competitiva desse tipo em aberto.',
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
                    ? 'CRIAR QUEST PESSOAL'
                    : 'ADICIONAR QUEST COMPETITIVA',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
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
            labelStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.neonBlue),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'ATRIBUTO DE RECOMPENSA',
          style: TextStyle(fontSize: 12, color: Colors.white38),
        ),
        const SizedBox(height: 8),
        const Text(
          'Quest pessoal: XP leve para progresso geral. O competitivo rende mais.',
          style: TextStyle(fontSize: 11.5, color: Colors.white54, height: 1.4),
        ),
        DropdownButton<AttributeType>(
          value: _selectedAttribute,
          isExpanded: true,
          dropdownColor: AppColors.background,
          items: AttributeType.values.map((attr) {
            return DropdownMenuItem(
              value: attr,
              child: Text(
                attr.name.toUpperCase(),
                style: const TextStyle(color: AppColors.neonBlue),
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedAttribute = val!),
        ),
      ],
    );
  }

  Widget _buildCompetitiveForm(List<CompetitiveQuestTemplate> templates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ESCOLHA UM MODELO OFICIAL',
          style: TextStyle(fontSize: 12, color: Colors.white38),
        ),
        const SizedBox(height: 12),
        ...templates.map(
          (template) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _selectedTemplate = template),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _selectedTemplate == template
                      ? AppColors.neonBlue.withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedTemplate == template
                        ? AppColors.neonBlue
                        : Colors.white10,
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
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _selectedTemplate == template
                                  ? AppColors.neonBlue
                                  : Colors.white,
                            ),
                          ),
                        ),
                        Icon(
                          _selectedTemplate == template
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: _selectedTemplate == template
                              ? AppColors.neonBlue
                              : Colors.white24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      template.description,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TemplateChip(
                          label: template.verificationLabel,
                          color: AppColors.neonBlue,
                        ),
                        _TemplateChip(
                          label:
                              '+${template.xpReward} XP | ${template.rewardAttribute.name.toUpperCase()}',
                          color: Colors.greenAccent,
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
    final borderColor = selected ? AppColors.neonBlue : Colors.white10;
    final backgroundColor = selected
        ? AppColors.neonBlue.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.04);
    final foregroundColor = selected ? AppColors.neonBlue : Colors.white70;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.neonBlue.withValues(alpha: 0.12),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: selected ? 18 : 14,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  Icon(
                    Icons.check,
                    size: 14,
                    color: foregroundColor,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  const _TemplateChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
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
