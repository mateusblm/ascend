import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/promotion_exam.dart';
import 'package:ascend/features/profile/domain/rank_arena.dart';
import 'package:ascend/features/profile/domain/rank_prestige.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/rank_season.dart';
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
    final season = buildCurrentSeasonSummary(history);
    final prestige = buildRankPrestigeSummary(history);
    final exam = ref.watch(promotionExamProvider).valueOrNull;
    final remoteWeeklyBoss = ref.watch(remoteWeeklyBossProvider);
    final topCompletions = ref.watch(weeklyBossTopCompletionsProvider);
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
              _buildHeader(context, snapshot, player),
              const SizedBox(height: 12),
              _buildMaintenanceCard(context, snapshot, player),
              const SizedBox(height: 12),
              _buildPromotionExamCard(context, snapshot, exam),
              const SizedBox(height: 12),
              _buildRankBossCard(
                context,
                remoteWeeklyBoss,
                topCompletions,
                arena,
                player,
              ),
              const SizedBox(height: 12),
              _buildPrestigeCard(context, prestige),
              const SizedBox(height: 12),
              _buildSeasonCard(context, season),
              const SizedBox(height: 12),
              _buildHistoryCard(context, history),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    CompetitiveRankSnapshot? snapshot,
    Player player,
  ) {
    final currentRank =
        snapshot?.currentRank ?? playerRankForLevel(player.level);
    final status = snapshot?.status ?? RankMaintenanceStatus.secure;
    final color = _statusColor(status);
    final nextRank = snapshot?.promotionTargetRank ?? rankAfter(currentRank);
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
                  '🛡️ CAMARA DE RANK',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              InfoTooltipIcon(
                title: 'Rank e manutenção',
                message:
                    'Aqui você vê seu rank atual, o status da semana e o próximo rank possível. A barra mostra o quanto você já sustentou da exigência mínima da semana.',
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
              borderRadius: BorderRadius.circular(20),
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
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: color.withValues(alpha: 0.7),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _StatusPill(
                                label: _statusLabel(status),
                                color: color,
                              ),
                              _StatusPill(
                                label: '${activeDays}/${requiredDays} DIAS',
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
                      'Seu rank competitivo ainda está sincronizando.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.45,
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
    BuildContext context,
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
                  '🛠️ MANUTENÇÃO',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InfoTooltipIcon(
                title: 'Manutenção sazonal',
                message:
                    'A manutenção define se o seu rank permanece estável na semana. Ela combina dias ativos e, em alguns ranks, a exigência de boss. Se a barra cair muito, o sistema entra em alerta.',
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
                : 'A manutenção mínima da semana já foi garantida.',
            style: TextStyle(
              color: remainingDays > 0 ? Colors.white70 : Colors.greenAccent,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            snapshot?.detail ??
                'O sistema mostra aqui o risco de queda, os requisitos da semana e o estado competitivo do rank.',
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
    CompetitiveRankSnapshot? snapshot,
    PromotionExam? exam,
  ) {
    final accentColor = switch (exam?.status) {
      PromotionExamStatus.inProgress => Colors.orangeAccent,
      PromotionExamStatus.passed => Colors.greenAccent,
      PromotionExamStatus.failed => Colors.redAccent,
      PromotionExamStatus.promoted => AppColors.neonBlue,
      null => AppColors.neonBlue,
    };

    final title = switch (exam?.status) {
      PromotionExamStatus.inProgress => '📈 EXAME DE PROMOÇÃO EM CURSO',
      PromotionExamStatus.passed => '📈 EXAME CONCLUÍDO',
      PromotionExamStatus.failed => '📈 EXAME FALHOU',
      PromotionExamStatus.promoted => '👑 PROMOÇÃO CONFIRMADA',
      null => '📈 EXAME DE PROMOÇÃO',
    };

    final description = switch (exam?.status) {
      PromotionExamStatus.inProgress =>
        'Conquiste ${exam!.targetActiveDays} dias ativos nesta semana antes de ${_formatShortDate(exam.expiresAt)}.',
      PromotionExamStatus.passed =>
        'Você venceu a prova para o rank ${exam!.targetRank}. Agora confirme a promoção.',
      PromotionExamStatus.failed =>
        'O exame expirou ou a progressão exigida não foi sustentada. Refaça o ciclo para tentar novamente.',
      PromotionExamStatus.promoted =>
        'Sua ascensão foi registrada. Agora o foco é sustentar o novo padrão.',
      null =>
        snapshot?.promotionReady == true
            ? 'Você destravou o exame para o rank ${snapshot!.promotionTargetRank}. Inicie a prova para validar a ascensão.'
            : 'Quando o sistema detectar promoção pronta, a prova formal aparece aqui.',
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
              InfoTooltipIcon(
                title: 'Exame de promoção',
                message:
                    'O exame aparece quando o rank está pronto para subir. A tela mostra o objetivo mínimo da semana e o estado atual da prova. Nesta versão, a apresentação é enxuta para evitar blocos de texto longos.',
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
          if (exam != null &&
              exam.status == PromotionExamStatus.inProgress) ...[
            const SizedBox(height: 12),
            _MetricCard(
              label: 'META DO EXAME',
              value: '${exam.targetActiveDays} dias',
              accent: accentColor,
            ),
          ],
          if (exam?.status == PromotionExamStatus.passed ||
              snapshot?.promotionReady == true) ...[
            const SizedBox(height: 12),
            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              lineHeight: 8,
              percent: 1.0,
              barRadius: const Radius.circular(999),
              backgroundColor: Colors.white10,
              progressColor: accentColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRankBossCard(
    BuildContext context,
    AsyncValue<RemoteWeeklyBoss?> remoteWeeklyBoss,
    AsyncValue<List<WeeklyBossCompletion>> topCompletions,
    RankArenaSummary arena,
    Player player,
  ) {
    final boss = remoteWeeklyBoss.valueOrNull;
    final isLoading = remoteWeeklyBoss.isLoading;

    if (!arena.hasActiveBoss && !isLoading) {
      return _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '⚔️ ARENA DO BOSS',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white54,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                InfoTooltipIcon(
                  title: 'Arena do boss',
                  message:
                      'Quando não há boss ativo, a arena mostra apenas a leitura estratégica do rank. Assim que o evento voltar, o card passa a exibir progresso, recompensa e pressão competitiva.',
                ),
              ],
            ),
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
          ],
        ),
      );
    }

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '⚔️ ARENA DO BOSS',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InfoTooltipIcon(
                title: 'Arena do boss',
                message:
                    'Este card resume o evento semanal remoto para o rank atual. Aqui você vê a recompensa, a pressão da arena e os melhores clears do evento.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (boss == null)
            const Text(
              'Conectando ao Firestore...',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    boss.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusPill(
                  label: arena.urgencyLabel,
                  color: Colors.amberAccent,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              boss.description,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 10),
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
                    label: 'RECOMPENSA',
                    value: arena.rewardLabel,
                    accent: Colors.purpleAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              arena.leaderHeadline,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
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
            if (topCompletions.valueOrNull?.isEmpty ?? true)
              const Text(
                'Nenhum clear remoto ainda.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              )
            else
              ...topCompletions.valueOrNull!
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

  Widget _buildPrestigeCard(
    BuildContext context,
    RankPrestigeSummary prestige,
  ) {
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
                  '👑 PRESTÍGIO',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InfoTooltipIcon(
                title: 'Prestígio do rank',
                message:
                    'O prestígio resume a qualidade da sua manutenção ao longo das semanas. Quanto mais estável e consistente for o ciclo, melhor o selo exibido aqui.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'MANUTENÇÃO',
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

  Widget _buildSeasonCard(BuildContext context, RankSeasonSummary season) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '📅 TEMPORADA',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InfoTooltipIcon(
                title: 'Temporada atual',
                message:
                    'A temporada agrupa as semanas registradas no mês atual. A barra e os números mostram consistência, semanas seguras e recompensa prevista para o ciclo.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'REGISTROS',
                  value: '${season.recordedWeeks}',
                  accent: AppColors.neonBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'MÉDIA',
                  value: season.recordedWeeks == 0
                      ? '-'
                      : season.averageActiveDays.toStringAsFixed(1),
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
                  label: 'PICO',
                  value: season.peakRank,
                  accent: Colors.amberAccent,
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
          const SizedBox(height: 12),
          Text(
            season.rewardPreview,
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

  Widget _buildHistoryCard(
    BuildContext context,
    List<CompetitiveRankSnapshot> history,
  ) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📚 TRILHA DE ASCENSÃO',
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
              'Seu histórico de rank vai aparecer aqui conforme as semanas forem registradas.',
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
      RankMaintenanceStatus.secure => 'ESTÁVEL',
      RankMaintenanceStatus.warning => 'ALERTA',
      RankMaintenanceStatus.critical => 'CRÍTICO',
      RankMaintenanceStatus.promotionReady => 'PROMOÇÃO',
      RankMaintenanceStatus.demoted => 'RECUO',
    };
  }

  String _historyEventLabel(CompetitiveRankSnapshot entry) {
    return switch (entry.eventType) {
      CompetitiveRankEventType.routine => 'ROTINA',
      CompetitiveRankEventType.warning => 'AVISO',
      CompetitiveRankEventType.perfectWeek => 'SEMANA PERFEITA',
      CompetitiveRankEventType.promotionUnlocked => 'EXAME ABERTO',
      CompetitiveRankEventType.promotionConfirmed => 'PROMOÇÃO',
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
        'Você está em uma faixa de manutenção muito alta. O padrão já é competitivo.',
      'ASCENDENTE' =>
        'Seu histórico indica subida consistente e boa chance de evoluir sem ruído.',
      'ESTAVEL' => 'Você mantém uma linha segura e previsível de progresso.',
      'OSCILANTE' =>
        'A temporada ainda alterna entre bom ritmo e quedas pontuais.',
      _ => 'A consistência ainda está em formação.',
    };
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

class _TopClearRow extends StatelessWidget {
  const _TopClearRow({required this.entry});

  final WeeklyBossCompletion entry;

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              entry.displayName,
              style: const TextStyle(
                fontSize: 12.5,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
