package app.ascend.backend.temporada;

import java.time.Instant;

public record RecompensaTemporada(
    String seasonKey,
    String seasonLabel,
    String currentRankBracket,
    String rewardTierLabel,
    String rewardStatusLabel,
    boolean rewardUnlocked,
    String rewardName,
    String rewardBadgeLabel,
    String rewardTitleLabel,
    String rewardBonusLabel,
    int recordedWeeks,
    int secureWeeks,
    int seasonScore,
    String scoreBandLabel,
    String clearRateLabel,
    String playerStandingLabel,
    String spotlightLabel,
    String resetLabel,
    String claimStatus,
    int syncSchemaVersion,
    String syncSource,
    Instant updatedAt,
    Instant claimedAt
) {
}
