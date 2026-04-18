import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:ascend/features/quests/presentation/widgets/add_quest_modal.dart';
import 'package:ascend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/quest_card.dart';

class QuestsScreen extends ConsumerWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(questProvider);
    final activeQuests = quests.where((q) => !q.isCompleted).toList();
    final completedQuests = quests.where((q) => q.isCompleted).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "DAILY QUESTS", 
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 4
                        ),
                      ),
                      Divider(color: AppColors.neonBlue, thickness: 1),
                    ],
                  ),
                ),
              ),

              if (activeQuests.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final quest = activeQuests[index];
                      // Passamos o context do BUILD principal para garantir estabilidade
                      return _buildDismissibleQuest(context, ref, quest);
                    },
                    childCount: activeQuests.length,
                  ),
                )
              else
                _buildEmptyState("NENHUMA MISSÃO ATIVA"),

              if (completedQuests.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40, bottom: 10),
                    child: Text(
                      "CONCLUÍDAS", 
                      style: TextStyle(fontSize: 14, color: Colors.white38, letterSpacing: 2)
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final quest = completedQuests[index];
                      return Opacity(
                        opacity: 0.6,
                        child: _buildDismissibleQuest(context, ref, quest),
                      );
                    },
                    childCount: completedQuests.length,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddQuestModal(context),
        //onPressed: () => ref.read(playerProvider.notifier).debugResetPlayer(),
        backgroundColor: AppColors.neonBlue,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildDismissibleQuest(BuildContext context, WidgetRef ref, dynamic quest) {
    return Dismissible(
      key: Key(quest.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ref.read(questProvider.notifier).deleteQuest(quest.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete_sweep, color: Colors.redAccent),
      ),
      child: QuestCard(
        quest: quest,
        onToggle: () {
          // Aqui usamos o context que vem do build() para evitar o erro de BuildContext inválido
          ref.read(questProvider.notifier).toggleQuest(
            quest.id,
            onLevelUp: (level) => _showLevelUpDialog(context, level),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            text, 
            style: const TextStyle(color: Colors.white24, fontSize: 12)
          ),
        ),
      ),
    );
  }

  void _openAddQuestModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddQuestModal(),
    );
  }

void _showLevelUpDialog(BuildContext context, int level) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85), // Levemente mais transparente para ver o fundo
      builder: (dialogContext) { 
        // Agendamos o fechamento automático usando o dialogContext
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        });

        return Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "LEVEL UP",
                  style: TextStyle(
                    color: AppColors.neonBlue,
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 10,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "NÍVEL $level",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 40),
                const Icon(Icons.keyboard_double_arrow_up, 
                  color: AppColors.neonBlue, 
                  size: 80 // Aumentei um pouco para dar mais impacto
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
