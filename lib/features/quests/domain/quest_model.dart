import 'package:isar/isar.dart';

part 'quest_model.g.dart';

enum AttributeType { strength, intelligence, vitality, agility }

enum QuestTemplateType {
  custom,
  focusSession,
  studySession,
  readingSession,
  runningSession,
  workoutSession,
}

enum QuestVerificationMode { manual, timer, timerWithReflection }

enum QuestVerificationStatus { none, ready, inProgress, verified }

/// Acrescentado ao fim para preservar a codificação Isar das quests existentes.
enum QuestMode { quick, guided }

const int personalQuestDefaultXp = 12;
const int personalQuestMinXp = 8;
const int personalQuestMaxXp = 15;

int normalizePersonalQuestXp(int value) {
  return value.clamp(personalQuestMinXp, personalQuestMaxXp);
}

@Collection()
class Quest {
  Id isarId = Isar.autoIncrement;

  final String? ownerUid;
  final String id;
  final String title;
  final String? journeyId;
  final String? recurrenceId;

  @enumerated
  final QuestMode mode;
  final String? activityCategoryId;
  final String? activityModalityId;
  final String? activityId;
  final String? executionType;
  final int activitySchemaVersion;
  final int targetStrengthSets;
  final int targetStrengthRepetitions;
  final double? targetStrengthLoadKg;

  @enumerated
  final AttributeType rewardAttribute;

  final int xpReward;

  @enumerated
  final QuestTemplateType templateType;

  @enumerated
  final QuestVerificationMode verificationMode;

  @enumerated
  final QuestVerificationStatus verificationStatus;

  final int targetDurationMinutes;
  final String? reflectionPrompt;
  final String? reflectionAnswer;
  final DateTime? verificationStartedAt;
  final DateTime? completedAt;
  final DateTime? verifiedAt;
  final DateTime? plannedFor;
  final DateTime? occursOn;
  final bool isCompleted;
  final bool isArchived;

  // Snapshot do estado do jogador antes da recompensa ser aplicada.
  // Usado para reverter completamente ao desfazer uma quest.
  final int? preRewardLevel;
  final int? preRewardXp;
  final int? preRewardMaxXp;
  final int? preRewardStatPoints;
  final int? preRewardStrength;
  final int? preRewardIntelligence;
  final int? preRewardVitality;
  final int? preRewardAgility;

  Quest({
    this.isarId = Isar.autoIncrement,
    this.ownerUid,
    required this.id,
    required this.title,
    this.journeyId,
    this.recurrenceId,
    this.mode = QuestMode.quick,
    this.activityCategoryId,
    this.activityModalityId,
    this.activityId,
    this.executionType,
    this.activitySchemaVersion = 0,
    this.targetStrengthSets = 0,
    this.targetStrengthRepetitions = 0,
    this.targetStrengthLoadKg,
    required this.rewardAttribute,
    required this.xpReward,
    this.templateType = QuestTemplateType.custom,
    this.verificationMode = QuestVerificationMode.manual,
    this.verificationStatus = QuestVerificationStatus.none,
    this.targetDurationMinutes = 0,
    this.reflectionPrompt,
    this.reflectionAnswer,
    this.verificationStartedAt,
    this.completedAt,
    this.verifiedAt,
    this.plannedFor,
    this.occursOn,
    this.isCompleted = false,
    this.isArchived = false,
    this.preRewardLevel,
    this.preRewardXp,
    this.preRewardMaxXp,
    this.preRewardStatPoints,
    this.preRewardStrength,
    this.preRewardIntelligence,
    this.preRewardVitality,
    this.preRewardAgility,
  });

  bool get hasPreRewardSnapshot => preRewardLevel != null;

  bool get requiresTimer =>
      verificationMode == QuestVerificationMode.timer ||
      verificationMode == QuestVerificationMode.timerWithReflection;

  bool get requiresReflection =>
      verificationMode == QuestVerificationMode.timerWithReflection;

  bool get isGuided => mode == QuestMode.guided;

