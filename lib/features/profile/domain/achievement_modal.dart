import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:flutter/material.dart';

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool Function(Player player) requirement;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.requirement,
  });
}

final systemAchievements = [
  Achievement(
    title: 'Recem Despertado',
    description: 'Chegue ao nivel 5',
    icon: Icons.auto_awesome,
    requirement: (player) => player.level >= 5,
  ),
  Achievement(
    title: 'Forca Bruta',
    description: 'Atingiu 20 de forca',
    icon: Icons.fitness_center,
    requirement: (player) => player.attributes.strength >= 20,
  ),
  Achievement(
    title: 'Intelecto Superior',
    description: 'Atingiu 20 de inteligencia',
    icon: Icons.psychology,
    requirement: (player) => player.attributes.intelligence >= 20,
  ),
  Achievement(
    title: 'Sobrevivente',
    description: 'Atingiu 20 de vitalidade',
    icon: Icons.favorite,
    requirement: (player) => player.attributes.vitality >= 20,
  ),
];
