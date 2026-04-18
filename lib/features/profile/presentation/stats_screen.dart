import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/auth/domain/auth_state.dart';
import 'package:ascend/features/auth/presentation/auth_controller.dart';
import 'package:ascend/features/profile/domain/achievement_modal.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/domain/weekly_insights.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:ascend/features/weekly_boss/presentation/weekly_boss_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'player_controller.dart';
import 'rank_progression_provider.dart';

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
    final rankHistory = ref.watch(rankProgressionHistoryProvider).valueOrNull ?? const <CompetitiveRankSnapshot>[];
    final attrs = player.attributes;
    final hasPoints = player.statPoints > 0;
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
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DETALHES DE STATUS',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
                    ),
                    Divider(color: AppColors.neonBlue, thickness: 1),
                  ],
                ),
              ),
              _buildSectionSwitcher(),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: switch (_currentSection) {
                  _StatsSection.overview => _buildOverviewSection(
                      player,
                      attrs,
                      rankSnapshot,
                      weeklyBoss,
                      weeklyBossProgress,
                      weeklyBossClaimed,
                      remoteWeeklyBoss,
                    ),
                  _StatsSection.analysis => _buildAnalysisSection(
                      player,
                      insights.discipline,
                      insights.review,
                      rankHistory,
                    ),
                  _StatsSection.plan => _buildPlanSection(player, insights.nextWeekPlan),
                  _StatsSection.build => _buildBuildSection(
                      context,
                      player,
                      attrs,
                      hasPoints,
                      authState,
                    ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionSwitcher() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: _StatsSection.values.map((section) {
          final selected = section == _currentSection;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => setState(() => _currentSection = section),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.neonBlue.withOpacity(0.16) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: selected ? Border.all(color: AppColors.neonBlue.withOpacity(0.45)) : null,
                  ),
                  child: Text(
                    section.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? AppColors.neonBlue : Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverviewSection(
    Player player,
    PlayerAttributes attrs,
    CompetitiveRankSnapshot? rankSnapshot,
    WeeklyBossDefinition? weeklyBoss,
    int weeklyBossProgress,
    bool weeklyBossClaimed,
    AsyncValue<RemoteWeeklyBoss?> remoteWeeklyBoss,
  ) {
    return Column(
      key: const ValueKey('overview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCombatPowerCard(player.level, attrs),
        const SizedBox(height: 20),
        _buildCompetitiveRankCard(rankSnapshot, player),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStreakCard(
                label: 'STREAK ATUAL',
                value: '${player.currentStreak}',
                caption: 'dias seguidos',
                accentColor: Colors.orangeAccent,
                icon: Icons.local_fire_department,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStreakCard(
                label: 'MELHOR STREAK',
                value: '${player.bestStreak}',
                caption: 'recorde pessoal',
                accentColor: AppColors.neonBlue,
                icon: Icons.emoji_events,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildInfoBox('ULTIMA CONCLUSAO', _formatLastCompletion(player.lastQuestCompletionDate)),
        _buildInfoBox('FOCO PRINCIPAL', player.primaryFocus.label),
        _buildInfoBox(
          'BOSS SEMANAL',
          weeklyBoss == null
              ? 'Nenhum boss ativo'
              : (weeklyBossClaimed
                  ? '${weeklyBoss.title} | resgatado'
                  : '${weeklyBossProgress}/${weeklyBoss.targetActiveDays}'),
        ),
        if (rankSnapshot != null)
          _buildInfoBox(
            'PROMOCAO',
            rankSnapshot.promotionReady
                ? 'Pronto para exame ${rankSnapshot.promotionTargetRank ?? ''}'.trim()
                : 'Ainda nao liberada',
          ),
        _buildOnlineEventInfoBox(remoteWeeklyBoss),
      ],
    );
  }

  Widget _buildAnalysisSection(
    Player player,
    WeeklyDisciplineReport weeklyScore,
    WeeklyReviewReport weeklyReview,
    List<CompetitiveRankSnapshot> rankHistory,
  ) {
    return Column(
      key: const ValueKey('analysis'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ULTIMOS 7 DIAS',
          style: TextStyle(fontSize: 14, color: Colors.white38, letterSpacing: 2),
        ),
        const SizedBox(height: 15),
        _buildWeeklyHistory(player),
        const SizedBox(height: 10),
        _buildInfoBox('DIAS ATIVOS', '${_activityDates(player).length}'),
        _buildInfoBox('CONSISTENCIA 7D', _calculateWeeklyConsistency(player)),
        const SizedBox(height: 10),
        _buildWeeklyScoreCard(weeklyScore),
        const SizedBox(height: 10),
        _buildWeeklyReviewCard(weeklyReview),
        const SizedBox(height: 10),
        _buildRankHistoryCard(rankHistory),
      ],
    );
  }

  Widget _buildPlanSection(Player player, NextWeekPlan nextWeekPlan) {
    return Column(
      key: const ValueKey('plan'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBox('FOCO DA SEMANA', player.primaryFocus.label),
        const SizedBox(height: 10),
        _buildNextWeekPlanCard(nextWeekPlan),
      ],
    );
  }

  Widget _buildBuildSection(
    BuildContext context,
    Player player,
    PlayerAttributes attrs,
    bool hasPoints,
    AuthState authState,
  ) {
    return Column(
      key: const ValueKey('build'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'POTENCIAL DE ATRIBUTO',
              style: TextStyle(fontSize: 14, color: Colors.white38, letterSpacing: 2),
            ),
            if (hasPoints)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.neonBlue),
                ),
                child: Text(
                  '${player.statPoints} PONTOS',
                  style: const TextStyle(color: AppColors.neonBlue, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        _buildDetailedStat(context, 'FORCA', attrs.strength, Colors.orangeAccent, AttributeType.strength, hasPoints),
        _buildDetailedStat(
          context,
          'INTELIGENCIA',
          attrs.intelligence,
          Colors.lightBlueAccent,
          AttributeType.intelligence,
          hasPoints,
        ),
        _buildDetailedStat(context, 'VITALIDADE', attrs.vitality, Colors.greenAccent, AttributeType.vitality, hasPoints),
        _buildDetailedStat(context, 'AGILIDADE', attrs.agility, Colors.purpleAccent, AttributeType.agility, hasPoints),
        const SizedBox(height: 30),
        const Text(
          'INFORMACOES DO SISTEMA',
          style: TextStyle(fontSize: 14, color: Colors.white38, letterSpacing: 2),
        ),
        const SizedBox(height: 15),
        _buildInfoBox('TITULO ATUAL', _getBestTitle(player)),
        _buildInfoBox('CLASSE', 'PLAYER'),
        const SizedBox(height: 30),
        const Text(
          'CONQUISTAS',
          style: TextStyle(fontSize: 14, color: Colors.white38, letterSpacing: 2),
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          itemCount: systemAchievements.length,
          itemBuilder: (context, index) {
            final achievement = systemAchievements[index];
            final isUnlocked = achievement.requirement(player);

            return Container(
              decoration: BoxDecoration(
                color: isUnlocked ? AppColors.neonBlue.withOpacity(0.05) : Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUnlocked ? AppColors.neonBlue.withOpacity(0.5) : Colors.white10,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    achievement.icon,
                    color: isUnlocked ? AppColors.neonBlue : Colors.white10,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: isUnlocked ? Colors.white : Colors.white24,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 40),
        if (authState is AuthSuccess)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: Colors.redAccent),
                foregroundColor: Colors.redAccent,
              ),
              onPressed: () => _confirmLogout(context, authState.displayName),
              icon: const Icon(Icons.logout),
              label: const Text(
                'SAIR DA CONTA GOOGLE',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCombatPowerCard(int level, PlayerAttributes attrs) {
    final power = (level * 10) + attrs.strength + attrs.intelligence + attrs.vitality + attrs.agility;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.neonBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.neonBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text('PODER DE COMBATE', style: TextStyle(fontSize: 12, color: Colors.white54)),
          Text(
            power.toString().padLeft(4, '0'),
            style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
          ),
          const SizedBox(height: 10),
          const Text('STATUS: ESTAVEL', style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildCompetitiveRankCard(CompetitiveRankSnapshot? snapshot, Player player) {
    final fallbackRank = playerRankForLevel(player.level);
    final currentRank = snapshot?.currentRank ?? fallbackRank;
    final status = snapshot?.status ?? RankMaintenanceStatus.secure;
    final statusColor = switch (status) {
      RankMaintenanceStatus.secure => Colors.greenAccent,
      RankMaintenanceStatus.warning => Colors.orangeAccent,
      RankMaintenanceStatus.critical => Colors.redAccent,
      RankMaintenanceStatus.promotionReady => AppColors.neonBlue,
      RankMaintenanceStatus.demoted => Colors.redAccent,
    };
    final statusLabel = switch (status) {
      RankMaintenanceStatus.secure => 'ESTAVEL',
      RankMaintenanceStatus.warning => 'ALERTA',
      RankMaintenanceStatus.critical => 'RISCO',
      RankMaintenanceStatus.promotionReady => 'PROMOCAO',
      RankMaintenanceStatus.demoted => 'QUEDA',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: statusColor.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'STATUS DE RANK',
                  style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1.2),
                ),
              ),
              Text(
                'RANK $currentRank',
                style: const TextStyle(
                  color: AppColors.neonBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              if (snapshot != null)
                Text(
                  '${snapshot.activeDays}/${snapshot.requiredActiveDays} dias',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            snapshot?.summary ?? 'Rank sincronizando com o sistema remoto.',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, height: 1.4),
          ),
          const SizedBox(height: 6),
          Text(
            snapshot?.detail ?? 'Assim que a progressao remota for criada, o app vai mostrar risco semanal, promocao e queda real.',
            style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
          ),
          if (snapshot != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMiniMetric(
                    'STRIKES',
                    '${snapshot.demotionStrikes}',
                    statusColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMiniMetric(
                    'BOSS',
                    snapshot.bossCompleted ? 'CLEAR' : (snapshot.requiresBossClear ? 'PEND' : 'N/A'),
                    snapshot.bossCompleted ? Colors.greenAccent : Colors.white54,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color color) {
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
            style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStat(
    BuildContext context,
    String label,
    int value,
    Color color,
    AttributeType type,
    bool canUpgrade,
  ) {
    final progress = (value / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Row(
                children: [
                  Text(value.toString(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                  if (canUpgrade) ...[
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: () => ref.read(playerProvider.notifier).upgradeAttribute(type),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(0.2),
                          border: Border.all(color: color.withOpacity(0.5)),
                        ),
                        child: Icon(Icons.add, color: color, size: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    height: 4,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineEventInfoBox(AsyncValue<RemoteWeeklyBoss?> remoteWeeklyBoss) {
    return remoteWeeklyBoss.when(
      data: (boss) {
        if (boss == null) {
          return _buildInfoBox('EVENTO ONLINE', 'Sem evento ativo');
        }

        return _buildInfoBox(
          'EVENTO ONLINE',
          '${boss.completedCount} concluidos | ${boss.participantCount} participantes',
        );
      },
      loading: () => _buildInfoBox('EVENTO ONLINE', 'Conectando ao Firestore...'),
      error: (error, _) => _buildInfoBox(
        'EVENTO ONLINE',
        'Erro ao consultar: ${_shortError(error)}',
      ),
    );
  }

  Widget _buildWeeklyHistory(Player player) {
    final weeklyEntries = _lastSevenDays(player);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: weeklyEntries.map((entry) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Text(
                    entry.label,
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: entry.isActive ? AppColors.neonBlue.withOpacity(0.18) : Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: entry.isActive ? AppColors.neonBlue : Colors.white10,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        entry.isActive ? Icons.check : Icons.remove,
                        color: entry.isActive ? AppColors.neonBlue : Colors.white24,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<_DailyActivity> _lastSevenDays(Player player) {
    final today = DateTime.now();
    final activeDates = _activityDates(player);

    return List.generate(7, (index) {
      final date = DateTime(today.year, today.month, today.day).subtract(Duration(days: 6 - index));
      final isActive = activeDates.contains(date);

      return _DailyActivity(
        label: _weekdayLabel(date.weekday),
        isActive: isActive,
      );
    });
  }

  String _calculateWeeklyConsistency(Player player) {
    final activeDays = _lastSevenDays(player).where((entry) => entry.isActive).length;
    return '$activeDays/7';
  }

  Set<DateTime> _activityDates(Player player) {
    final activityDates = player.activityHistory
        .map((entry) => DateTime(entry.year, entry.month, entry.day))
        .toSet();

    final lastCompletion = player.lastQuestCompletionDate;
    if (lastCompletion != null) {
      activityDates.add(DateTime(lastCompletion.year, lastCompletion.month, lastCompletion.day));
    }

    return activityDates;
  }

  Widget _buildWeeklyScoreCard(WeeklyDisciplineReport report) {
    final deltaPrefix = report.deltaFromPreviousWeek > 0 ? '+' : '';
    final deltaColor = switch (report.deltaFromPreviousWeek) {
      > 0 => Colors.greenAccent,
      < 0 => Colors.redAccent,
      _ => Colors.white54,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neonBlue.withOpacity(0.05),
        border: Border.all(color: AppColors.neonBlue.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SCORE SEMANAL',
            style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${report.score}%',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  report.grade,
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neonBlue,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$deltaPrefix${report.deltaFromPreviousWeek}d',
                style: TextStyle(
                  color: deltaColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Semana atual: ${report.currentWeekActiveDays}/7 dias | Semana passada: ${report.previousWeekActiveDays}/7 dias',
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyReviewCard(WeeklyReviewReport review) {
    final trendColor = switch (review.status) {
      WeeklyReviewStatus.rising => Colors.greenAccent,
      WeeklyReviewStatus.stable => AppColors.neonBlue,
      WeeklyReviewStatus.risk => Colors.orangeAccent,
      WeeklyReviewStatus.critical => Colors.redAccent,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: trendColor.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(review.icon, color: trendColor, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'REVISAO SEMANAL',
                  style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1.2),
                ),
              ),
              Text(
                review.badge,
                style: TextStyle(
                  color: trendColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.summary,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            review.detail,
            style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: trendColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: trendColor.withOpacity(0.2)),
            ),
            child: Text(
              review.recommendation,
              style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankHistoryCard(List<CompetitiveRankSnapshot> history) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRILHA DE RANK',
            style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          if (history.isEmpty)
            const Text(
              'O historico competitivo vai aparecer aqui assim que o Firestore registrar as semanas.',
              style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
            )
          else
            ...history.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.neonBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.neonBlue.withOpacity(0.2)),
                      ),
                      child: Text(
                        entry.weekKey,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10, color: AppColors.neonBlue),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rank ${entry.currentRank} | ${_rankStatusLabel(entry.status)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${entry.activeDays}/${entry.requiredActiveDays} dias | strikes ${entry.demotionStrikes}',
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.summary,
                            style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                          ),
                        ],
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

  Widget _buildNextWeekPlanCard(NextWeekPlan plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_outlined, color: AppColors.neonBlue, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'PLANO DA PROXIMA SEMANA',
                  style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1.2),
                ),
              ),
              Text(
                plan.difficultyLabel,
                style: const TextStyle(
                  color: AppColors.neonBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            plan.headline,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            plan.summary,
            style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 12),
          ...plan.priorities.map(
            (priority) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.bolt, color: AppColors.neonBlue, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      priority,
                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neonBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.neonBlue.withOpacity(0.2)),
            ),
            child: Text(
              plan.rule,
              style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    return labels[weekday - 1];
  }

  String _rankStatusLabel(RankMaintenanceStatus status) {
    return switch (status) {
      RankMaintenanceStatus.secure => 'ESTAVEL',
      RankMaintenanceStatus.warning => 'ALERTA',
      RankMaintenanceStatus.critical => 'RISCO',
      RankMaintenanceStatus.promotionReady => 'PROMOCAO',
      RankMaintenanceStatus.demoted => 'QUEDA',
    };
  }

  Widget _buildStreakCard({
    required String label,
    required String value,
    required String caption,
    required Color accentColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: accentColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _getBestTitle(Player player) {
    final unlocked = systemAchievements.where((achievement) => achievement.requirement(player)).toList();
    return unlocked.isNotEmpty ? unlocked.last.title : 'ASPIRANTE';
  }

  String _formatLastCompletion(DateTime? value) {
    if (value == null) return 'Nenhuma ainda';
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  String _shortError(Object? error) {
    if (error == null) return 'desconhecido';
    final text = error.toString().replaceAll('\n', ' ');
    return text.length > 48 ? '${text.substring(0, 48)}...' : text;
  }

  Future<void> _confirmLogout(BuildContext context, String displayName) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Sair da conta'),
          content: Text('Deseja desconectar $displayName da sua sessao atual?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && mounted) {
      await ref.read(authProvider.notifier).signOut();
    }
  }
}

enum _StatsSection {
  overview('RESUMO'),
  analysis('ANALISE'),
  plan('PLANO'),
  build('BUILD');

  const _StatsSection(this.label);

  final String label;
}

class _DailyActivity {
  const _DailyActivity({
    required this.label,
    required this.isActive,
  });

  final String label;
  final bool isActive;
}
