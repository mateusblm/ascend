import 'package:ascend/features/profile/domain/player_model.dart';

import 'quest_model.dart';

class CompetitiveQuestTemplate {
  const CompetitiveQuestTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardAttribute,
    required this.xpReward,
    required this.templateType,
    required this.verificationMode,
    required this.targetDurationMinutes,
    this.reflectionPrompt,
  });

  final String id;
  final String title;
  final String description;
  final AttributeType rewardAttribute;
  final int xpReward;
  final QuestTemplateType templateType;
  final QuestVerificationMode verificationMode;
  final int targetDurationMinutes;
  final String? reflectionPrompt;

  String get verificationLabel => switch (verificationMode) {
    QuestVerificationMode.manual => 'CHECK SIMPLES',
    QuestVerificationMode.timer => '$targetDurationMinutes MIN NO APP',
    QuestVerificationMode.timerWithReflection =>
      '$targetDurationMinutes MIN + REFLEXAO',
  };

  Quest toQuest() {
    return Quest(
      id: '$id-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      rewardAttribute: rewardAttribute,
      xpReward: xpReward,
      category: QuestCategory.competitive,
      templateType: templateType,
      verificationMode: verificationMode,
      verificationStatus: verificationMode == QuestVerificationMode.manual
          ? QuestVerificationStatus.ready
          : QuestVerificationStatus.none,
      targetDurationMinutes: targetDurationMinutes,
      reflectionPrompt: reflectionPrompt,
    );
  }
}

List<CompetitiveQuestTemplate> templatesForFocus(AwakeningPath focus) {
  return switch (focus) {
    AwakeningPath.discipline => const [
      CompetitiveQuestTemplate(
        id: 'focus-25',
        title: 'Sessao de foco de 25 minutos',
        description: 'Inicie no app e complete um bloco curto sem sair cedo.',
        rewardAttribute: AttributeType.agility,
        xpReward: 30,
        templateType: QuestTemplateType.focusSession,
        verificationMode: QuestVerificationMode.timer,
        targetDurationMinutes: 25,
      ),
      CompetitiveQuestTemplate(
        id: 'reading-20',
        title: 'Leitura de 20 minutos',
        description: 'Feche um bloco curto de leitura e registre o que absorveu.',
        rewardAttribute: AttributeType.intelligence,
        xpReward: 30,
        templateType: QuestTemplateType.readingSession,
        verificationMode: QuestVerificationMode.timerWithReflection,
        targetDurationMinutes: 20,
        reflectionPrompt: 'O que voce tirou desta leitura?',
      ),
    ],
    AwakeningPath.study => const [
      CompetitiveQuestTemplate(
        id: 'study-30',
        title: 'Estudo profundo de 30 minutos',
        description: 'Complete uma sessao real de estudo com tempo minimo.',
        rewardAttribute: AttributeType.intelligence,
        xpReward: 35,
        templateType: QuestTemplateType.studySession,
        verificationMode: QuestVerificationMode.timer,
        targetDurationMinutes: 30,
      ),
      CompetitiveQuestTemplate(
        id: 'reading-20',
        title: 'Leitura de 20 minutos',
        description: 'Leia com foco e registre um resumo curto ao terminar.',
        rewardAttribute: AttributeType.intelligence,
        xpReward: 30,
        templateType: QuestTemplateType.readingSession,
        verificationMode: QuestVerificationMode.timerWithReflection,
        targetDurationMinutes: 20,
        reflectionPrompt: 'Qual foi a ideia principal da leitura?',
      ),
    ],
    AwakeningPath.training => const [
      CompetitiveQuestTemplate(
        id: 'focus-25',
        title: 'Sessao de foco de 25 minutos',
        description: 'Mesmo no build de treino, voce precisa proteger o foco.',
        rewardAttribute: AttributeType.agility,
        xpReward: 30,
        templateType: QuestTemplateType.focusSession,
        verificationMode: QuestVerificationMode.timer,
        targetDurationMinutes: 25,
      ),
      CompetitiveQuestTemplate(
        id: 'reading-15',
        title: 'Revisao de treino de 15 minutos',
        description: 'Feche uma revisao curta e registre o que vai executar.',
        rewardAttribute: AttributeType.intelligence,
        xpReward: 25,
        templateType: QuestTemplateType.readingSession,
        verificationMode: QuestVerificationMode.timerWithReflection,
        targetDurationMinutes: 15,
        reflectionPrompt: 'O que voce vai ajustar no proximo treino?',
      ),
    ],
    AwakeningPath.health => const [
      CompetitiveQuestTemplate(
        id: 'focus-20',
        title: 'Sessao de foco de 20 minutos',
        description: 'Uma ancora curta de consistencia para proteger o ritmo.',
        rewardAttribute: AttributeType.vitality,
        xpReward: 25,
        templateType: QuestTemplateType.focusSession,
        verificationMode: QuestVerificationMode.timer,
        targetDurationMinutes: 20,
      ),
      CompetitiveQuestTemplate(
        id: 'reading-15',
        title: 'Leitura ou revisao de 15 minutos',
        description: 'Feche um bloco curto e registre a principal decisao da sessao.',
        rewardAttribute: AttributeType.intelligence,
        xpReward: 25,
        templateType: QuestTemplateType.readingSession,
        verificationMode: QuestVerificationMode.timerWithReflection,
        targetDurationMinutes: 15,
        reflectionPrompt: 'Qual acao pratica voce leva dessa sessao?',
      ),
    ],
    AwakeningPath.productivity => const [
      CompetitiveQuestTemplate(
        id: 'focus-30',
        title: 'Bloco de foco de 30 minutos',
        description: 'Sessao curta, objetiva e verificavel dentro do app.',
        rewardAttribute: AttributeType.agility,
        xpReward: 35,
        templateType: QuestTemplateType.focusSession,
        verificationMode: QuestVerificationMode.timer,
        targetDurationMinutes: 30,
      ),
      CompetitiveQuestTemplate(
        id: 'study-20',
        title: 'Revisao de 20 minutos',
        description: 'Feche uma revisao curta e escreva uma saida objetiva.',
        rewardAttribute: AttributeType.intelligence,
        xpReward: 30,
        templateType: QuestTemplateType.studySession,
        verificationMode: QuestVerificationMode.timerWithReflection,
        targetDurationMinutes: 20,
        reflectionPrompt: 'O que saiu de concreto desta sessao?',
      ),
    ],
  };
}
