import 'package:ascend/features/profile/domain/achievement_modal.dart';
import 'package:ascend/features/quests/domain/quest_model.dart'; // Importante para o AttributeType
import 'package:ascend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'player_controller.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  String _getBestTitle(dynamic player) {
    final unlocked = systemAchievements.where((a) => a.requirement(player)).toList();
    return unlocked.isNotEmpty ? unlocked.last.title : "ASPIRANTE";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final attrs = player.attributes;
    final hasPoints = player.statPoints > 0;

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
                    Text("DETALHES DE STATUS",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4)),
                    Divider(color: AppColors.neonBlue, thickness: 1),
                  ],
                ),
              ),

              _buildCombatPowerCard(player.level, attrs),

              const SizedBox(height: 30),

              // --- SEÇÃO DE PONTOS DISPONÍVEIS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("POTENCIAL DE ATRIBUTO",
                      style: TextStyle(fontSize: 14, color: Colors.white38, letterSpacing: 2)),
                  if (hasPoints)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.neonBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.neonBlue),
                      ),
                      child: Text(
                        "${player.statPoints} PONTOS",
                        style: const TextStyle(color: AppColors.neonBlue, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              _buildDetailedStat(context, ref, "FORÇA", attrs.strength, Colors.orangeAccent, AttributeType.strength, hasPoints),
              _buildDetailedStat(context, ref, "INTELIGÊNCIA", attrs.intelligence, Colors.lightBlueAccent, AttributeType.intelligence, hasPoints),
              _buildDetailedStat(context, ref, "VITALIDADE", attrs.vitality, Colors.greenAccent, AttributeType.vitality, hasPoints),
              _buildDetailedStat(context, ref, "AGILIDADE", attrs.agility, Colors.purpleAccent, AttributeType.agility, hasPoints),

              const SizedBox(height: 40),

              const Text("INFORMAÇÕES DO SISTEMA", 
                  style: TextStyle(fontSize: 14, color: Colors.white38, letterSpacing: 2)),
              const SizedBox(height: 15),
              
              _buildInfoBox("TÍTULO ATUAL", _getBestTitle(player)),
              _buildInfoBox("CLASSE", "PLAYER"),

              const SizedBox(height: 30),

              const Text("CONQUISTAS", 
                  style: TextStyle(fontSize: 14, color: Colors.white38, letterSpacing: 2)),
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
                      color: isUnlocked 
                          ? AppColors.neonBlue.withOpacity(0.05) 
                          : Colors.white.withOpacity(0.02),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCombatPowerCard(int level, dynamic attrs) {
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
          const Text("PODER DE COMBATE", style: TextStyle(fontSize: 12, color: Colors.white54)),
          Text(
            power.toString().padLeft(4, '0'),
            style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
          ),
          const SizedBox(height: 10),
          const Text("STATUS: ESTÁVEL", style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildDetailedStat(BuildContext context, WidgetRef ref, String label, int value, Color color, AttributeType type, bool canUpgrade) {
    double progress = (value / 100).clamp(0.0, 1.0);
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
                }
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Container(
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
}
