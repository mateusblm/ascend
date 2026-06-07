package app.ascend.backend.quiz;

import app.ascend.backend.compartilhado.ExcecaoApi;
import java.util.List;
import org.springframework.http.HttpStatus;

public class GeradorIaQuizLeitura implements GeradorQuizLeitura {

  private final ProvedorPerguntasQuizLeitura provedor;
  private final GeradorDeterministicoQuizLeitura base = new GeradorDeterministicoQuizLeitura();

  public GeradorIaQuizLeitura(ProvedorPerguntasQuizLeitura provedor) {
    this.provedor = provedor;
  }

  @Override
  public TentativaQuizLeitura gerarTentativa(RequisicaoGeracaoQuizLeitura requisicao) {
    if (provedor == null) {
      throw new ExcecaoApi(
          HttpStatus.PRECONDITION_FAILED,
          "reading_quiz_ai_not_configured",
          "Gerador de quiz por IA nao configurado."
      );
    }

    List<PerguntaQuizLeitura> perguntas = saneadas(provedor.gerarPerguntas(requisicao));
    TentativaQuizLeitura tentativa = base.gerarTentativa(requisicao);
    return new TentativaQuizLeitura(
        tentativa.quizId(),
        tentativa.questId(),
        tentativa.topic(),
        tentativa.minimumScore(),
        "ai_adapter_v1",
        perguntas,
        tentativa.issuedAt(),
        tentativa.expiresAt()
    );
  }

  private List<PerguntaQuizLeitura> saneadas(List<PerguntaQuizLeitura> perguntas) {
    if (perguntas == null || perguntas.size() < 2) {
      throw new ExcecaoApi(
          HttpStatus.PRECONDITION_FAILED,
          "reading_quiz_ai_incomplete",
          "IA retornou quiz de leitura incompleto."
      );
    }
    return perguntas
        .stream()
        .limit(4)
        .map(pergunta -> new PerguntaQuizLeitura(
            textoObrigatorio(pergunta.id(), "ai-question"),
            textoObrigatorio(pergunta.prompt(), "Pergunta de compreensao."),
            textoObrigatorio(pergunta.acceptedAnswer(), "resposta esperada")
        ))
        .toList();
  }

  private String textoObrigatorio(String valor, String padrao) {
    return valor == null || valor.isBlank() ? padrao : valor.trim();
  }
}
