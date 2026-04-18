import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/auth/domain/auth_state.dart';
import 'package:ascend/features/auth/presentation/auth_controller.dart';
import 'package:ascend/features/profile/domain/achievement_modal.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/rank_prestige.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/rank_season.dart';
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
    final rankHistory = ref.watch(rankProgressionHistoryProvider).valueOrNull ?? const <CompetitiveRankSnapshot>[];
    final prestige = buildRankPrestigeSummary(rankHistory);
    final season = buildCurrentSeasonSummary(rankHistory);
    final authState = ref.watch(authProvider);
    final remoteWeeklyBoss = ref.watch(remoteWeeklyBossProvider);
    final topCompletions = ref.watch(weeklyBossTopCompletionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(player.name, player.level, competitiveRank, _calculateCurrentTitle(player)),
            const SizedBox(height: 40),
            _buildStatusCard(
              child: Column(
                children: [
                  _buildFocusBanner(context, player.primaryFocus),
                  const SizedBox(height: 20),
                  _buildStatBar('XP', player.xp / player.maxXp, AppColors.neonBlue, '${player.xp} / ${player.maxXp}'),
                  const SizedBox(height: 20),
                  _buildStatBar('HP', 1.0, Colors.redAccent, '100%'),
                  const SizedBox(height: 24),
                  _buildCompetitivePulse(rankSnapshot, prestige, season),
                  const SizedBox(height: 20),
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
            const SizedBox(height: 40),
            const Text(
              'ATRIBUTOS',
              style: TextStyle(fontSize: 18, letterSpacing: 3, fontWeight: FontWeight.bold),
            ),
            const Divider(color: AppColors.neonBlue, thickness: 0.5),
            const SizedBox(height: 10),
            _buildAttributeRow('FORCA', player.attributes.strength.toString(), Icons.fitness_center),
            _buildAttributeRow('INTELIGENCIA', player.attributes.intelligence.toString(), Icons.psychology),
            _buildAttributeRow('VITALIDADE', player.attributes.vitality.toString(), Icons.favorite),
            _buildAttributeRow('AGILIDADE', player.attributes.agility.toString(), Icons.speed),
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

  Widget _buildHeader(String name, int level, String rank, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PLAYER: $name | $title',
          style: const TextStyle(fontSize: 12, color: AppColors.neonBlue, letterSpacing: 1.5),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RANK: $rank',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: AppColors.neonBlue.withOpacity(0.8), blurRadius: 20)],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('LEVEL', style: TextStyle(fontSize: 10, color: Colors.white38)),
                Text(level.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }

  Widget _buildFocusBanner(BuildContext context, AwakeningPath focus) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.neonBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonBlue.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'FOCO ATUAL',
                  style: TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 1.2),
                ),
              ),
              TextButton(
                onPressed: () => _openFocusSelectionSheet(context, focus),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

  void _openFocusSelectionSheet(BuildContext context, AwakeningPath currentFocus) {
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
        const SnackBar(content: Text('Faca login para registrar e resgatar o boss semanal.')),
      );
      return;
    }

    if (remoteBoss == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum boss remoto ativo para resgate no momento.')),
      );
      return;
    }

    if (!weeklyBoss.isCompleted(ref.read(playerProvider)) ||
        weeklyBoss.isClaimedThisWeek(ref.read(playerProvider))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O boss semanal ainda nao esta pronto para resgate.')),
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

      if (remoteResult == ClaimWeeklyBossRemoteResult.alreadyCompleted) {
        ref.read(playerProvider.notifier).markWeeklyBossClaimedNow();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seu clear remoto ja estava registrado nesta semana.')),
        );
        return;
      }

      final applied = ref.read(playerProvider.notifier).claimWeeklyBossReward(weeklyBoss);
      if (!applied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clear remoto registrado, mas recompensa local ja estava aplicada.')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boss semanal derrotado. Recompensa e ranking sincronizados.')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao registrar clear remoto. Tente novamente em instantes.')),
      );
    }
  }

  Widget _buildStatBar(String label, double progress, Color color, String trailing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text(trailing, style: const TextStyle(fontSize: 10, color: Colors.white38)),
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
      CompetitiveRankEventType.promotionConfirmed => 'PROMOCAO REGISTRADA',
      CompetitiveRankEventType.promotionUnlocked => 'EXAME DISPONIVEL',
      CompetitiveRankEventType.demotionApplied => 'QUEDA DE RANK',
      CompetitiveRankEventType.perfectWeek => 'SEMANA PERFEITA',
      CompetitiveRankEventType.warning => 'RANK EM ALERTA',
      _ => 'STATUS COMPETITIVO',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.35)),
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
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            'Temporada ${season.seasonLabel} | manutencao ${prestige.maintenanceRate}% | pico ${season.peakRank}',
            style: const TextStyle(color: Colors.white60, fontSize: 11, height: 1.4),
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
        color: Colors.white.withOpacity(0.02),
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
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
    final progress = weeklyBoss?.progressFor(player) ?? 0;
    final isClaimed = weeklyBoss?.isClaimedThisWeek(player) ?? false;
    final isCompleted = weeklyBoss?.isCompleted(player) ?? false;

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
          Row(
            children: [
              const Icon(Icons.shield_moon, color: Colors.amberAccent, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'BOSS SEMANAL',
                  style: TextStyle(fontSize: 12, color: Colors.white38, letterSpacing: 1.2),
                ),
              ),
              Text(
                hasActiveRemoteBoss ? '$progress/${weeklyBoss.targetActiveDays}' : '--',
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
              'ONLINE: ${remoteBoss.completedCount} concluidos | ${remoteBoss.participantCount} participantes',
              style: const TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 0.5),
            ),
          ] else if (remoteWeeklyBoss.isLoading) ...[
            const SizedBox(height: 8),
            const Text(
              'ONLINE: conectando ao Firestore...',
              style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 0.5),
            ),
          ] else if (remoteWeeklyBoss.hasError) ...[
            const SizedBox(height: 8),
            Text(
              'ONLINE: erro ao consultar evento (${_shortError(remoteWeeklyBoss.error)})',
              style: const TextStyle(color: Colors.redAccent, fontSize: 11, letterSpacing: 0.5),
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
              style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
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
                    'RECOMPENSA: ${weeklyBoss.rewardXp} XP + ${weeklyBoss.rewardStatPoints} pontos',
                    style: const TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 0.6),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isClaimed
                        ? Colors.white12
                        : (isCompleted ? Colors.amberAccent : Colors.white12),
                    foregroundColor: isCompleted && !isClaimed ? Colors.black : Colors.white54,
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
              'PRIMEIROS CLEARS',
              style: TextStyle(fontSize: 11, color: Colors.white38, letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
            ..._buildTopCompletions(topCompletions),
          ] else if (!remoteWeeklyBoss.isLoading && !remoteWeeklyBoss.hasError) ...[
            const Text(
              'Nenhum boss semanal ativo no momento.',
              style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildTopCompletions(AsyncValue<List<WeeklyBossCompletion>> topCompletions) {
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
          Icon(icon, size: 18, color: AppColors.neonBlue.withOpacity(0.5)),
          const SizedBox(width: 15),
          Text(label, style: const TextStyle(color: Colors.white70, letterSpacing: 1)),
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

  String _calculateCurrentTitle(Player player) {
    final unlocked = systemAchievements.where((achievement) => achievement.requirement(player)).toList();
    return unlocked.isNotEmpty ? unlocked.last.title : 'ASPIRANTE';
  }

  String _shortError(Object? error) {
    if (error == null) return 'desconhecido';
    final text = error.toString().replaceAll('\n', ' ');
    return text.length > 48 ? '${text.substring(0, 48)}...' : text;
  }
}
