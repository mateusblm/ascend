package app.ascend.backend.boss;

import com.google.cloud.Timestamp;
import java.util.Map;

record BossSemanal(
    boolean ativo,
    Timestamp inicioEm,
    Timestamp fimEm,
    String rank,
    int recompensaXp,
    int recompensaPontosAtributo
) {

  static BossSemanal deDocumento(Map<String, Object> data) {
    return new BossSemanal(
        data.get("isActive") instanceof Boolean ativo && ativo,
        timestamp(data.get("startsAt")),
        timestamp(data.get("endsAt")),
        normalizarRank(data.get("rank")),
        Math.max(0, inteiro(data.get("rewardXp"), 0)),
        Math.max(0, inteiro(data.get("rewardStatPoints"), 0))
    );
  }

  private static Timestamp timestamp(Object value) {
    return value instanceof Timestamp timestamp ? timestamp : null;
  }

  private static int inteiro(Object value, int fallback) {
    return value instanceof Number number ? number.intValue() : fallback;
  }

  private static String normalizarRank(Object value) {
    return value instanceof String texto ? texto.trim().toUpperCase() : "";
  }
}
