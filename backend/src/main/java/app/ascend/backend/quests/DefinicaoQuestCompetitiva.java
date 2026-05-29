package app.ascend.backend.quests;

public record DefinicaoQuestCompetitiva(
    String title,
    String templateType,
    String verificationMode,
    int targetDurationMinutes,
    int xpReward,
    String rewardAttribute
) {
}
