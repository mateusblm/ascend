package app.ascend.backend.quiz;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.quests.CatalogoQuestCompetitiva;
import app.ascend.backend.quests.DefinicaoQuestCompetitiva;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import java.time.Instant;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class InicioQuizLeituraService {

  private final GuardaSessaoAtiva guardaSessaoAtiva;
  private final CatalogoQuestCompetitiva catalogo;
  private final FabricaGeradorQuizLeitura fabricaGerador;
  private final RepositorioQuizLeitura repositorio;

  public InicioQuizLeituraService(
      GuardaSessaoAtiva guardaSessaoAtiva,
      CatalogoQuestCompetitiva catalogo,
      FabricaGeradorQuizLeitura fabricaGerador,
      RepositorioQuizLeitura repositorio
  ) {
    this.guardaSessaoAtiva = guardaSessaoAtiva;
    this.catalogo = catalogo;
    this.fabricaGerador = fabricaGerador;
    this.repositorio = repositorio;
  }

  /**
   * Cria uma tentativa de quiz somente para templates oficiais de compreensao
   * de leitura. A resposta enviada ao app nunca inclui acceptedAnswer; esse
   * campo fica persistido no Firestore para avaliacao backend posterior.
   */
  public RespostaInicioQuizLeitura iniciar(String uid, RequisicaoInicioQuizLeitura requisicao) {
    RequisicaoInicioQuizLeitura request = validar(requisicao);
    guardaSessaoAtiva.exigirSessaoAtiva(uid, request.deviceSessionId());
    DefinicaoQuestCompetitiva template = catalogo
        .buscarPorIdOuQuestId(request.templateCatalogId(), request.questId())
        .orElseThrow(() -> new ExcecaoApi(
            HttpStatus.PRECONDITION_FAILED,
            "reading_quiz_unavailable",
            "Quiz de leitura indisponivel para essa quest."
        ));
    if (!"readingComprehension".equals(template.evidenceType())) {
      throw new ExcecaoApi(
          HttpStatus.PRECONDITION_FAILED,
          "reading_quiz_unavailable",
          "Quiz de leitura indisponivel para essa quest."
      );
    }

    TentativaQuizLeitura tentativa = fabricaGerador.criar().gerarTentativa(
        new RequisicaoGeracaoQuizLeitura(
            request.questId(),
            request.topic(),
            template.minimumQuizScore(),
            Instant.now()
        )
    );
    repositorio.gravarTentativa(
        uid,
        tentativa,
        request.deviceSessionId(),
        request.deviceLabel()
    );
    return respostaPublica(tentativa);
  }

  private RequisicaoInicioQuizLeitura validar(RequisicaoInicioQuizLeitura requisicao) {
    if (requisicao == null) {
      throw new ExcecaoApi(
          HttpStatus.BAD_REQUEST,
          "invalid_reading_quiz_payload",
          "Payload de quiz invalido."
      );
    }
    return new RequisicaoInicioQuizLeitura(
        textoObrigatorio(requisicao.deviceSessionId(), "deviceSessionId", 160),
        textoOpcional(requisicao.deviceLabel(), "unknown", 80),
        textoObrigatorio(requisicao.questId(), "questId", 120),
        textoOpcional(requisicao.templateCatalogId(), null, 120),
        textoOpcional(requisicao.topic(), "leitura", 120)
    );
  }

  private RespostaInicioQuizLeitura respostaPublica(TentativaQuizLeitura tentativa) {
    return new RespostaInicioQuizLeitura(
        tentativa.quizId(),
        tentativa.questId(),
        tentativa.topic(),
        tentativa.minimumScore(),
        tentativa.generator(),
        tentativa.issuedAt(),
        tentativa.expiresAt(),
        tentativa.questions()
            .stream()
            .map(question -> new PerguntaPublicaQuizLeitura(question.id(), question.prompt()))
            .toList()
    );
  }

  private String textoObrigatorio(String valor, String campo, int tamanhoMaximo) {
    if (valor == null || valor.isBlank()) {
      throw new ExcecaoApi(
          HttpStatus.BAD_REQUEST,
          "invalid_reading_quiz_payload",
          "Campo obrigatorio invalido: " + campo + "."
      );
    }
    return textoOpcional(valor, "", tamanhoMaximo);
  }

  private String textoOpcional(String valor, String padrao, int tamanhoMaximo) {
    if (valor == null || valor.isBlank()) {
      return padrao;
    }
    String limpo = valor.trim();
    return limpo.length() <= tamanhoMaximo ? limpo : limpo.substring(0, tamanhoMaximo);
  }
}
