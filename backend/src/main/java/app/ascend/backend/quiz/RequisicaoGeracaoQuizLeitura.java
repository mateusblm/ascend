package app.ascend.backend.quiz;

import java.time.Instant;

public record RequisicaoGeracaoQuizLeitura(
    String questId,
    String topic,
    int minimumScore,
    Instant now
) {
}
