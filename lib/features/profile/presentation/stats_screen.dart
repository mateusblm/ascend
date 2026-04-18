import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/auth/domain/auth_state.dart';
import 'package:ascend/features/auth/presentation/auth_controller.dart';
import 'package:ascend/features/profile/domain/achievement_modal.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'player_controller.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final authState = ref.watch(authProvider);
    final attrs = player.attributes;
    final hasPoints = player.statPoints > 0;
    final weeklyBoss = weeklyBossFor(player.primaryFocus);
    final weeklyBossProgress = weeklyBoss.progressFor(player);
    final weeklyBossClaimed = weeklyBoss.isClaimedThisWeek(player);

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
              _buildCombatPowerCard(player.level, attrs),
              const SizedBox(height: 20),
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
                weeklyBossClaimed
                    ? '${weeklyBoss.title} | resgatado'
                    : '${weeklyBossProgress}/${weeklyBoss.targetActiveDays}',
              ),
              const SizedBox(height: 30),
              const Text(
                'ULTIMOS 7 DIAS',
                style: TextStyle(fontSize: 14, color: Colors.white38, letterSpacing: 2),
              ),
              const SizedBox(height: 15),
              _buildWeeklyHistory(player),
              const SizedBox(height: 10),
              _buildInfoBox('DIAS ATIVOS', '${_activityDates(player).length}'),
              _buildInfoBox('CONSISTENCIA 7D', _calculateWeeklyConsistency(player)),
              const SizedBox(height: 30),
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
              _buildDetailedStat(context, ref, 'FORCA', attrs.strength, Colors.orangeAccent, AttributeType.strength, hasPoints),
              _buildDetailedStat(
                context,
                ref,
                'INTELIGENCIA',
                attrs.intelligence,
                Colors.lightBlueAccent,
                AttributeType.intelligence,
                hasPoints,
              ),
              _buildDetailedStat(context, ref, 'VITALIDADE', attrs.vitality, Colors.greenAccent, AttributeType.vitality, hasPoints),
              _buildDetailedStat(context, ref, 'AGILIDADE', attrs.agility, Colors.purpleAccent, AttributeType.agility, hasPoints),
              const SizedBox(height: 40),
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
              const SizedBox(height: 50),
              if (authState is AuthSuccess)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: const BorderSide(color: Colors.redAccent),
                      foregroundColor: Colors.redAccent,
                    ),
                    onPressed: () => _confirmLogout(context, ref, authState.displayName),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'SAIR DA CONTA GOOGLE',
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
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

  Widget _buildDetailedStat(
    BuildContext context,
    WidgetRef ref,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 13)),
        ],
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

  String _weekdayLabel(int weekday) {
    const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    return labels[weekday - 1];
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

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref, String displayName) async {
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

    if (shouldLogout == true) {
      await ref.read(authProvider.notifier).signOut();
    }
  }
}

class _DailyActivity {
  const _DailyActivity({
    required this.label,
    required this.isActive,
  });

  final String label;
  final bool isActive;
}
