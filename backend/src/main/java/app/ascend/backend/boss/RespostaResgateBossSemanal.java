package app.ascend.backend.boss;

import java.util.Map;

public record RespostaResgateBossSemanal(
    String status,
    Map<String, Object> profile
) {
}
