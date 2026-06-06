package app.ascend.backend.competitivo;

import java.time.Instant;

public record SnapshotRankCompetitivo(
    String currentRank,
    String peakRank,
    String highestEligibleRank,
    String weekKey,
    int activeDays,
    int requiredActiveDays,
    boolean requiresBossClear,
    boolean bossCompleted,
    String status,
    int demotionStrikes,
    boolean promotionReady,
    String promotionTargetRank,
    int targetRequiredLevel,
    boolean targetLevelGateMet,
    String advancementMode,
    String eventType,
    String summary,
    String detail,
    int syncSchemaVersion,
    String syncSource,
    Instant updatedAt
) {
}
