package app.ascend.backend.quests;

import java.util.List;

public record DefinicaoQuestCompetitiva(
    String id,
    String title,
    String templateType,
    String verificationMode,
    int targetDurationMinutes,
    int xpReward,
    String rewardAttribute,
    String evidenceType,
    int minimumTrustTier,
    int minimumDurationMinutes,
    int minimumDistanceMeters,
    int minimumQuizScore,
    List<String> allowedProviders
) {
}
