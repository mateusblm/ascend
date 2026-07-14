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
  final bool isCompleted;

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
    this.isCompleted = false,
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

  Quest copyWith({
    String? ownerUid,
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
  }) {
    return Quest(
      isarId: isarId,
      ownerUid: ownerUid ?? this.ownerUid,
      id: id,
      title: title,
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
      isCompleted: isCompleted ?? this.isCompleted,
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
