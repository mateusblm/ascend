import 'dart:async';

import 'package:ascend/core/theme/ascend_design_tokens.dart';
import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/core/widgets/reveal_block.dart';
import 'package:ascend/core/widgets/system/ascend_system_panel.dart';
import 'package:ascend/core/widgets/system/system_badge.dart';
import 'package:ascend/features/profile/domain/first_week_journey.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/domain/weekly_insights.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/quests/data/competitive_quest_authority_repository.dart';
import 'package:ascend/features/quests/domain/competitive_quest_evidence.dart';
import 'package:ascend/features/quests/domain/competitive_quest_template.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/domain/quest_suggestion.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:ascend/features/quests/presentation/widgets/add_quest_modal.dart';
import 'package:ascend/features/quests/presentation/widgets/quest_card.dart';
import 'package:ascend/features/weekly_boss/presentation/weekly_boss_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final questLiveNowProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 15), (_) => DateTime.now());
});

class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});

  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

enum _QuestBoard { arena, base, concluidas }

class _QuestsScreenState extends ConsumerState<QuestsScreen> {
  _QuestBoard _selectedBoard = _QuestBoard.base;

  @override
  Widget build(BuildContext context) {
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
    final weeklyBossProgress = weeklyBoss?.progressFor(player) ?? 0;
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
                quest.id.startsWith('${template.id}-'),
          ),
        )
        .toList();

    final competitiveQuests = quests
        .where((q) => q.isCompetitive && !q.isCompleted)
        .toList();
    final personalActiveQuests = quests
        .where((q) => !q.isCompetitive && !q.isCompleted)
        .toList();
    final completedQuests = quests.where((q) => q.isCompleted).toList();
    final firstWeekJourney = buildFirstWeekJourney(
      player: player,
      quests: quests,
    );
    final liveNow =
        ref.watch(questLiveNowProvider).valueOrNull ?? DateTime.now();
    final completedCount = completedQuests.length;
    final totalActiveCount =
        competitiveQuests.length + personalActiveQuests.length;
    final heroSummary = firstWeekJourney.isActive
        ? firstWeekJourney.nextAction
        : weeklyBoss == null
        ? 'Terminal pronto para novas missões.'
        : 'Boss $weeklyBossProgress/${weeklyBoss.targetActiveDays} ativo.';

    void createQuest() => _openAddQuestModal(context);

    return Scaffold(
      key: const ValueKey('quests-screen'),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: RevealBlock(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 16),
                    child: _buildHero(
                      context,
                      playerName: player.name,
                      activeCount: totalActiveCount,
                      competitiveCount: competitiveQuests.length,
                      personalCount: personalActiveQuests.length,
                      completedCount: completedCount,
                      summary: heroSummary,
                      detail: '',
                      weeklyBossTitle: weeklyBoss?.title,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: RevealBlock(
                  delay: const Duration(milliseconds: 70),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildQuestCommandDeck(
                      onCreateQuest: createQuest,
                      competitiveCount: competitiveQuests.length,
                      personalCount: personalActiveQuests.length,
                      completedCount: completedCount,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: RevealBlock(
                  delay: const Duration(milliseconds: 95),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildQuestReturnLoopPanel(
                      personalCount: personalActiveQuests.length,
                      competitiveCount: competitiveQuests.length,
                      completedCount: completedCount,
                      weeklyReview: insights.review,
                      weeklyBoss: weeklyBoss,
                      weeklyBossProgress: weeklyBossProgress,
                    ),
                  ),
                ),
              ),
              if (firstWeekJourney.isActive)
                SliverToBoxAdapter(
                  child: RevealBlock(
                    delay: const Duration(milliseconds: 110),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildFirstWeekPanel(
                        firstWeekJourney,
                        onCreateQuest: createQuest,
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: RevealBlock(
                  delay: const Duration(milliseconds: 140),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildMissionBoardSelector(
                      selected: _selectedBoard,
                      onChanged: (board) =>
                          setState(() => _selectedBoard = board),
                      arenaCount: competitiveQuests.length,
                      baseCount: personalActiveQuests.length,
                      completedCount: completedCount,
                    ),
                  ),
                ),
              ),
              ..._buildBoardSlivers(
                context: context,
                ref: ref,
                selectedBoard: _selectedBoard,
                competitiveQuests: competitiveQuests,
                personalActiveQuests: personalActiveQuests,
                completedQuests: completedQuests,
                suggestions: suggestions,
                officialTemplates: officialTemplates,
                liveNow: liveNow,
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBoardSlivers({
    required BuildContext context,
    required WidgetRef ref,
    required _QuestBoard selectedBoard,
    required List<Quest> competitiveQuests,
    required List<Quest> personalActiveQuests,
    required List<Quest> completedQuests,
    required List<QuestSuggestion> suggestions,
    required List<CompetitiveQuestTemplate> officialTemplates,
    required DateTime liveNow,
  }) {
    switch (selectedBoard) {
      case _QuestBoard.arena:
        return [
          if (officialTemplates.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _buildCompetitiveTemplatesPanel(
                  context,
                  ref,
                  officialTemplates,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSectionHeader(
                title: 'Arena',
                subtitle: 'Contratos verificados.',
                accent: AppColors.arenaAccent,
              ),
            ),
          ),
          if (competitiveQuests.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final quest = competitiveQuests[index];
                return _buildQuestItem(context, ref, quest, liveNow);
              }, childCount: competitiveQuests.length),
            )
          else
            _buildEmptyState('Nenhum contrato ativo.'),
        ];
      case _QuestBoard.base:
        return [
          if (suggestions.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _buildSuggestionsPanel(context, ref, suggestions),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSectionHeader(
                title: 'Base',
                subtitle: 'Missões pessoais.',
                accent: AppColors.questAccent,
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
            _buildEmptyState('Nenhuma missão ativa.'),
        ];
      case _QuestBoard.concluidas:
        return [
          if (completedQuests.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSectionHeader(
                  title: 'Concluídas',
                  subtitle: 'Arquivo do dia.',
                  accent: Colors.white70,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final quest = completedQuests[index];
                return Opacity(
                  opacity: 0.82,
                  child: _buildQuestItem(context, ref, quest, liveNow),
                );
              }, childCount: completedQuests.length),
            ),
          ] else
            _buildEmptyState('Nenhum registro concluído.'),
        ];
    }
  }

  Widget _buildMissionBoardSelector({
    required _QuestBoard selected,
    required ValueChanged<_QuestBoard> onChanged,
    required int arenaCount,
    required int baseCount,
    required int completedCount,
  }) {
    return _SectionPanel(
      accent: AppColors.neonBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Quadro de missões',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
              _StatusBadge(label: 'OPERACIONAL', accent: AppColors.neonBlue),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MissionBoardButton(
                  label: 'Arena',
                  count: arenaCount,
                  icon: Icons.shield_rounded,
                  accent: AppColors.arenaAccent,
                  selected: selected == _QuestBoard.arena,
                  onTap: () => onChanged(_QuestBoard.arena),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MissionBoardButton(
                  label: 'Base',
                  count: baseCount,
                  icon: Icons.track_changes_rounded,
                  accent: AppColors.questAccent,
                  selected: selected == _QuestBoard.base,
                  onTap: () => onChanged(_QuestBoard.base),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MissionBoardButton(
                  label: 'Feitas',
                  count: completedCount,
                  icon: Icons.inventory_2_rounded,
                  accent: Colors.white70,
                  selected: selected == _QuestBoard.concluidas,
                  onTap: () => onChanged(_QuestBoard.concluidas),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestReturnLoopPanel({
    required int personalCount,
    required int competitiveCount,
    required int completedCount,
    required WeeklyReviewReport weeklyReview,
    required WeeklyBossDefinition? weeklyBoss,
    required int weeklyBossProgress,
  }) {
    final tomorrowAction = completedCount == 0 ? 'Fechar 1' : 'Retorno OK';
    final todayAction = personalCount > 0
        ? 'Base'
        : competitiveCount > 0
        ? 'Arena'
        : 'Nova';
    final weeklyPressure = weeklyBoss == null
        ? weeklyReview.badge
        : 'Boss $weeklyBossProgress/${weeklyBoss.targetActiveDays}';
    final statusAccent = switch (weeklyReview.status) {
      WeeklyReviewStatus.rising => AppColors.questAccent,
      WeeklyReviewStatus.stable => AppColors.neonBlue,
      WeeklyReviewStatus.risk => Colors.orangeAccent,
      WeeklyReviewStatus.critical => AppColors.danger,
    };

    return _SectionPanel(
      key: const ValueKey('quests-return-loop'),
      accent: statusAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_repeat_rounded, color: statusAccent, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Ciclo de retorno',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
              _StatusBadge(label: weeklyReview.badge, accent: statusAccent),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusBadge(
                label: 'HOJE: $todayAction',
                accent: AppColors.questAccent,
              ),
              _StatusBadge(
                label: 'AMANHÃ: $tomorrowAction',
                accent: Colors.orangeAccent,
              ),
              _StatusBadge(
                label: weeklyPressure,
                accent: AppColors.arenaAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero(
    BuildContext context, {
    required String playerName,
    required int activeCount,
    required int competitiveCount,
    required int personalCount,
    required int completedCount,
    required String summary,
    required String detail,
    required String? weeklyBossTitle,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return AscendSystemPanel(
      padding: const EdgeInsets.all(22),
      accent: AppColors.questAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        const SystemBadge(
                          label: 'TERMINAL DE MISSÃO',
                          color: AppColors.questAccent,
                          icon: Icons.bolt_rounded,
                        ),
                        SystemBadge(
                          label: weeklyBossTitle ?? 'SEMANA ATIVA',
                          color: AppColors.arenaAccent,
                          icon: Icons.shield_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Quests',
                      style: GoogleFonts.sora(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      playerName,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            summary,
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          if (detail.isNotEmpty) ...[
            Text(detail, style: textTheme.bodyMedium),
            const SizedBox(height: 18),
          ] else
            const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.05,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _QuestSummaryTile(
                label: 'ATIVAS',
                value: '$activeCount',
                accent: Colors.white,
                icon: Icons.radio_button_checked_rounded,
              ),
              _QuestSummaryTile(
                label: 'ARENA',
                value: '$competitiveCount',
                accent: AppColors.arenaAccent,
                icon: Icons.shield_rounded,
              ),
              _QuestSummaryTile(
                label: 'BASE',
                value: '$personalCount',
                accent: AppColors.questAccent,
                icon: Icons.track_changes_rounded,
              ),
              _QuestSummaryTile(
                label: 'CONCLUÍDAS',
                value: '$completedCount',
                accent: AscendDesignTokens.reward,
                icon: Icons.inventory_2_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCommandDeck({
    required VoidCallback onCreateQuest,
    required int competitiveCount,
    required int personalCount,
    required int completedCount,
  }) {
    final headline = switch ((competitiveCount, personalCount)) {
      (0, 0) => 'Nenhuma frente aberta.',
      (0, _) => 'Arena vazia.',
      (_, 0) => 'Base curta.',
      _ => 'Frentes ativas.',
    };

    return _SectionPanel(
      accent: AppColors.planAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comando',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            headline,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CommandReadTile(
                  label: 'Arena',
                  accent: AppColors.arenaAccent,
                  body: '$competitiveCount aberto(s)',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CommandReadTile(
                  label: 'Base',
                  accent: AppColors.questAccent,
                  body: '$personalCount aberto(s)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCreateQuest,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                personalCount == 0 && competitiveCount == 0
                    ? 'Abrir primeira quest'
                    : 'Nova quest',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstWeekPanel(
    FirstWeekJourneySummary summary, {
    required VoidCallback onCreateQuest,
  }) {
    return _SectionPanel(
      accent: AppColors.planAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Primeira semana',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              _StatusBadge(
                label: summary.progressLabel,
                accent: AppColors.planAccent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary.nextAction,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          ...summary.steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: step.isDone
                          ? AppColors.questAccent.withValues(alpha: 0.16)
                          : Colors.white.withValues(alpha: 0.04),
                      border: Border.all(
                        color: step.isDone
                            ? AppColors.questAccent.withValues(alpha: 0.24)
                            : AppColors.borderStrong,
                      ),
                    ),
                    child: Icon(
                      step.isDone ? Icons.check_rounded : Icons.circle_outlined,
                      size: 14,
                      color: step.isDone
                          ? AppColors.questAccent
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        step.label,
                        style: TextStyle(
                          color: step.isDone
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCreateQuest,
              icon: const Icon(Icons.add_task_rounded),
              label: Text(
                summary.steps.every((step) => step.isDone)
                    ? 'Abrir nova quest'
                    : 'Criar quest para o próximo passo',
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
    return _SectionPanel(
      accent: AppColors.neonBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Abrir quest de arena',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Modelos oficiais prontos para validação competitiva.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          ...templates.map(
            (template) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
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
                      _buildQuestChip(
                        template.verificationLabel,
                        AppColors.neonBlue,
                      ),
                      _buildQuestChip(
                        'Tier ${template.verificationRequirement.minimumTrustTier}',
                        AppColors.arenaAccent,
                      ),
                      _buildQuestChip(
                        '+${template.xpReward} XP',
                        AppColors.questAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.neonBlue.withValues(
                          alpha: 0.16,
                        ),
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
                                    : 'Você já tem uma quest parecida em aberto.',
                              ),
                            ),
                          );
                      },
                      child: const Text('Adicionar'),
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

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required Color accent,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 42,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
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
          color: AppColors.danger.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: AppColors.danger),
      ),
      child: QuestCard(
        quest: quest,
        primaryActionLabel: primaryLabel,
        helperText: helperText,
        primaryActionEnabled: !quest.isCompleted || !quest.isCompetitive,
        onPrimaryAction: () => _handleQuestPrimaryAction(context, ref, quest),
        onSecondaryAction: quest.isCompleted && !quest.isCompetitive
            ? () async {
                try {
                  final result = await controller.toggleQuest(quest.id);
                  if (!context.mounted) return;
                  _showQuestResult(context, quest, result);
                } catch (_) {
                  if (!context.mounted) return;
                  _showRemoteFailure(context);
                }
              }
            : null,
        secondaryActionLabel: quest.isCompleted && !quest.isCompetitive
            ? 'Desfazer'
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
      try {
        final result = await controller.toggleQuest(
          quest.id,
          onLevelUp: (level) => _showLevelUpDialog(context, level),
        );
        if (!context.mounted) return;
        _showQuestResult(context, quest, result);
      } catch (_) {
        if (!context.mounted) return;
        _showRemoteFailure(context);
      }
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
        quest.reflectionPrompt ?? 'O que você fez nesta quest?',
      );
      if (reflectionAnswer == null) return;
    }
    if (!context.mounted) return;

    String? readingQuizId;
    var readingQuizAnswers = const <String>[];
    final requirement = officialTemplateForQuest(
      quest,
    )?.verificationRequirement;
    final requiresReadingQuiz =
        requirement?.evidenceType ==
        CompetitiveEvidenceType.readingComprehension;
    if (requiresReadingQuiz) {
      ReadingQuizAttempt? attempt;
      try {
        attempt = await controller.startReadingQuizAttempt(quest.id);
      } catch (_) {
        if (!context.mounted) return;
        _showRemoteFailure(context);
        return;
      }
      if (!context.mounted) return;
      if (attempt == null) {
        _showRemoteFailure(context);
        return;
      }

      final answers = await _openReadingQuizPrompt(context, attempt);
      if (!context.mounted || answers == null) return;
      readingQuizId = attempt.quizId;
      readingQuizAnswers = answers;
    }

    try {
      final result = await controller.completeCompetitiveQuest(
        quest.id,
        reflectionAnswer: reflectionAnswer,
        readingQuizId: readingQuizId,
        readingQuizAnswers: readingQuizAnswers,
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
      QuestCompletionResult.success =>
        quest.verificationStatus == QuestVerificationStatus.inProgress
            ? 'Quest concluída e registrada.'
            : 'Sessão iniciada. Volte quando terminar.',
      QuestCompletionResult.notFound => 'Quest não encontrada.',
      QuestCompletionResult.alreadyCompleted => 'Essa quest já foi concluída.',
      QuestCompletionResult.invalidFlow =>
        'Essa ação não está disponível para essa quest agora.',
      QuestCompletionResult.timerStillRunning =>
        'Ainda falta um pouco de tempo para essa sessão contar.',
      QuestCompletionResult.missingReflection =>
        'Escreva uma resposta curta para concluir essa quest.',
      QuestCompletionResult.insufficientEvidence =>
        'Evidência recusada: faltou tempo, distância ou resposta mínima para a Arena.',
      QuestCompletionResult.evidenceRejected =>
        'Evidência rejeitada: os dados enviados não batem com uma validação competitiva segura.',
      QuestCompletionResult.duplicateEvidence =>
        'Essa evidência já foi usada em outra validação. Reinicie a sessão para gerar uma prova nova.',
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
            'Não foi possível validar essa quest agora. Tente novamente em instantes.',
          ),
        ),
      );
  }

  String _primaryLabelForQuest(Quest quest) {
    if (!quest.isCompetitive) {
      return quest.isCompleted ? 'Concluída' : 'Marcar como feita';
    }
    if (quest.isCompleted) return 'Validada';
    if (quest.verificationStatus == QuestVerificationStatus.inProgress) {
      return quest.requiresReflection ? 'Finalizar e responder' : 'Finalizar';
    }
    return 'Iniciar';
  }

  String _helperTextForQuest(Quest quest, DateTime liveNow) {
    if (!quest.isCompetitive) {
      return 'Quest pessoal: ajuda no progresso geral, mas não entra no rank.';
    }

    final template = officialTemplateForQuest(quest);
    final evidenceSummary = template == null
        ? 'Evidência oficial indisponível para este modelo.'
        : 'Evidência exigida: ${competitiveEvidenceRequirementSummary(template.verificationRequirement)}.';

    if (quest.verificationStatus == QuestVerificationStatus.inProgress &&
        quest.verificationStartedAt != null) {
      final elapsed = liveNow
          .difference(quest.verificationStartedAt!)
          .inMinutes;
      return 'Sessao em andamento ha ${elapsed.clamp(0, 999)} min. Meta: ${quest.targetDurationMinutes} min. $evidenceSummary';
    }

    if (quest.isCompleted) {
      return 'Quest validada. Este dia já conta para rank e desafio da semana.';
    }

    return switch (quest.verificationMode) {
      QuestVerificationMode.manual => 'Pronta para validar. $evidenceSummary',
      QuestVerificationMode.timer =>
        'Inicie no app e envie evidência simulada após ${quest.targetDurationMinutes} min. $evidenceSummary',
      QuestVerificationMode.timerWithReflection =>
        'Inicie no app, feche ${quest.targetDurationMinutes} min e responda para gerar prova. $evidenceSummary',
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
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
                  'Finalizar quest',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  prompt,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Escreva uma resposta curta',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (controller.text.trim().isEmpty) return;
                      Navigator.of(context).pop(controller.text.trim());
                    },
                    child: const Text('Finalizar quest'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<String>?> _openReadingQuizPrompt(
    BuildContext context,
    ReadingQuizAttempt attempt,
  ) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReadingQuizPromptSheet(attempt: attempt),
    );
  }

  Widget _buildSuggestionsPanel(
    BuildContext context,
    WidgetRef ref,
    List<QuestSuggestion> suggestions,
  ) {
    return _SectionPanel(
      accent: AppColors.questAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sugestões da semana',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Quests simples para ganhar ritmo e preencher sua base.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.questAccent.withValues(alpha: 0.16),
                foregroundColor: AppColors.questAccent,
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
                          : 'Essas sugestões já estão na sua lista.',
                    ),
                  ),
                );
              },
              child: Text('Adicionar ${suggestions.length} sugestões'),
            ),
          ),
          const SizedBox(height: 14),
          ...suggestions.map(
            (suggestion) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildQuestChip('Base', AppColors.questAccent),
                      const Spacer(),
                      Text(
                        '+${suggestion.xpReward} XP',
                        style: const TextStyle(
                          color: AppColors.questAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    suggestion.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    suggestion.reason,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(questProvider.notifier)
                            .addPersonalQuest(
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
                      child: const Text('Adicionar'),
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

  Widget _buildEmptyState(String text) {
    return SliverToBoxAdapter(
      child: _SectionPanel(
        accent: AppColors.borderStrong,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.45,
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
                Text(
                  'Subiu de nivel',
                  style: GoogleFonts.sora(
                    color: AppColors.neonBlue,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Nivel $level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 28),
                const Icon(
                  Icons.keyboard_double_arrow_up_rounded,
                  color: AppColors.neonBlue,
                  size: 72,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReadingQuizPromptSheet extends StatefulWidget {
  const _ReadingQuizPromptSheet({required this.attempt});

  final ReadingQuizAttempt attempt;

  @override
  State<_ReadingQuizPromptSheet> createState() =>
      _ReadingQuizPromptSheetState();
}

class _ReadingQuizPromptSheetState extends State<_ReadingQuizPromptSheet> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = [
      for (final _ in widget.attempt.questions) TextEditingController(),
    ];
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final answers = _controllers
        .map((controller) => controller.text.trim())
        .toList(growable: false);
    if (answers.any((answer) => answer.isEmpty)) return;
    Navigator.of(context).pop(answers);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
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
                'Prova de leitura',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Responda com base no que você leu. Nota mínima: ${widget.attempt.minimumScore}%.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              for (
                var index = 0;
                index < widget.attempt.questions.length;
                index++
              ) ...[
                Text(
                  widget.attempt.questions[index].prompt,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controllers[index],
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Resposta ${index + 1}',
                  ),
                ),
                const SizedBox(height: 14),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Enviar respostas'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionPanel extends StatelessWidget {
  const _SectionPanel({super.key, required this.child, required this.accent});

  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.06), AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MissionBoardButton extends StatelessWidget {
  const _MissionBoardButton({
    required this.label,
    required this.count,
    required this.icon,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AscendDesignTokens.radiusControl),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 74),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: selected ? 0.16 : 0.07),
            borderRadius: BorderRadius.circular(
              AscendDesignTokens.radiusControl,
            ),
            border: Border.all(
              color: accent.withValues(alpha: selected ? 0.38 : 0.14),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: accent, size: 18),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestSummaryTile extends StatelessWidget {
  const _QuestSummaryTile({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
  });

  final String label;
  final String value;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommandReadTile extends StatelessWidget {
  const _CommandReadTile({
    required this.label,
    required this.body,
    required this.accent,
  });

  final String label;
  final String body;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
