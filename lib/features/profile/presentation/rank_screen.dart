import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/promotion_exam.dart';
import 'package:ascend/features/profile/domain/rank_arena.dart';
import 'package:ascend/features/profile/domain/rank_prestige.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/rank_season.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/profile/presentation/rank_progression_provider.dart';
import 'package:ascend/features/weekly_boss/domain/weekly_boss_completion.dart';
import 'package:ascend/features/weekly_boss/presentation/weekly_boss_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(snapshot, player),
              const SizedBox(height: 24),
              _buildMaintenanceCard(snapshot, player),
              const SizedBox(height: 12),
              _buildPromotionExamCard(context, ref, snapshot, exam),
              const SizedBox(height: 12),
              _buildRankBossCard(remoteWeeklyBoss, topCompletions, arena),
              const SizedBox(height: 12),
              _buildPrestigeCard(prestige),
              const SizedBox(height: 12),
              _buildSeasonCard(season),
              const SizedBox(height: 12),
              _buildHistoryCard(history),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CompetitiveRankSnapshot? snapshot, Player player) {
    final rank = snapshot?.currentRank ?? playerRankForLevel(player.level);
    final status = snapshot?.status ?? RankMaintenanceStatus.secure;
    final color = _statusColor(status);
    final nextRank = snapshot?.promotionTargetRank ?? rankAfter(rank);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CAMARA DE RANK',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        const Divider(color: AppColors.neonBlue, thickness: 1),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.3,
              colors: [
                color.withOpacity(0.18),
                AppColors.neonBlue.withOpacity(0.08),
                Colors.white.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.35)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.18),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
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
                    const SizedBox(height: 10),
                    Text(
                      rank,
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: color.withOpacity(0.8), blurRadius: 22),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.45)),
                      ),
                      child: Text(
                        'ESTADO: ${_statusLabel(status)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      snapshot?.summary ??
                          'Seu rank competitivo ainda esta sincronizando.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        height: 1.4,
                      ),
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
                    player.level.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'PROXIMO',
                    style: TextStyle(fontSize: 10, color: Colors.white38),
                  ),
                  Text(
                    nextRank ?? '--',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neonBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
    final activeDays = snapshot?.activeDays ?? 0;
    final progress = rule.requiredActiveDays == 0
        ? 0.0
        : (activeDays / rule.requiredActiveDays).clamp(0.0, 1.0);
    final remainingDays = (rule.requiredActiveDays - activeDays).clamp(
      0,
      rule.requiredActiveDays,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _statusColor(status).withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MANUTENCAO DO RANK',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white54,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _metric(
                  'STATUS',
                  _statusLabel(status),
                  _statusColor(status),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metric(
                  'SEMANA',
                  '$activeDays/${rule.requiredActiveDays} dias',
                  AppColors.neonBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white10,
              color: _statusColor(status),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _metric(
                  'STRIKES',
                  '${snapshot?.demotionStrikes ?? 0}',
                  (snapshot?.demotionStrikes ?? 0) > 0
                      ? Colors.orangeAccent
                      : Colors.white70,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metric(
                  'BOSS',
                  rule.requiresBossClear
                      ? ((snapshot?.bossCompleted ?? false)
                            ? 'CLEAR'
                            : 'PENDENTE')
                      : 'NAO EXIGIDO',
                  (snapshot?.bossCompleted ?? false)
                      ? Colors.greenAccent
                      : Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            remainingDays > 0
                ? 'Faltam $remainingDays dia(s) ativo(s) para segurar o rank nesta semana.'
                : 'A manutencao minima da semana ja foi garantida.',
            style: TextStyle(
              color: remainingDays > 0 ? Colors.white70 : Colors.greenAccent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            snapshot?.detail ??
                'O sistema vai mostrar aqui o risco de queda, os requisitos da semana e o estado competitivo do seu rank.',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              height: 1.5,
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
  ) {
    final accentColor = switch (exam?.status) {
      PromotionExamStatus.inProgress => Colors.orangeAccent,
      PromotionExamStatus.passed => Colors.greenAccent,
      PromotionExamStatus.failed => Colors.redAccent,
      PromotionExamStatus.promoted => AppColors.neonBlue,
      null => AppColors.neonBlue,
    };

    final title = switch (exam?.status) {
      PromotionExamStatus.inProgress => 'EXAME DE PROMOCAO EM CURSO',
      PromotionExamStatus.passed => 'EXAME CONCLUIDO',
      PromotionExamStatus.failed => 'EXAME FALHOU',
      PromotionExamStatus.promoted => 'PROMOCAO CONFIRMADA',
      null => 'EXAME DE PROMOCAO',
    };

    final description = switch (exam?.status) {
      PromotionExamStatus.inProgress =>
        'Conquiste ${exam!.targetActiveDays} dias ativos nesta semana antes de ${_formatShortDate(exam.expiresAt)}.',
      PromotionExamStatus.passed =>
        'Voce venceu a prova para o rank ${exam!.targetRank}. Agora confirme a promocao.',
      PromotionExamStatus.failed =>
        'O exame expirou ou voce nao sustentou a progressao exigida. Conquiste o estado de promocao para tentar de novo.',
      PromotionExamStatus.promoted =>
        'Sua ascensao foi registrada. Agora voce precisa sustentar o novo padrao.',
      null =>
        snapshot?.promotionReady == true
            ? 'Voce destravou o exame para o rank ${snapshot!.promotionTargetRank}. Inicie a prova para validar a ascensao.'
            : 'Quando o sistema detectar promocao pronta, a prova formal vai aparecer aqui.',
    };

    final actionLabel = switch (exam?.status) {
      PromotionExamStatus.passed => 'PROMOVER RANK',
      PromotionExamStatus.inProgress => null,
      PromotionExamStatus.failed => null,
      PromotionExamStatus.promoted => null,
      null => snapshot?.promotionReady == true ? 'INICIAR EXAME' : null,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white54,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          if (exam != null &&
              exam.status == PromotionExamStatus.inProgress) ...[
            const SizedBox(height: 12),
            _metric(
              'META DO EXAME',
              '${exam.targetActiveDays} dias',
              accentColor,
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                ),
                onPressed: () =>
                    _handlePromotionExamAction(context, ref, snapshot, exam),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRankBossCard(
    AsyncValue remoteWeeklyBoss,
    AsyncValue<List<WeeklyBossCompletion>> topCompletions,
    RankArenaSummary arena,
  ) {
    final boss = remoteWeeklyBoss.valueOrNull;
    if (!arena.hasActiveBoss && !remoteWeeklyBoss.isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ARENA DO RANK',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white54,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              arena.leaderHeadline,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              arena.crowdReading,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ARENA DO RANK',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white54,
              letterSpacing: 1.2,
            ),
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
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amberAccent.withOpacity(0.35),
                    ),
                  ),
                  child: Text(
                    arena.urgencyLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.amberAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              boss.description,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              arena.leaderHeadline,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _metric(
                    'SEU PROGRESSO',
                    '${arena.progress}/${arena.target}',
                    AppColors.neonBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _metric(
                    'ESTADO',
                    arena.stateLabel,
                    Colors.amberAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _metric(
                    'CLEARS TOTAIS',
                    '${arena.completedCount}',
                    arena.completedCount >= 10
                        ? Colors.greenAccent
                        : Colors.white70,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _metric(
                    'RECOMPENSA',
                    arena.rewardLabel,
                    Colors.purpleAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              arena.crowdReading,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                height: 1.4,
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
            ..._buildTopCompletions(topCompletions),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryCard(List<CompetitiveRankSnapshot> history) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRILHA DE ASCENSAO',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white54,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          if (history.isEmpty)
            const Text(
              'Seu historico de rank vai aparecer aqui conforme as semanas forem registradas.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
                height: 1.4,
              ),
            )
          else
            ...history.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _statusColor(entry.status),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _statusColor(entry.status).withOpacity(0.45),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _statusColor(entry.status).withOpacity(0.18),
                          ),
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
                                    color: AppColors.neonBlue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.neonBlue.withOpacity(
                                        0.2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    entry.weekKey,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.neonBlue,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _historyEventLabel(entry),
                                  style: TextStyle(
                                    color: _statusColor(entry.status),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rank ${entry.currentRank} | ${_statusLabel(entry.status)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${entry.activeDays}/${entry.requiredActiveDays} dias | strikes ${entry.demotionStrikes}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.summary,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ],
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

  Widget _buildPrestigeCard(RankPrestigeSummary prestige) {
    final accentColor = switch (prestige.prestigeLabel) {
      'PREDADOR' => Colors.amberAccent,
      'ASCENDENTE' => AppColors.neonBlue,
      'ESTAVEL' => Colors.greenAccent,
      'OSCILANTE' => Colors.orangeAccent,
      _ => Colors.redAccent,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'PRESTIGIO DO RANK',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                prestige.prestigeLabel,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _metric(
                  'MANUTENCAO',
                  '${prestige.maintenanceRate}%',
                  accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metric(
                  'STREAK SEGURA',
                  '${prestige.secureStreak}',
                  Colors.greenAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _metric(
                  'SEMANAS PERFEITAS',
                  '${prestige.perfectWeeks}',
                  Colors.amberAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metric(
                  'EXAMES',
                  '${prestige.examClears}',
                  AppColors.neonBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _prestigeReading(prestige),
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonCard(RankSeasonSummary season) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonBlue.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'TEMPORADA ATUAL',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                season.seasonLabel,
                style: const TextStyle(
                  color: AppColors.neonBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (season.recordedWeeks == 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A temporada ainda nao tem semanas registradas. Conforme voce jogar, esta area vai mostrar o peso competitivo do seu mes.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _metric(
                  'RESET',
                  _formatShortDate(season.resetAt),
                  Colors.white70,
                ),
              ],
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _metric('PICO', season.peakRank, Colors.amberAccent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _metric(
                    'MEDIA',
                    season.averageActiveDays.toStringAsFixed(1),
                    AppColors.neonBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _metric(
                    'SEMANAS SEGURAS',
                    '${season.secureWeeks}',
                    Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _metric(
                    'EXAMES',
                    '${season.examWeeks}',
                    Colors.orangeAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _metric(
                    'QUEDAS',
                    '${season.demotionEvents}',
                    Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _metric(
                    'PROMOCOES',
                    '${season.promotionEvents}',
                    AppColors.neonBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _metric(
                    'PERFEITAS',
                    '${season.perfectWeeks}',
                    Colors.amberAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _metric(
                    'SEMANAS RESTANTES',
                    '${season.weeksRemaining}',
                    Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.neonBlue.withOpacity(0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRILHA SAZONAL: ${season.rewardTierLabel}',
                    style: const TextStyle(
                      color: AppColors.neonBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    season.rewardPreview,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Reset previsto em ${_formatShortDate(season.resetAt)}.',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _seasonReading(season),
              style: const TextStyle(
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


  Widget _metric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
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

  Future<void> _handlePromotionExamAction(
    BuildContext context,
    WidgetRef ref,
    CompetitiveRankSnapshot? snapshot,
    PromotionExam? exam,
  ) async {
    if (snapshot == null) return;

    final repository = ref.read(rankProgressionRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    if (exam?.status == PromotionExamStatus.passed) {
      final promoted = await repository.promoteIfExamPassed(snapshot);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            promoted
                ? 'Promocao confirmada. O sistema registrou seu novo rank.'
                : 'A promocao nao pode ser concluida agora.',
          ),
        ),
      );
      return;
    }

    final started = await repository.startPromotionExam(snapshot);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          started
              ? 'Exame iniciado. Ganhe mais um dia ativo para concluir a promocao.'
              : 'Nao foi possivel iniciar o exame agora.',
        ),
      ),
    );
  }

  Future<void> _forcePromotionReady(
    BuildContext context,
    WidgetRef ref,
    Player player,
  ) async {
    final repository = ref.read(rankProgressionRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final ok = await repository.debugForcePromotionReady(player);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Snapshot forcado para promotionReady.'
              : 'Nao foi possivel forcar promotionReady.',
        ),
      ),
    );
  }

  Future<void> _forceExamPassed(
    BuildContext context,
    WidgetRef ref,
    Player player,
  ) async {
    final repository = ref.read(rankProgressionRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final ok = await repository.debugForceExamPassed(player);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Exame marcado como aprovado para teste.'
              : 'Nao foi possivel forcar exame aprovado.',
        ),
      ),
    );
  }

  Future<void> _clearPromotionState(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(rankProgressionRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    await repository.debugClearPromotionState();
    messenger.showSnackBar(
      const SnackBar(content: Text('Exame atual encerrado para teste.')),
    );
  }

  Color _statusColor(RankMaintenanceStatus status) {
    return switch (status) {
      RankMaintenanceStatus.secure => Colors.greenAccent,
      RankMaintenanceStatus.warning => Colors.orangeAccent,
      RankMaintenanceStatus.critical => Colors.redAccent,
      RankMaintenanceStatus.promotionReady => AppColors.neonBlue,
      RankMaintenanceStatus.demoted => Colors.redAccent,
    };
  }

  String _statusLabel(RankMaintenanceStatus status) {
    return switch (status) {
      RankMaintenanceStatus.secure => 'ESTAVEL',
      RankMaintenanceStatus.warning => 'ALERTA',
      RankMaintenanceStatus.critical => 'RISCO',
      RankMaintenanceStatus.promotionReady => 'PROMOCAO',
      RankMaintenanceStatus.demoted => 'QUEDA',
    };
  }

  String _historyEventLabel(CompetitiveRankSnapshot entry) {
    return switch (entry.eventType) {
      CompetitiveRankEventType.demotionApplied => 'QUEDA',
      CompetitiveRankEventType.promotionConfirmed => 'PROMOVIDO',
      CompetitiveRankEventType.promotionUnlocked => 'EXAME',
      CompetitiveRankEventType.perfectWeek => 'SEMANA PERFEITA',
      CompetitiveRankEventType.warning => 'ALERTA',
      _ => 'REGISTRO',
    };
  }

  String _formatShortDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}';
  }

  String _shortError(Object? error) {
    if (error == null) return 'desconhecido';
    final text = error.toString().replaceAll('\n', ' ');
    return text.length > 48 ? '${text.substring(0, 48)}...' : text;
  }

  String _seasonReading(RankSeasonSummary season) {
    if (season.demotionEvents > 0) {
      return 'A temporada mostra instabilidade competitiva. O foco agora e proteger manutencao antes de buscar novos exames.';
    }
    if (season.promotionEvents > 0) {
      return 'A temporada ja registrou promocao real. Agora o desafio e preservar esse novo patamar ate o reset.';
    }
    if (season.examWeeks > 0) {
      return 'Voce entrou em zona de ascensao nesta temporada. Continue empilhando semanas fortes para transformar exame em promocao.';
    }
    if (season.secureWeeks >= 2) {
      return 'A temporada esta consistente. Seu sistema ja aguenta pressao e comeca a construir prestigio real.';
    }
    return 'A temporada ainda esta ganhando forma. O mais importante agora e acumular semanas registradas sem perder o ciclo.';
  }

  String _prestigeReading(RankPrestigeSummary prestige) {
    if (prestige.prestigeLabel == 'PREDADOR') {
      return 'Seu nome carrega peso dentro do rank. A manutencao esta alta e voce ja produz semanas dignas de elite.';
    }
    if (prestige.prestigeLabel == 'ASCENDENTE') {
      return 'Voce esta construindo reputacao real. O proximo salto vem de transformar exames em dominacao constante.';
    }
    if (prestige.prestigeLabel == 'ESTAVEL') {
      return 'Seu rank esta respeitavel. Agora o desafio e converter consistencia em prestigio forte.';
    }
    if (prestige.prestigeLabel == 'OSCILANTE') {
      return 'O sistema reconhece potencial, mas ainda ha quebra demais entre semanas. Menos explosao, mais sustentacao.';
    }
    return 'Seu prestigio ainda e fragil. Primeiro recupere manutencao, depois volte a pensar em ascensao.';
  }
}
