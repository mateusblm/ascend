import 'dart:async';

import 'package:ascend/core/widgets/reveal_block.dart';
import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/profile/domain/first_week_journey.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/domain/weekly_insights.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/quests/domain/competitive_quest_template.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/domain/quest_suggestion.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:ascend/features/quests/presentation/widgets/add_quest_modal.dart';
import 'package:ascend/features/quests/presentation/widgets/quest_card.dart';
import 'package:ascend/features/weekly_boss/presentation/weekly_boss_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final questLiveNowProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(
    const Duration(seconds: 15),
    (_) => DateTime.now(),
  );
});

class QuestsScreen extends ConsumerWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(questProvider);
    final player = ref.watch(playerProvider);
    final remoteWeeklyBoss = ref.watch(remoteWeeklyBossProvider).valueOrNull;
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
    final officialTemplates = templatesForFocus(player.primaryFocus)
        .where(
          (template) => !quests.any(
            (quest) =>
                quest.isCompetitive &&
                !quest.isCompleted &&
                quest.templateType == template.templateType,
          ),
        )
        .toList();

    final competitiveQuests = quests.where((q) => q.isCompetitive).toList();
    final personalActiveQuests = quests
        .where((q) => !q.isCompetitive && !q.isCompleted)
        .toList();
    final completedQuests = quests.where((q) => q.isCompleted).toList();
    final firstWeekJourney = buildFirstWeekJourney(
      player: player,
      quests: quests,
    );
    final liveNow = ref.watch(questLiveNowProvider).valueOrNull ?? DateTime.now();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: RevealBlock(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SUAS QUESTS',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Monte sua rotina do dia, proteja seu rank e mantenha o ritmo da semana.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white60,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 12),
                        Divider(color: AppColors.neonBlue, thickness: 1),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: RevealBlock(
                  delay: const Duration(milliseconds: 70),
                  child: _buildCompetitiveIntro(context),
                ),
              ),
              if (firstWeekJourney.isActive)
                SliverToBoxAdapter(
                  child: RevealBlock(
                    delay: const Duration(milliseconds: 100),
                    child: _buildFirstWeekPanel(firstWeekJourney),
                  ),
                ),
              if (officialTemplates.isNotEmpty)
                SliverToBoxAdapter(
                  child: RevealBlock(
                    delay: const Duration(milliseconds: 130),
                    child: _buildCompetitiveTemplatesPanel(
                      context,
                      ref,
                      officialTemplates,
                    ),
                  ),
                ),
              if (competitiveQuests.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 10),
                    child: Text(
                      'QUESTS COMPETITIVAS',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (competitiveQuests.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final quest = competitiveQuests[index];
                    return _buildQuestItem(context, ref, quest, liveNow);
                  }, childCount: competitiveQuests.length),
                ),
              if (suggestions.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSuggestionsPanel(context, ref, suggestions),
                ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 10),
                    child: Text(
                      'QUESTS DO DIA A DIA',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white54,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (personalActiveQuests.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final quest = personalActiveQuests[index];
                    return _buildQuestItem(context, ref, quest, liveNow);
                  }, childCount: personalActiveQuests.length),
                )
              else
                _buildEmptyState(
                  'Nenhuma quest pessoal ativa. Toque em + para criar uma ou use as sugestoes abaixo.',
                ),
              if (completedQuests.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 10),
                    child: Text(
                      'FEITAS HOJE',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white38,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final quest = completedQuests[index];
                    return Opacity(
                      opacity: 0.75,
                      child: _buildQuestItem(context, ref, quest, liveNow),
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
        backgroundColor: AppColors.neonBlue,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildCompetitiveIntro(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neonBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neonBlue.withValues(alpha: 0.25)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COMO FUNCIONA',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Quests de rank ajudam na sua subida e no desafio da semana. Quests pessoais ajudam no seu ritmo e no level.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstWeekPanel(FirstWeekJourneySummary summary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'KIT DA PRIMEIRA SEMANA',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
              Text(
                summary.progressLabel,
                style: const TextStyle(
                  color: AppColors.neonBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary.nextAction,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          ...summary.steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    step.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 16,
                    color: step.isDone ? Colors.greenAccent : Colors.white38,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step.label,
                      style: TextStyle(
                        color: step.isDone ? Colors.white : Colors.white70,
                        fontSize: 11.5,
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

  Widget _buildCompetitiveTemplatesPanel(
    BuildContext context,
    WidgetRef ref,
    List<CompetitiveQuestTemplate> templates,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neonBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neonBlue.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMECE POR AQUI',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Esses modelos ja entram prontos para contar no rank.',
            style: TextStyle(color: Colors.white60, fontSize: 11.5, height: 1.4),
          ),
          const SizedBox(height: 12),
          ...templates.map(
            (template) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    template.description,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuestChip(
                        template.verificationLabel,
                        AppColors.neonBlue,
                      ),
                      _buildQuestChip(
                        '+${template.xpReward} XP',
                        Colors.greenAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.neonBlue),
                        foregroundColor: AppColors.neonBlue,
                      ),
                      onPressed: () {
                        final added = ref
                            .read(questProvider.notifier)
                            .addCompetitiveTemplate(template);
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                added
                                    ? '"${template.title}" entrou na sua lista.'
                                    : 'Voce ja tem uma quest parecida em aberto.',
                              ),
                            ),
                          );
                      },
                      child: const Text(
                        'ADICIONAR',
                        style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildQuestItem(
    BuildContext context,
    WidgetRef ref,
    Quest quest,
    DateTime liveNow,
  ) {
    final controller = ref.read(questProvider.notifier);
    final helperText = _helperTextForQuest(quest, liveNow);
    final primaryLabel = _primaryLabelForQuest(quest);

    return Dismissible(
      key: Key(quest.id),
      direction: quest.isCompleted
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => controller.deleteQuest(quest.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete_sweep, color: Colors.redAccent),
      ),
      child: QuestCard(
        quest: quest,
        primaryActionLabel: primaryLabel,
        helperText: helperText,
        primaryActionEnabled: !quest.isCompleted || !quest.isCompetitive,
        onPrimaryAction: () => _handleQuestPrimaryAction(context, ref, quest),
        onSecondaryAction: quest.isCompleted && !quest.isCompetitive
            ? () => controller.toggleQuest(quest.id)
            : null,
        secondaryActionLabel: quest.isCompleted && !quest.isCompetitive
            ? 'DESFAZER'
            : null,
      ),
    );
  }

  Future<void> _handleQuestPrimaryAction(
    BuildContext context,
    WidgetRef ref,
    Quest quest,
  ) async {
    final controller = ref.read(questProvider.notifier);

    if (!quest.isCompetitive) {
      controller.toggleQuest(
        quest.id,
        onLevelUp: (level) => _showLevelUpDialog(context, level),
      );
      return;
    }

    if (quest.isCompleted) return;

    if (quest.verificationStatus != QuestVerificationStatus.inProgress) {
      try {
        final result = await controller.startCompetitiveQuest(quest.id);
        if (!context.mounted) return;
        _showQuestResult(context, quest, result);
      } catch (_) {
        if (!context.mounted) return;
        _showRemoteFailure(context);
      }
      return;
    }

    String? reflectionAnswer;
    if (quest.requiresReflection) {
      reflectionAnswer = await _openReflectionPrompt(
        context,
        quest.reflectionPrompt ?? 'O que voce fez nesta quest?',
      );
      if (reflectionAnswer == null) return;
    }
    if (!context.mounted) return;

    try {
      final result = await controller.completeCompetitiveQuest(
        quest.id,
        reflectionAnswer: reflectionAnswer,
        onLevelUp: (level) => _showLevelUpDialog(context, level),
      );
      if (!context.mounted) return;
      _showQuestResult(context, quest, result);
    } catch (_) {
      if (!context.mounted) return;
      _showRemoteFailure(context);
    }
  }

  void _showQuestResult(
    BuildContext context,
    Quest quest,
    QuestCompletionResult result,
  ) {
    final message = switch (result) {
      QuestCompletionResult.success => quest.verificationStatus ==
              QuestVerificationStatus.inProgress
          ? 'Quest concluida e registrada.'
          : 'Sessao iniciada. Volte quando terminar.',
      QuestCompletionResult.notFound => 'Quest nao encontrada.',
      QuestCompletionResult.alreadyCompleted => 'Essa quest ja foi concluida.',
        QuestCompletionResult.invalidFlow => 'Essa acao nao esta disponivel para essa quest agora.',
      QuestCompletionResult.timerStillRunning =>
        'Ainda falta um pouco de tempo para essa sessao contar.',
      QuestCompletionResult.missingReflection =>
        'Escreva uma resposta curta para concluir essa quest.',
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showRemoteFailure(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Nao foi possivel validar essa quest agora. Tente novamente em instantes.',
          ),
        ),
      );
  }

  String _primaryLabelForQuest(Quest quest) {
    if (!quest.isCompetitive) {
      return quest.isCompleted ? 'CONCLUIDA' : 'MARCAR COMO FEITA';
    }
    if (quest.isCompleted) return 'VALIDADA';
    if (quest.verificationStatus == QuestVerificationStatus.inProgress) {
      return quest.requiresReflection ? 'FINALIZAR E RESPONDER' : 'FINALIZAR';
    }
    return 'INICIAR';
  }

  String _helperTextForQuest(Quest quest, DateTime liveNow) {
    if (!quest.isCompetitive) {
      return 'Quest pessoal: ajuda no seu progresso geral, mas nao entra no rank.';
    }

    if (quest.verificationStatus == QuestVerificationStatus.inProgress &&
        quest.verificationStartedAt != null) {
      final elapsed = liveNow.difference(quest.verificationStartedAt!).inMinutes;
      return 'Sessao em andamento ha ${elapsed.clamp(0, 999)} min. Meta: ${quest.targetDurationMinutes} min.';
    }

    if (quest.isCompleted) {
      return 'Quest validada. Este dia ja conta para rank e desafio da semana.';
    }

    return switch (quest.verificationMode) {
      QuestVerificationMode.manual =>
        'Pronta para validar.',
      QuestVerificationMode.timer =>
        'Inicie no app e feche ${quest.targetDurationMinutes} min para contar.',
      QuestVerificationMode.timerWithReflection =>
        'Inicie no app, feche ${quest.targetDurationMinutes} min e responda uma pergunta curta.',
    };
  }

  Future<String?> _openReflectionPrompt(
    BuildContext context,
    String prompt,
  ) async {
    final controller = TextEditingController();
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                'FINALIZAR QUEST',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                prompt,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Escreva uma resposta curta',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonBlue,
                  ),
                  onPressed: () {
                    if (controller.text.trim().isEmpty) return;
                    Navigator.of(context).pop(controller.text.trim());
                  },
                  child: const Text(
                    'FINALIZAR QUEST',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
        color: AppColors.neonBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neonBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SUGESTOES PESSOAIS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Essas sugestoes ajudam no seu ritmo e rendem um pouco de XP.',
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
                          ? '$addedCount quests adicionadas para esta semana.'
                          : 'Essas sugestoes ja estao na sua lista.',
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
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildQuestChip('PESSOAL', Colors.white70),
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
                        ref.read(questProvider.notifier).addPersonalQuest(
                              suggestion.title,
                              suggestion.rewardAttribute,
                              suggestion.xpReward,
                            );
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.hideCurrentSnackBar();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              '"${suggestion.title}" entrou na sua lista.',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'ADICIONAR',
                        style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildQuestChip(String label, Color color) {
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

  Widget _buildEmptyState(String text) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12.5,
              height: 1.45,
            ),
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
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (dialogContext) {
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
                  'SUBIU DE NIVEL',
                  style: TextStyle(
                    color: AppColors.neonBlue,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'NIVEL $level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 36),
                const Icon(
                  Icons.keyboard_double_arrow_up,
                  color: AppColors.neonBlue,
                  size: 80,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
