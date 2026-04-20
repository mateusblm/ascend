import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/domain/weekly_insights.dart';

import 'quest_model.dart';

class QuestSuggestion {
  const QuestSuggestion({
    required this.title,
    required this.rewardAttribute,
    required this.xpReward,
    required this.reason,
    required this.tag,
  });

  final String title;
  final AttributeType rewardAttribute;
  final int xpReward;
  final String reason;
  final String tag;
}

List<QuestSuggestion> buildWeeklyQuestSuggestions(
  Player player,
  WeeklyInsightsBundle insights, {
  WeeklyBossDefinition? weeklyBoss,
}) {
  final suggestions = <QuestSuggestion>[];
  final score = insights.discipline.score;

  switch (player.primaryFocus) {
    case AwakeningPath.discipline:
      suggestions.addAll([
        QuestSuggestion(
          title: score >= 55 ? 'Abrir o dia com a primeira quest em 5 minutos' : 'Arrumar a cama ao acordar',
          rewardAttribute: AttributeType.vitality,
          xpReward: 12,
          reason: 'Fortalece o gatilho inicial de consistencia diaria.',
          tag: 'BASE',
        ),
        QuestSuggestion(
          title: 'Revisar metas do dia por 2 minutos',
          rewardAttribute: AttributeType.agility,
          xpReward: 14,
          reason: 'Reduz atrito mental e melhora execucao.',
          tag: 'FOCO',
        ),
      ]);
    case AwakeningPath.study:
      suggestions.addAll([
        QuestSuggestion(
          title: score >= 55 ? 'Bloco de estudo profundo de 45 minutos' : 'Estudar por 20 minutos sem interrupcao',
          rewardAttribute: AttributeType.intelligence,
          xpReward: score >= 55 ? 15 : 13,
          reason: 'Mantem o foco do build em progresso intelectual visivel.',
          tag: 'ESTUDO',
        ),
        QuestSuggestion(
          title: 'Fechar o estudo com 1 resumo curto',
          rewardAttribute: AttributeType.intelligence,
          xpReward: 14,
          reason: 'Transforma absorcao em saida e consolida aprendizado.',
          tag: 'REVISAO',
        ),
      ]);
    case AwakeningPath.training:
      suggestions.addAll([
        QuestSuggestion(
          title: score >= 55 ? 'Treino objetivo de 25 minutos' : 'Mobilidade ou caminhada de 15 minutos',
          rewardAttribute: AttributeType.strength,
          xpReward: score >= 55 ? 15 : 13,
          reason: 'Mantem o corpo em movimento sem quebrar consistencia.',
          tag: 'TREINO',
        ),
        QuestSuggestion(
          title: 'Encerrar o dia com alongamento rapido',
          rewardAttribute: AttributeType.vitality,
          xpReward: 12,
          reason: 'Ajuda recuperacao e reduz chance de abandonar a semana.',
          tag: 'RECUP',
        ),
      ]);
    case AwakeningPath.health:
      suggestions.addAll([
        QuestSuggestion(
          title: 'Bater a meta de agua do dia',
          rewardAttribute: AttributeType.vitality,
          xpReward: 12,
          reason: 'Cria uma ancora de saude simples e repetivel.',
          tag: 'SAUDE',
        ),
        QuestSuggestion(
          title: 'Dormir dentro da janela planejada',
          rewardAttribute: AttributeType.vitality,
          xpReward: 15,
          reason: 'Sono consistente melhora todo o resto do sistema.',
          tag: 'SONO',
        ),
      ]);
    case AwakeningPath.productivity:
      suggestions.addAll([
        QuestSuggestion(
          title: 'Concluir a tarefa critica antes do meio do dia',
          rewardAttribute: AttributeType.agility,
          xpReward: 15,
          reason: 'Evita dispersao e reforca execucao deliberada.',
          tag: 'PRIOR',
        ),
        QuestSuggestion(
          title: 'Executar 2 blocos de foco sem notificacoes',
          rewardAttribute: AttributeType.intelligence,
          xpReward: 14,
          reason: 'Protege profundidade de trabalho e reduz troca de contexto.',
          tag: 'DEEP',
        ),
      ]);
  }

  if (weeklyBoss != null) {
    suggestions.add(
      QuestSuggestion(
        title: 'Garantir mais um dia ativo para ${weeklyBoss.title}',
        rewardAttribute: AttributeType.agility,
        xpReward: weeklyBoss.rewardXp > 180 ? 15 : 14,
        reason: 'Empurra progresso direto no boss semanal sem depender do ultimo dia.',
        tag: 'BOSS',
      ),
    );
  }

  final seenTitles = <String>{};
  return suggestions.where((suggestion) => seenTitles.add(suggestion.title)).take(4).toList();
}
