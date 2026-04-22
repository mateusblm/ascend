import 'package:ascend/core/widgets/reveal_block.dart';
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
  _StatsSection _currentSection = _StatsSection.overview;

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RevealBlock(
                child: _buildHeader(
                  context,
                  player,
                  authState,
                  rankSnapshot,
                  promotionExam,
                ),
              ),
              const SizedBox(height: 14),
              RevealBlock(
                delay: const Duration(milliseconds: 80),
                child: _buildSectionTabs(),
              ),
              const SizedBox(height: 14),
              RevealBlock(
                delay: const Duration(milliseconds: 140),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: switch (_currentSection) {
                    _StatsSection.overview => _buildOverviewSection(
                      player,
                      rankSnapshot,
                      insights,
                    ),
                    _StatsSection.build => _buildAttributesSection(
                      context,
                      player,
                      attrs,
                    ),
                    _StatsSection.week => _buildWeeklySection(
                      player,
                      insights,
                      weeklyBoss,
                      weeklyBossProgress,
                      weeklyBossClaimed,
                      rankHistory,
                    ),
                    _StatsSection.plan => _buildPlanSection(
                      player,
                      insights,
                      weeklyBoss,
                      rankSnapshot,
                    ),
                  },
                ),
              ),
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
    CompetitiveRankSnapshot? rankSnapshot,
    PromotionExam? promotionExam,
  ) {
    final currentRank =
        rankSnapshot?.currentRank ?? playerRankForLevel(player.level);
    final progress = player.maxXp == 0
        ? 0.0
        : (player.xp / player.maxXp).clamp(0.0, 1.0);

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'ANALISE',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (authState is AuthSuccess) ...[
                TextButton.icon(
                  onPressed: () => _openAccountScreen(context),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(
                    Icons.manage_accounts_rounded,
                    size: 16,
                    color: AppColors.neonBlue,
                  ),
                  label: const Text(
                    'CONTA',
                    style: TextStyle(
                      color: AppColors.neonBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              InfoTooltipIcon(
                title: 'Como ler esta tela',
                message:
                    'Aqui voce acompanha seu progresso, sua semana e o que vale ajustar. A tela de Rank cuida da parte competitiva.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Leitura de cadencia, planejamento da semana e gestao do seu build sem repetir a parte competitiva.',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.neonBlue.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonBlue.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.neonBlue.withValues(alpha: 0.30),
                    ),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.neonBlue,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rank $currentRank | Lv ${player.level}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearPercentIndicator(
                        padding: EdgeInsets.zero,
                        lineHeight: 8,
                        percent: progress,
                        barRadius: const Radius.circular(999),
                        backgroundColor: Colors.white10,
                        progressColor: AppColors.neonBlue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'XP',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white38,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      '${player.xp}/${player.maxXp}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'PONTOS',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white38,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      '${player.statPoints}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: player.statPoints > 0
                            ? Colors.amberAccent
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (promotionExam != null) ...[
            const SizedBox(height: 12),
            _MiniNote(
              title: 'Exame',
              text: switch (promotionExam.status) {
                PromotionExamStatus.inProgress =>
                  promotionExam.mode == PromotionExamMode.reconquest
                      ? 'Reconquista em andamento: meta de ${promotionExam.targetActiveDays} dias ativos.'
                      : 'Prova em andamento: meta de ${promotionExam.targetActiveDays} dias ativos.',
                PromotionExamStatus.passed =>
                  promotionExam.mode == PromotionExamMode.reconquest
                      ? 'Reconquista pronta para confirmar.'
                      : 'Promocao pronta para confirmar.',
                PromotionExamStatus.failed =>
                  'A prova expirou ou nao foi sustentada.',
                PromotionExamStatus.promoted =>
                  promotionExam.mode == PromotionExamMode.reconquest
                      ? 'Reconquista ja registrada.'
                      : 'Promocao ja registrada.',
              },
              accent: AppColors.neonBlue,
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

  Widget _buildSectionTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final section in _StatsSection.values) ...[
            _SectionChip(
              label: section.label,
              selected: section == _currentSection,
              onTap: () => setState(() => _currentSection = section),
            ),
            const SizedBox(width: 8),
          ],
        ],
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
                'RITMO ATUAL',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                  letterSpacing: 1.2,
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
                'LEITURA DE PROGRESSO',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                  letterSpacing: 1.2,
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
                'Atributos e distribuicao de pontos ficam na aba BUILD. Boss semanal e corrida competitiva ficam em RANK.',
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
                      'ATRIBUTOS',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white54,
                        letterSpacing: 1.2,
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
                      'SEMANA',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white54,
                        letterSpacing: 1.2,
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
                'HISTORICO RECENTE',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                  letterSpacing: 1.2,
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
    Player player,
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
                      'PROXIMA SEMANA',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white54,
                        letterSpacing: 1.2,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
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
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.3,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({
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
                  Icon(Icons.check, size: 14, color: foregroundColor),
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
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white54,
              letterSpacing: 1.0,
            ),
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

enum _StatsSection {
  overview('GERAL'),
  build('BUILD'),
  week('SEMANA'),
  plan('PLANO');

  const _StatsSection(this.label);

  final String label;
}
