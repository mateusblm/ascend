import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:ascend/features/quests/presentation/widgets/quest_card.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escutando os estados
    final quests = ref.watch(questProvider);
    final player = ref.watch(playerProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [AppColors.background, Colors.black],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(player.name, player.level),
              const SizedBox(height: 30),
              
              // Barra de XP dinâmica: xp atual / xp máximo
              _buildStatBar("XP", player.xp / player.maxXp, AppColors.neonBlue),
              const SizedBox(height: 10),
              _buildStatBar("HP", 1.0, Colors.redAccent),
              const SizedBox(height: 40),
              
              const Text("ATRIBUTOS", style: TextStyle(fontSize: 18, letterSpacing: 2)),
              const Divider(color: AppColors.neonBlue, thickness: 0.5),
              
              // Atributos vindo do provider
              _buildAttributeRow("FORÇA", player.attributes[AttributeType.strength].toString()),
              _buildAttributeRow("INTELIGÊNCIA", player.attributes[AttributeType.intelligence].toString()),
              _buildAttributeRow("VITALIDADE", player.attributes[AttributeType.vitality].toString()),
              _buildAttributeRow("AGILIDADE", player.attributes[AttributeType.agility].toString()),
              
              const SizedBox(height: 40),

              const Text("DAILY QUESTS", style: TextStyle(fontSize: 18, letterSpacing: 2)),
              const Divider(color: AppColors.neonBlue, thickness: 0.5),
              const SizedBox(height: 10),

              if (quests.isEmpty)
                const Text("NENHUMA MISSÃO DISPONÍVEL", style: TextStyle(color: Colors.white24))
              else
                ...quests.map((quest) => QuestCard(
                  quest: quest,
                  onToggle: () {
                    ref.read(questProvider.notifier).toggleQuest(quest.id);
                  },
                )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name, int level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("NOME: $name | LVL: $level", style: const TextStyle(fontSize: 14)),
        Text(
          "RANK: ${_calculateRank(level)}",
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: AppColors.neonBlue,
            shadows: [Shadow(color: AppColors.neonBlue.withOpacity(0.7), blurRadius: 15)],
          ),
        ),
      ],
    );
  }

  // Lógica visual simples para o Rank baseado no nível
  String _calculateRank(int level) {
    if (level < 5) return "E";
    if (level < 10) return "D";
    if (level < 20) return "C";
    if (level < 30) return "B";
    if (level < 40) return "A";
    return "S";
  }

  Widget _buildStatBar(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0), // Garante que o valor fique entre 0 e 1
          backgroundColor: Colors.white10,
          color: color,
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildAttributeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60)),
          Text(value, style: const TextStyle(color: AppColors.neonBlue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}