package app.ascend.backend.perfil;

import com.google.cloud.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

record PerfilUsuario(
    String name,
    int level,
    int xp,
    int maxXp,
    int statPoints,
    AtributosPerfil attributes,
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
    int authoritativeAllocatedStatPoints
) {

  static PerfilUsuario deDocumento(Map<String, Object> data, String fallbackName) {
    Map<?, ?> attributes = data.get("attributes") instanceof Map<?, ?> raw ? raw : Map.of();
    int maxXp = Math.max(1, inteiro(data.get("maxXp"), 100));
    int xp = Math.max(0, Math.min(maxXp, inteiro(data.get("xp"), 0)));
    int currentStreak = Math.max(0, inteiro(data.get("currentStreak"), 0));
    int bestStreak = Math.max(currentStreak, inteiro(data.get("bestStreak"), currentStreak));
    return new PerfilUsuario(
        nomeSeguro(data.get("name"), fallbackName),
        Math.max(1, inteiro(data.get("level"), 1)),
        xp,
        maxXp,
        Math.max(0, inteiro(data.get("statPoints"), 0)),
        new AtributosPerfil(
            Math.max(10, inteiro(attributes.get("strength"), 10)),
            Math.max(10, inteiro(attributes.get("intelligence"), 10)),
            Math.max(10, inteiro(attributes.get("vitality"), 10)),
            Math.max(10, inteiro(attributes.get("agility"), 10))
        ),
        timestamp(data.get("lastResetDate")),
        currentStreak,
        bestStreak,
        timestamp(data.get("lastQuestCompletionDate")),
        timestamps(data.get("activityHistory")),
        timestamp(data.get("lastCompetitiveQuestCompletionDate")),
        timestamps(data.get("competitiveActivityHistory")),
        focoSeguro(data.get("primaryFocus")),
        data.get("hasCompletedOnboarding") instanceof Boolean completed && completed,
        timestamp(data.get("weeklyBossLastClaimedAt")),
        Math.max(0, inteiro(data.get("authoritativeQuestXp"), 0)),
        Math.max(0, inteiro(data.get("authoritativeWeeklyBossXp"), 0)),
        Math.max(0, inteiro(data.get("authoritativeWeeklyBossStatPoints"), 0)),
        Math.max(0, inteiro(data.get("authoritativeAllocatedStatPoints"), 0))
    );
  }

  Map<String, Object> paraDocumento(
      String idSessaoDispositivo,
      String rotuloDispositivo,
      Timestamp updatedAt
  ) {
    Map<String, Object> data = new HashMap<>();
    data.put("name", name);
    data.put("level", level);
    data.put("xp", xp);
    data.put("maxXp", maxXp);
    data.put("statPoints", statPoints);
    data.put("attributes", attributes.paraDocumento());
    data.put("lastResetDate", lastResetDate);
    data.put("currentStreak", currentStreak);
    data.put("bestStreak", bestStreak);
    data.put("lastQuestCompletionDate", lastQuestCompletionDate);
    data.put("activityHistory", activityHistory);
    data.put("lastCompetitiveQuestCompletionDate", lastCompetitiveQuestCompletionDate);
    data.put("competitiveActivityHistory", competitiveActivityHistory);
    data.put("primaryFocus", primaryFocus);
    data.put("hasCompletedOnboarding", hasCompletedOnboarding);
    data.put("weeklyBossLastClaimedAt", weeklyBossLastClaimedAt);
    data.put("authoritativeQuestXp", authoritativeQuestXp);
    data.put("authoritativeWeeklyBossXp", authoritativeWeeklyBossXp);
    data.put("authoritativeWeeklyBossStatPoints", authoritativeWeeklyBossStatPoints);
    data.put("authoritativeAllocatedStatPoints", authoritativeAllocatedStatPoints);
    data.put("syncSchemaVersion", 1);
    data.put("syncSource", "callable_server_authoritative");
    data.put("activeDeviceSessionId", idSessaoDispositivo);
    data.put("activeDeviceLabel", rotuloDispositivo);
    data.put("updatedAt", updatedAt);
    return data;
  }

  private static int inteiro(Object value, int fallback) {
    return value instanceof Number number ? number.intValue() : fallback;
  }

  private static Timestamp timestamp(Object value) {
    return value instanceof Timestamp timestamp ? timestamp : null;
  }

  private static List<Timestamp> timestamps(Object value) {
    if (!(value instanceof List<?> raw)) {
      return List.of();
    }
    List<Timestamp> result = new ArrayList<>();
    for (Object entry : raw) {
      if (entry instanceof Timestamp timestamp) {
        result.add(timestamp);
      }
    }
    return result;
  }

  private static String nomeSeguro(Object value, String fallbackName) {
    String fallback = fallbackName == null || fallbackName.isBlank() ? "Jogador" : fallbackName.trim();
    if (!(value instanceof String text) || text.isBlank()) {
      return fallback.length() > 40 ? fallback.substring(0, 40) : fallback;
    }
    String normalized = text.trim();
    return normalized.length() > 40 ? normalized.substring(0, 40) : normalized;
  }

  private static String focoSeguro(Object value) {
    if (!(value instanceof String focus)) {
      return "discipline";
    }
    return switch (focus) {
      case "discipline", "study", "training", "health", "productivity" -> focus;
      default -> "discipline";
    };
  }
}
