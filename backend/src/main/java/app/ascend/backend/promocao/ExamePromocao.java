package app.ascend.backend.promocao;

import java.time.Instant;

public record ExamePromocao(
    String sourceRank,
    String targetRank,
    String sourceWeekKey,
    String status,
    String mode,
    int baselineActiveDays,
    int requiredExtraActiveDays,
    boolean bossRequired,
    int requiredLevel,
    Instant startedAt,
    Instant expiresAt,
    int syncSchemaVersion,
    String syncSource,
    Instant resolvedAt
) {
}
