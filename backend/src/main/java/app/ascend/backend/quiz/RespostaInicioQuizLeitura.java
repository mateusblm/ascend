package app.ascend.backend.quiz;

import java.time.Instant;
import java.util.List;

public record RespostaInicioQuizLeitura(
    String quizId,
    String questId,
    String topic,
    int minimumScore,
    String generator,
    Instant issuedAt,
    Instant expiresAt,
    List<PerguntaPublicaQuizLeitura> questions
) {
}
