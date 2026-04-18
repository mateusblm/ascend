import 'package:isar/isar.dart';

part 'player_model.g.dart';

enum AwakeningPath { discipline, study, training, health, productivity }

extension AwakeningPathX on AwakeningPath {
  String get label => switch (this) {
        AwakeningPath.discipline => 'DISCIPLINA',
        AwakeningPath.study => 'ESTUDO',
        AwakeningPath.training => 'TREINO',
        AwakeningPath.health => 'SAUDE',
        AwakeningPath.productivity => 'PRODUTIVIDADE',
      };

  String get description => switch (this) {
        AwakeningPath.discipline => 'Cria constancia com pequenas vitorias diarias.',
        AwakeningPath.study => 'Foca em aprendizado, leitura e progresso intelectual.',
        AwakeningPath.training => 'Fortalece corpo, energia e presenca fisica.',
        AwakeningPath.health => 'Prioriza sono, hidratacao e recuperacao.',
        AwakeningPath.productivity => 'Organiza entregas, foco e execucao do dia.',
      };
}

@embedded
class PlayerAttributes {
  int strength;
  int intelligence;
  int vitality;
  int agility;

  PlayerAttributes({
    this.strength = 10,
    this.intelligence = 10,
    this.vitality = 10,
    this.agility = 10,
  });
}

@Collection()
class Player {
  Id id = Isar.autoIncrement;

  final String name;
  final int level;
  final int xp;
  final int maxXp;
  final int statPoints;
  final PlayerAttributes attributes;
  final DateTime lastResetDate;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastQuestCompletionDate;
  final List<DateTime> activityHistory;
  @enumerated
  final AwakeningPath primaryFocus;
  final bool hasCompletedOnboarding;

  Player({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.level,
    required this.xp,
    required this.maxXp,
    this.statPoints = 0,
    required this.attributes,
    required this.lastResetDate,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastQuestCompletionDate,
    this.activityHistory = const [],
    this.primaryFocus = AwakeningPath.discipline,
    this.hasCompletedOnboarding = false,
  });

  Player copyWith({
    int? level,
    int? xp,
    int? maxXp,
    int? statPoints,
    PlayerAttributes? attributes,
    DateTime? lastResetDate,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastQuestCompletionDate,
    List<DateTime>? activityHistory,
    AwakeningPath? primaryFocus,
    bool? hasCompletedOnboarding,
    bool clearLastQuestCompletionDate = false,
  }) {
    return Player(
      id: id,
      name: name,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      maxXp: maxXp ?? this.maxXp,
      statPoints: statPoints ?? this.statPoints,
      attributes: attributes ?? this.attributes,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastQuestCompletionDate: clearLastQuestCompletionDate
          ? null
          : (lastQuestCompletionDate ?? this.lastQuestCompletionDate),
      activityHistory: activityHistory ?? this.activityHistory,
      primaryFocus: primaryFocus ?? this.primaryFocus,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}
