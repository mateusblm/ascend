import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/domain/weekly_insights.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/domain/quest_suggestion.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:ascend/features/quests/presentation/widgets/add_quest_modal.dart';
import 'package:ascend/features/weekly_boss/presentation/weekly_boss_provider.dart';
import 'package:ascend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/quest_card.dart';

class QuestsScreen extends ConsumerWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(questProvider);
    final player = ref.watch(playerProvider);
    final remoteWeeklyBoss = ref.watch(remoteWeeklyBossProvider).valueOrNull;
    final activeQuests = quests.where((q) => !q.isCompleted).toList();
    final completedQuests = quests.where((q) => q.isCompleted).toList();
    final weeklyBoss = remoteWeeklyBoss == null
        ? null
        : WeeklyBossDefinition(
            rank: remoteWeeklyBoss.rank,
            title: remoteWeeklyBoss.title,
            description: remoteWeeklyBoss.description,
            targetActiveDays: remoteWeeklyBoss.targetActiveDays,
            rewardXp: remoteWeeklyBoss.rewardXp,
            rewardStatPoints: remoteWeeklyBoss.rewardStatPoints,
          );
    final insights = buildWeeklyInsights(
      player,
      weeklyBoss: weeklyBoss,
      weeklyBossProgress: weeklyBoss?.progressFor(player) ?? 0,
      weeklyBossClaimed: weeklyBoss?.isClaimedThisWeek(player) ?? false,
    );
    final suggestions =
        buildWeeklyQuestSuggestions(player, insights, weeklyBoss: weeklyBoss)
            .where(
              (suggestion) =>
                  !quests.any((quest) => quest.title == suggestion.title),
            )
            .toList();

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
                        "QUESTS DIÁRIAS",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                      Divider(color: AppColors.neonBlue, thickness: 1),
                    ],
                  ),
                ),
              ),
              if (suggestions.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSuggestionsPanel(context, ref, suggestions),
                ),

              if (activeQuests.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final quest = activeQuests[index];
                    // Passamos o context do BUILD principal para garantir estabilidade
                    return _buildDismissibleQuest(context, ref, quest);
                  }, childCount: activeQuests.length),
                )
              else
                _buildEmptyState("NENHUMA MISSÃO ATIVA"),

              if (completedQuests.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40, bottom: 10),
                    child: Text(
                      "CONCLUÍDAS",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white38,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final quest = completedQuests[index];
                    return Opacity(
                      opacity: 0.6,
                      child: _buildDismissibleQuest(context, ref, quest),
                    );
                  }, childCount: completedQuests.length),
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

  Widget _buildDismissibleQuest(
    BuildContext context,
    WidgetRef ref,
    Quest quest,
  ) {
    return Dismissible(
      key: Key(quest.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) =>
          ref.read(questProvider.notifier).deleteQuest(quest.id),
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
          ref
              .read(questProvider.notifier)
              .toggleQuest(
                quest.id,
                onLevelUp: (level) => _showLevelUpDialog(context, level),
              );
        },
      ),
    );
  }

  Widget _buildSuggestionsPanel(
    BuildContext context,
    WidgetRef ref,
    List<QuestSuggestion> suggestions,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neonBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neonBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SUGESTOES DA SEMANA',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Baseadas no seu foco, ritmo recente e plano da proxima semana.',
            style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.neonBlue,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                final addedCount = ref
                    .read(questProvider.notifier)
                    .addSuggestedQuests(suggestions);
                final messenger = ScaffoldMessenger.of(context);
                messenger.hideCurrentSnackBar();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      addedCount > 0
                          ? '$addedCount quests adicionadas para a sua semana.'
                          : 'Essas sugestoes ja estao na sua lista atual.',
                    ),
                  ),
                );
              },
              child: Text(
                'MONTAR SEMANA (${suggestions.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...suggestions.map(
            (suggestion) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.neonBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          suggestion.tag,
                          style: const TextStyle(
                            color: AppColors.neonBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '+${suggestion.xpReward} XP',
                        style: const TextStyle(
                          color: AppColors.neonBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    suggestion.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    suggestion.reason,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.neonBlue),
                        foregroundColor: AppColors.neonBlue,
                      ),
                      onPressed: () {
                        ref
                            .read(questProvider.notifier)
                            .addQuest(
                              suggestion.title,
                              suggestion.rewardAttribute,
                              suggestion.xpReward,
                            );
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.hideCurrentSnackBar();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              '"${suggestion.title}" adicionada nas quests.',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'ADICIONAR',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
            style: const TextStyle(color: Colors.white24, fontSize: 12),
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
      barrierColor: Colors.black.withOpacity(
        0.85,
      ), // Levemente mais transparente para ver o fundo
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
                const Icon(
                  Icons.keyboard_double_arrow_up,
                  color: AppColors.neonBlue,
                  size: 80, // Aumentei um pouco para dar mais impacto
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
