package app.ascend.backend.quiz;

import java.time.Instant;
import java.util.List;

public record TentativaQuizLeitura(
    String quizId,
    String questId,
    String topic,
    int minimumScore,
    String generator,
    List<PerguntaQuizLeitura> questions,
    Instant issuedAt,
    Instant expiresAt
) {
}
