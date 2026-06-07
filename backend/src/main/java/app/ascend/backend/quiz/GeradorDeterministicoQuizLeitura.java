package app.ascend.backend.quiz;

import java.time.Duration;
import java.util.List;

public class GeradorDeterministicoQuizLeitura implements GeradorQuizLeitura {

  static final Duration DURACAO_TENTATIVA = Duration.ofHours(2);

  @Override
  public TentativaQuizLeitura gerarTentativa(RequisicaoGeracaoQuizLeitura requisicao) {
    String topico = normalizarTopico(requisicao.topic());
    return new TentativaQuizLeitura(
        requisicao.questId() + "__" + requisicao.now().toEpochMilli(),
        requisicao.questId(),
        topico,
        requisicao.minimumScore(),
        "deterministic_contract_v1",
        List.of(
            new PerguntaQuizLeitura(
                "main-idea",
                "Qual foi a ideia principal de " + topico + "?",
                "ideia principal"
            ),
            new PerguntaQuizLeitura(
                "practical-action",
                "Qual acao pratica voce tira de " + topico + "?",
                "acao pratica"
            )
        ),
        requisicao.now(),
        requisicao.now().plus(DURACAO_TENTATIVA)
    );
  }

  private String normalizarTopico(String topico) {
    if (topico == null || topico.isBlank()) {
      return "leitura";
    }
    String limpo = topico.trim();
    return limpo.length() <= 120 ? limpo : limpo.substring(0, 120);
  }
}
