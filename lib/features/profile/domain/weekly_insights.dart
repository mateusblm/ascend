import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:flutter/material.dart';

class WeeklyDisciplineReport {
  const WeeklyDisciplineReport({
    required this.score,
    required this.grade,
    required this.currentWeekActiveDays,
    required this.previousWeekActiveDays,
    required this.deltaFromPreviousWeek,
  });

  final int score;
  final String grade;
  final int currentWeekActiveDays;
  final int previousWeekActiveDays;
  final int deltaFromPreviousWeek;
}

enum WeeklyReviewStatus {
  rising,
  stable,
  risk,
  critical,
}

class WeeklyReviewReport {
  const WeeklyReviewReport({
    required this.status,
    required this.badge,
    required this.icon,
    required this.summary,
    required this.detail,
    required this.recommendation,
  });

  final WeeklyReviewStatus status;
  final String badge;
  final IconData icon;
  final String summary;
  final String detail;
  final String recommendation;
}

class NextWeekPlan {
  const NextWeekPlan({
    required this.difficultyLabel,
    required this.headline,
    required this.summary,
    required this.priorities,
    required this.rule,
  });

  final String difficultyLabel;
  final String headline;
  final String summary;
  final List<String> priorities;
  final String rule;
}

class WeeklyInsightsBundle {
  const WeeklyInsightsBundle({
    required this.discipline,
    required this.review,
    required this.nextWeekPlan,
  });

  final WeeklyDisciplineReport discipline;
  final WeeklyReviewReport review;
  final NextWeekPlan nextWeekPlan;
}

WeeklyInsightsBundle buildWeeklyInsights(
  Player player, {
  WeeklyBossDefinition? weeklyBoss,
  required int weeklyBossProgress,
  required bool weeklyBossClaimed,
}) {
  final discipline = _weeklyDisciplineReport(player);
  final review = _weeklyReviewReport(
    player,
    discipline,
    weeklyBoss,
    weeklyBossProgress,
    weeklyBossClaimed,
  );
  final nextWeekPlan = _nextWeekPlan(
    player,
    discipline,
    weeklyBoss,
    weeklyBossClaimed,
  );

  return WeeklyInsightsBundle(
    discipline: discipline,
    review: review,
    nextWeekPlan: nextWeekPlan,
  );
}

WeeklyDisciplineReport _weeklyDisciplineReport(Player player) {
  final today = DateTime.now();
  final currentWeekStart = weekStartFor(today);
  final previousWeekStart = currentWeekStart.subtract(const Duration(days: 7));
  final currentWeekEnd = currentWeekStart.add(const Duration(days: 7));

  final activeDates = _activityDates(player);

  final currentWeekActiveDays = activeDates
      .where((date) => !date.isBefore(currentWeekStart) && date.isBefore(currentWeekEnd))
      .length;

  final previousWeekActiveDays = activeDates
      .where((date) => !date.isBefore(previousWeekStart) && date.isBefore(currentWeekStart))
      .length;

  final score = ((currentWeekActiveDays / 7) * 100).round();

  return WeeklyDisciplineReport(
    score: score,
    grade: _gradeForScore(score),
    currentWeekActiveDays: currentWeekActiveDays,
    previousWeekActiveDays: previousWeekActiveDays,
    deltaFromPreviousWeek: currentWeekActiveDays - previousWeekActiveDays,
  );
}

