import 'dart:math' as math;

import 'package:ascend/core/widgets/reveal_block.dart';
import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/auth/domain/auth_state.dart';
import 'package:ascend/features/auth/presentation/auth_controller.dart';
import 'package:ascend/features/profile/domain/achievement_modal.dart';
import 'package:ascend/features/profile/domain/first_week_journey.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/progress_payoff.dart';
import 'package:ascend/features/profile/domain/rank_prestige.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/rank_rivalry.dart';
import 'package:ascend/features/profile/domain/rank_season.dart';
import 'package:ascend/features/profile/domain/rank_season_leaderboard.dart';
import 'package:ascend/features/profile/domain/season_profile_snapshot.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/presentation/focus_selection_sheet.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/profile/presentation/rank_progression_provider.dart';
import 'package:ascend/features/weekly_boss/data/weekly_boss_repository.dart';
import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:ascend/features/weekly_boss/domain/weekly_boss_completion.dart';
import 'package:ascend/features/weekly_boss/presentation/weekly_boss_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final competitiveRank = ref.watch(competitiveRankProvider);
    final rankSnapshot = ref.watch(rankProgressionSnapshotProvider).valueOrNull;
    final rankHistory =
        ref.watch(rankProgressionHistoryProvider).valueOrNull ??
        const <CompetitiveRankSnapshot>[];
    final integrity = ref
        .watch(currentCompetitiveIntegrityProvider)
        .valueOrNull;
    final prestige = buildRankPrestigeSummary(
      rankHistory,
      integrity: integrity,
    );
    final season = buildCurrentSeasonSummary(rankHistory);
    final seasonProfile = ref.watch(seasonProfileProvider).valueOrNull;
    final seasonReward = ref.watch(currentSeasonRewardProvider).valueOrNull;
    final bracketLeaderboard =
        ref.watch(seasonBracketLeaderboardProvider).valueOrNull ??
        const <RankSeasonLeaderboardEntry>[];
    final authState = ref.watch(authProvider);
    final remoteWeeklyBoss = ref.watch(remoteWeeklyBossProvider);
    final topCompletions = ref.watch(weeklyBossTopCompletionsProvider);
    final firstWeekJourney = buildFirstWeekJourney(
      player: player,
      snapshot: rankSnapshot,
    );
    final progressPayoff = buildProgressPayoff(
      player: player,
      snapshot: rankSnapshot,
      seasonReward: seasonReward,
      seasonProfile: seasonProfile,
    );
    final rivalry = buildRankRivalrySummary(bracketLeaderboard);
    final heroSummary = firstWeekJourney.isActive
        ? firstWeekJourney.headline
        : progressPayoff.headline;
    final heroDetail = firstWeekJourney.isActive
        ? firstWeekJourney.nextAction
        : rankSnapshot?.summary ?? progressPayoff.body;
    final xpProgress = player.maxXp == 0
        ? 0.0
        : (player.xp / player.maxXp).clamp(0.0, 1.0);

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
                      name: player.name,
                      level: player.level,
                      rank: competitiveRank,
                      title: _resolveDisplayTitle(player, seasonProfile),
                      focus: player.primaryFocus,
                      summary: heroSummary,
                      detail: heroDetail,
                      xpProgress: xpProgress,
                      xp: player.xp,
                      maxXp: player.maxXp,
                      currentStreak: player.currentStreak,
                      seasonLabel: seasonProfile?.activeSeasonLabel,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: RevealBlock(
                  delay: const Duration(milliseconds: 70),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildSnapshotPanel(
                      context,
                      player: player,
                      firstWeekJourney: firstWeekJourney,
                      progressPayoff: progressPayoff,
                      rankSnapshot: rankSnapshot,
                      prestige: prestige,
                      season: season,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: RevealBlock(
                  delay: const Duration(milliseconds: 130),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildBuildPanel(context, player.attributes),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: RevealBlock(
                  delay: const Duration(milliseconds: 190),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildBaseDetailDirectory(
                      context,
                      player,
                      firstWeekJourney,
                      progressPayoff,
                      rankSnapshot,
                      prestige,
                      season,
                      rivalry,
                      authState,
                      remoteWeeklyBoss,
                      topCompletions,
                      competitiveRank,
                      ref,
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
    BuildContext context, {
    required String name,
    required int level,
    required String rank,
    required String title,
    required AwakeningPath focus,
    required String summary,
    required String detail,
    required double xpProgress,
    required int xp,
    required int maxXp,
    required int currentStreak,
    String? seasonLabel,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.neonBlue.withValues(alpha: 0.14),
            AppColors.surface.withValues(alpha: 0.96),
            AppColors.surfaceMuted.withValues(alpha: 0.98),
          ],
        ),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
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
                      'Base',
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.neonBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 28,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildHeaderPill(seasonLabel ?? 'Base ativa', AppColors.neonBlue),
            ],
          ),
          const SizedBox(height: 18),
          Text(summary, style: textTheme.titleLarge?.copyWith(height: 1.2)),
          const SizedBox(height: 8),
          Text(detail, style: textTheme.bodyMedium),
          const SizedBox(height: 18),
          _buildStatBar('XP', xpProgress, AppColors.neonBlue, '$xp / $maxXp'),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 138,
                child: _buildHeaderMetricCard(
                  label: 'LEVEL',
                  value: level.toString().padLeft(2, '0'),
                  accentColor: AppColors.neonBlue,
                ),
              ),
              SizedBox(
                width: 138,
                child: _buildHeaderMetricCard(
                  label: 'RANK',
                  value: rank,
                  accentColor: AppColors.arenaAccent,
                ),
              ),
              SizedBox(
                width: 138,
                child: _buildHeaderMetricCard(
                  label: 'STREAK',
                  value: '$currentStreak dias',
                  accentColor: Colors.orangeAccent,
                  compactValue: true,
                ),
              ),
              SizedBox(
                width: 138,
                child: _buildHeaderMetricCard(
                  label: 'FOCO',
                  value: focus.label,
                  accentColor: AppColors.questAccent,
                  compactValue: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotPanel(
    BuildContext context, {
    required Player player,
    required FirstWeekJourneySummary firstWeekJourney,
    required ProgressPayoffSummary progressPayoff,
    required CompetitiveRankSnapshot? rankSnapshot,
    required RankPrestigeSummary prestige,
    required RankSeasonSummary season,
  }) {
    final topLabel = firstWeekJourney.isActive
        ? firstWeekJourney.progressLabel
        : season.resetLabel;
    final headline = firstWeekJourney.isActive
        ? firstWeekJourney.nextAction
        : rankSnapshot?.summary ?? progressPayoff.headline;
    final body = firstWeekJourney.isActive
        ? firstWeekJourney.body
        : 'Constancia efetiva ${prestige.effectiveMaintenanceRate}% nesta temporada. ${progressPayoff.rankLabel}';

    return _buildStatusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Momento atual',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildHeaderPill(topLabel, AppColors.planAccent),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            headline,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          _buildFocusBanner(context, player.primaryFocus),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMiniMetric(
                  icon: Icons.local_fire_department,
                  label: 'STREAK',
                  value: '${player.currentStreak} dias',
                  accentColor: Colors.orangeAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniMetric(
                  icon: Icons.auto_awesome,
                  label: 'PONTOS LIVRES',
                  value: player.statPoints > 0
                      ? '${player.statPoints} disponiveis'
                      : 'Sem pontos livres',
                  accentColor: player.statPoints > 0
                      ? Colors.amberAccent
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(
              'Proximo ganho: ${progressPayoff.levelLabel}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildPanel(BuildContext context, PlayerAttributes attrs) {
    return _buildStatusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Build atual',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Radar compacto da sua build agora. O resto da leitura fica dentro do detalhe.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          _buildAttributeRadarPanel(context, attrs),
        ],
      ),
    );
  }

  Widget _buildHeaderPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.5,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildHeaderMetricCard({
    required String label,
    required String value,
    required Color accentColor,
    bool compactValue = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: compactValue ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compactValue ? 13 : 26,
              color: accentColor,
              fontWeight: FontWeight.w800,
              height: compactValue ? 1.2 : 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceMuted,
            AppColors.surface,
            AppColors.surfaceStrong.withValues(alpha: 0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
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

  Widget _buildFocusBanner(BuildContext context, AwakeningPath focus) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.neonBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonBlue.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'FOCO ATUAL',
                  style: TextStyle(fontSize: 10, color: Colors.white38),
                ),
              ),
              TextButton(
                onPressed: () => _openFocusSelectionSheet(context, focus),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  'Mudar',
                  style: TextStyle(
                    color: AppColors.neonBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            focus.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.neonBlue,
            ),
          ),
        ],
      ),
    );
  }

  void _openFocusSelectionSheet(
    BuildContext context,
    AwakeningPath currentFocus,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FocusSelectionSheet(currentFocus: currentFocus),
    );
  }

  Future<void> _claimWeeklyBoss(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    RemoteWeeklyBoss? remoteBoss,
    WeeklyBossDefinition weeklyBoss,
    String rank,
  ) async {
    if (authState is! AuthSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faca login para registrar e resgatar o boss semanal.'),
        ),
      );
      return;
    }

    if (remoteBoss == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum boss remoto ativo para resgate no momento.'),
        ),
      );
      return;
    }

    if (!weeklyBoss.isCompleted(ref.read(playerProvider)) ||
        weeklyBoss.isClaimedThisWeek(ref.read(playerProvider))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O boss semanal ainda nao esta pronto para resgate.'),
        ),
      );
      return;
    }

    try {
      final repository = ref.read(weeklyBossRepositoryProvider);
      final fallbackPlayer = ref.read(playerProvider);
      final remoteResult = await repository.claimWeeklyBoss(
        bossId: remoteBoss.id,
        uid: authState.uid,
        fallbackName: fallbackPlayer.name,
        displayName: authState.displayName,
        photoUrl: authState.photoUrl,
        rankAtCompletion: rank,
      );
      ref
          .read(playerProvider.notifier)
          .applyAuthoritativeProfile(remoteResult.player);
      if (!context.mounted) return;

      if (remoteResult.status == ClaimWeeklyBossRemoteResult.alreadyCompleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Seu clear remoto ja estava registrado nesta semana.',
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Boss semanal derrotado. Recompensa e ranking sincronizados.',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Falha ao registrar clear remoto. Tente novamente em instantes.',
          ),
        ),
      );
    }
  }

  Widget _buildStatBar(
    String label,
    double progress,
    Color color,
    String trailing,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              trailing,
              style: const TextStyle(fontSize: 10, color: Colors.white38),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white10,
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakPanel(Player player) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniMetric(
            icon: Icons.local_fire_department,
            label: 'STREAK ATUAL',
            value: '${player.currentStreak} dias',
            accentColor: Colors.orangeAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniMetric(
            icon: Icons.emoji_events,
            label: 'MELHOR STREAK',
            value: '${player.bestStreak} dias',
            accentColor: AppColors.neonBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildFirstWeekCard(FirstWeekJourneySummary summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neonBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonBlue.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Campanha inicial',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.neonBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                summary.progressLabel,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary.headline,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary.body,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11.5,
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
                    step.isDone
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
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
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: summary.progress,
              minHeight: 7,
              backgroundColor: Colors.white10,
              color: AppColors.neonBlue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            summary.nextAction,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressPayoffCard(ProgressPayoffSummary summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proximo ganho',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary.headline,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary.body,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          _buildMiniMetric(
            icon: Icons.trending_up,
            label: 'LEVEL',
            value: summary.levelLabel,
            accentColor: Colors.greenAccent,
          ),
          const SizedBox(height: 10),
          _buildMiniMetric(
            icon: Icons.military_tech,
            label: 'RANK',
            value: summary.rankLabel,
            accentColor: AppColors.neonBlue,
          ),
          const SizedBox(height: 10),
          _buildMiniMetric(
            icon: Icons.workspace_premium,
            label: 'TEMPORADA',
            value: summary.seasonLabel,
            accentColor: Colors.amberAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildRivalryCard(RankRivalrySummary summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amberAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disputa da semana',
            style: TextStyle(
              fontSize: 12,
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary.headline,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary.body,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          _buildMiniMetric(
            icon: Icons.north,
            label: 'QUEM ESTA NA SUA FRENTE',
            value: summary.chaseLabel,
            accentColor: Colors.amberAccent,
          ),
          const SizedBox(height: 10),
          _buildMiniMetric(
            icon: Icons.warning_amber_rounded,
            label: 'QUEM ESTA PERTO',
            value: summary.pressureLabel,
            accentColor: Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitivePulse(
    CompetitiveRankSnapshot? snapshot,
    RankPrestigeSummary prestige,
    RankSeasonSummary season,
  ) {
    final status = snapshot?.status ?? RankMaintenanceStatus.secure;
    final accentColor = switch (status) {
      RankMaintenanceStatus.secure => Colors.greenAccent,
      RankMaintenanceStatus.warning => Colors.orangeAccent,
      RankMaintenanceStatus.critical => Colors.redAccent,
      RankMaintenanceStatus.promotionReady => AppColors.neonBlue,
      RankMaintenanceStatus.demoted => Colors.redAccent,
    };

    final headline = switch (snapshot?.eventType) {
      CompetitiveRankEventType.promotionConfirmed => 'RANK CONFIRMADO',
      CompetitiveRankEventType.promotionUnlocked => 'PROVA LIBERADA',
      CompetitiveRankEventType.reconquestUnlocked => 'RETOMADA LIBERADA',
      CompetitiveRankEventType.demotionApplied => 'QUEDA DE RANK',
      CompetitiveRankEventType.perfectWeek => 'SEMANA FORTE',
      CompetitiveRankEventType.warning => 'ATENCAO NESTA SEMANA',
      _ => 'SEU MOMENTO',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  headline,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              Text(
                prestige.prestigeLabel,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            snapshot?.summary ?? 'Seu estado competitivo esta sincronizando.',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Temporada ${season.seasonLabel} | constancia ${prestige.effectiveMaintenanceRate}% | melhor rank ${season.peakRank}',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white38,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBossPanel(
    BuildContext context,
    WidgetRef ref,
    Player player,
    AuthState authState,
    AsyncValue<RemoteWeeklyBoss?> remoteWeeklyBoss,
    AsyncValue<List<WeeklyBossCompletion>> topCompletions,
    String competitiveRank,
  ) {
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
    final hasActiveRemoteBoss = weeklyBoss != null;
    final progress =
        weeklyBoss?.progressFor(player, competitiveOnly: true) ?? 0;
    final isClaimed = weeklyBoss?.isClaimedThisWeek(player) ?? false;
    final isCompleted =
        weeklyBoss?.isCompleted(player, competitiveOnly: true) ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_moon,
                color: Colors.amberAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Evento da semana',
                  style: TextStyle(fontSize: 12, color: Colors.white38),
                ),
              ),
              Text(
                hasActiveRemoteBoss
                    ? '$progress/${weeklyBoss.targetActiveDays}'
                    : '--',
                style: const TextStyle(
                  color: AppColors.neonBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (remoteBoss != null) ...[
            const SizedBox(height: 8),
            Text(
              'EVENTO ONLINE: ${remoteBoss.completedCount} concluidos',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ] else if (remoteWeeklyBoss.isLoading) ...[
            const SizedBox(height: 8),
            const Text(
              'EVENTO ONLINE: conectando...',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ] else if (remoteWeeklyBoss.hasError) ...[
            const SizedBox(height: 8),
            Text(
              'EVENTO ONLINE: erro ao consultar evento (${_shortError(remoteWeeklyBoss.error)})',
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ],
          const SizedBox(height: 10),
          if (hasActiveRemoteBoss) ...[
            Text(
              weeklyBoss.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              weeklyBoss.description,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (progress / weeklyBoss.targetActiveDays).clamp(0.0, 1.0),
                backgroundColor: Colors.white10,
                color: isCompleted ? Colors.amberAccent : AppColors.neonBlue,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'RECOMPENSA: ${weeklyBoss.rewardXp} XP + ${weeklyBoss.rewardStatPoints} pontos | conta so com dias competitivos validados',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isClaimed
                        ? Colors.white12
                        : (isCompleted ? Colors.amberAccent : Colors.white12),
                    foregroundColor: isCompleted && !isClaimed
                        ? Colors.black
                        : Colors.white54,
                  ),
                  onPressed: isCompleted && !isClaimed
                      ? () => _claimWeeklyBoss(
                          context,
                          ref,
                          authState,
                          remoteBoss,
                          weeklyBoss,
                          competitiveRank,
                        )
                      : null,
                  child: Text(isClaimed ? 'RESGATADO' : 'RESGATAR'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 12),
            const Text(
              'Quem ja concluiu',
              style: TextStyle(fontSize: 11, color: Colors.white38),
            ),
            const SizedBox(height: 10),
            ..._buildTopCompletions(topCompletions),
          ] else if (!remoteWeeklyBoss.isLoading &&
              !remoteWeeklyBoss.hasError) ...[
            const Text(
              'Nenhum desafio semanal ativo agora.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildTopCompletions(
    AsyncValue<List<WeeklyBossCompletion>> topCompletions,
  ) {
    return topCompletions.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const [
            Text(
              'Nenhum clear remoto registrado ainda.',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ];
        }

        return List.generate(entries.length, (index) {
          final entry = entries[index];
          final position = index + 1;
          final timestamp = entry.completedAt;
          final timeLabel = timestamp == null
              ? 'sincronizando...'
              : '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '#$position',
                    style: const TextStyle(
                      color: AppColors.neonBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.displayName,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timeLabel,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          );
        });
      },
      loading: () => const [
        Text(
          'Carregando ranking remoto...',
          style: TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
      error: (error, _) => [
        Text(
          'Falha ao carregar ranking: ${_shortError(error)}',
          style: const TextStyle(color: Colors.redAccent, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildBaseDetailDirectory(
    BuildContext context,
    Player player,
    FirstWeekJourneySummary firstWeekJourney,
    ProgressPayoffSummary progressPayoff,
    CompetitiveRankSnapshot? rankSnapshot,
    RankPrestigeSummary prestige,
    RankSeasonSummary season,
    RankRivalrySummary rivalry,
    AuthState authState,
    AsyncValue<RemoteWeeklyBoss?> remoteWeeklyBoss,
    AsyncValue<List<WeeklyBossCompletion>> topCompletions,
    String competitiveRank,
    WidgetRef ref,
  ) {
    final remoteBoss = remoteWeeklyBoss.valueOrNull;
    final pulseAccent = switch (rankSnapshot?.status) {
      RankMaintenanceStatus.secure => Colors.greenAccent,
      RankMaintenanceStatus.warning => Colors.orangeAccent,
      RankMaintenanceStatus.critical => Colors.redAccent,
      RankMaintenanceStatus.promotionReady => AppColors.neonBlue,
      RankMaintenanceStatus.demoted => Colors.redAccent,
      null => AppColors.planAccent,
    };

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
          'A superficie principal fica curta. O resto da leitura abre por camada.',
          style: TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        if (firstWeekJourney.isActive) ...[
          _BaseDetailEntry(
            title: 'Campanha Inicial',
            summary: firstWeekJourney.nextAction,
            accent: AppColors.neonBlue,
            onTap: () => _openBaseDetailSheet(
              context,
              title: 'Campanha Inicial',
              child: _buildFirstWeekCard(firstWeekJourney),
            ),
          ),
          const SizedBox(height: 10),
        ],
        _BaseDetailEntry(
          title: 'Ritmo e Streak',
          summary:
              '${player.currentStreak} dias agora | melhor ${player.bestStreak} dias',
          accent: Colors.orangeAccent,
          onTap: () => _openBaseDetailSheet(
            context,
            title: 'Ritmo e Streak',
            child: _buildStatusCard(child: _buildStreakPanel(player)),
          ),
        ),
        const SizedBox(height: 10),
        _BaseDetailEntry(
          title: 'Proximo ganho',
          summary: progressPayoff.headline,
          accent: AppColors.questAccent,
          onTap: () => _openBaseDetailSheet(
            context,
            title: 'Proximo ganho',
            child: _buildProgressPayoffCard(progressPayoff),
          ),
        ),
        const SizedBox(height: 10),
        _BaseDetailEntry(
          title: 'Pulso competitivo',
          summary:
              rankSnapshot?.summary ??
              'Seu estado competitivo ainda esta sincronizando.',
          accent: pulseAccent,
          onTap: () => _openBaseDetailSheet(
            context,
            title: 'Pulso competitivo',
            child: _buildCompetitivePulse(rankSnapshot, prestige, season),
          ),
        ),
        const SizedBox(height: 10),
        if (rivalry.isActive) ...[
          _BaseDetailEntry(
            title: 'Disputa da Arena',
            summary: rivalry.headline,
            accent: Colors.amberAccent,
            onTap: () => _openBaseDetailSheet(
              context,
              title: 'Disputa da Arena',
              child: _buildRivalryCard(rivalry),
            ),
          ),
          const SizedBox(height: 10),
        ],
        _BaseDetailEntry(
          title: 'Evento da Semana',
          summary: remoteBoss?.title ?? 'Nenhum boss remoto ativo agora.',
          accent: Colors.redAccent,
          onTap: () => _openBaseDetailSheet(
            context,
            title: 'Evento da Semana',
            child: _buildWeeklyBossPanel(
              context,
              ref,
              player,
              authState,
              remoteWeeklyBoss,
              topCompletions,
              competitiveRank,
            ),
          ),
        ),
      ],
    );
  }

  void _openBaseDetailSheet(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BaseDetailSheet(title: title, child: child),
    );
  }

  Widget _buildAttributeRadarPanel(
    BuildContext context,
    PlayerAttributes attrs,
  ) {
    final summary = _buildAttributeBuildSummary(attrs);
    final scaleMax = _attributeScaleMax(attrs);
    final items = <_AttributeVisualSpec>[
      _AttributeVisualSpec(
        label: 'FORCA',
        shortLabel: 'STR',
        value: attrs.strength,
        icon: Icons.fitness_center,
        color: Colors.redAccent,
        description: 'Pressao fisica e presenca em tarefas duras.',
      ),
      _AttributeVisualSpec(
        label: 'INTELIGENCIA',
        shortLabel: 'INT',
        value: attrs.intelligence,
        icon: Icons.psychology,
        color: Colors.cyanAccent,
        description: 'Clareza, estudo e leitura de situacao.',
      ),
      _AttributeVisualSpec(
        label: 'VITALIDADE',
        shortLabel: 'VIT',
        value: attrs.vitality,
        icon: Icons.favorite,
        color: Colors.greenAccent,
        description: 'Energia, constancia e margem de recuperacao.',
      ),
      _AttributeVisualSpec(
        label: 'AGILIDADE',
        shortLabel: 'AGI',
        value: attrs.agility,
        icon: Icons.speed,
        color: Colors.amberAccent,
        description: 'Velocidade de resposta e execucao.',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;
        final summaryCard = _buildAttributeSummaryCard(
          context,
          items,
          summary,
          scaleMax,
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 11,
                child: _buildAttributeChartBlock(items, scaleMax, summary),
              ),
              const SizedBox(width: 18),
              Expanded(flex: 10, child: summaryCard),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAttributeChartBlock(items, scaleMax, summary),
            const SizedBox(height: 18),
            summaryCard,
          ],
        );
      },
    );
  }

  Widget _buildAttributeChartBlock(
    List<_AttributeVisualSpec> items,
    int scaleMax,
    _AttributeBuildSummary summary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Leitura de build',
                style: TextStyle(fontSize: 11, color: Colors.white38),
              ),
            ),
            Text(
              'Escala $scaleMax',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.neonBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          summary.archetype,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          summary.focusLine,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white60,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 1,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, progress, child) {
              return CustomPaint(
                painter: _AttributeRadarPainter(
                  items: items,
                  scaleMax: scaleMax,
                  progress: progress,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (final item in items)
                        _AttributeRadarLabel(
                          spec: item,
                          index: items.indexOf(item),
                          total: items.length,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeDetailsBlock(
    List<_AttributeVisualSpec> items,
    _AttributeBuildSummary summary,
    int scaleMax,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary.archetype,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                summary.summary,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Dominante: ${summary.primaryLabel} | apoio: ${summary.secondaryLabel} | leitura relativa ate $scaleMax',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildAttributeInsightCard(item, scaleMax),
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeSummaryCard(
    BuildContext context,
    List<_AttributeVisualSpec> items,
    _AttributeBuildSummary summary,
    int scaleMax,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.archetype,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            summary.summary,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Dominante: ${summary.primaryLabel} | apoio: ${summary.secondaryLabel} | leitura relativa ate $scaleMax',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => _openBaseDetailSheet(
              context,
              title: 'Build',
              child: _buildAttributeDetailsBlock(items, summary, scaleMax),
            ),
            icon: const Icon(Icons.chevron_right_rounded),
            label: const Text('Abrir build'),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeInsightCard(_AttributeVisualSpec item, int scaleMax) {
    final progress = (item.value / scaleMax).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item.color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, size: 18, color: item.color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
              Text(
                item.value.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: item.color,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white10,
              color: item.color,
            ),
          ),
        ],
      ),
    );
  }

  String _resolveDisplayTitle(
    Player player,
    SeasonProfileSnapshot? seasonProfile,
  ) {
    if (seasonProfile != null) {
      return seasonProfile.activeTitleLabel;
    }
    return _calculateCurrentTitle(player);
  }

  String _calculateCurrentTitle(Player player) {
    final unlocked = systemAchievements
        .where((achievement) => achievement.requirement(player))
        .toList();
    return unlocked.isNotEmpty ? unlocked.last.title : 'Aspirante';
  }

  String _shortError(Object? error) {
    if (error == null) return 'desconhecido';
    final text = error.toString().replaceAll('\n', ' ');
    return text.length > 48 ? '${text.substring(0, 48)}...' : text;
  }

  int _attributeScaleMax(PlayerAttributes attrs) {
    final maxValue = [
      attrs.strength,
      attrs.intelligence,
      attrs.vitality,
      attrs.agility,
    ].reduce(math.max);
    return math.max(20, ((maxValue + 4) ~/ 5) * 5);
  }

  _AttributeBuildSummary _buildAttributeBuildSummary(PlayerAttributes attrs) {
    final entries = <MapEntry<String, int>>[
      MapEntry('FORCA', attrs.strength),
      MapEntry('INTELIGENCIA', attrs.intelligence),
      MapEntry('VITALIDADE', attrs.vitality),
      MapEntry('AGILIDADE', attrs.agility),
    ]..sort((a, b) => b.value.compareTo(a.value));

    final primary = entries[0];
    final secondary = entries[1];
    final spread = primary.value - entries.last.value;
    final isBalanced = spread <= 2;

    if (isBalanced) {
      return _AttributeBuildSummary(
        archetype: 'Build equilibrado',
        focusLine: 'Sem ponto fraco gritante.',
        primaryLabel: primary.key,
        secondaryLabel: secondary.key,
        summary:
            'Seu perfil esta distribuido. Isso passa leitura de consistencia, adaptacao e margem para varias linhas de quest sem depender de um unico atributo.',
      );
    }

    final archetype = switch (primary.key) {
      'FORCA' => 'Brutalista',
      'INTELIGENCIA' => 'Estratega',
      'VITALIDADE' => 'Tanque',
      'AGILIDADE' => 'Veloz',
      _ => 'Hunter',
    };

    return _AttributeBuildSummary(
      archetype: archetype,
      focusLine: '${primary.key} puxa sua leitura atual.',
      primaryLabel: primary.key,
      secondaryLabel: secondary.key,
      summary:
          '${primary.key} lidera sua build agora, com ${secondary.key} como apoio. O grafico mostra uma identidade mais marcada e menos neutra no jeito como voce progride.',
    );
  }
}

class _AttributeVisualSpec {
  const _AttributeVisualSpec({
    required this.label,
    required this.shortLabel,
    required this.value,
    required this.icon,
    required this.color,
    required this.description,
  });

  final String label;
  final String shortLabel;
  final int value;
  final IconData icon;
  final Color color;
  final String description;
}

class _AttributeBuildSummary {
  const _AttributeBuildSummary({
    required this.archetype,
    required this.focusLine,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.summary,
  });

  final String archetype;
  final String focusLine;
  final String primaryLabel;
  final String secondaryLabel;
  final String summary;
}

class _BaseDetailEntry extends StatelessWidget {
  const _BaseDetailEntry({
    required this.title,
    required this.summary,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String summary;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 84),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.06),
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
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      summary,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withValues(alpha: 0.25)),
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

class _BaseDetailSheet extends StatelessWidget {
  const _BaseDetailSheet({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.76,
      minChildSize: 0.55,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 10, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AttributeRadarLabel extends StatelessWidget {
  const _AttributeRadarLabel({
    required this.spec,
    required this.index,
    required this.total,
  });

  final _AttributeVisualSpec spec;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final angle = (-math.pi / 2) + ((2 * math.pi) / total) * index;
    final dx = math.cos(angle) * 0.82;
    final dy = math.sin(angle) * 0.82;

    return Align(
      alignment: Alignment(dx, dy),
      child: Transform.translate(
        offset: Offset(dx * 10, dy * 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: spec.color.withValues(alpha: 0.26)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(spec.icon, size: 14, color: spec.color),
              const SizedBox(width: 6),
              Text(
                spec.shortLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: spec.color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttributeRadarPainter extends CustomPainter {
  const _AttributeRadarPainter({
    required this.items,
    required this.scaleMax,
    required this.progress,
  });

  final List<_AttributeVisualSpec> items;
  final int scaleMax;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.34;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;

    for (var ring = 1; ring <= 5; ring++) {
      final ringRadius = radius * (ring / 5);
      final path = Path();
      for (var i = 0; i < items.length; i++) {
        final point = _pointForIndex(
          index: i,
          total: items.length,
          center: center,
          radius: ringRadius,
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (var i = 0; i < items.length; i++) {
      final point = _pointForIndex(
        index: i,
        total: items.length,
        center: center,
        radius: radius,
      );
      canvas.drawLine(center, point, axisPaint);
    }

    final dataPath = Path();
    for (var i = 0; i < items.length; i++) {
      final normalized = (items[i].value / scaleMax).clamp(0.18, 1.0);
      final point = _pointForIndex(
        index: i,
        total: items.length,
        center: center,
        radius: radius * normalized * progress,
      );
      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.neonBlue.withValues(alpha: 0.34),
          Colors.cyanAccent.withValues(alpha: 0.18),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = AppColors.neonBlue.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    for (var i = 0; i < items.length; i++) {
      final normalized = (items[i].value / scaleMax).clamp(0.18, 1.0);
      final point = _pointForIndex(
        index: i,
        total: items.length,
        center: center,
        radius: radius * normalized * progress,
      );
      canvas.drawCircle(point, 5, Paint()..color = items[i].color);
      canvas.drawCircle(
        point,
        9,
        Paint()
          ..color = items[i].color.withValues(alpha: 0.16)
          ..style = PaintingStyle.fill,
      );
    }
  }

  Offset _pointForIndex({
    required int index,
    required int total,
    required Offset center,
    required double radius,
  }) {
    final angle = (-math.pi / 2) + ((2 * math.pi) / total) * index;
    return Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
  }

  @override
  bool shouldRepaint(covariant _AttributeRadarPainter oldDelegate) {
    return oldDelegate.items != items ||
        oldDelegate.scaleMax != scaleMax ||
        oldDelegate.progress != progress;
  }
}
