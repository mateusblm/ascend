import 'package:flutter/material.dart';
class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool Function(dynamic player) requirement; // Lógica para desbloqueio

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.requirement,
  });
}

// Lista Global de Conquistas do Sistema
final systemAchievements = [
  Achievement(
    title: "RECÉM DESPERTADO",
    description: "Chegue ao Nível 5",
    icon: Icons.auto_awesome,
    requirement: (player) => player.level >= 5,
  ),
  Achievement(
    title: "FORÇA BRUTA",
    description: "Atingiu 20 de Força",
    icon: Icons.fitness_center,
    requirement: (player) => player.attributes.strength >= 20,
  ),
  Achievement(
    title: "INTELECTO SUPERIOR",
    description: "Atingiu 20 de Inteligência",
    icon: Icons.psychology,
    requirement: (player) => player.attributes.intelligence >= 20,
  ),
  Achievement(
    title: "SOBREVIVENTE",
    description: "Atingiu 20 de Vitalidade",
    icon: Icons.favorite,
    requirement: (player) => player.attributes.vitality >= 20,
  ),
];