WeeklyReviewReport _weeklyReviewReport(
  Player player,
  WeeklyDisciplineReport weeklyScore,
  WeeklyBossDefinition? weeklyBoss,
  int weeklyBossProgress,
  bool weeklyBossClaimed,
) {
  final bossTarget = weeklyBoss?.targetActiveDays ?? 0;
  final bossMissingDays = weeklyBoss == null ? 0 : (bossTarget - weeklyBossProgress).clamp(0, bossTarget);
  final score = weeklyScore.score;
  final delta = weeklyScore.deltaFromPreviousWeek;

  if (weeklyBossClaimed) {
    return WeeklyReviewReport(
      status: WeeklyReviewStatus.rising,
      badge: 'CLEAR',
      icon: Icons.workspace_premium,
      summary: 'Semana dominada. O boss ja foi resgatado.',
      detail:
          'Voce fechou ${weeklyScore.currentWeekActiveDays}/7 dias ativos e consolidou seu foco em ${player.primaryFocus.label.toLowerCase()}.',
      recommendation:
          'Mantenha o ritmo e tente terminar a proxima semana sem depender da recuperacao de ultimo momento.',
    );
  }

  if (score >= 85 && delta >= 0) {
    return WeeklyReviewReport(
      status: WeeklyReviewStatus.rising,
      badge: 'SUBINDO',
      icon: Icons.trending_up,
      summary: 'Voce esta puxando a semana para cima.',
      detail: weeklyBoss == null
          ? 'Foram ${weeklyScore.currentWeekActiveDays}/7 dias ativos com melhora consistente sobre a semana passada.'
          : 'Foram ${weeklyScore.currentWeekActiveDays}/7 dias ativos e faltam $bossMissingDays dias para fechar ${weeklyBoss.title}.',
      recommendation:
          'Proteja a constancia nos proximos dias e priorize quests alinhadas ao foco ${player.primaryFocus.label.toLowerCase()}.',
    );
  }

  if (score >= 55) {
    return WeeklyReviewReport(
      status: WeeklyReviewStatus.stable,
      badge: 'ESTAVEL',
      icon: Icons.tune,
      summary: 'A base da semana esta montada, mas ainda falta pressao final.',
      detail: weeklyBoss == null
          ? 'Voce segurou ${weeklyScore.currentWeekActiveDays}/7 dias ativos e ficou ${delta >= 0 ? 'no mesmo nivel ou acima' : 'abaixo'} da semana passada.'
          : 'Voce tem ${weeklyScore.currentWeekActiveDays}/7 dias ativos e precisa de mais $bossMissingDays para concluir o boss semanal.',
      recommendation: 'Escolha uma quest inevitavel para amanha e use isso como ancora para nao perder o embalo.',
    );
  }

  if (score >= 30) {
    return WeeklyReviewReport(
      status: WeeklyReviewStatus.risk,
      badge: 'EM RISCO',
      icon: Icons.warning_amber_rounded,
      summary: 'A semana ainda pode ser salva, mas o sistema ja entrou em alerta.',
      detail: weeklyBoss == null
          ? 'So ${weeklyScore.currentWeekActiveDays}/7 dias foram ativados e houve oscilacao frente a semana passada.'
          : 'So ${weeklyScore.currentWeekActiveDays}/7 dias foram ativados e o boss ainda exige mais $bossMissingDays dias.',
      recommendation:
          'Reduza ambicao, aumente consistencia: foque em uma unica quest curta por dia ate recuperar a tracao.',
    );
  }

  return WeeklyReviewReport(
    status: WeeklyReviewStatus.critical,
    badge: 'QUEDA',
    icon: Icons.sensors_off,
    summary: 'A semana perdeu momentum e precisa de reinicio tatico.',
    detail: weeklyBoss == null
        ? 'Voce registrou apenas ${weeklyScore.currentWeekActiveDays}/7 dias ativos e o sistema detecta risco real de quebra de ciclo.'
        : 'Voce registrou apenas ${weeklyScore.currentWeekActiveDays}/7 dias ativos e ainda faltam $bossMissingDays dias para o boss.',
    recommendation:
        'Volte para o minimo viavel hoje. Nao tente compensar tudo; recupere o habito primeiro e depois suba a carga.',
  );
}