  Quest copyWith({
    String? ownerUid,
    String? journeyId,
    String? recurrenceId,
    QuestMode? mode,
    String? activityCategoryId,
    String? activityModalityId,
    String? activityId,
    String? executionType,
    int? activitySchemaVersion,
    int? targetStrengthSets,
    int? targetStrengthRepetitions,
    double? targetStrengthLoadKg,
    bool clearTargetStrengthLoadKg = false,
    bool clearJourney = false,
    bool? isCompleted,
    QuestTemplateType? templateType,
    QuestVerificationMode? verificationMode,
    QuestVerificationStatus? verificationStatus,
    int? targetDurationMinutes,
    String? reflectionPrompt,
    String? reflectionAnswer,
    DateTime? verificationStartedAt,
    DateTime? completedAt,
    DateTime? verifiedAt,
    DateTime? plannedFor,
    DateTime? occursOn,
    int? preRewardLevel,
    int? preRewardXp,
    int? preRewardMaxXp,
    int? preRewardStatPoints,
    int? preRewardStrength,
    int? preRewardIntelligence,
    int? preRewardVitality,
    int? preRewardAgility,
    bool clearPreRewardSnapshot = false,
    bool clearVerificationProgress = false,
    bool? isArchived,
  }) {
    return Quest(
      isarId: isarId,
      ownerUid: ownerUid ?? this.ownerUid,
      id: id,
      title: title,
      journeyId: clearJourney ? null : (journeyId ?? this.journeyId),
      recurrenceId: recurrenceId ?? this.recurrenceId,
      mode: mode ?? this.mode,
      activityCategoryId: activityCategoryId ?? this.activityCategoryId,
      activityModalityId: activityModalityId ?? this.activityModalityId,
      activityId: activityId ?? this.activityId,
      executionType: executionType ?? this.executionType,
      activitySchemaVersion:
          activitySchemaVersion ?? this.activitySchemaVersion,
      targetStrengthSets: targetStrengthSets ?? this.targetStrengthSets,
      targetStrengthRepetitions:
          targetStrengthRepetitions ?? this.targetStrengthRepetitions,
      targetStrengthLoadKg: clearTargetStrengthLoadKg
          ? null
          : (targetStrengthLoadKg ?? this.targetStrengthLoadKg),
      rewardAttribute: rewardAttribute,
      xpReward: xpReward,
      templateType: templateType ?? this.templateType,
      verificationMode: verificationMode ?? this.verificationMode,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      targetDurationMinutes:
          targetDurationMinutes ?? this.targetDurationMinutes,
      reflectionPrompt: reflectionPrompt ?? this.reflectionPrompt,
      reflectionAnswer: clearVerificationProgress
          ? null
          : (reflectionAnswer ?? this.reflectionAnswer),
      verificationStartedAt: clearVerificationProgress
          ? null
          : (verificationStartedAt ?? this.verificationStartedAt),
      completedAt: clearVerificationProgress
          ? null
          : (completedAt ?? this.completedAt),
      verifiedAt: clearVerificationProgress
          ? null
          : (verifiedAt ?? this.verifiedAt),
      plannedFor: plannedFor ?? this.plannedFor,
      occursOn: occursOn ?? this.occursOn,
      isCompleted: isCompleted ?? this.isCompleted,
      isArchived: isArchived ?? this.isArchived,
      preRewardLevel: clearPreRewardSnapshot
          ? null
          : (preRewardLevel ?? this.preRewardLevel),
      preRewardXp: clearPreRewardSnapshot
          ? null
          : (preRewardXp ?? this.preRewardXp),
      preRewardMaxXp: clearPreRewardSnapshot
          ? null
          : (preRewardMaxXp ?? this.preRewardMaxXp),
      preRewardStatPoints: clearPreRewardSnapshot
          ? null
          : (preRewardStatPoints ?? this.preRewardStatPoints),
      preRewardStrength: clearPreRewardSnapshot
          ? null
          : (preRewardStrength ?? this.preRewardStrength),
      preRewardIntelligence: clearPreRewardSnapshot
          ? null
          : (preRewardIntelligence ?? this.preRewardIntelligence),
      preRewardVitality: clearPreRewardSnapshot
          ? null
          : (preRewardVitality ?? this.preRewardVitality),
      preRewardAgility: clearPreRewardSnapshot
          ? null
          : (preRewardAgility ?? this.preRewardAgility),
    );
  }
}
