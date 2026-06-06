package app.ascend.backend.competitivo;

import java.time.Instant;

public record SnapshotIntegridadeCompetitiva(
    String weekKey,
    int trustScore,
    String trustBand,
    int weeklyActiveDays,
    int weeklyCompetitiveDays,
    int personalQuestCompletionsToday,
    int competitiveQuestCompletionsToday,
    int personalXpToday,
    int competitiveXpToday,
    int suspiciousPatternCount,
    String summary,
    String detail,
    int syncSchemaVersion,
    String syncSource,
    Instant updatedAt
) {
}
