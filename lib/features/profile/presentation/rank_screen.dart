import 'package:ascend/core/widgets/reveal_block.dart';
import 'package:ascend/core/widgets/detail_shell_screen.dart';
import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/competitive_integrity.dart';
import 'package:ascend/features/profile/domain/promotion_exam.dart';
import 'package:ascend/features/profile/domain/rank_arena.dart';
import 'package:ascend/features/profile/domain/rank_prestige.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/rank_rivalry.dart';
import 'package:ascend/features/profile/domain/rank_season.dart';
import 'package:ascend/features/profile/domain/rank_season_leaderboard.dart';
import 'package:ascend/features/profile/domain/season_legacy_reward.dart';
import 'package:ascend/features/profile/domain/season_profile_snapshot.dart';
import 'package:ascend/features/profile/domain/season_reward_snapshot.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/presentation/info_tooltip.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/profile/presentation/rank_progression_provider.dart';
import 'package:ascend/features/weekly_boss/domain/weekly_boss_completion.dart';
import 'package:ascend/features/weekly_boss/presentation/weekly_boss_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

class RankScreen extends ConsumerStatefulWidget {
  const RankScreen({super.key});

  @override
  ConsumerState<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends ConsumerState<RankScreen> {
  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final snapshot = ref.watch(rankProgressionSnapshotProvider).valueOrNull;
    final history =
        ref.watch(rankProgressionHistoryProvider).valueOrNull ??
        const <CompetitiveRankSnapshot>[];
    final exam = ref.watch(promotionExamProvider).valueOrNull;
    final currentSeasonReward = ref
        .watch(currentSeasonRewardProvider)
        .valueOrNull;
    final integrity = ref
        .watch(currentCompetitiveIntegrityProvider)
        .valueOrNull;
    final seasonProfile = ref.watch(seasonProfileProvider).valueOrNull;
    final seasonLegacyHistory =
        ref.watch(seasonLegacyHistoryProvider).valueOrNull ??
        const <SeasonLegacyReward>[];
    final bracketLeaderboard =
        ref.watch(seasonBracketLeaderboardProvider).valueOrNull ??
        const <RankSeasonLeaderboardEntry>[];
    final remoteWeeklyBoss = ref.watch(remoteWeeklyBossProvider);
    final topCompletions =
        ref.watch(weeklyBossTopCompletionsProvider).valueOrNull ??
        const <WeeklyBossCompletion>[];

    final season = buildCurrentSeasonSummary(history);
    final prestige = buildRankPrestigeSummary(history, integrity: integrity);
    final arena = buildRankArenaSummary(
      player: player,
      boss: remoteWeeklyBoss.valueOrNull,
      topCompletions: topCompletions,
    );
    final leaderboard = buildRankSeasonLeaderboardSummary(
      player: player,
      season: season,
      activeBoss: remoteWeeklyBoss.valueOrNull,
      topCompletions: topCompletions,
      snapshot: snapshot,
      integrity: integrity,
      globalLeaderboard: bracketLeaderboard,
    );
    final rivalry = buildRankRivalrySummary(bracketLeaderboard);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RevealBlock(child: _buildHero(player, snapshot)),
              const SizedBox(height: 14),
              RevealBlock(
                delay: const Duration(milliseconds: 80),
                child: _buildArenaHub(
                  context,
                  player,
                  snapshot,
                  exam,
                  arena,
                  prestige,
                  integrity,
                  season,
                  leaderboard,
                  currentSeasonReward,
                  rivalry,
                  history,
                  seasonProfile,
                  seasonLegacyHistory,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(Player player, CompetitiveRankSnapshot? snapshot) {
    final currentRank =
        snapshot?.currentRank ?? playerRankForLevel(player.level);
    final status = snapshot?.status ?? RankMaintenanceStatus.secure;
    final accent = _statusColor(status);
    final peakRank = snapshot?.peakRank ?? currentRank;
    final nextRank = snapshot?.promotionTargetRank ?? rankAfter(currentRank);
    final eligibleRank =
        snapshot?.highestEligibleRank ?? playerRankForLevel(player.level);
    final heroMessage =
        snapshot?.summary ?? 'Seu estado competitivo ainda esta sincronizando.';

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ARENA',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const InfoTooltipIcon(
                title: 'Como ler esta tela',
                message:
                    'Agora mostra o que precisa ser feito nesta semana. Temporada resume seu momento atual. Legado guarda o que voce ja conquistou.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Veja seu posto atual, o que falta para manter e o que abre a proxima subida.',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  accent.withValues(alpha: 0.18),
                  AppColors.neonBlue.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: accent.withValues(alpha: 0.30)),
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
                          const Text(
                            'SEU RANK AGORA',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white54,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentRank,
                            style: TextStyle(
                              fontSize: 58,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: accent.withValues(alpha: 0.65),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _StatusPill(
                                label: _statusLabel(status),
                                color: accent,
                              ),
                              _StatusPill(
                                label: 'PICO $peakRank',
                                color: Colors.amberAccent,
                              ),
                              if (nextRank != null)
                                _StatusPill(
                                  label: 'PROXIMO $nextRank',
                                  color: AppColors.neonBlue,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'LEVEL',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white38,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Text(
                          player.level.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  heroMessage,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Seu level ${player.level} ja permite buscar ate o rank $eligibleRank.',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArenaHub(
    BuildContext context,
    Player player,
    CompetitiveRankSnapshot? snapshot,
    PromotionExam? exam,
    RankArenaSummary arena,
    RankPrestigeSummary prestige,
    CompetitiveIntegritySnapshot? integrity,
    RankSeasonSummary season,
    RankSeasonLeaderboardSummary leaderboard,
    SeasonRewardSnapshot? currentSeasonReward,
    RankRivalrySummary rivalry,
    List<CompetitiveRankSnapshot> history,
    SeasonProfileSnapshot? seasonProfile,
    List<SeasonLegacyReward> seasonLegacyHistory,
  ) {
    final currentRank =
        snapshot?.currentRank ?? playerRankForLevel(player.level);
    final status = snapshot?.status ?? RankMaintenanceStatus.secure;
    final accent = _statusColor(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.14),
                Colors.redAccent.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withValues(alpha: 0.20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TABULEIRO DA SEMANA',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'POSTO',
                      value: currentRank,
                      accent: accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      label: 'TEMPORADA',
                      value: season.rewardStatusLabel,
                      accent: AppColors.neonBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      label: 'PRESTIGIO',
                      value: prestige.prestigeLabel,
                      accent: Colors.amberAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionEntryCard(
          title: 'PRESSAO ATUAL',
          summary: snapshot?.summary ?? arena.leaderHeadline,
          supporting:
              'Manutencao do posto, prova ativa e evento competitivo da semana.',
          badge: _statusLabel(status),
          accent: accent,
          onTap: () => _openRankDetail(
            context,
            title: 'Pressao Atual',
            subtitle:
                'Manutencao do posto, promocao ou reconquista e evento competitivo da semana.',
            child: _buildNowSection(
              context,
              player,
              snapshot,
              exam,
              arena,
              prestige,
              integrity,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SectionEntryCard(
          title: 'CORRIDA SAZONAL',
          summary:
              '${leaderboard.playerStandingLabel} | ${season.rewardStatusLabel}',
          supporting:
              'Pontuacao sazonal, recompensa do ciclo e disputa do grupo atual.',
          badge: season.rewardTierLabel,
          accent: AppColors.neonBlue,
          onTap: () => _openRankDetail(
            context,
            title: 'Corrida Sazonal',
            subtitle:
                'Corrida sazonal, recompensa do ciclo e situacao atual do seu grupo.',
            child: _buildSeasonSection(
              context,
              player,
              season,
              leaderboard,
              currentSeasonReward,
              rivalry,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SectionEntryCard(
          title: 'LEGADO',
          summary:
              seasonProfile?.activeTitleLabel ??
              'Pico atual: ${snapshot?.peakRank ?? currentRank}',
          supporting:
              'Arquivo competitivo, recompensas permanentes e historico ja consolidado.',
          badge: season.peakRank == '-'
              ? (snapshot?.peakRank ?? currentRank)
              : season.peakRank,
          accent: Colors.amberAccent,
          onTap: () => _openRankDetail(
            context,
            title: 'Legado',
            subtitle:
                'Titulos, picos, recompensas permanentes e trilha historica da conta.',
            child: _buildLegacySection(
              snapshot,
              history,
              seasonProfile,
              seasonLegacyHistory,
            ),
          ),
        ),
      ],
    );
  }

  void _openRankDetail(
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

  Widget _buildNowSection(
    BuildContext context,
    Player player,
    CompetitiveRankSnapshot? snapshot,
    PromotionExam? exam,
    RankArenaSummary arena,
    RankPrestigeSummary prestige,
    CompetitiveIntegritySnapshot? integrity,
  ) {
    return Column(
      key: const ValueKey('rank-now'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNowCard(player, snapshot),
        const SizedBox(height: 12),
        _buildPromotionExamCard(context, player, snapshot, exam),
        const SizedBox(height: 12),
        _buildArenaCard(arena),
        const SizedBox(height: 12),
        if (integrity != null) ...[
          _buildIntegrityCard(integrity),
          const SizedBox(height: 12),
        ],
        _buildMomentumCard(prestige),
      ],
    );
  }

  Widget _buildNowCard(Player player, CompetitiveRankSnapshot? snapshot) {
    final currentRank =
        snapshot?.currentRank ?? playerRankForLevel(player.level);
    final currentRule = rankRuleFor(currentRank);
    final nextRank = snapshot?.promotionTargetRank ?? rankAfter(currentRank);
    final nextRule = nextRank == null ? null : rankRuleFor(nextRank);
    final currentProgress =
        snapshot == null || currentRule.requiredActiveDays == 0
        ? 0.0
        : (snapshot.activeDays / currentRule.requiredActiveDays).clamp(
            0.0,
            1.0,
          );
    final remainingCurrentDays = snapshot == null
        ? currentRule.requiredActiveDays
        : (currentRule.requiredActiveDays - snapshot.activeDays).clamp(
            0,
            currentRule.requiredActiveDays,
          );
    final nextBoss = nextRank == null ? null : weeklyBossForRank(nextRank);
    final nextActiveDays =
        nextBoss?.progressFor(player) ?? snapshot?.activeDays ?? 0;
    final nextBossDone = nextBoss?.isCompleted(player) ?? false;
    final nextProgress = nextRule == null || nextRule.requiredActiveDays == 0
        ? 0.0
        : (nextActiveDays / nextRule.requiredActiveDays).clamp(0.0, 1.0);
    final targetLevel =
        snapshot?.targetRequiredLevel ?? nextRule?.minimumLevel ?? player.level;
    final targetLevelGateMet = snapshot?.targetLevelGateMet ?? true;
    final mode = snapshot?.advancementMode;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AGORA',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white54,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _InfoBanner(
            title: _statusHeadline(
              snapshot?.status ?? RankMaintenanceStatus.secure,
            ),
            body: remainingCurrentDays == 0
                ? 'Seu rank desta semana esta protegido por atividade competitiva validada.'
                : 'Faltam $remainingCurrentDays dia(s) competitivos validados para segurar o rank $currentRank.',
            accent: _statusColor(
              snapshot?.status ?? RankMaintenanceStatus.secure,
            ),
          ),
          const SizedBox(height: 12),
          _SplitMetricRow(
            left: _MetricCard(
              label: 'SEGURAR $currentRank',
              value:
                  '${snapshot?.activeDays ?? 0}/${currentRule.requiredActiveDays} dias validos',
              accent: AppColors.neonBlue,
            ),
            right: _MetricCard(
              label: 'DESAFIO DO RANK',
              value: currentRule.requiresBossClear
                  ? ((snapshot?.bossCompleted ?? false) ? 'OK' : 'PENDENTE')
                  : 'NAO EXIGIDO',
              accent: (snapshot?.bossCompleted ?? false)
                  ? Colors.greenAccent
                  : Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 10,
            percent: currentProgress,
            barRadius: const Radius.circular(999),
            backgroundColor: Colors.white10,
            progressColor: _statusColor(
              snapshot?.status ?? RankMaintenanceStatus.secure,
            ),
          ),
          if (nextRank != null && nextRule != null) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 16),
            Text(
              mode == RankAdvancementMode.reconquest
                  ? 'RECONQUISTA DE $nextRank'
                  : 'SUBIR PARA $nextRank',
              style: TextStyle(
                fontSize: 13,
                color: targetLevelGateMet
                    ? AppColors.neonBlue
                    : Colors.orangeAccent,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              targetLevelGateMet
                  ? mode == RankAdvancementMode.reconquest
                        ? 'Seu level ja permite voltar para $nextRank. Agora falta fechar a semana.'
                        : 'Seu level ja permite tentar $nextRank. Agora falta fechar a semana.'
                  : 'O rank $nextRank abre a partir do level $targetLevel.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            _SplitMetricRow(
              left: _MetricCard(
                label: 'DIAS PARA LIBERAR',
                value:
                    '$nextActiveDays/${nextRule.requiredActiveDays} dias validos',
                accent: nextActiveDays >= nextRule.requiredActiveDays
                    ? Colors.greenAccent
                    : AppColors.neonBlue,
              ),
              right: _MetricCard(
                label: 'DESAFIO DO $nextRank',
                value: nextRule.requiresBossClear
                    ? (nextBossDone ? 'OK' : 'PENDENTE')
                    : 'NAO EXIGIDO',
                accent: nextRule.requiresBossClear
                    ? (nextBossDone ? Colors.greenAccent : Colors.white70)
                    : Colors.white70,
              ),
            ),
            const SizedBox(height: 10),
            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              lineHeight: 10,
              percent: nextProgress,
              barRadius: const Radius.circular(999),
              backgroundColor: Colors.white10,
              progressColor: targetLevelGateMet
                  ? AppColors.neonBlue
                  : Colors.orangeAccent,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusPill(
                  label: targetLevelGateMet ? 'LEVEL OK' : 'LEVEL $targetLevel',
                  color: targetLevelGateMet
                      ? AppColors.neonBlue
                      : Colors.orangeAccent,
                ),
                if (snapshot?.promotionReady == true)
                  const _StatusPill(
                    label: 'EXAME LIBERADO',
                    color: Colors.greenAccent,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPromotionExamCard(
    BuildContext context,
    Player player,
    CompetitiveRankSnapshot? snapshot,
    PromotionExam? exam,
  ) {
    final examMode =
        exam?.mode ??
        (snapshot?.advancementMode == RankAdvancementMode.reconquest
            ? PromotionExamMode.reconquest
            : PromotionExamMode.ascension);
    final accent = switch (exam?.status ?? snapshot?.status) {
      PromotionExamStatus.passed => Colors.greenAccent,
      PromotionExamStatus.failed => Colors.redAccent,
      PromotionExamStatus.promoted => AppColors.neonBlue,
      PromotionExamStatus.inProgress => Colors.orangeAccent,
      _ => AppColors.neonBlue,
    };
    final title = switch (exam?.status) {
      PromotionExamStatus.inProgress =>
        examMode == PromotionExamMode.reconquest
            ? 'RECONQUISTA EM CURSO'
            : 'PROVA EM CURSO',
      PromotionExamStatus.passed =>
        examMode == PromotionExamMode.reconquest
            ? 'RECONQUISTA PRONTA'
            : 'PROMOCAO PRONTA',
      PromotionExamStatus.failed => 'PROVA NAO CONCLUIDA',
      PromotionExamStatus.promoted => 'RANK ATUALIZADO',
      null =>
        snapshot?.promotionReady == true
            ? (snapshot?.advancementMode == RankAdvancementMode.reconquest
                  ? 'RECONQUISTA DISPONIVEL'
                  : 'PROVA DISPONIVEL')
            : 'PROVA DE RANK',
    };
    final body = switch (exam?.status) {
      PromotionExamStatus.inProgress =>
        examMode == PromotionExamMode.reconquest
            ? 'Voce ja cumpriu a base da semana. Agora falta fechar a prova para voltar ao seu pico.'
            : 'Voce ja cumpriu a base da semana. Agora falta fechar a prova para subir.',
      PromotionExamStatus.passed =>
        examMode == PromotionExamMode.reconquest
            ? 'A prova foi vencida. Agora voce pode recuperar seu rank.'
            : 'A prova foi vencida. Agora voce pode confirmar a subida.',
      PromotionExamStatus.failed =>
        'A prova expirou ou nao foi sustentada a tempo.',
      PromotionExamStatus.promoted =>
        'A ultima prova ja foi convertida em rank.',
      null =>
        snapshot?.promotionReady == true
            ? (snapshot?.advancementMode == RankAdvancementMode.reconquest
                  ? 'Seu historico ja provou esse posto. Falta so passar na prova de retorno.'
                  : 'Voce ja cumpriu os requisitos. Falta so passar na prova final.')
            : 'Quando sua semana liberar uma prova, ela aparece aqui.',
    };

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROXIMA ETAPA',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white54,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _InfoBanner(title: title, body: body, accent: accent),
          if (exam != null) ...[
            const SizedBox(height: 12),
            _SplitMetricRow(
              left: _MetricCard(
                label: 'META',
                value: '${exam.targetActiveDays} dias',
                accent: accent,
              ),
              right: _MetricCard(
                label: 'PRAZO',
                value: _formatShortDate(exam.expiresAt),
                accent: Colors.white70,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (snapshot?.promotionReady == true && exam == null)
                _ActionButton(
                  label:
                      snapshot?.advancementMode ==
                          RankAdvancementMode.reconquest
                      ? 'INICIAR RECONQUISTA'
                      : 'INICIAR EXAME',
                  accent: AppColors.neonBlue,
                  onTap: () async {
                    final success = await ref
                        .read(rankProgressionRepositoryProvider)
                        .startPromotionExam(snapshot!);
                    if (!context.mounted) return;
                    _showSnackBar(
                      context,
                      success
                          ? (snapshot.advancementMode ==
                                    RankAdvancementMode.reconquest
                                ? 'Prova de reconquista iniciada.'
                                : 'Exame iniciado.')
                          : 'Nao foi possivel iniciar a prova agora.',
                    );
                  },
                ),
              if (exam?.status == PromotionExamStatus.passed &&
                  snapshot != null)
                _ActionButton(
                  label: exam?.mode == PromotionExamMode.reconquest
                      ? 'RECONQUISTAR RANK'
                      : 'PROMOVER RANK',
                  accent: Colors.greenAccent,
                  onTap: () async {
                    final success = await ref
                        .read(rankProgressionRepositoryProvider)
                        .promoteIfExamPassed(snapshot);
                    if (!context.mounted) return;
                    _showSnackBar(
                      context,
                      success
                          ? (exam?.mode == PromotionExamMode.reconquest
                                ? 'Rank recuperado.'
                                : 'Promocao confirmada.')
                          : 'Nao foi possivel confirmar o resultado.',
                    );
                  },
                ),
              if (exam?.status == PromotionExamStatus.inProgress)
                _ActionButton(
                  label: 'ATUALIZAR STATUS',
                  accent: Colors.orangeAccent,
                  onTap: () async {
                    await ref
                        .read(rankProgressionRepositoryProvider)
                        .syncCompetitiveState(player);
                    if (!context.mounted) return;
                    _showSnackBar(context, 'Status da prova atualizado.');
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArenaCard(RankArenaSummary arena) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EVENTO DA SEMANA',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white54,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _InfoBanner(
            title: arena.stateLabel,
            body: arena.leaderHeadline,
            accent: arena.hasActiveBoss ? Colors.amberAccent : Colors.white70,
          ),
          const SizedBox(height: 12),
          _SplitMetricRow(
            left: _MetricCard(
              label: 'SEU PROGRESSO',
              value: arena.hasActiveBoss
                  ? '${arena.progress}/${arena.target} dias'
                  : '--',
              accent: AppColors.neonBlue,
            ),
            right: _MetricCard(
              label: 'ARENA',
              value: arena.urgencyLabel,
              accent: Colors.amberAccent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            arena.rewardLabel,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            arena.crowdReading,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11.8,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMomentumCard(RankPrestigeSummary prestige) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONSISTENCIA',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white54,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _InfoBanner(
            title: prestige.prestigeLabel,
            body: _prestigeReading(prestige),
            accent: AppColors.neonBlue,
          ),
          const SizedBox(height: 12),
          _SplitMetricRow(
            left: _MetricCard(
              label: 'SEMANAS SEGURAS',
              value: '${prestige.effectiveMaintenanceRate}%',
              accent: Colors.greenAccent,
            ),
            right: _MetricCard(
              label: 'LEITURA',
              value: prestige.integrityBandLabel,
              accent: AppColors.neonBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonSection(
    BuildContext context,
    Player player,
    RankSeasonSummary season,
    RankSeasonLeaderboardSummary leaderboard,
    SeasonRewardSnapshot? currentSeasonReward,
    RankRivalrySummary rivalry,
  ) {
    return Column(
      key: const ValueKey('rank-season'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSeasonSummaryCard(season),
        const SizedBox(height: 12),
        _buildSeasonRewardCard(context, season, currentSeasonReward),
        const SizedBox(height: 12),
        _buildSeasonLeaderboardCard(leaderboard),
        if (rivalry.isActive) ...[
          const SizedBox(height: 12),
          _buildRivalryPanel(rivalry),
        ],
      ],
    );
  }

  Widget _buildSeasonSummaryCard(RankSeasonSummary season) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TEMPORADA',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white54,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _InfoBanner(
            title: season.rewardStatusLabel,
            body:
                '${season.seasonLabel}. ${season.nextUnlockHint} ${season.resetLabel}.',
            accent: AppColors.neonBlue,
          ),
          const SizedBox(height: 12),
          _SplitMetricRow(
            left: _MetricCard(
              label: 'TRILHA',
              value: season.rewardTrackLabel,
              accent: AppColors.neonBlue,
            ),
            right: _MetricCard(
              label: 'PICO',
              value: season.peakRank,
              accent: Colors.amberAccent,
            ),
          ),
          const SizedBox(height: 10),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 10,
            percent: season.rewardProgress.clamp(0.0, 1.0),
            barRadius: const Radius.circular(999),
            backgroundColor: Colors.white10,
            progressColor: AppColors.neonBlue,
          ),
          const SizedBox(height: 12),
          _SplitMetricRow(
            left: _MetricCard(
              label: 'SEMANAS SEGURAS',
              value: '${season.secureWeeks}/${season.recordedWeeks}',
              accent: Colors.greenAccent,
            ),
            right: _MetricCard(
              label: 'MEDIA',
              value: '${season.averageActiveDays.toStringAsFixed(1)} dias',
              accent: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonRewardCard(
    BuildContext context,
    RankSeasonSummary season,
    SeasonRewardSnapshot? currentSeasonReward,
  ) {
    final reward = currentSeasonReward;
    final claimStatus = reward?.claimStatus ?? SeasonRewardClaimStatus.locked;
    final accent = switch (claimStatus) {
      SeasonRewardClaimStatus.claimed => Colors.greenAccent,
      SeasonRewardClaimStatus.readyToClaim => Colors.amberAccent,
      SeasonRewardClaimStatus.locked => Colors.white70,
    };

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECOMPENSA DA TEMPORADA',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white54,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _InfoBanner(
            title: reward?.rewardName ?? season.rewardName,
            body: reward?.rewardBonusLabel ?? season.rewardBonusLabel,
            accent: accent,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(
                label: reward?.rewardBadgeLabel ?? season.rewardBadgeLabel,
                color: Colors.amberAccent,
              ),
              _StatusPill(
                label: reward?.rewardTitleLabel ?? season.rewardTitleLabel,
                color: AppColors.neonBlue,
              ),
              _StatusPill(
                label: _seasonClaimStatusLabel(claimStatus),
                color: accent,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (reward?.canClaim == true)
            _ActionButton(
              label: 'RESGATAR TEMPORADA',
              accent: Colors.amberAccent,
              onTap: () async {
                final success = await ref
                    .read(rankProgressionRepositoryProvider)
                    .claimCurrentSeasonReward();
                if (!context.mounted) return;
                _showSnackBar(
                  context,
                  success
                      ? 'Pacote sazonal resgatado.'
                      : 'A recompensa ainda nao pode ser resgatada.',
                );
              },
            )
          else if (claimStatus == SeasonRewardClaimStatus.claimed)
            Text(
              'Resgatado em ${_formatShortDate(reward?.claimedAt ?? reward?.updatedAt ?? DateTime.now())}',
              style: const TextStyle(color: Colors.white54, fontSize: 11.5),
            )
          else
            Text(
              season.rewardPreview,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                height: 1.45,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSeasonLeaderboardCard(RankSeasonLeaderboardSummary leaderboard) {
    final scoreColor = switch (leaderboard.scoreBandLabel) {
      'LIDERANCA' => Colors.amberAccent,
      'ELITE' => Colors.greenAccent,
      'DISPUTA' => AppColors.neonBlue,
      _ => Colors.orangeAccent,
    };

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PLACAR DA TEMPORADA',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white54,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _InfoBanner(
            title: leaderboard.playerStandingLabel,
            body: leaderboard.spotlightLabel,
            accent: scoreColor,
          ),
          const SizedBox(height: 12),
          _SplitMetricRow(
            left: _MetricCard(
              label: 'FAIXA',
              value: leaderboard.scoreBandLabel,
              accent: scoreColor,
            ),
            right: _MetricCard(
              label: 'PONTOS',
              value: '${leaderboard.seasonScore}',
              accent: AppColors.neonBlue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${leaderboard.divisionLabel} | ${leaderboard.boardStatusLabel}',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            leaderboard.nextThresholdLabel,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
          if (leaderboard.podium.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'PODIO DA ARENA',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white54,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            ...leaderboard.podium.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: (entry.isPlayer ? scoreColor : Colors.white)
                        .withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (entry.isPlayer ? scoreColor : Colors.white54)
                          .withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '#${entry.position}',
                          style: TextStyle(
                            color: entry.isPlayer
                                ? scoreColor
                                : AppColors.neonBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.displayName,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              entry.detail,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRivalryPanel(RankRivalrySummary rivalry) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RIVALIDADE',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white54,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _InfoBanner(
            title: rivalry.headline,
            body: rivalry.body,
            accent: Colors.amberAccent,
          ),
          const SizedBox(height: 12),
          _SplitMetricRow(
            left: _MetricCard(
              label: 'QUEM ESTA NA SUA FRENTE',
              value: rivalry.chaseLabel,
              accent: Colors.amberAccent,
            ),
            right: _MetricCard(
              label: 'QUEM ESTA PERTO',
              value: rivalry.pressureLabel,
              accent: Colors.orangeAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegacySection(
    CompetitiveRankSnapshot? snapshot,
    List<CompetitiveRankSnapshot> history,
    SeasonProfileSnapshot? seasonProfile,
    List<SeasonLegacyReward> seasonLegacyHistory,
  ) {
    return Column(
      key: const ValueKey('rank-legacy'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActiveLegacyCard(snapshot, seasonProfile),
        const SizedBox(height: 12),
        _buildSeasonArchiveCard(seasonLegacyHistory),
        const SizedBox(height: 12),
        _buildHistoryCard(history),
      ],
    );
  }

  Widget _buildActiveLegacyCard(
    CompetitiveRankSnapshot? snapshot,
    SeasonProfileSnapshot? seasonProfile,
  ) {
    final peakRank = snapshot?.peakRank ?? snapshot?.currentRank ?? 'E';

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LEGADO ATIVO',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white54,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _InfoBanner(
            title: seasonProfile?.activeTitleLabel ?? 'SEM TITULO SAZONAL',
            body: seasonProfile == null
                ? 'Seu melhor marco atual e o pico de rank $peakRank.'
                : 'Seu legado ativo veio da temporada ${seasonProfile.activeSeasonLabel}.',
            accent: AppColors.neonBlue,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(label: 'PICO $peakRank', color: Colors.amberAccent),
              if (seasonProfile != null) ...[
                _StatusPill(
                  label: seasonProfile.activeBadgeLabel,
                  color: Colors.amberAccent,
                ),
                _StatusPill(
                  label: seasonProfile.cosmeticAuraLabel,
                  color: AppColors.neonBlue,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonArchiveCard(List<SeasonLegacyReward> rewards) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ARQUIVO SAZONAL',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white54,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (rewards.isEmpty)
            const Text(
              'Voce ainda nao resgatou nenhuma temporada.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12.5,
                height: 1.45,
              ),
            )
          else
            ...rewards
                .take(4)
                .map(
                  (reward) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.amberAccent.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  reward.seasonLabel,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              _StatusPill(
                                label: reward.rewardBadgeLabel,
                                color: Colors.amberAccent,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            reward.rewardTitleLabel,
                            style: const TextStyle(
                              color: AppColors.neonBlue,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            reward.rewardBonusLabel,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11.5,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Resgatado em ${_formatShortDate(reward.claimedAt)}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(List<CompetitiveRankSnapshot> history) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRILHA',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white54,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (history.isEmpty)
            const Text(
              'As semanas registradas vao aparecer aqui.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12.5,
                height: 1.45,
              ),
            )
          else
            ...history
                .take(5)
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _statusColor(
                            entry.status,
                          ).withValues(alpha: 0.18),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _StatusPill(
                                label: entry.weekKey,
                                color: AppColors.neonBlue,
                              ),
                              const Spacer(),
                              Text(
                                _historyEventLabel(entry),
                                style: TextStyle(
                                  color: _statusColor(entry.status),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rank ${entry.currentRank}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.summary,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11.5,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildIntegrityCard(CompetitiveIntegritySnapshot integrity) {
    final accent = switch (integrity.trustBand) {
      CompetitiveTrustBand.high => Colors.greenAccent,
      CompetitiveTrustBand.stable => AppColors.neonBlue,
      CompetitiveTrustBand.attention => Colors.orangeAccent,
      CompetitiveTrustBand.restricted => Colors.redAccent,
    };

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONFIANCA DA CONTA',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white54,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _InfoBanner(
            title: _integrityHeadline(integrity),
            body: _integrityBody(integrity),
            accent: accent,
          ),
          const SizedBox(height: 12),
          _SplitMetricRow(
            left: _MetricCard(
              label: 'BASE DO DIA',
              value: '${integrity.weeklyCompetitiveDays} dia(s) validados',
              accent: AppColors.neonBlue,
            ),
            right: _MetricCard(
              label: 'SINAL DE RISCO',
              value: _integrityRiskLabel(integrity),
              accent: accent,
            ),
          ),
        ],
      ),
    );
  }

  String _statusHeadline(RankMaintenanceStatus status) {
    return switch (status) {
      RankMaintenanceStatus.secure => 'Semana segura',
      RankMaintenanceStatus.warning => 'Atencao nesta semana',
      RankMaintenanceStatus.critical => 'Risco real de queda',
      RankMaintenanceStatus.promotionReady => 'Pronto para prova',
      RankMaintenanceStatus.demoted => 'Queda aplicada',
    };
  }

  String _statusLabel(RankMaintenanceStatus status) {
    return switch (status) {
      RankMaintenanceStatus.secure => 'ESTAVEL',
      RankMaintenanceStatus.warning => 'ALERTA',
      RankMaintenanceStatus.critical => 'CRITICO',
      RankMaintenanceStatus.promotionReady => 'PROVA',
      RankMaintenanceStatus.demoted => 'QUEDA',
    };
  }

  String _historyEventLabel(CompetitiveRankSnapshot entry) {
    return switch (entry.eventType) {
      CompetitiveRankEventType.routine => 'ROTINA',
      CompetitiveRankEventType.warning => 'ALERTA',
      CompetitiveRankEventType.perfectWeek => 'SEMANA FORTE',
      CompetitiveRankEventType.promotionUnlocked => 'EXAME',
      CompetitiveRankEventType.reconquestUnlocked => 'RECONQUISTA',
      CompetitiveRankEventType.promotionConfirmed => 'PROMOCAO',
      CompetitiveRankEventType.demotionApplied => 'QUEDA',
    };
  }

  Color _statusColor(RankMaintenanceStatus status) {
    return switch (status) {
      RankMaintenanceStatus.secure => Colors.greenAccent,
      RankMaintenanceStatus.warning => Colors.orangeAccent,
      RankMaintenanceStatus.critical => Colors.redAccent,
      RankMaintenanceStatus.promotionReady => AppColors.neonBlue,
      RankMaintenanceStatus.demoted => Colors.deepOrangeAccent,
    };
  }

  String _prestigeReading(RankPrestigeSummary prestige) {
    return switch (prestige.prestigeLabel) {
      'PREDADOR' =>
        'Voce esta sustentando uma faixa de elite com consistencia rara.',
      'ASCENDENTE' =>
        'Seu historico mostra evolucao real e boa chance de continuar subindo.',
      'ESTAVEL' => 'Seu ritmo esta confiavel e seguro.',
      'OSCILANTE' => 'Ha bons sinais, mas ainda com semanas de oscilacao.',
      _ => 'Sua consistencia ainda esta sendo formada.',
    };
  }

  String _seasonClaimStatusLabel(SeasonRewardClaimStatus status) {
    return switch (status) {
      SeasonRewardClaimStatus.locked => 'BLOQUEADA',
      SeasonRewardClaimStatus.readyToClaim => 'PRONTA',
      SeasonRewardClaimStatus.claimed => 'RESGATADA',
    };
  }

  String _integrityHeadline(CompetitiveIntegritySnapshot integrity) {
    return switch (integrity.trustBand) {
      CompetitiveTrustBand.high => 'Trilha muito confiavel',
      CompetitiveTrustBand.stable => 'Conta estavel',
      CompetitiveTrustBand.attention => 'Conta em observacao',
      CompetitiveTrustBand.restricted => 'Conta fragil no momento',
    };
  }

  String _integrityBody(CompetitiveIntegritySnapshot integrity) {
    return switch (integrity.trustBand) {
      CompetitiveTrustBand.high =>
        'Seu ritmo recente esta muito confiavel. Continue fechando quests competitivas para manter isso.',
      CompetitiveTrustBand.stable =>
        'Sua conta esta estavel. Mais dias competitivos ajudam a manter sua posicao forte.',
      CompetitiveTrustBand.attention =>
        'Seu progresso recente ainda precisa de mais constancia para deixar sua conta mais firme no competitivo.',
      CompetitiveTrustBand.restricted =>
        'Sua conta ainda precisa de mais constancia. Priorize quests competitivas confirmadas nesta semana.',
    };
  }

  String _integrityRiskLabel(CompetitiveIntegritySnapshot integrity) {
    if (integrity.suspiciousPatternCount <= 0) {
      return 'LIMPO';
    }
    if (integrity.suspiciousPatternCount <= 2) {
      return 'LEVE';
    }
    if (integrity.suspiciousPatternCount <= 4) {
      return 'MEDIO';
    }
    return 'ALTO';
  }

  String _formatShortDate(DateTime value) {
    const months = <String>[
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ',
    ];
    return '${value.day.toString().padLeft(2, '0')} ${months[value.month - 1]}';
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.title,
    required this.body,
    required this.accent,
  });

  final String title;
  final String body;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
              fontSize: 12,
              color: accent,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitMetricRow extends StatelessWidget {
  const _SplitMetricRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 10),
        Expanded(child: right),
      ],
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
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: accent,
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
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.18)),
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
                            color: Colors.black.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      supporting,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12.3,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withValues(alpha: 0.25)),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: accent,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: BorderSide(color: accent.withValues(alpha: 0.45)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.6),
      ),
    );
  }
}
