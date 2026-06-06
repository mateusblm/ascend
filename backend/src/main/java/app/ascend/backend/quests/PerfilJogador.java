package app.ascend.backend.quests;

import com.google.cloud.Timestamp;
import java.util.List;
import java.util.Map;

record PerfilJogador(
    String name,
    int level,
    int xp,
    int maxXp,
    int statPoints,
    AtributosJogador attributes,
    Timestamp lastResetDate,
    int currentStreak,
    int bestStreak,
    Timestamp lastQuestCompletionDate,
    List<Timestamp> activityHistory,
    Timestamp lastCompetitiveQuestCompletionDate,
    List<Timestamp> competitiveActivityHistory,
    String primaryFocus,
    boolean hasCompletedOnboarding,
    Timestamp weeklyBossLastClaimedAt,
    int authoritativeQuestXp,
    int authoritativeWeeklyBossXp,
    int authoritativeWeeklyBossStatPoints,
    int authoritativeAllocatedStatPoints,
    int syncSchemaVersion,
    String syncSource,
    String activeDeviceSessionId,
    String activeDeviceLabel,
    Timestamp updatedAt
) {

  Map<String, Object> paraDocumento(
      String idSessaoDispositivo,
      String rotuloDispositivo,
      Timestamp now,
      String fonteSincronizacao
  ) {
    return new MapBuilder()
        .put("name", name)
        .put("level", level)
        .put("xp", xp)
        .put("maxXp", maxXp)
        .put("statPoints", statPoints)
        .put("attributes", attributes.paraMap().build())
        .put("lastResetDate", lastResetDate)
        .put("currentStreak", currentStreak)
        .put("bestStreak", bestStreak)
        .put("lastQuestCompletionDate", lastQuestCompletionDate)
        .put("activityHistory", activityHistory)
        .put("lastCompetitiveQuestCompletionDate", lastCompetitiveQuestCompletionDate)
        .put("competitiveActivityHistory", competitiveActivityHistory)
        .put("primaryFocus", primaryFocus)
        .put("hasCompletedOnboarding", hasCompletedOnboarding)
        .put("weeklyBossLastClaimedAt", weeklyBossLastClaimedAt)
        .put("authoritativeQuestXp", authoritativeQuestXp)
        .put("authoritativeWeeklyBossXp", authoritativeWeeklyBossXp)
        .put("authoritativeWeeklyBossStatPoints", authoritativeWeeklyBossStatPoints)
        .put("authoritativeAllocatedStatPoints", authoritativeAllocatedStatPoints)
        .put("syncSchemaVersion", 1)
        .put("syncSource", fonteSincronizacao)
        .put("activeDeviceSessionId", idSessaoDispositivo)
        .put("activeDeviceLabel", rotuloDispositivo)
        .put("updatedAt", now)
        .build();
  }
}
