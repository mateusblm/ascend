package app.ascend.backend.temporada;

import java.time.Instant;

public record RecompensaLegadoTemporada(
    String seasonKey,
    String seasonLabel,
    String claimedRankBracket,
    String rewardTierLabel,
    String rewardName,
    String rewardBadgeLabel,
    String rewardTitleLabel,
    String rewardBonusLabel,
    String scoreBandLabel,
    int seasonScore,
    String playerStandingLabel,
    String spotlightLabel,
    String cosmeticFrameLabel,
    String cosmeticAuraLabel,
    Instant claimedAt,
    int syncSchemaVersion,
    String syncSource,
    Instant updatedAt
) {
}
