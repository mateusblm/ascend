package app.ascend.backend.atividades;

import app.ascend.backend.infraestrutura.postgres.ConversorDocumentoPostgres;
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
        from execucoes_atividades where uid = ? and activity_id = ? order by registrada_em desc limit 50
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
    return new RespostaProgressoAtividade(activityId, type, history.size(), highlights, history);
  }

  @SuppressWarnings("unchecked")
  private Map<String, Object> highlights(String type, List<Map<String, Object>> history) {
    double total = 0, best = 0; String totalKey = ""; String bestKey = "";
    for (Map<String, Object> row : history) {
      Map<String, Object> input = (Map<String, Object>) row.get("metrics");
      Map<String, Object> derived = (Map<String, Object>) row.get("calculatedMetrics");
      if ("strengthSets".equals(type)) { total += number(derived.get("volumeKg")); best = Math.max(best, number(input.get("loadKg"))); totalKey = "totalVolumeKg"; bestKey = "maxLoadKg"; }
      if ("distanceDuration".equals(type)) { total += number(input.get("distanceKm")); double pace = number(derived.get("paceSecondsPerKm")); if (best == 0 || (pace > 0 && pace < best)) best = pace; totalKey = "totalDistanceKm"; bestKey = "bestPaceSecondsPerKm"; }
      if ("studySession".equals(type)) { total += number(input.get("durationMinutes")); best = Math.max(best, number(derived.get("accuracyPercent"))); totalKey = "totalMinutes"; bestKey = "bestAccuracyPercent"; }
    }
    Map<String, Object> result = new LinkedHashMap<>(); result.put(totalKey.isEmpty() ? "total" : totalKey, total); if (!bestKey.isEmpty()) result.put(bestKey, best); return result;
  }
  private double number(Object value) { return value instanceof Number n ? n.doubleValue() : 0; }
}
