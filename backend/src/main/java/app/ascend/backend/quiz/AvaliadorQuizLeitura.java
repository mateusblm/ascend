package app.ascend.backend.quiz;

import java.text.Normalizer;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Pattern;
import org.springframework.stereotype.Component;

/**
 * Avalia respostas de quiz de leitura emitido pelo backend. O cliente envia
 * apenas `quizId` e respostas ordenadas; a tentativa persistida guarda as
 * respostas aceitas e o backend calcula o score antes de conceder recompensa.
 */
@Component
public class AvaliadorQuizLeitura {

  private static final Pattern MARCAS_UNICODE = Pattern.compile("\\p{M}+");
  private static final Pattern SEPARADOR_TOKEN = Pattern.compile("[^a-z0-9]+");

  /**
   * Reproduz o contrato legado de leitura: uma resposta e aceita quando contem
   * todos os tokens da resposta curta esperada para a pergunta correspondente.
   * Mismatch de quest, quiz expirado e ID divergente sao tratados como riscos
   * fortes; score baixo ou resposta ausente deixam a evidencia insuficiente.
   */
  public ResultadoAvaliacaoQuizLeitura avaliar(
      Optional<TentativaQuizLeitura> tentativa,
      String questId,
      String quizId,
      List<String> respostas,
      Instant now
  ) {
    if (tentativa.isEmpty()) {
      return new ResultadoAvaliacaoQuizLeitura(
          quizId == null ? "" : quizId,
          0,
          false,
          List.of("missingQuizAttempt")
      );
    }
    TentativaQuizLeitura tentativaEncontrada = tentativa.get();
    List<String> flags = new ArrayList<>();
    if (quizId == null || quizId.isBlank()) {
      flags.add("missingQuizSubmission");
    } else if (!tentativaEncontrada.quizId().equals(quizId)) {
      flags.add("quizIdMismatch");
    }
    if (!tentativaEncontrada.questId().equals(questId)) {
      flags.add("quizQuestMismatch");
    }
    if (tentativaEncontrada.expiresAt().isBefore(now)) {
      flags.add("staleQuiz");
    }

    int corretas = 0;
    List<String> respostasNormalizadas = respostas == null ? List.of() : respostas;
    for (int index = 0; index < tentativaEncontrada.questions().size(); index++) {
      PerguntaQuizLeitura pergunta = tentativaEncontrada.questions().get(index);
      String resposta = index < respostasNormalizadas.size() ? respostasNormalizadas.get(index) : null;
      if (resposta == null || resposta.isBlank()) {
        flags.add("missingQuizAnswer");
        continue;
      }
      if (respostaContemEsperado(resposta, pergunta.acceptedAnswer())) {
        corretas += 1;
      }
    }

    int score = Math.round((corretas * 100.0f) / tentativaEncontrada.questions().size());
    if (score < tentativaEncontrada.minimumScore()) {
      flags.add("lowQuizScore");
    }

    List<String> flagsUnicas = new ArrayList<>(new LinkedHashSet<>(flags));
    return new ResultadoAvaliacaoQuizLeitura(
        tentativaEncontrada.quizId(),
        score,
        flagsUnicas.isEmpty(),
        flagsUnicas
    );
  }

  private boolean respostaContemEsperado(String resposta, String esperado) {
    Set<String> tokensResposta = new LinkedHashSet<>(tokens(resposta));
    return tokensResposta.containsAll(tokens(esperado));
  }

  private List<String> tokens(String valor) {
    String semAcentos = MARCAS_UNICODE
        .matcher(Normalizer.normalize(valor.toLowerCase(), Normalizer.Form.NFD))
        .replaceAll("");
    return SEPARADOR_TOKEN
        .splitAsStream(semAcentos)
        .filter(token -> !token.isBlank())
        .toList();
  }
}
