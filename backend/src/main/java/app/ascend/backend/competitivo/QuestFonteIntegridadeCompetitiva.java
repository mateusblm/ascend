package app.ascend.backend.competitivo;

import java.time.Instant;

public record QuestFonteIntegridadeCompetitiva(
    String title,
    int xpReward,
    boolean isCompetitive,
    boolean countsTowardCompetitive,
    boolean isCompleted,
    Instant completedAt
) {
}
