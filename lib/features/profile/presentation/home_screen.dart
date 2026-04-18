import 'package:ascend/features/profile/domain/achievement_modal.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Deixamos o gradiente para o MainNavigation
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(player.name, player.level, _calculateCurrentTitle(player)),
            const SizedBox(height: 40),
            
            // Card de Progresso Principal
            _buildStatusCard(
              title: "EVOLUÇÃO",
              child: Column(
                children: [
                  _buildStatBar(
                    "XP", 
                    player.xp / player.maxXp, 
                    AppColors.neonBlue, 
                    "${player.xp} / ${player.maxXp}"
                  ),
                  const SizedBox(height: 20),
                  _buildStatBar("HP", 1.0, Colors.redAccent, "100%"),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            // Janela de Atributos
            const Text("ATRIBUTOS", style: TextStyle(fontSize: 18, letterSpacing: 3, fontWeight: FontWeight.bold)),
            const Divider(color: AppColors.neonBlue, thickness: 0.5),
            const SizedBox(height: 10),
            
            _buildAttributeRow("FORÇA", player.attributes.strength.toString(), Icons.fitness_center),
            _buildAttributeRow("INTELIGÊNCIA", player.attributes.intelligence.toString(), Icons.psychology),
            _buildAttributeRow("VITALIDADE", player.attributes.vitality.toString(), Icons.favorite),
            _buildAttributeRow("AGILIDADE", player.attributes.agility.toString(), Icons.speed),
            
            const SizedBox(height: 50),
            
            // Dica de RPG (Flavor Text)
            Center(
              child: Text(
                "\"O MEDO NÃO É UM OBSTÁCULO, É UMA FERRAMENTA.\"",
                textAlign: TextAlign.center,
                style: TextStyle(
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
        Text("PLAYER: $name | $title", // Título aparece aqui agora
            style: const TextStyle(fontSize: 12, color: AppColors.neonBlue, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "RANK: ${_calculateRank(level)}",
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
                const Text("LEVEL", style: TextStyle(fontSize: 10, color: Colors.white38)),
                Text(level.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ],
    );
  }

  String _calculateRank(int level) {
    if (level < 5) return "E";
    if (level < 10) return "D";
    if (level < 20) return "C";
    if (level < 30) return "B";
    if (level < 40) return "A";
    return "S";
  }

  Widget _buildStatusCard({required String title, required Widget child}) {
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

  Widget _buildAttributeRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
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
              fontFamily: 'Courier', // Estilo terminal/sistema
            )
          ),
        ],
      ),
    );
  }

  String _calculateCurrentTitle(Player player) {
  // Pega todas as conquistas que o player cumpre os requisitos
  final unlocked = systemAchievements.where((a) => a.requirement(player)).toList();
  
  // Retorna o último título conquistado ou o padrão
  return unlocked.isNotEmpty ? unlocked.last.title : "ASPIRANTE";
  }
}
