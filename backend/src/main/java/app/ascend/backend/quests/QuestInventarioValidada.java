package app.ascend.backend.quests;

import com.google.cloud.Timestamp;

public record QuestInventarioValidada(
    String id,
    String title,
    String rewardAttribute,
    int xpReward,
    String category,
    String templateType,
    String verificationMode,
    String verificationStatus,
    int targetDurationMinutes,
    String reflectionPrompt,
    String reflectionAnswer,
    Timestamp verificationStartedAt,
    Timestamp completedAt,
    Timestamp verifiedAt,
    boolean isCompleted,
    Integer preRewardLevel,
    Integer preRewardXp,
    Integer preRewardMaxXp,
    Integer preRewardStatPoints,
    Integer preRewardStrength,
    Integer preRewardIntelligence,
    Integer preRewardVitality,
    Integer preRewardAgility,
    String journeyId
) {
}
