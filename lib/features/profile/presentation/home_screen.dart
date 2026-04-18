import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/profile/domain/achievement_modal.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/presentation/focus_selection_sheet.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:ascend/features/weekly_boss/presentation/weekly_boss_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final remoteWeeklyBoss = ref.watch(remoteWeeklyBossProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(player.name, player.level, _calculateCurrentTitle(player)),
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
                  _buildStreakPanel(player),
                  const SizedBox(height: 20),
                  _buildWeeklyBossPanel(context, ref, player, remoteWeeklyBoss),
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

  Widget _buildHeader(String name, int level, String title) {
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
              'RANK: ${playerRankForLevel(level)}',
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

  void _claimWeeklyBoss(BuildContext context, WidgetRef ref) {
    final claimed = ref.read(playerProvider.notifier).claimWeeklyBossReward();
    final message = claimed
        ? 'Boss semanal derrotado. Recompensa aplicada ao sistema.'
        : 'O boss semanal ainda nao esta pronto para resgate.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
    AsyncValue<RemoteWeeklyBoss?> remoteWeeklyBoss,
  ) {
    final localBoss = weeklyBossForPlayer(player);
    final remoteBoss = remoteWeeklyBoss.valueOrNull;
    final weeklyBoss = remoteBoss == null
        ? localBoss
        : WeeklyBossDefinition(
            rank: remoteBoss.rank,
            title: remoteBoss.title,
            description: remoteBoss.description,
            targetActiveDays: remoteBoss.targetActiveDays,
            rewardXp: remoteBoss.rewardXp,
            rewardStatPoints: remoteBoss.rewardStatPoints,
          );
    final progress = weeklyBoss.progressFor(player);
    final isClaimed = weeklyBoss.isClaimedThisWeek(player);
    final isCompleted = weeklyBoss.isCompleted(player);

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
                '$progress/${weeklyBoss.targetActiveDays}',
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
          ],
          const SizedBox(height: 10),
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
                    ? () => _claimWeeklyBoss(context, ref)
                    : null,
                child: Text(isClaimed ? 'RESGATADO' : 'RESGATAR'),
              ),
            ],
          ),
        ],
      ),
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
}
