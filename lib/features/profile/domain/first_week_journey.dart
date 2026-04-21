import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';

class FirstWeekJourneyStep {
  const FirstWeekJourneyStep({
    required this.label,
    required this.isDone,
  });

  final String label;
  final bool isDone;
}

class FirstWeekJourneySummary {
  const FirstWeekJourneySummary({
    required this.isActive,
    required this.headline,
    required this.body,
    required this.nextAction,
    required this.progressLabel,
    required this.progress,
    required this.steps,
  });

  final bool isActive;
  final String headline;
  final String body;
  final String nextAction;
  final String progressLabel;
  final double progress;
  final List<FirstWeekJourneyStep> steps;
}

FirstWeekJourneySummary buildFirstWeekJourney({
  required Player player,
  List<Quest> quests = const [],
  CompetitiveRankSnapshot? snapshot,
  DateTime? now,
}) {
  final currentDate = now ?? DateTime.now();
  final personalStepDone =
      quests.any((quest) => !quest.isCompetitive && quest.isCompleted) ||
      (player.activityHistory.isNotEmpty &&
          player.competitiveActivityHistory.isEmpty);
  final competitiveStepDone =
      player.competitiveActivityHistory.isNotEmpty ||
      quests.any((quest) => quest.isCompetitive && quest.isCompleted);
  final weeklyBaseDone =
      _countWeekDays(player.activityHistory, currentDate) >= 3;
  final steps = <FirstWeekJourneyStep>[
    FirstWeekJourneyStep(
      label: 'Fechar 1 quest pessoal',
      isDone: personalStepDone,
    ),
    FirstWeekJourneyStep(
      label: 'Validar 1 quest competitiva',
      isDone: competitiveStepDone,
    ),
    FirstWeekJourneyStep(
      label: 'Chegar a 3 dias ativos na semana',
      isDone: weeklyBaseDone,
    ),
  ];
  final completedSteps = steps.where((step) => step.isDone).length;
  final isActive =
      player.hasCompletedOnboarding &&
      player.level <= 4 &&
      player.activityHistory.length < 10 &&
      (snapshot == null || snapshot.currentRank == 'E');

  final nextAction = !personalStepDone
      ? 'Feche uma quest pessoal para ganhar ritmo logo no comeco.'
      : !competitiveStepDone
      ? 'Conclua sua primeira quest de rank para comecar a abrir caminho.'
      : !weeklyBaseDone
      ? 'Chegue a 3 dias ativos nesta semana para firmar sua base.'
      : 'Sua base inicial esta pronta. Agora vale manter o ritmo e encarar o desafio da semana.';

  return FirstWeekJourneySummary(
    isActive: isActive,
    headline: completedSteps == steps.length
        ? 'Base da primeira semana pronta'
        : 'Primeira semana em andamento',
    body: completedSteps == steps.length
        ? 'Voce ja montou a base da sua primeira semana.'
        : 'Esse bloco existe para te colocar em movimento sem precisar entender tudo de uma vez.',
    nextAction: nextAction,
    progressLabel: '$completedSteps/${steps.length} passos',
    progress: steps.isEmpty ? 0 : completedSteps / steps.length,
    steps: steps,
  );
}

int _countWeekDays(List<DateTime> entries, DateTime now) {
  final weekStart = weekStartFor(now);
  final weekEnd = weekStart.add(const Duration(days: 7));
  final unique = <DateTime>{};
  for (final entry in entries) {
    final normalized = DateTime(entry.year, entry.month, entry.day);
    if (!normalized.isBefore(weekStart) && normalized.isBefore(weekEnd)) {
      unique.add(normalized);
    }
  }
  return unique.length;
}
