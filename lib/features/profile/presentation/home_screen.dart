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
    final integrity = ref.watch(currentCompetitiveIntegrityProvider).valueOrNull;
    final prestige = buildRankPrestigeSummary(rankHistory, integrity: integrity);
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RevealBlock(
              child: _buildHeader(
                player.name,
                player.level,
                competitiveRank,
                _resolveDisplayTitle(player, seasonProfile),
                seasonProfile,
              ),
            ),
            const SizedBox(height: 40),
            RevealBlock(
              delay: const Duration(milliseconds: 90),
              child: _buildStatusCard(
                child: Column(
                  children: [
                    _buildFocusBanner(context, player.primaryFocus),
                    const SizedBox(height: 20),
                    _buildStatBar(
                      'XP',
                      player.xp / player.maxXp,
                      AppColors.neonBlue,
                      '${player.xp} / ${player.maxXp}',
                    ),
                    const SizedBox(height: 20),
                    _buildStatBar('HP', 1.0, Colors.redAccent, '100%'),
                    const SizedBox(height: 24),
                    _buildCompetitivePulse(rankSnapshot, prestige, season),
                    const SizedBox(height: 20),
                    if (firstWeekJourney.isActive) ...[
                      _buildFirstWeekCard(firstWeekJourney),
                      const SizedBox(height: 20),
                    ],
                    _buildProgressPayoffCard(progressPayoff),
                    const SizedBox(height: 20),
                    if (rivalry.isActive) ...[
                      _buildRivalryCard(rivalry),
                      const SizedBox(height: 20),
                    ],
                    _buildStreakPanel(player),
                    const SizedBox(height: 20),
                    _buildWeeklyBossPanel(
                      context,
                      ref,
                      player,
                      authState,
                      remoteWeeklyBoss,
                      topCompletions,
                      competitiveRank,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            RevealBlock(
              delay: const Duration(milliseconds: 180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeading(
                    'ATRIBUTOS',
                    'Sua base permanente de crescimento.',
                  ),
                  const SizedBox(height: 10),
                  _buildAttributeRow(
                    'FORCA',
                    player.attributes.strength.toString(),
                    Icons.fitness_center,
                  ),
                  _buildAttributeRow(
                    'INTELIGENCIA',
                    player.attributes.intelligence.toString(),
                    Icons.psychology,
                  ),
                  _buildAttributeRow(
                    'VITALIDADE',
                    player.attributes.vitality.toString(),
                    Icons.favorite,
                  ),
                  _buildAttributeRow(
                    'AGILIDADE',
                    player.attributes.agility.toString(),
                    Icons.speed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: Text(
                '"O MEDO NAO E UM OBSTACULO, E UMA FERRAMENTA."',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white10,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    String name,
    int level,
    String rank,
    String title,
    SeasonProfileSnapshot? seasonProfile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'JOGADOR: $name | $title',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.neonBlue,
            letterSpacing: 1.5,
          ),
        ),
        if (seasonProfile != null) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSeasonHeaderChip(
                seasonProfile.activeBadgeLabel,
                Colors.amberAccent,
              ),
              _buildSeasonHeaderChip(
                seasonProfile.cosmeticAuraLabel,
                AppColors.neonBlue,
              ),
              _buildSeasonHeaderChip(
                seasonProfile.activeSeasonLabel,
                Colors.white70,
              ),
            ],
          ),
        ],
        const SizedBox(height: 4),
        const Text(
          'Veja rapido como voce esta, o que falta e qual e o desafio da vez.',
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.white60,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RANK: $rank',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: AppColors.neonBlue.withValues(alpha: 0.8),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'LEVEL',
                  style: TextStyle(fontSize: 10, color: Colors.white38),
                ),
                Text(
                  level.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeasonHeaderChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildStatusCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(color: AppColors.neonBlue, thickness: 0.5),
      ],
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
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white38,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _openFocusSelectionSheet(context, focus),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'ALTERAR',
                  style: TextStyle(
                    color: AppColors.neonBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
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
              letterSpacing: 1.5,
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
      final remoteResult = await repository.claimWeeklyBoss(
        bossId: remoteBoss.id,
        displayName: authState.displayName,
        photoUrl: authState.photoUrl,
        rankAtCompletion: rank,
      );
      if (!context.mounted) return;

      if (remoteResult == ClaimWeeklyBossRemoteResult.alreadyCompleted) {
        ref.read(playerProvider.notifier).markWeeklyBossClaimedNow();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Seu clear remoto ja estava registrado nesta semana.',
            ),
          ),
        );
        return;
      }

      final applied = ref
          .read(playerProvider.notifier)
          .claimWeeklyBossReward(weeklyBoss);
      if (!applied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Clear remoto registrado, mas recompensa local ja estava aplicada.',
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
                  'PRIMEIRA SEMANA',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.neonBlue,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
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
            'PROXIMO GANHO',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white54,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
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
            'DISPUTA DA SEMANA',
            style: TextStyle(
              fontSize: 12,
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
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
    final progress = weeklyBoss?.progressFor(player, competitiveOnly: true) ?? 0;
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
                  'DESAFIO DA SEMANA',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white38,
                    letterSpacing: 1.2,
                  ),
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
              'QUEM JA CONCLUIU',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white38,
                letterSpacing: 1.1,
              ),
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

  Widget _buildAttributeRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.neonBlue.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 15),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, letterSpacing: 1),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.neonBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'Courier',
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
    return unlocked.isNotEmpty ? unlocked.last.title : 'ASPIRANTE';
  }

  String _shortError(Object? error) {
    if (error == null) return 'desconhecido';
    final text = error.toString().replaceAll('\n', ' ');
    return text.length > 48 ? '${text.substring(0, 48)}...' : text;
  }
}
