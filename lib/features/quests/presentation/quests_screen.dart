import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:ascend/features/quests/presentation/widgets/add_quest_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});
  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends ConsumerState<QuestsScreen> {
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final quests = ref.watch(questProvider);
    final filtered = quests
        .where((quest) => quest.isCompleted == _showCompleted)
        .toList();
    final pending = quests.where((quest) => !quest.isCompleted).length;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Tooltip(
        message: 'Nova missao',
        child: FloatingActionButton(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddQuestModal(),
          ),
          backgroundColor: AppColors.questAccent,
          foregroundColor: AppColors.background,
          child: const Icon(Icons.add_rounded),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 118),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TERMINAL DE MISSOES',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'ESCOLHA A PROXIMA ACAO',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.questAccent.withValues(alpha: 0.10),
                    border: Border.all(
                      color: AppColors.questAccent.withValues(alpha: 0.25),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$pending ATIVAS',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.questAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _MissionFilter(
              selectedCompleted: _showCompleted,
              onChanged: (value) => setState(() => _showCompleted = value),
            ),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              _EmptyTerminal(showCompleted: _showCompleted)
            else ...[
              for (final quest in filtered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _QuestRow(quest: quest),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MissionFilter extends StatelessWidget {
  const _MissionFilter({
    required this.selectedCompleted,
    required this.onChanged,
  });
  final bool selectedCompleted;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.surface.withValues(alpha: 0.90),
      border: Border.all(color: AppColors.borderStrong),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Expanded(
          child: _FilterButton(
            label: 'ATIVAS',
            selected: !selectedCompleted,
            onTap: () => onChanged(false),
          ),
        ),
        Expanded(
          child: _FilterButton(
            label: 'CONCLUIDAS',
            selected: selectedCompleted,
            onTap: () => onChanged(true),
          ),
        ),
      ],
    ),
  );
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.questAccent.withValues(alpha: 0.13)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: selected ? AppColors.questAccent : AppColors.textMuted,
          ),
        ),
      ),
    ),
  );
}

class _QuestRow extends ConsumerWidget {
  const _QuestRow({required this.quest});
  final Quest quest;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = _attributeColor(quest.rewardAttribute);
    return Dismissible(
      key: ValueKey(quest.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) =>
          ref.read(questProvider.notifier).deleteQuest(quest.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete_outline_rounded),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 12, 8, 12),
        decoration: BoxDecoration(
          color: quest.isCompleted
              ? AppColors.surfaceMuted.withValues(alpha: 0.68)
              : AppColors.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: quest.isCompleted
                ? AppColors.borderSubtle
                : accent.withValues(alpha: 0.20),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 42,
              color: quest.isCompleted ? AppColors.textMuted : accent,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: quest.isCompleted
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration: quest.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '+${quest.xpReward} XP  |  ${_attributeLabel(quest.rewardAttribute)}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: quest.isCompleted ? AppColors.textMuted : accent,
                    ),
                  ),
                ],
              ),
            ),
            Tooltip(
              message: quest.isCompleted ? 'Reabrir missao' : 'Concluir missao',
              child: IconButton(
                onPressed: () =>
                    ref.read(questProvider.notifier).toggleQuest(quest.id),
                icon: Icon(
                  quest.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                ),
                color: quest.isCompleted
                    ? AppColors.questAccent
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTerminal extends StatelessWidget {
  const _EmptyTerminal({required this.showCompleted});
  final bool showCompleted;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.surface.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.borderStrong),
    ),
    child: Column(
      children: [
        Icon(
          showCompleted ? Icons.inventory_2_outlined : Icons.add_task_rounded,
          size: 32,
          color: AppColors.questAccent,
        ),
        const SizedBox(height: 12),
        Text(
          showCompleted
              ? 'Nenhuma missao concluida ainda.'
              : 'Nenhuma missao ativa.',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        Text(
          showCompleted
              ? 'Suas vitorias aparecerao aqui.'
              : 'Use o botao + para criar sua proxima ordem.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    ),
  );
}

String _attributeLabel(AttributeType attribute) => switch (attribute) {
  AttributeType.strength => 'FORCA',
  AttributeType.intelligence => 'INTELECTO',
  AttributeType.vitality => 'VITALIDADE',
  AttributeType.agility => 'AGILIDADE',
};

Color _attributeColor(AttributeType attribute) => switch (attribute) {
  AttributeType.strength => const Color(0xFFF18B72),
  AttributeType.intelligence => AppColors.neonBlue,
  AttributeType.vitality => AppColors.questAccent,
  AttributeType.agility => const Color(0xFFF0C76C),
};