NextWeekPlan _nextWeekPlan(
  Player player,
  WeeklyDisciplineReport weeklyScore,
  WeeklyBossDefinition? weeklyBoss,
  bool weeklyBossClaimed,
) {
  final score = weeklyScore.score;
  final basePriorities = _focusPriorities(player.primaryFocus);
  final activeTarget = weeklyBoss?.targetActiveDays ?? (score >= 60 ? 5 : 4);

  if (weeklyBossClaimed || score >= 85) {
    return NextWeekPlan(
      difficultyLabel: 'PUSH',
      headline: 'Hora de transformar consistencia em dominio.',
      summary:
          'Seu foco atual e ${player.primaryFocus.label.toLowerCase()}. A meta da proxima semana e manter alto nivel sem perder controle de carga.',
      priorities: [
        'Garanta $activeTarget dias ativos com regularidade, sem depender do ultimo dia.',
        basePriorities[0],
        basePriorities[1],
      ],
      rule: 'Regra da semana: feche a primeira quest do dia antes de abrir espaco para improviso.',
    );
  }

  if (score >= 55) {
    return NextWeekPlan(
      difficultyLabel: 'BASE',
      headline: 'Consolidar a base antes de acelerar.',
      summary:
          'Voce ja tem tracao suficiente para estabilizar a semana. O foco agora e reduzir oscilacao e subir a previsibilidade.',
      priorities: [
        'Planeje $activeTarget dias ativos como meta minima nao negociavel.',
        basePriorities[0],
        'Crie uma quest ancora curta para os dias de menor energia.',
      ],
      rule: 'Regra da semana: nunca deixe dois dias seguidos passarem sem concluir ao menos uma quest.',
    );
  }

  if (score >= 30) {
    return NextWeekPlan(
      difficultyLabel: 'RECUPERAR',
      headline: 'A proxima semana precisa de simplicidade e repeticao.',
      summary:
          'Nao e hora de aumentar ambicao. Primeiro recuperamos o ciclo, depois subimos dificuldade.',
      priorities: [
        'Defina apenas 4 dias ativos como alvo minimo da semana.',
        'Escolha uma unica quest curta para repetir nos primeiros 3 dias.',
        basePriorities[0],
      ],
      rule:
          'Regra da semana: vencer pequeno todos os dias vale mais do que tentar compensar com um unico dia forte.',
    );
  }

  return NextWeekPlan(
    difficultyLabel: 'RESET',
    headline: 'Comecamos de novo com o minimo viavel.',
    summary:
        'O objetivo da proxima semana nao e performar; e reconstruir confianca no sistema com passos pequenos e inevitaveis.',
    priorities: [
      'Planeje 3 dias ativos obrigatorios logo no inicio da semana.',
      'Reduza cada quest ao menor tamanho possivel sem perder sentido.',
      basePriorities[0],
    ],
    rule:
        'Regra da semana: zero heroismo. Tudo precisa ser simples o bastante para acontecer ate em dia ruim.',
  );
}

List<String> _focusPriorities(AwakeningPath focus) {
  return switch (focus) {
    AwakeningPath.discipline => const [
        'Comece o dia com uma quest de abertura para sinalizar controle do sistema.',
        'Feche a noite revisando se o dia seguinte ja tem uma primeira acao clara.',
      ],
    AwakeningPath.study => const [
        'Proteja um bloco fixo de estudo profundo em pelo menos 3 dias da semana.',
        'Transforme aprendizado em saida: resumo, exercicio ou revisao ativa.',
      ],
    AwakeningPath.training => const [
        'Distribua esforco fisico em blocos sustentaveis para evitar quebra apos um dia forte.',
        'Use mobilidade ou caminhada como fallback nos dias em que o treino completo nao entrar.',
      ],
    AwakeningPath.health => const [
        'Priorize uma ancora de recuperacao diaria, como sono, agua ou refeicao limpa.',
        'Evite metas agressivas; foque em repeticao e previsibilidade do corpo.',
      ],
    AwakeningPath.productivity => const [
        'Defina a tarefa critica do dia antes de abrir outras frentes.',
        'Agrupe execucao em blocos de foco para reduzir dispersao e troca de contexto.',
      ],
  };
}

String _gradeForScore(int score) {
  if (score >= 90) return 'S';
  if (score >= 75) return 'A';
  if (score >= 60) return 'B';
  if (score >= 45) return 'C';
  if (score >= 30) return 'D';
  return 'E';
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
