package app.ascend.backend.atividades;

import app.ascend.backend.infraestrutura.postgres.ConversorDocumentoPostgres;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class ProgressoAtividadeService {
  private final JdbcTemplate jdbc;
  private final ConversorDocumentoPostgres json;
  public ProgressoAtividadeService(JdbcTemplate jdbc, ConversorDocumentoPostgres json) { this.jdbc = jdbc; this.json = json; }

  public RespostaProgressoAtividade consultar(String uid, String activityId) {
    List<Map<String, Object>> history = jdbc.query("""
        select id, execution_type, metricas::text, metricas_calculadas::text, observacao, registrada_em
        from execucoes_atividades where uid = ? and activity_id = ? and revogada_em is null order by registrada_em desc limit 50
        """, (rs, row) -> {
      Map<String, Object> item = new LinkedHashMap<>();
      item.put("id", rs.getString("id")); item.put("executionType", rs.getString("execution_type"));
      item.put("metrics", json.paraDocumento(rs.getString("metricas")));
      item.put("calculatedMetrics", json.paraDocumento(rs.getString("metricas_calculadas")));
      item.put("observation", rs.getString("observacao")); item.put("recordedAt", rs.getTimestamp("registrada_em").toInstant().toString());
      return item;
    }, uid, activityId);
    String type = history.isEmpty() ? "" : String.valueOf(history.getFirst().get("executionType"));
    Map<String, Object> highlights = highlights(type, history);
    return new RespostaProgressoAtividade(activityId, type, history.size(), highlights,
        recordes(type, history), tendencias(type, history), history);
  }

  @SuppressWarnings("unchecked")
  private Map<String, Object> highlights(String type, List<Map<String, Object>> history) {
    double total = 0, best = 0; String totalKey = ""; String bestKey = "";
    for (Map<String, Object> row : history) {
      Map<String, Object> input = (Map<String, Object>) row.get("metrics");
      Map<String, Object> derived = (Map<String, Object>) row.get("calculatedMetrics");
      if ("strengthSets".equals(type)) { total += number(derived.get("volumeKg")); best = Math.max(best, number(derived.get("maxLoadKg"))); totalKey = "totalVolumeKg"; bestKey = "maxLoadKg"; }
      if ("distanceDuration".equals(type)) { total += number(input.get("distanceKm")); double pace = number(derived.get("paceSecondsPerKm")); if (best == 0 || (pace > 0 && pace < best)) best = pace; totalKey = "totalDistanceKm"; bestKey = "bestPaceSecondsPerKm"; }
      if ("studySession".equals(type)) { total += number(input.get("durationMinutes")); best = Math.max(best, number(derived.get("accuracyPercent"))); totalKey = "totalMinutes"; bestKey = "bestAccuracyPercent"; }
      if ("readingProgress".equals(type)) { total += number(input.get("pagesRead")); best = Math.max(best, number(input.get("pagesRead"))); totalKey = "totalPagesRead"; bestKey = "maxPagesRead"; }
      if ("sleepTracking".equals(type)) { total += number(derived.get("durationMinutes")); best = Math.max(best, number(derived.get("durationMinutes"))); totalKey = "totalSleepMinutes"; bestKey = "longestSleepMinutes"; }
    }
    Map<String, Object> result = new LinkedHashMap<>(); result.put(totalKey.isEmpty() ? "total" : totalKey, total); if (!bestKey.isEmpty()) result.put(bestKey, best); return result;
  }
  @SuppressWarnings("unchecked")
  private Map<String, Object> recordes(String type, List<Map<String, Object>> history) {
    Map<String, Object> records = new LinkedHashMap<>();
    for (Map<String, Object> row : history) {
      Map<String, Object> input = (Map<String, Object>) row.get("metrics");
      Map<String, Object> derived = (Map<String, Object>) row.get("calculatedMetrics");
      if ("strengthSets".equals(type)) {
        maior(records, "maxLoadKg", number(derived.get("maxLoadKg")));
        maior(records, "maxVolumeKg", number(derived.get("volumeKg")));
        maior(records, "maxEstimatedOneRepMaxKg", number(derived.get("estimatedOneRepMaxKg")));
      } else if ("distanceDuration".equals(type)) {
        maior(records, "maxDistanceKm", number(input.get("distanceKm")));
        menor(records, "bestPaceSecondsPerKm", number(derived.get("paceSecondsPerKm")));
      } else if ("studySession".equals(type)) {
        maior(records, "maxStudyMinutes", number(input.get("durationMinutes")));
        maior(records, "bestAccuracyPercent", number(derived.get("accuracyPercent")));
      } else if ("readingProgress".equals(type)) {
        maior(records, "maxPagesRead", number(input.get("pagesRead")));
      } else if ("sleepTracking".equals(type)) {
        maior(records, "longestSleepMinutes", number(derived.get("durationMinutes")));
      }
    }
    return records;
  }
  @SuppressWarnings("unchecked")
  private Map<String, Object> tendencias(String type, List<Map<String, Object>> history) {
    Instant now = Instant.now(); double weekly = 0, previousWeekly = 0, monthly = 0, previousMonthly = 0;
    for (Map<String, Object> row : history) {
      Instant at = Instant.parse(String.valueOf(row.get("recordedAt")));
      Map<String, Object> input = (Map<String, Object>) row.get("metrics");
      Map<String, Object> derived = (Map<String, Object>) row.get("calculatedMetrics");
      double value = "strengthSets".equals(type) ? number(derived.get("volumeKg")) :
          "distanceDuration".equals(type) ? number(input.get("distanceKm")) :
          "readingProgress".equals(type) ? number(input.get("pagesRead")) : number(input.get("durationMinutes"));
      if ("sleepTracking".equals(type)) value = number(derived.get("durationMinutes"));
      if (!at.isBefore(now.minus(7, ChronoUnit.DAYS))) weekly += value;
      else if (!at.isBefore(now.minus(14, ChronoUnit.DAYS))) previousWeekly += value;
      if (!at.isBefore(now.minus(30, ChronoUnit.DAYS))) monthly += value;
      else if (!at.isBefore(now.minus(60, ChronoUnit.DAYS))) previousMonthly += value;
    }
    return Map.of("weekly", weekly, "previousWeekly", previousWeekly,
        "monthly", monthly, "previousMonthly", previousMonthly);
  }
  private void maior(Map<String, Object> values, String key, double value) { values.put(key, Math.max(number(values.get(key)), value)); }
  private void menor(Map<String, Object> values, String key, double value) { if (value > 0 && (number(values.get(key)) == 0 || value < number(values.get(key)))) values.put(key, value); }
  private double number(Object value) { return value instanceof Number n ? n.doubleValue() : 0; }
}
