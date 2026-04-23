import 'package:ascend/core/widgets/reveal_block.dart';
import 'package:ascend/core/widgets/detail_shell_screen.dart';
import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/auth/domain/auth_state.dart';
import 'package:ascend/features/auth/presentation/auth_controller.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/promotion_exam.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/domain/weekly_insights.dart';
import 'package:ascend/features/profile/presentation/account_screen.dart';
import 'package:ascend/features/profile/presentation/info_tooltip.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/profile/presentation/rank_progression_provider.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/weekly_boss/presentation/weekly_boss_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final authState = ref.watch(authProvider);
    final remoteWeeklyBoss = ref.watch(remoteWeeklyBossProvider);
    final rankSnapshot = ref.watch(rankProgressionSnapshotProvider).valueOrNull;
    final rankHistory =
        ref.watch(rankProgressionHistoryProvider).valueOrNull ??
        const <CompetitiveRankSnapshot>[];
    final promotionExam = ref.watch(promotionExamProvider).valueOrNull;
    final attrs = player.attributes;
    final remoteBoss = remoteWeeklyBoss.valueOrNull;
    final weeklyBoss = remoteBoss == null
        ? null
        : WeeklyBossDefinition(
            rank: remoteBoss.rank,
            title: remoteBoss.title,
            description: remoteBoss.description,
            targetActiveDays: remoteBoss.targetActiveDays,
            rewardXp: remoteBoss.rewardXp,
            rewardStatPoints: remoteBoss.rewardStatPoints,
          );
    final weeklyBossProgress = weeklyBoss?.progressFor(player) ?? 0;
    final weeklyBossClaimed = weeklyBoss?.isClaimedThisWeek(player) ?? false;
    final insights = buildWeeklyInsights(
      player,
      weeklyBoss: weeklyBoss,
      weeklyBossProgress: weeklyBossProgress,
      weeklyBossClaimed: weeklyBossClaimed,
    );
    final weekProgress = (insights.discipline.currentWeekActiveDays / 7).clamp(
      0.0,
      1.0,
    );

    return Scaffold(
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
                    child: _buildHeader(
                      context,
                      player,
                      authState,
                      insights,
                      promotionExam,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: RevealBlock(
                  delay: const Duration(milliseconds: 70),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildWeeklyReadPanel(
                      context,
                      player,
                      insights,
                      weekProgress,
                      weeklyBoss,
                      weeklyBossProgress,
                      weeklyBossClaimed,
                      rankHistory,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: RevealBlock(
                  delay: const Duration(milliseconds: 130),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildNextStepPanel(
                      context,
                      insights,
                      weeklyBoss,
                      rankSnapshot,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: RevealBlock(
                  delay: const Duration(milliseconds: 190),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildPlanHub(
                      context,
                      player,
                      attrs,
                      insights,
                      weeklyBoss,
                      weeklyBossProgress,
                      weeklyBossClaimed,
                      rankHistory,
                      rankSnapshot,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Player player,
    AuthState authState,
    WeeklyInsightsBundle insights,
    PromotionExam? promotionExam,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final statusAccent = switch (insights.review.status) {
      WeeklyReviewStatus.rising => AppColors.questAccent,
      WeeklyReviewStatus.stable => AppColors.planAccent,
      WeeklyReviewStatus.risk => AppColors.arenaAccent,
      WeeklyReviewStatus.critical => AppColors.danger,
    };

    return _ContrastPanel(
      accent: AppColors.planAccent,
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
                    Text(
                      'Plano',
                      style: textTheme.labelMedium?.copyWith(
                        fontSize: 11,
                        color: AppColors.planAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Leitura semanal e proximo passo',
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 28,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      player.name,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (authState is AuthSuccess) ...[
                    OutlinedButton.icon(
                      onPressed: () => _openAccountScreen(context),
                      icon: const Icon(Icons.manage_accounts_rounded, size: 16),
                      label: const Text(
                        'Conta',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const InfoTooltipIcon(
                    title: 'Como ler esta tela',
                    message:
                        'Aqui voce acompanha seu progresso, sua semana e o que vale ajustar. A tela de Rank cuida da parte competitiva.',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insights.review.summary,
            style: textTheme.titleLarge?.copyWith(height: 1.2),
          ),
          const SizedBox(height: 8),
          Text(insights.review.detail, style: textTheme.bodyMedium),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricCard(
                label: 'Score',
                value: '${insights.discipline.score}%',
                accent: statusAccent,
              ),
              _MetricCard(
                label: 'Grau',
                value: insights.discipline.grade,
                accent: statusAccent,
              ),
              _MetricCard(
                label: 'Semana',
                value: '${insights.discipline.currentWeekActiveDays}/7',
                accent: AppColors.questAccent,
              ),
              _MetricCard(
                label: 'Foco',
                value: player.primaryFocus.label,
                accent: AppColors.planAccent,
              ),
            ],
          ),
          if (promotionExam != null) ...[
            const SizedBox(height: 12),
            _MiniNote(
              title: 'Arena em paralelo',
              text: switch (promotionExam.status) {
                PromotionExamStatus.inProgress =>
                  promotionExam.mode == PromotionExamMode.reconquest
                      ? 'Existe uma reconquista em andamento com meta de ${promotionExam.targetActiveDays} dias ativos. O detalhe competitivo fica em Arena.'
                      : 'Existe uma prova em andamento com meta de ${promotionExam.targetActiveDays} dias ativos. O detalhe competitivo fica em Arena.',
                PromotionExamStatus.passed =>
                  promotionExam.mode == PromotionExamMode.reconquest
                      ? 'A reconquista esta pronta para confirmar. O fechamento competitivo continua em Arena.'
                      : 'A promocao esta pronta para confirmar. O fechamento competitivo continua em Arena.',
                PromotionExamStatus.failed =>
                  'A prova expirou ou nao foi sustentada. Use esta tela para reorganizar a semana antes de voltar a Arena.',
                PromotionExamStatus.promoted =>
                  promotionExam.mode == PromotionExamMode.reconquest
                      ? 'A reconquista ja foi registrada.'
                      : 'A promocao ja foi registrada.',
              },
              accent: AppColors.textMuted,
            ),
          ],
        ],
      ),
    );
  }

  void _openAccountScreen(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AccountScreen()));
  }

  Widget _buildPlanHub(
    BuildContext context,
    Player player,
    PlayerAttributes attrs,
    WeeklyInsightsBundle insights,
    WeeklyBossDefinition? weeklyBoss,
    int weeklyBossProgress,
    bool weeklyBossClaimed,
    List<CompetitiveRankSnapshot> rankHistory,
    CompetitiveRankSnapshot? rankSnapshot,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Abrir detalhes',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Abra os detalhes para ver ritmo da conta, build e leitura completa da semana.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        _SectionEntryCard(
          title: 'Visao geral',
          summary:
              'Ritmo da conta, streak, level e leitura consolidada da semana em um unico detalhe.',
          supporting: 'Panorama da conta e do ciclo atual.',
          badge: insights.review.badge,
          accent: AppColors.planAccent,
          onTap: () => _openPlanDetail(
            context,
            title: 'Visao Geral',
            subtitle:
                'Resumo do seu ritmo atual, da progressao geral e do estado da semana.',
            child: _buildOverviewSection(player, rankSnapshot, insights),
          ),
        ),
        const SizedBox(height: 12),
        _SectionEntryCard(
          title: 'Build',
          summary:
              'For ${attrs.strength} | Int ${attrs.intelligence} | Vit ${attrs.vitality} | Agi ${attrs.agility}',
          supporting: 'Ajuste de atributos e pontos livres.',
          badge: player.statPoints > 0 ? '${player.statPoints} PTS' : 'SEM PTS',
          accent: Colors.amberAccent,
          onTap: () => _openPlanDetail(
            context,
            title: 'Build',
            subtitle:
                'Gestao dos atributos, pontos livres e linha de crescimento atual.',
            child: _buildAttributesSection(context, player, attrs),
          ),
        ),
        const SizedBox(height: 12),
        _SectionEntryCard(
          title: 'Semana detalhada',
          summary:
              'Historico recente, leitura completa da cadencia e comparacao com a semana anterior.',
          supporting: 'Abre a leitura completa da semana e do historico.',
          badge: '${insights.discipline.currentWeekActiveDays}/7',
          accent: AppColors.questAccent,
          onTap: () => _openPlanDetail(
            context,
            title: 'Semana',
            subtitle:
                'Leitura semanal, historico recente e o peso disso na sua consistencia.',
            child: _buildWeeklySection(
              player,
              insights,
              weeklyBoss,
              weeklyBossProgress,
              weeklyBossClaimed,
              rankHistory,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyReadPanel(
    BuildContext context,
    Player player,
    WeeklyInsightsBundle insights,
    double weekProgress,
    WeeklyBossDefinition? weeklyBoss,
    int weeklyBossProgress,
    bool weeklyBossClaimed,
    List<CompetitiveRankSnapshot> rankHistory,
  ) {
    final reviewAccent = switch (insights.review.status) {
      WeeklyReviewStatus.rising => AppColors.questAccent,
      WeeklyReviewStatus.stable => AppColors.planAccent,
      WeeklyReviewStatus.risk => AppColors.arenaAccent,
      WeeklyReviewStatus.critical => AppColors.danger,
    };
    final delta = insights.discipline.deltaFromPreviousWeek;
    final deltaLabel = delta == 0
        ? 'sem mudanca'
        : '${delta > 0 ? '+' : ''}$delta';

    return _AccentPanel(
      accent: reviewAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Leitura da semana',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _InlineBadge(label: insights.review.badge, accent: reviewAccent),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            insights.review.summary,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            insights.review.recommendation,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Score',
                  value: '${insights.discipline.score}%',
                  accent: reviewAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'Grau',
                  value: insights.discipline.grade,
                  accent: reviewAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'Delta',
                  value: deltaLabel,
                  accent: delta >= 0 ? AppColors.planAccent : AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildOverviewBar(
            label: 'Cadencia da semana',
            trailing:
                '${insights.discipline.currentWeekActiveDays}/7 dias ativos',
            percent: weekProgress,
            color: reviewAccent,
          ),
          const SizedBox(height: 12),
          _MiniNote(
            title: 'Comparacao',
            text:
                'Semana passada: ${insights.discipline.previousWeekActiveDays}/7 dias ativos. Historico recente: ${rankHistory.isEmpty ? 'ainda sem semanas registradas.' : '${rankHistory.take(2).length} leitura(s) pronta(s) para abrir no detalhe.'}',
            accent: AppColors.textMuted,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => _openPlanDetail(
                context,
                title: 'Semana',
                subtitle:
                    'Leitura semanal, historico recente e o peso disso na sua consistencia.',
                child: _buildWeeklySection(
                  player,
                  insights,
                  weeklyBoss,
                  weeklyBossProgress,
                  weeklyBossClaimed,
                  rankHistory,
                ),
              ),
              icon: const Icon(Icons.chevron_right_rounded),
              label: const Text('Abrir semana'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepPanel(
    BuildContext context,
    WeeklyInsightsBundle insights,
    WeeklyBossDefinition? weeklyBoss,
    CompetitiveRankSnapshot? rankSnapshot,
  ) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Proximo passo',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _InlineBadge(
                label: insights.nextWeekPlan.difficultyLabel,
                accent: AppColors.planAccent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            insights.nextWeekPlan.headline,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            insights.nextWeekPlan.summary,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          ...insights.nextWeekPlan.priorities
              .take(3)
              .map(
                (priority) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: AppColors.planAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          priority,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 6),
          _MiniNote(
            title: 'Regra da semana',
            text: insights.nextWeekPlan.rule,
            accent: AppColors.planAccent,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => _openPlanDetail(
                context,
                title: 'Proximo Passo',
                subtitle:
                    'Plano da proxima semana com prioridades curtas e regra operacional.',
                child: _buildPlanSection(insights, weeklyBoss, rankSnapshot),
              ),
              icon: const Icon(Icons.chevron_right_rounded),
              label: const Text('Abrir plano'),
            ),
          ),
        ],
      ),
    );
  }

  void _openPlanDetail(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            DetailShellScreen(title: title, subtitle: subtitle, child: child),
      ),
    );
  }

  Widget _buildOverviewSection(
    Player player,
    CompetitiveRankSnapshot? rankSnapshot,
    WeeklyInsightsBundle insights,
  ) {
    final levelProgress = player.maxXp == 0
        ? 0.0
        : (player.xp / player.maxXp).clamp(0.0, 1.0);
    final weeklyProgress = (insights.discipline.currentWeekActiveDays / 7)
        .clamp(0.0, 1.0);
    final reviewAccent = switch (insights.review.status) {
      WeeklyReviewStatus.rising => Colors.greenAccent,
      WeeklyReviewStatus.stable => AppColors.neonBlue,
      WeeklyReviewStatus.risk => Colors.orangeAccent,
      WeeklyReviewStatus.critical => Colors.redAccent,
    };
    final currentRank =
        rankSnapshot?.currentRank ?? playerRankForLevel(player.level);

    return Column(
      key: const ValueKey('overview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AccentPanel(
          accent: AppColors.neonBlue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ritmo atual',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                insights.review.summary,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                insights.review.detail,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'SCORE',
                      value: '${insights.discipline.score}%',
                      accent: reviewAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      label: 'GRAU',
                      value: insights.discipline.grade,
                      accent: reviewAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      label: 'RANK',
                      value: currentRank,
                      accent: AppColors.neonBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'SEMANA',
                      value:
                          '${insights.discipline.currentWeekActiveDays}/7 dias',
                      accent: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      label: 'DELTA',
                      value:
                          '${insights.discipline.deltaFromPreviousWeek >= 0 ? '+' : ''}${insights.discipline.deltaFromPreviousWeek}',
                      accent: insights.discipline.deltaFromPreviousWeek >= 0
                          ? Colors.amberAccent
                          : Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildOverviewBar(
                label: 'CADENCIA DA SEMANA',
                trailing:
                    '${insights.discipline.currentWeekActiveDays}/7 dias ativos',
                percent: weeklyProgress,
                color: reviewAccent,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ContrastPanel(
          accent: Colors.amberAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Leitura de progresso',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Seu build cresce melhor quando a semana segura o ritmo.',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                insights.review.recommendation,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),
              _buildOverviewBar(
                label: 'PROGRESSO DE LEVEL',
                trailing: '${player.xp}/${player.maxXp} XP',
                percent: levelProgress,
                color: AppColors.neonBlue,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'STREAK',
                      value: '${player.currentStreak} dias',
                      accent: Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      label: 'MELHOR',
                      value: '${player.bestStreak} dias',
                      accent: Colors.purpleAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      label: 'PONTOS',
                      value: '${player.statPoints}',
                      accent: player.statPoints > 0
                          ? Colors.amberAccent
                          : Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Atributos e distribuicao de pontos ficam em Build. Boss semanal e corrida competitiva ficam em Arena.',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttributesSection(
    BuildContext context,
    Player player,
    PlayerAttributes attrs,
  ) {
    return Column(
      key: const ValueKey('attributes'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Atributos',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white54,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  InfoTooltipIcon(
                    title: 'Atributos',
                    message:
                        'Use seus pontos livres para fortalecer o que mais combina com seu foco atual.',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _AttributeRow(
                label: 'FORCA',
                value: attrs.strength,
                accent: Colors.amberAccent,
                canUpgrade: player.statPoints > 0,
                onTap: () => ref
                    .read(playerProvider.notifier)
                    .upgradeAttribute(AttributeType.strength),
              ),
              _AttributeRow(
                label: 'INTELIGENCIA',
                value: attrs.intelligence,
                accent: AppColors.neonBlue,
                canUpgrade: player.statPoints > 0,
                onTap: () => ref
                    .read(playerProvider.notifier)
                    .upgradeAttribute(AttributeType.intelligence),
              ),
              _AttributeRow(
                label: 'VITALIDADE',
                value: attrs.vitality,
                accent: Colors.greenAccent,
                canUpgrade: player.statPoints > 0,
                onTap: () => ref
                    .read(playerProvider.notifier)
                    .upgradeAttribute(AttributeType.vitality),
              ),
              _AttributeRow(
                label: 'AGILIDADE',
                value: attrs.agility,
                accent: Colors.purpleAccent,
                canUpgrade: player.statPoints > 0,
                onTap: () => ref
                    .read(playerProvider.notifier)
                    .upgradeAttribute(AttributeType.agility),
              ),
              const SizedBox(height: 12),
              Text(
                player.statPoints > 0
                    ? 'Voce tem ${player.statPoints} ponto(s) para gastar.'
                    : 'Nenhum ponto livre no momento.',
                style: TextStyle(
                  color: player.statPoints > 0
                      ? Colors.amberAccent
                      : Colors.white60,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklySection(
    Player player,
    WeeklyInsightsBundle insights,
    WeeklyBossDefinition? weeklyBoss,
    int weeklyBossProgress,
    bool weeklyBossClaimed,
    List<CompetitiveRankSnapshot> rankHistory,
  ) {
    return Column(
      key: const ValueKey('week'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Semana',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white54,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  InfoTooltipIcon(
                    title: 'Leitura semanal',
                    message:
                        'Esse bloco resume como a sua semana esta indo e o que vale ajustar antes do reset.',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'SCORE',
                      value: '${insights.discipline.score}%',
                      accent: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      label: 'GRAU',
                      value: insights.discipline.grade,
                      accent: AppColors.neonBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                insights.review.summary,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                insights.review.recommendation,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11.8,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),
              LinearPercentIndicator(
                padding: EdgeInsets.zero,
                lineHeight: 10,
                percent: (insights.discipline.currentWeekActiveDays / 7).clamp(
                  0.0,
                  1.0,
                ),
                barRadius: const Radius.circular(999),
                backgroundColor: Colors.white10,
                progressColor: Colors.greenAccent,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Historico recente',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              if (rankHistory.isEmpty)
                const Text(
                  'Ainda nao ha semanas registradas.',
                  style: TextStyle(color: Colors.white60, fontSize: 12.5),
                )
              else
                ...rankHistory
                    .take(4)
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _MiniNote(
                          title: '${entry.weekKey} - ${entry.currentRank}',
                          text:
                              '${entry.activeDays}/${entry.requiredActiveDays} dias - ${entry.summary}',
                          accent: AppColors.neonBlue,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanSection(
    WeeklyInsightsBundle insights,
    WeeklyBossDefinition? weeklyBoss,
    CompetitiveRankSnapshot? rankSnapshot,
  ) {
    return Column(
      key: const ValueKey('plan'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Proxima semana',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white54,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  InfoTooltipIcon(
                    title: 'Proxima semana',
                    message:
                        'O plano organiza o que mais vale fazer agora para manter o ritmo e proteger o rank.',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                insights.nextWeekPlan.headline,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                insights.nextWeekPlan.summary,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              ...insights.nextWeekPlan.priorities.map(
                (priority) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.neonBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          priority,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _MiniNote(
                title: 'Regra',
                text: insights.nextWeekPlan.rule,
                accent: Colors.amberAccent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewBar({
    required String label,
    required String trailing,
    required double percent,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white54,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            Text(
              trailing,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: 9,
          percent: percent,
          barRadius: const Radius.circular(999),
          backgroundColor: Colors.white10,
          progressColor: color,
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceMuted,
            AppColors.surface,
            AppColors.surfaceStrong.withValues(alpha: 0.86),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AccentPanel extends StatelessWidget {
  const _AccentPanel({required this.child, required this.accent});

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
          colors: [
            accent.withValues(alpha: 0.08),
            AppColors.surface,
            AppColors.surfaceMuted,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
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

class _ContrastPanel extends StatelessWidget {
  const _ContrastPanel({required this.child, required this.accent});

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
          colors: [
            accent.withValues(alpha: 0.08),
            AppColors.surface,
            AppColors.surfaceMuted,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InlineBadge extends StatelessWidget {
  const _InlineBadge({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
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

class _MiniNote extends StatelessWidget {
  const _MiniNote({
    required this.title,
    required this.text,
    required this.accent,
  });

  final String title;
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.3,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionEntryCard extends StatelessWidget {
  const _SectionEntryCard({
    required this.title,
    required this.summary,
    required this.supporting,
    required this.badge,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String summary;
  final String supporting;
  final String badge;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 84),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            color: accent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              color: accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      summary,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    if (supporting.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        supporting,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.3,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withValues(alpha: 0.18)),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: accent,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 108),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttributeRow extends StatelessWidget {
  const _AttributeRow({
    required this.label,
    required this.value,
    required this.accent,
    required this.canUpgrade,
    required this.onTap,
  });

  final String label;
  final int value;
  final Color accent;
  final bool canUpgrade;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white54,
                      letterSpacing: 0.9,
                    ),
                  ),
                  const SizedBox(height: 6),
                  LinearPercentIndicator(
                    padding: EdgeInsets.zero,
                    lineHeight: 8,
                    percent: (value / 100).clamp(0.0, 1.0),
                    barRadius: const Radius.circular(999),
                    backgroundColor: Colors.white10,
                    progressColor: accent,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
            const SizedBox(width: 8),
            InkResponse(
              onTap: canUpgrade ? onTap : null,
              radius: 22,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: canUpgrade
                      ? accent.withValues(alpha: 0.16)
                      : Colors.white.withValues(alpha: 0.05),
                  border: Border.all(
                    color: canUpgrade
                        ? accent.withValues(alpha: 0.38)
                        : Colors.white10,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: canUpgrade ? accent : Colors.white38,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
