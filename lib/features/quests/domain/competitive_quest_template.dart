import 'package:ascend/features/profile/domain/player_model.dart';

import 'competitive_quest_evidence.dart';
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
    required this.verificationRequirement,
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
  final CompetitiveVerificationRequirement verificationRequirement;
  final String? reflectionPrompt;

  String get verificationLabel => switch (verificationMode) {
    QuestVerificationMode.manual => _requirementLabel,
    QuestVerificationMode.timer =>
      '$targetDurationMinutes MIN + $_requirementLabel',
    QuestVerificationMode.timerWithReflection =>
      '$targetDurationMinutes MIN + RESPOSTA',
  };

  String get _requirementLabel =>
      switch (verificationRequirement.evidenceType) {
        CompetitiveEvidenceType.timedFocus => 'TIMER',
        CompetitiveEvidenceType.runningDistance =>
          '${verificationRequirement.minimumDistanceMeters ~/ 1000} KM',
        CompetitiveEvidenceType.readingComprehension => 'QUIZ',
        CompetitiveEvidenceType.workoutSession => 'TREINO',
        CompetitiveEvidenceType.studySession => 'ESTUDO',
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

const _focus25Requirement = CompetitiveVerificationRequirement(
  evidenceType: CompetitiveEvidenceType.timedFocus,
  minimumTrustTier: 2,
  minimumDurationMinutes: 25,
  allowedProviders: [
    CompetitiveEvidenceProvider.appTimer,
    CompetitiveEvidenceProvider.mockEvidence,
  ],
);

const _focus20Requirement = CompetitiveVerificationRequirement(
  evidenceType: CompetitiveEvidenceType.timedFocus,
  minimumTrustTier: 2,
  minimumDurationMinutes: 20,
  allowedProviders: [
    CompetitiveEvidenceProvider.appTimer,
    CompetitiveEvidenceProvider.mockEvidence,
  ],
);

const _focus30Requirement = CompetitiveVerificationRequirement(
  evidenceType: CompetitiveEvidenceType.timedFocus,
  minimumTrustTier: 2,
  minimumDurationMinutes: 30,
  allowedProviders: [
    CompetitiveEvidenceProvider.appTimer,
    CompetitiveEvidenceProvider.mockEvidence,
  ],
);

const _reading20Requirement = CompetitiveVerificationRequirement(
  evidenceType: CompetitiveEvidenceType.readingComprehension,
  minimumTrustTier: 2,
  minimumDurationMinutes: 20,
  minimumQuizScore: 70,
  allowedProviders: [CompetitiveEvidenceProvider.mockEvidence],
);

const _reading15Requirement = CompetitiveVerificationRequirement(
  evidenceType: CompetitiveEvidenceType.readingComprehension,
  minimumTrustTier: 2,
  minimumDurationMinutes: 15,
  minimumQuizScore: 70,
  allowedProviders: [CompetitiveEvidenceProvider.mockEvidence],
);

const _study20Requirement = CompetitiveVerificationRequirement(
  evidenceType: CompetitiveEvidenceType.studySession,
  minimumTrustTier: 2,
  minimumDurationMinutes: 20,
  minimumQuizScore: 70,
  allowedProviders: [CompetitiveEvidenceProvider.mockEvidence],
);

const _study30Requirement = CompetitiveVerificationRequirement(
  evidenceType: CompetitiveEvidenceType.studySession,
  minimumTrustTier: 2,
  minimumDurationMinutes: 30,
  allowedProviders: [
    CompetitiveEvidenceProvider.appTimer,
    CompetitiveEvidenceProvider.mockEvidence,
  ],
);

const _run2kRequirement = CompetitiveVerificationRequirement(
  evidenceType: CompetitiveEvidenceType.runningDistance,
  minimumTrustTier: 2,
  minimumDurationMinutes: 10,
  minimumDistanceMeters: 2000,
  allowedProviders: [CompetitiveEvidenceProvider.mockEvidence],
);

const _run5kRequirement = CompetitiveVerificationRequirement(
  evidenceType: CompetitiveEvidenceType.runningDistance,
  minimumTrustTier: 3,
  minimumDurationMinutes: 20,
  minimumDistanceMeters: 5000,
  allowedProviders: [CompetitiveEvidenceProvider.mockEvidence],
);

const _workout20Requirement = CompetitiveVerificationRequirement(
  evidenceType: CompetitiveEvidenceType.workoutSession,
  minimumTrustTier: 2,
  minimumDurationMinutes: 20,
  allowedProviders: [
    CompetitiveEvidenceProvider.appTimer,
    CompetitiveEvidenceProvider.mockEvidence,
  ],
);

List<CompetitiveQuestTemplate> officialCompetitiveQuestCatalog() {
  return const [
    CompetitiveQuestTemplate(
      id: 'run-2k-controlled',
      title: 'Corrida controlada de 2 km',
      description: 'Registre distancia e tempo para uma prova curta de arena.',
      rewardAttribute: AttributeType.agility,
      xpReward: 35,
      templateType: QuestTemplateType.runningSession,
      verificationMode: QuestVerificationMode.timer,
      targetDurationMinutes: 10,
      verificationRequirement: _run2kRequirement,
    ),
    CompetitiveQuestTemplate(
      id: 'focus-25',
      title: 'Sessao de foco de 25 minutos',
      description: 'Inicie no app e complete um bloco curto sem sair cedo.',
      rewardAttribute: AttributeType.agility,
      xpReward: 30,
      templateType: QuestTemplateType.focusSession,
      verificationMode: QuestVerificationMode.timer,
      targetDurationMinutes: 25,
      verificationRequirement: _focus25Requirement,
    ),
    CompetitiveQuestTemplate(
      id: 'reading-20',
      title: 'Leitura de 20 minutos',
      description: 'Feche um bloco curto de leitura e prove compreensao.',
      rewardAttribute: AttributeType.intelligence,
      xpReward: 30,
      templateType: QuestTemplateType.readingSession,
      verificationMode: QuestVerificationMode.timerWithReflection,
      targetDurationMinutes: 20,
      verificationRequirement: _reading20Requirement,
      reflectionPrompt: 'Qual foi a ideia principal da leitura?',
    ),
    CompetitiveQuestTemplate(
      id: 'bodyweight-20',
      title: 'Treino corporal de 20 minutos',
      description: 'Complete uma sessao curta com evidencia de duracao.',
      rewardAttribute: AttributeType.strength,
      xpReward: 35,
      templateType: QuestTemplateType.workoutSession,
      verificationMode: QuestVerificationMode.timer,
      targetDurationMinutes: 20,
      verificationRequirement: _workout20Requirement,
    ),
    CompetitiveQuestTemplate(
      id: 'study-30',
      title: 'Estudo profundo de 30 minutos',
      description: 'Complete uma sessao real de estudo com tempo minimo.',
      rewardAttribute: AttributeType.intelligence,
      xpReward: 35,
      templateType: QuestTemplateType.studySession,
      verificationMode: QuestVerificationMode.timer,
      targetDurationMinutes: 30,
      verificationRequirement: _study30Requirement,
    ),
    CompetitiveQuestTemplate(
      id: 'study-20-recall',
      title: 'Revisao ativa de 20 minutos',
      description: 'Feche uma revisao curta e valide lembranca objetiva.',
      rewardAttribute: AttributeType.intelligence,
      xpReward: 30,
      templateType: QuestTemplateType.studySession,
      verificationMode: QuestVerificationMode.timerWithReflection,
      targetDurationMinutes: 20,
      verificationRequirement: _study20Requirement,
      reflectionPrompt: 'O que saiu de concreto desta sessao?',
    ),
    CompetitiveQuestTemplate(
      id: 'focus-20',
      title: 'Sessao de foco de 20 minutos',
      description: 'Uma ancora curta de consistencia para proteger o ritmo.',
      rewardAttribute: AttributeType.vitality,
      xpReward: 25,
      templateType: QuestTemplateType.focusSession,
      verificationMode: QuestVerificationMode.timer,
      targetDurationMinutes: 20,
      verificationRequirement: _focus20Requirement,
    ),
    CompetitiveQuestTemplate(
      id: 'focus-30',
      title: 'Bloco de foco de 30 minutos',
      description: 'Sessao curta, objetiva e verificavel dentro do app.',
      rewardAttribute: AttributeType.agility,
      xpReward: 35,
      templateType: QuestTemplateType.focusSession,
      verificationMode: QuestVerificationMode.timer,
      targetDurationMinutes: 30,
      verificationRequirement: _focus30Requirement,
    ),
    CompetitiveQuestTemplate(
      id: 'reading-15',
      title: 'Leitura ou revisao de 15 minutos',
      description: 'Feche um bloco curto e registre a principal decisao.',
      rewardAttribute: AttributeType.intelligence,
      xpReward: 25,
      templateType: QuestTemplateType.readingSession,
      verificationMode: QuestVerificationMode.timerWithReflection,
      targetDurationMinutes: 15,
      verificationRequirement: _reading15Requirement,
      reflectionPrompt: 'Qual acao pratica voce leva dessa sessao?',
    ),
    CompetitiveQuestTemplate(
      id: 'reading-15-training',
      title: 'Revisao de treino de 15 minutos',
      description: 'Feche uma revisao curta e registre o que vai executar.',
      rewardAttribute: AttributeType.intelligence,
      xpReward: 25,
      templateType: QuestTemplateType.readingSession,
      verificationMode: QuestVerificationMode.timerWithReflection,
      targetDurationMinutes: 15,
      verificationRequirement: _reading15Requirement,
      reflectionPrompt: 'O que voce vai ajustar no proximo treino?',
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
      verificationRequirement: _study20Requirement,
      reflectionPrompt: 'O que saiu de concreto desta sessao?',
    ),
    CompetitiveQuestTemplate(
      id: 'run-5k-ranked',
      title: 'Corrida ranqueada de 5 km',
      description: 'Prova mais pesada para evolucao competitiva futura.',
      rewardAttribute: AttributeType.vitality,
      xpReward: 55,
      templateType: QuestTemplateType.runningSession,
      verificationMode: QuestVerificationMode.timer,
      targetDurationMinutes: 20,
      verificationRequirement: _run5kRequirement,
    ),
  ];
}

CompetitiveQuestTemplate? officialTemplateForQuest(Quest quest) {
  for (final template in officialCompetitiveQuestCatalog()) {
    if (quest.id.startsWith('${template.id}-') ||
        (quest.title == template.title &&
            quest.templateType == template.templateType &&
            quest.targetDurationMinutes == template.targetDurationMinutes &&
            quest.xpReward == template.xpReward)) {
      return template;
    }
  }
  return null;
}

List<CompetitiveQuestTemplate> templatesForFocus(AwakeningPath focus) {
  return switch (focus) {
    AwakeningPath.discipline =>
      officialCompetitiveQuestCatalog()
          .where(
            (template) => [
              'focus-25',
              'reading-20',
              'study-20-recall',
            ].contains(template.id),
          )
          .toList(growable: false),
    AwakeningPath.study =>
      officialCompetitiveQuestCatalog()
          .where(
            (template) => [
              'study-30',
              'reading-20',
              'study-20-recall',
            ].contains(template.id),
          )
          .toList(growable: false),
    AwakeningPath.training =>
      officialCompetitiveQuestCatalog()
          .where(
            (template) => [
              'run-2k-controlled',
              'bodyweight-20',
              'focus-25',
            ].contains(template.id),
          )
          .toList(growable: false),
    AwakeningPath.health =>
      officialCompetitiveQuestCatalog()
          .where(
            (template) => [
              'run-2k-controlled',
              'bodyweight-20',
              'reading-20',
            ].contains(template.id),
          )
          .toList(growable: false),
    AwakeningPath.productivity =>
      officialCompetitiveQuestCatalog()
          .where(
            (template) => [
              'focus-25',
              'study-20-recall',
              'reading-20',
            ].contains(template.id),
          )
          .toList(growable: false),
  };
}
