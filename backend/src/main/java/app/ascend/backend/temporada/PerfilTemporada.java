package app.ascend.backend.temporada;

import java.time.Instant;

public record PerfilTemporada(
    String activeSeasonKey,
    String activeSeasonLabel,
    String activeRewardName,
    String activeBadgeLabel,
    String activeTitleLabel,
    String cosmeticFrameLabel,
    String cosmeticAuraLabel,
    Instant equippedAt,
    int syncSchemaVersion,
    String syncSource,
    Instant updatedAt
) {
}
