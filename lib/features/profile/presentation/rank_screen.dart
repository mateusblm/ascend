import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/promotion_exam.dart';
import 'package:ascend/features/profile/domain/rank_arena.dart';
import 'package:ascend/features/profile/domain/rank_prestige.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/rank_season.dart';
import 'package:ascend/features/profile/domain/rank_season_leaderboard.dart';
import 'package:ascend/features/profile/domain/season_legacy_reward.dart';
import 'package:ascend/features/profile/domain/season_profile_snapshot.dart';
import 'package:ascend/features/profile/domain/season_reward_snapshot.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/presentation/info_tooltip.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/profile/presentation/rank_progression_provider.dart';
import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:ascend/features/weekly_boss/domain/weekly_boss_completion.dart';
import 'package:ascend/features/weekly_boss/presentation/weekly_boss_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

class RankScreen extends ConsumerWidget {
  const RankScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final snapshot = ref.watch(rankProgressionSnapshotProvider).valueOrNull;
    final history =
        ref.watch(rankProgressionHistoryProvider).valueOrNull ??
        const <CompetitiveRankSnapshot>[];
    final remoteWeeklyBoss = ref.watch(remoteWeeklyBossProvider);
    final topCompletions = ref.watch(weeklyBossTopCompletionsProvider);
    final currentSeasonReward = ref.watch(currentSeasonRewardProvider).valueOrNull;
    final seasonProfile = ref.watch(seasonProfileProvider).valueOrNull;
    final seasonLegacyHistory =
        ref.watch(seasonLegacyHistoryProvider).valueOrNull ??
        const <SeasonLegacyReward>[];
    final season = buildCurrentSeasonSummary(history);
    final seasonLeaderboard = buildRankSeasonLeaderboardSummary(
      player: player,
      season: season,
      activeBoss: remoteWeeklyBoss.valueOrNull,
      topCompletions:
          topCompletions.valueOrNull ?? const <WeeklyBossCompletion>[],
      snapshot: snapshot,
    );
    final prestige = buildRankPrestigeSummary(history);
    final exam = ref.watch(promotionExamProvider).valueOrNull;
    final arena = buildRankArenaSummary(
      player: player,
      boss: remoteWeeklyBoss.valueOrNull,
      topCompletions:
          topCompletions.valueOrNull ?? const <WeeklyBossCompletion>[],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(snapshot, player),
              const SizedBox(height: 12),
              _buildMaintenanceCard(snapshot, player),
              const SizedBox(height: 12),
              _buildPromotionExamCard(context, ref, snapshot, exam, player),
              const SizedBox(height: 12),
              _buildRankBossCard(remoteWeeklyBoss, topCompletions, arena),
              const SizedBox(height: 12),
              _buildPrestigeCard(prestige),
              const SizedBox(height: 12),
              _buildActiveSeasonProfileCard(seasonProfile),
              const SizedBox(height: 12),
              _buildSeasonCard(context, ref, season, currentSeasonReward),
              const SizedBox(height: 12),
              _buildSeasonLeaderboardCard(seasonLeaderboard),
              const SizedBox(height: 12),
              _buildSeasonArchiveCard(seasonLegacyHistory),
              const SizedBox(height: 12),
              _buildHistoryCard(history),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(CompetitiveRankSnapshot? snapshot, Player player) {
    final currentRank =
        snapshot?.currentRank ?? playerRankForLevel(player.level);
    final status = snapshot?.status ?? RankMaintenanceStatus.secure;
    final color = _statusColor(status);
    final nextRank = snapshot?.promotionTargetRank ?? rankAfter(currentRank);
    final peakRank = snapshot?.peakRank ?? currentRank;
    final eligibleRank =
        snapshot?.highestEligibleRank ?? playerRankForLevel(player.level);
    final activeDays = snapshot?.activeDays ?? 0;
    final requiredDays =
        snapshot?.requiredActiveDays ??
        rankRuleFor(currentRank).requiredActiveDays;
    final progress = requiredDays == 0
        ? 0.0
        : (activeDays / requiredDays).clamp(0.0, 1.0);

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'CAMARA DE RANK',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const InfoTooltipIcon(
                title: 'Rank competitivo',
                message:
                    'Aqui fica a leitura principal do seu estado competitivo: rank atual, pressao semanal, exame, temporada e trilha de ascensao.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.3,
                colors: [
                  color.withValues(alpha: 0.20),
                  AppColors.neonBlue.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: color.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 22,
                  spreadRadius: 1,
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
                          const Text(
                            'RANK ATUAL',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white54,
                              letterSpacing: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentRank,
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: color.withValues(alpha: 0.65),
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
                                color: color,
                              ),
                              _StatusPill(
                                label: '$activeDays/$requiredDays DIAS',
                                color: AppColors.neonBlue,
                              ),
                              _StatusPill(
                                label: 'PICO $peakRank',
                                color: Colors.amberAccent,
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
                        const SizedBox(height: 18),
                        const Text(
                          'PROXIMO',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white38,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Text(
                          nextRank ?? '--',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neonBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  snapshot?.summary ??
                      'A leitura competitiva ainda esta sincronizando neste dispositivo.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Seu level ${player.level} libera tentativas ate o rank $eligibleRank.',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  lineHeight: 10,
                  percent: progress,
                  barRadius: const Radius.circular(999),
                  backgroundColor: Colors.white10,
                  progressColor: color,
                  animation: true,
                  animationDuration: 800,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceCard(
    CompetitiveRankSnapshot? snapshot,
    Player player,
  ) {
    final currentRank =
        snapshot?.currentRank ?? playerRankForLevel(player.level);
    final rule = rankRuleFor(currentRank);
    final status = snapshot?.status ?? RankMaintenanceStatus.secure;
    final statusColor = _statusColor(status);
    final activeDays = snapshot?.activeDays ?? 0;
    final bossCompleted = snapshot?.bossCompleted ?? false;
    final progress = rule.requiredActiveDays == 0
        ? 0.0
        : (activeDays / rule.requiredActiveDays).clamp(0.0, 1.0);
    final remainingDays = (rule.requiredActiveDays - activeDays).clamp(
      0,
      rule.requiredActiveDays,
    );

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'MANUTENCAO',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const InfoTooltipIcon(
                title: 'Manutencao semanal',
                message:
                    'A manutencao decide se o rank se sustenta. Ela combina dias ativos, boss obrigatorio em alguns ranks e a acumulacao de strikes quando a semana falha.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'STATUS',
                  value: _statusLabel(status),
                  accent: statusColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'SEMANA',
                  value: '$activeDays/${rule.requiredActiveDays} dias',
                  accent: AppColors.neonBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 10,
            percent: progress,
            barRadius: const Radius.circular(999),
            backgroundColor: Colors.white10,
            progressColor: statusColor,
            animation: true,
            animationDuration: 800,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'STRIKES',
                  value: '${snapshot?.demotionStrikes ?? 0}',
                  accent: (snapshot?.demotionStrikes ?? 0) > 0
                      ? Colors.orangeAccent
                      : Colors.white70,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'BOSS',
                  value: rule.requiresBossClear
                      ? (bossCompleted ? 'CLEAR' : 'PENDENTE')
                      : 'N/A',
                  accent: bossCompleted ? Colors.greenAccent : Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            remainingDays > 0
                ? 'Faltam $remainingDays dia(s) ativo(s) para segurar este rank.'
                : 'A manutencao minima da semana ja foi garantida.',
            style: TextStyle(
              color: remainingDays > 0 ? Colors.white70 : Colors.greenAccent,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (snapshot != null) ...[
            Text(
              snapshot.targetLevelGateMet
                  ? 'Seu level ${player.level} ja libera o proximo alvo competitivo.'
                  : 'Seu level ${player.level} ainda nao libera ${snapshot.promotionTargetRank ?? '--'}. Necessario: level ${snapshot.targetRequiredLevel}.',
              style: TextStyle(
                color: snapshot.targetLevelGateMet
                    ? AppColors.neonBlue
                    : Colors.orangeAccent,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            snapshot?.detail ??
                'Esta area resume o risco atual, as exigencias da semana e a chance de sustentar ou perder o rank.',
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

  Widget _buildPromotionExamCard(
    BuildContext context,
    WidgetRef ref,
    CompetitiveRankSnapshot? snapshot,
    PromotionExam? exam,
    Player player,
  ) {
    final examMode =
        exam?.mode ?? snapshot?.advancementMode ?? RankAdvancementMode.ascension;
    final accentColor = switch (exam?.status) {
      PromotionExamStatus.inProgress => Colors.orangeAccent,
      PromotionExamStatus.passed => Colors.greenAccent,
      PromotionExamStatus.failed => Colors.redAccent,
      PromotionExamStatus.promoted => AppColors.neonBlue,
      null => AppColors.neonBlue,
    };

    final title = switch (exam?.status) {
      PromotionExamStatus.inProgress => examMode == RankAdvancementMode.reconquest
          ? 'EXAME DE RECONQUISTA EM CURSO'
          : 'EXAME DE PROMOCAO EM CURSO',
      PromotionExamStatus.passed => 'EXAME CONCLUIDO',
      PromotionExamStatus.failed => 'EXAME FALHOU',
      PromotionExamStatus.promoted => 'PROMOCAO CONFIRMADA',
      null => examMode == RankAdvancementMode.reconquest
          ? 'EXAME DE RECONQUISTA'
          : 'EXAME DE PROMOCAO',
    };

    final description = switch (exam?.status) {
      PromotionExamStatus.inProgress =>
        'Conquiste ${exam!.targetActiveDays} dias ativos nesta semana antes de ${_formatShortDate(exam.expiresAt)}.',
      PromotionExamStatus.passed =>
        exam!.mode == PromotionExamMode.reconquest
            ? 'Voce venceu a prova para reconquistar o rank ${exam.targetRank}. Agora confirme a retomada.'
            : 'Voce venceu a prova para o rank ${exam.targetRank}. Agora confirme a promocao.',
      PromotionExamStatus.failed =>
        'O exame expirou ou a progressao exigida nao foi sustentada. Refaca o ciclo para tentar novamente.',
      PromotionExamStatus.promoted =>
        exam!.mode == PromotionExamMode.reconquest
            ? 'Sua reconquista foi registrada. Agora o foco e sustentar o posto retomado.'
            : 'Sua ascensao foi registrada. Agora o foco e sustentar o novo padrao.',
      null =>
        snapshot?.promotionReady == true
            ? snapshot!.advancementMode == RankAdvancementMode.reconquest
                ? 'Voce destravou um exame de reconquista para o rank ${snapshot.promotionTargetRank}. Inicie a prova para retomar seu pico historico.'
                : 'Voce destravou o exame para o rank ${snapshot.promotionTargetRank}. Inicie a prova para validar a ascensao.'
            : 'Quando o sistema detectar promocao ou reconquista pronta, a prova formal aparece aqui.',
    };

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const InfoTooltipIcon(
                title: 'Exame de promocao',
                message:
                    'A subida de rank nao e automatica. O exame confirma tanto uma ascensao nova quanto a reconquista de um rank que ja foi seu.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          if (exam != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'META DO EXAME',
                    value: '${exam.targetActiveDays} dias',
                    accent: accentColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    label: 'ESTADO',
                    value: exam.status.name.toUpperCase(),
                    accent: accentColor,
                  ),
                ),
              ],
            ),
          ],
          if (exam != null &&
              exam.status == PromotionExamStatus.inProgress) ...[
            const SizedBox(height: 12),
            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              lineHeight: 8,
              percent: (player.activityHistory.length / exam.targetActiveDays)
                  .clamp(0.0, 1.0),
              barRadius: const Radius.circular(999),
              backgroundColor: Colors.white10,
              progressColor: accentColor,
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (snapshot?.promotionReady == true && exam == null)
                _ActionButton(
                  label: snapshot?.advancementMode == RankAdvancementMode.reconquest
                      ? 'INICIAR RECONQUISTA'
                      : 'INICIAR EXAME',
                  accent: AppColors.neonBlue,
                  onTap: () async {
                    final success = await ref
                        .read(rankProgressionRepositoryProvider)
                        .startPromotionExam(
                      snapshot!,
                    );
                    if (!context.mounted) return;
                    _showSnackBar(
                      context,
                      success
                          ? (snapshot.advancementMode == RankAdvancementMode.reconquest
                              ? 'Reconquista iniciada.'
                              : 'Exame iniciado.')
                          : 'Nao foi possivel iniciar o exame agora.',
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
                        .promoteIfExamPassed(
                      snapshot,
                    );
                    if (!context.mounted) return;
                    _showSnackBar(
                      context,
                      success
                          ? (exam?.mode == PromotionExamMode.reconquest
                              ? 'Rank reconquistado.'
                              : 'Promocao confirmada.')
                          : 'Nao foi possivel confirmar a ascensao.',
                    );
                  },
                ),
              if (exam != null && exam.status == PromotionExamStatus.inProgress)
                _ActionButton(
                  label: 'REVER STATUS',
                  accent: Colors.orangeAccent,
                  onTap: () async {
                    await ref
                        .read(rankProgressionRepositoryProvider)
                        .syncCompetitiveState(player);
                    if (!context.mounted) return;
                    _showSnackBar(context, 'Estado do exame atualizado.');
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankBossCard(
    AsyncValue<RemoteWeeklyBoss?> remoteWeeklyBoss,
    AsyncValue<List<WeeklyBossCompletion>> topCompletions,
    RankArenaSummary arena,
  ) {
    final boss = remoteWeeklyBoss.valueOrNull;
    final top = topCompletions.valueOrNull ?? const <WeeklyBossCompletion>[];

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ARENA DO BOSS',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const InfoTooltipIcon(
                title: 'Arena do rank',
                message:
                    'Aqui voce ve a pressao do evento semanal do seu rank: urgencia, recompensa, primeiro clear e leitura da arena.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!arena.hasActiveBoss && !remoteWeeklyBoss.isLoading) ...[
            _StatusPill(label: arena.stateLabel, color: Colors.white70),
            const SizedBox(height: 12),
            Text(
              arena.leaderHeadline,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              arena.crowdReading,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11.5,
                height: 1.45,
              ),
            ),
          ] else if (boss == null) ...[
            const Text(
              'Conectando ao Firestore...',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        boss.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        boss.description,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12.5,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatusPill(
                      label: arena.urgencyLabel,
                      color: Colors.amberAccent,
                    ),
                    const SizedBox(height: 8),
                    _StatusPill(
                      label: arena.stateLabel,
                      color: AppColors.neonBlue,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'SEU PROGRESSO',
                    value: '${arena.progress}/${arena.target}',
                    accent: AppColors.neonBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    label: 'CLEARS',
                    value: '${arena.completedCount}',
                    accent: Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    label: 'RECOMPENSA',
                    value: arena.rewardLabel,
                    accent: Colors.purpleAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              arena.leaderHeadline,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              arena.crowdReading,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'TOP CLEARS',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white38,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            if (top.isEmpty)
              const Text(
                'Nenhum clear remoto ainda.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              )
            else
              ...top
                  .take(3)
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TopClearRow(entry: entry),
                    ),
                  ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrestigeCard(RankPrestigeSummary prestige) {
    final accentColor = switch (prestige.prestigeLabel) {
      'PREDADOR' => Colors.amberAccent,
      'ASCENDENTE' => AppColors.neonBlue,
      'ESTAVEL' => Colors.greenAccent,
      'OSCILANTE' => Colors.orangeAccent,
      _ => Colors.redAccent,
    };

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'PRESTIGIO',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const InfoTooltipIcon(
                title: 'Prestigio do rank',
                message:
                    'Prestigio resume a qualidade da sua manutencao ao longo das semanas. Quanto mais estavel e limpa a trilha, maior o peso competitivo do perfil.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'MANUTENCAO',
                  value: '${prestige.maintenanceRate}%',
                  accent: accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'STREAK SEGURA',
                  value: '${prestige.secureStreak}',
                  accent: Colors.greenAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'SEMANAS PERFEITAS',
                  value: '${prestige.perfectWeeks}',
                  accent: Colors.amberAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'EXAMES',
                  value: '${prestige.examClears}',
                  accent: AppColors.neonBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _prestigeReading(prestige),
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonCard(
    BuildContext context,
    WidgetRef ref,
    RankSeasonSummary season,
    SeasonRewardSnapshot? currentSeasonReward,
  ) {
    final progressColor = switch (season.rewardStatusLabel) {
      'GARANTIDA' => Colors.greenAccent,
      'RECOMPENSA AVANCADA' => Colors.amberAccent,
      'EM ROTA' => AppColors.neonBlue,
      'ABRINDO TRILHA' => Colors.orangeAccent,
      _ => Colors.redAccent,
    };

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'TEMPORADA',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const InfoTooltipIcon(
                title: 'Temporada atual',
                message:
                    'A temporada agrupa as semanas do mes atual. Aqui voce acompanha consistencia, trilha de recompensa e a pressao do reset sazonal.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'REGISTROS',
                  value: '${season.recordedWeeks}/${season.totalSeasonWeeks}',
                  accent: AppColors.neonBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'MEDIA',
                  value: season.recordedWeeks == 0
                      ? '-'
                      : season.averageActiveDays.toStringAsFixed(1),
                  accent: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'PICO',
                  value: season.peakRank,
                  accent: Colors.amberAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatusPill(label: season.rewardStatusLabel, color: progressColor),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 10,
            percent: season.rewardProgress,
            barRadius: const Radius.circular(999),
            backgroundColor: Colors.white10,
            progressColor: progressColor,
            animation: true,
            animationDuration: 800,
          ),
          const SizedBox(height: 10),
          Text(
            season.rewardTrackLabel,
            style: TextStyle(
              color: progressColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            season.nextUnlockHint,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.3,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            season.rewardPreview,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: progressColor.withValues(alpha: 0.20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        season.rewardUnlocked
                            ? 'RECOMPENSA DA TEMPORADA'
                            : 'PACOTE DE TEMPORADA',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white54,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    _StatusPill(
                      label: currentSeasonReward?.rewardBadgeLabel ?? season.rewardBadgeLabel,
                      color: (currentSeasonReward?.rewardUnlocked ?? season.rewardUnlocked)
                          ? progressColor
                          : Colors.white54,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  currentSeasonReward?.rewardName ?? season.rewardName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  currentSeasonReward?.rewardTitleLabel ?? season.rewardTitleLabel,
                  style: TextStyle(
                    color: progressColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentSeasonReward?.rewardBonusLabel ?? season.rewardBonusLabel,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                if (currentSeasonReward != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatusPill(
                        label: _seasonClaimStatusLabel(currentSeasonReward.claimStatus),
                        color: switch (currentSeasonReward.claimStatus) {
                          SeasonRewardClaimStatus.claimed => Colors.greenAccent,
                          SeasonRewardClaimStatus.readyToClaim => Colors.amberAccent,
                          SeasonRewardClaimStatus.locked => Colors.white54,
                        },
                      ),
                      const SizedBox(width: 10),
                      if (currentSeasonReward.canClaim)
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
                                  : 'A recompensa sazonal ainda nao pode ser resgatada.',
                            );
                          },
                        )
                      else if (currentSeasonReward.claimStatus ==
                          SeasonRewardClaimStatus.claimed)
                        Text(
                          'Resgatado em ${_formatShortDate(currentSeasonReward.claimedAt ?? currentSeasonReward.updatedAt)}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'TAXA SEGURA',
                  value: '${season.secureRate}%',
                  accent: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'RESET',
                  value: season.resetLabel,
                  accent: season.weeksRemaining <= 1
                      ? Colors.orangeAccent
                      : Colors.white70,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'RECOMPENSA',
                  value: season.rewardTierLabel,
                  accent: Colors.purpleAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSeasonProfileCard(SeasonProfileSnapshot? seasonProfile) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'LEGADO ATIVO',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const InfoTooltipIcon(
                title: 'Legado sazonal',
                message:
                    'Quando uma recompensa sazonal e resgatada, ela vira legado permanente. Este bloco mostra o titulo, o emblema e a assinatura visual atualmente equipados na conta.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (seasonProfile == null)
            const Text(
              'Nenhum legado sazonal equipado ainda. Resgate uma temporada para fixar titulo e emblema permanentes na conta.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12.5,
                height: 1.45,
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'TITULO',
                    value: seasonProfile.activeTitleLabel,
                    accent: Colors.amberAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    label: 'EMBLEMA',
                    value: seasonProfile.activeBadgeLabel,
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
                    label: 'AURA',
                    value: seasonProfile.cosmeticAuraLabel,
                    accent: Colors.purpleAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    label: 'QUADRO',
                    value: seasonProfile.cosmeticFrameLabel,
                    accent: Colors.greenAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${seasonProfile.activeRewardName} | ${seasonProfile.activeSeasonLabel}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Equipado em ${_formatShortDate(seasonProfile.equippedAt)}.',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'PLACAR SAZONAL',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const InfoTooltipIcon(
                title: 'Leaderboard sazonal',
                message:
                    'Este placar combina a pressao da arena atual com sua pontuacao da temporada. Ele mostra se voce esta liderando, disputando ou precisando recuperar terreno no seu bracket.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            leaderboard.divisionLabel,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            leaderboard.boardStatusLabel,
            style: TextStyle(
              color: scoreColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'POSICAO',
                  value: leaderboard.playerStandingLabel,
                  accent: scoreColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'PONTOS',
                  value: '${leaderboard.seasonScore}',
                  accent: AppColors.neonBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'BANDA',
                  value: leaderboard.scoreBandLabel,
                  accent: Colors.purpleAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            leaderboard.momentumLabel,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
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
          const SizedBox(height: 12),
          const Text(
            'PODIO DA ARENA',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white38,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          if (leaderboard.podium.isEmpty)
            const Text(
              'Nenhum clear entrou no podio ainda.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            )
          else
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
                          .withValues(alpha: 0.20),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '#${entry.position}',
                          style: TextStyle(
                            color: entry.isPlayer ? scoreColor : AppColors.neonBlue,
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
          const SizedBox(height: 10),
          Text(
            leaderboard.spotlightLabel,
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

  Widget _buildSeasonArchiveCard(List<SeasonLegacyReward> rewards) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ARQUIVO SAZONAL',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const InfoTooltipIcon(
                title: 'Historico sazonal',
                message:
                    'Aqui fica o arquivo permanente das temporadas resgatadas. E o curriculo sazonal do jogador: titulo, emblema, score e assinatura visual de cada conquista.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (rewards.isEmpty)
            const Text(
              'Nenhum legado sazonal resgatado ainda.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12.5,
                height: 1.45,
              ),
            )
          else
            ...rewards.take(4).map(
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
                          letterSpacing: 0.6,
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusPill(
                            label: reward.cosmeticAuraLabel,
                            color: Colors.purpleAccent,
                          ),
                          _StatusPill(
                            label: reward.cosmeticFrameLabel,
                            color: AppColors.neonBlue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'BANDA ${reward.scoreBandLabel} | score ${reward.seasonScore}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                          Text(
                            reward.playerStandingLabel,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
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
            'TRILHA DE ASCENSAO',
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
              'Seu historico de rank vai aparecer aqui conforme as semanas forem registradas.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12.5,
                height: 1.45,
              ),
            )
          else
            ...history
                .take(6)
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
                          ).withValues(alpha: 0.20),
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
                                  letterSpacing: 0.9,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rank ${entry.currentRank} | ${_statusLabel(entry.status)}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${entry.activeDays}/${entry.requiredActiveDays} dias | strikes ${entry.demotionStrikes}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(height: 6),
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

  String _statusLabel(RankMaintenanceStatus status) {
    return switch (status) {
      RankMaintenanceStatus.secure => 'ESTAVEL',
      RankMaintenanceStatus.warning => 'ALERTA',
      RankMaintenanceStatus.critical => 'CRITICO',
      RankMaintenanceStatus.promotionReady => 'PROMOCAO',
      RankMaintenanceStatus.demoted => 'RECUO',
    };
  }

  String _historyEventLabel(CompetitiveRankSnapshot entry) {
    return switch (entry.eventType) {
      CompetitiveRankEventType.routine => 'ROTINA',
      CompetitiveRankEventType.warning => 'AVISO',
      CompetitiveRankEventType.perfectWeek => 'SEMANA PERFEITA',
      CompetitiveRankEventType.promotionUnlocked => 'EXAME ABERTO',
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

  String _prestigeReading(RankPrestigeSummary prestige) {
    return switch (prestige.prestigeLabel) {
      'PREDADOR' =>
        'Voce esta em uma faixa de manutencao muito alta. O padrao ja e competitivo.',
      'ASCENDENTE' =>
        'Seu historico indica subida consistente e boa chance de evoluir sem ruido.',
      'ESTAVEL' => 'Voce mantem uma linha segura e previsivel de progresso.',
      'OSCILANTE' =>
        'A temporada ainda alterna entre bom ritmo e quedas pontuais.',
      _ => 'A consistencia ainda esta em formacao.',
    };
  }

  String _seasonClaimStatusLabel(SeasonRewardClaimStatus status) {
    return switch (status) {
      SeasonRewardClaimStatus.locked => 'BLOQUEADA',
      SeasonRewardClaimStatus.readyToClaim => 'PRONTA',
      SeasonRewardClaimStatus.claimed => 'RESGATADA',
    };
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
        border: Border.all(color: accent.withValues(alpha: 0.25)),
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

class _TopClearRow extends StatelessWidget {
  const _TopClearRow({required this.entry});

  final WeeklyBossCompletion entry;

  @override
  Widget build(BuildContext context) {
    final completedAt = entry.completedAt;
    final completedLabel = completedAt == null
        ? '--'
        : '${completedAt.day.toString().padLeft(2, '0')}/${completedAt.month.toString().padLeft(2, '0')} ${completedAt.hour.toString().padLeft(2, '0')}:${completedAt.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium,
            size: 16,
            color: Colors.amberAccent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rank ${entry.rankAtCompletion} | $completedLabel',
                  style: const TextStyle(fontSize: 10.5, color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
