package app.ascend.backend.quests;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.quiz.AvaliadorQuizLeitura;
import app.ascend.backend.quiz.PerguntaQuizLeitura;
import app.ascend.backend.quiz.RepositorioQuizLeitura;
import app.ascend.backend.quiz.TentativaQuizLeitura;
import com.google.cloud.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.junit.jupiter.api.Test;

class MutacaoQuestCompetitivaServiceTest {

  @Test
  void verificaEvidenciaValidaEGravaGrantAuditoriaPerfilEQuest() {
    RepositorioInventarioQuestEmMemoria repositorio = repositorioComSessaoAtiva();
    repositorio.perfil = perfilBase();
    repositorio.sessaoExiste = true;
    repositorio.sessao = Map.of("startedAt", timestamp("2026-06-06T10:00:00Z"));

    RespostaVerificacaoQuestCompetitiva resposta = service(repositorio)
        .verificarConclusao("user-1", "Mateus", requisicaoComEvidencia(
            evidencia("2026-06-06T10:00:00Z", "2026-06-06T10:30:00Z", 30, null)
        ));

    assertThat(resposta.status()).isEqualTo("verified");
    assertThat(resposta.verificationDecision().status()).isEqualTo("accepted");
    assertThat(repositorio.concessaoSalva)
        .containsEntry("questId", "focus-20-1")
        .containsEntry("confidenceScore", 75)
        .containsEntry("evidenceProvider", "mockEvidence");
    assertThat(repositorio.auditoriaEvidenciaSalva)
        .containsEntry("status", "accepted")
        .containsEntry("syncSource", "backend");
    assertThat(repositorio.conclusaoSalva)
        .containsEntry("countsTowardCompetitive", true)
        .containsEntry("xpReward", 25);
    assertThat(repositorio.questSalva)
        .containsEntry("isCompleted", true)
        .containsEntry("verificationStatus", "verified");
    assertThat(repositorio.perfilSalvo)
        .containsEntry("authoritativeQuestXp", 25);
  }

  @Test
  void rejeitaSourceActivityIdDuplicadoSemGravarRecompensa() {
    RepositorioInventarioQuestEmMemoria repositorio = repositorioComSessaoAtiva();
    repositorio.perfil = perfilBase();
    repositorio.sessaoExiste = true;
    repositorio.sessao = Map.of("startedAt", timestamp("2026-06-06T10:00:00Z"));
    repositorio.sourceActivityIdJaUsado = true;

    assertThatThrownBy(() -> service(repositorio)
        .verificarConclusao("user-1", "Mateus", requisicaoComEvidencia(
            evidencia("2026-06-06T10:00:00Z", "2026-06-06T10:30:00Z", 30, "source-1")
        )))
        .isInstanceOfSatisfying(ExcecaoApi.class, error -> {
          assertThat(error.codigo()).isEqualTo("duplicate_source_activity_id");
          assertThat(error.getMessage()).contains("duplicateSourceActivityId");
        });

    assertThat(repositorio.concessaoSalva).isNull();
    assertThat(repositorio.perfilSalvo).isNull();
  }

  @Test
  void rejeitaRitmoImpossivel() {
    RepositorioInventarioQuestEmMemoria repositorio = repositorioComSessaoAtiva();
    repositorio.perfil = perfilBase();
    repositorio.sessaoExiste = true;
    repositorio.sessao = Map.of("startedAt", timestamp("2026-06-06T10:00:00Z"));

    assertThatThrownBy(() -> service(repositorio)
        .verificarConclusao("user-1", "Mateus", new RequisicaoQuestCompetitiva(
            "device-1",
            "Notebook",
            "run-2k-1",
            questCompetitiva("run-2k-1", "Corrida controlada de 2 km", "runningSession", "timer", 10, 35, "agility"),
            new EvidenciaQuestCompetitiva(
                "run-2k-1",
                "mockEvidence",
                "runningDistance",
                "2026-06-06T10:00:00Z",
                "2026-06-06T10:05:00Z",
                5,
                5000,
                "run-source-1",
                null,
                null,
                null,
                null
            ),
            null
        )))
        .isInstanceOfSatisfying(ExcecaoApi.class, error -> {
          assertThat(error.codigo()).isEqualTo("competitive_evidence_insufficient");
          assertThat(error.getMessage()).contains("impossiblePace");
        });

    assertThat(repositorio.concessaoSalva).isNull();
    assertThat(repositorio.auditoriaEvidenciaSalva).isNull();
  }

  @Test
  void avaliaQuizDeLeituraAntesDeConcederRecompensaCompetitiva() {
    RepositorioInventarioQuestEmMemoria repositorio = repositorioComSessaoAtiva();
    RepositorioQuizLeituraEmMemoria repositorioQuiz = new RepositorioQuizLeituraEmMemoria();
    repositorio.perfil = perfilBase();
    repositorio.sessaoExiste = true;
    repositorio.sessao = Map.of("startedAt", timestamp("2026-06-06T10:00:00Z"));
    repositorioQuiz.tentativa = tentativaQuiz("quiz-1", "reading-20-1", "2099-06-06T12:00:00Z");

    RespostaVerificacaoQuestCompetitiva resposta = service(repositorio, repositorioQuiz)
        .verificarConclusao("user-1", "Mateus", requisicaoLeitura(
            List.of("A ideia principal apareceu no texto", "Vou fazer uma acao pratica hoje")
        ));

    assertThat(resposta.status()).isEqualTo("verified");
    assertThat(resposta.verificationDecision().status()).isEqualTo("accepted");
    assertThat(repositorio.auditoriaEvidenciaSalva)
        .containsEntry("quizId", "quiz-1")
        .containsEntry("quizScore", 100)
        .containsEntry("quizRiskFlags", List.of());
  }

  @Test
  void rejeitaQuizDeLeituraComScoreBaixoSemGravarRecompensa() {
    RepositorioInventarioQuestEmMemoria repositorio = repositorioComSessaoAtiva();
    RepositorioQuizLeituraEmMemoria repositorioQuiz = new RepositorioQuizLeituraEmMemoria();
    repositorio.perfil = perfilBase();
    repositorio.sessaoExiste = true;
    repositorio.sessao = Map.of("startedAt", timestamp("2026-06-06T10:00:00Z"));
    repositorioQuiz.tentativa = tentativaQuiz("quiz-1", "reading-20-1", "2099-06-06T12:00:00Z");

    assertThatThrownBy(() -> service(repositorio, repositorioQuiz)
        .verificarConclusao("user-1", "Mateus", requisicaoLeitura(List.of("resposta vaga"))))
        .isInstanceOfSatisfying(ExcecaoApi.class, error -> {
          assertThat(error.codigo()).isEqualTo("competitive_evidence_insufficient");
          assertThat(error.getMessage()).contains("lowQuizScore");
        });

    assertThat(repositorio.concessaoSalva).isNull();
    assertThat(repositorio.perfilSalvo).isNull();
  }

  private RepositorioInventarioQuestEmMemoria repositorioComSessaoAtiva() {
    RepositorioInventarioQuestEmMemoria repositorio = new RepositorioInventarioQuestEmMemoria();
    repositorio.activeSession = new RegistroSessaoAtiva(
        "device-1",
        timestamp("2099-01-01T00:00:00Z")
    );
    return repositorio;
  }

  private MutacaoQuestCompetitivaService service(RepositorioInventarioQuestEmMemoria repositorio) {
    return service(repositorio, new RepositorioQuizLeituraEmMemoria());
  }

  private MutacaoQuestCompetitivaService service(
      RepositorioInventarioQuestEmMemoria repositorio,
      RepositorioQuizLeitura repositorioQuizLeitura
  ) {
    CatalogoQuestCompetitiva catalogo = new CatalogoQuestCompetitiva();
    return new MutacaoQuestCompetitivaService(
        new GuardaSessaoAtiva(repositorio),
        new ValidadorRequisicaoInventarioQuest(catalogo),
        catalogo,
        repositorio,
        repositorioQuizLeitura,
        new AvaliadorQuizLeitura()
    );
  }

  private RequisicaoQuestCompetitiva requisicaoComEvidencia(EvidenciaQuestCompetitiva evidencia) {
    return new RequisicaoQuestCompetitiva(
        "device-1",
        "Notebook",
        "focus-20-1",
        questCompetitiva("focus-20-1", "Sessao de foco de 20 minutos", "focusSession", "timer", 20, 25, "vitality"),
        evidencia,
        null
    );
  }

  private QuestFonteInventario questCompetitiva(
      String id,
      String title,
      String templateType,
      String verificationMode,
      int targetDurationMinutes,
      int xpReward,
      String rewardAttribute
  ) {
    return new QuestFonteInventario(
        id,
        title,
        rewardAttribute,
        xpReward,
        "competitive",
        templateType,
        verificationMode,
        "inProgress",
        targetDurationMinutes,
        null,
        null,
        "2026-06-06T10:00:00Z",
        null,
        null,
        false,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null
    );
  }

  private EvidenciaQuestCompetitiva evidencia(
      String startedAt,
      String completedAt,
      int durationMinutes,
      String sourceActivityId
  ) {
    return new EvidenciaQuestCompetitiva(
        "focus-20-1",
        "mockEvidence",
        "timedFocus",
        startedAt,
        completedAt,
        durationMinutes,
        null,
        sourceActivityId,
        null,
        null,
        null,
        null
    );
  }

  private RequisicaoQuestCompetitiva requisicaoLeitura(List<String> respostas) {
    return new RequisicaoQuestCompetitiva(
        "device-1",
        "Notebook",
        "reading-20-1",
        questCompetitiva(
            "reading-20-1",
            "Leitura de 20 minutos",
            "readingSession",
            "timerWithReflection",
            20,
            30,
            "intelligence"
        ),
        new EvidenciaQuestCompetitiva(
            "reading-20-1",
            "mockEvidence",
            "readingComprehension",
            "2026-06-06T10:00:00Z",
            "2026-06-06T10:25:00Z",
            25,
            null,
            null,
            null,
            "quiz-1",
            respostas,
            null
        ),
        "Resumo curto da leitura."
    );
  }

  private TentativaQuizLeitura tentativaQuiz(String quizId, String questId, String expiresAt) {
    return new TentativaQuizLeitura(
        quizId,
        questId,
        "Leitura",
        70,
        "deterministic_contract_v1",
        List.of(
            new PerguntaQuizLeitura("main-idea", "Qual foi a ideia principal?", "ideia principal"),
            new PerguntaQuizLeitura("practical-action", "Qual acao pratica?", "acao pratica")
        ),
        Instant.parse("2026-06-06T10:05:00Z"),
        Instant.parse(expiresAt)
    );
  }

  private Map<String, Object> perfilBase() {
    return Map.ofEntries(
        Map.entry("name", "Mateus"),
        Map.entry("level", 1),
        Map.entry("xp", 10),
        Map.entry("maxXp", 100),
        Map.entry("statPoints", 0),
        Map.entry("attributes", Map.of(
            "strength", 10,
            "intelligence", 10,
            "vitality", 10,
            "agility", 10
        )),
        Map.entry("lastResetDate", timestamp("2026-06-01T00:00:00Z")),
        Map.entry("primaryFocus", "discipline"),
        Map.entry("hasCompletedOnboarding", true)
    );
  }

  private Timestamp timestamp(String value) {
    Instant instant = Instant.parse(value);
    return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
  }

  private static class RepositorioQuizLeituraEmMemoria implements RepositorioQuizLeitura {

    private TentativaQuizLeitura tentativa;

    @Override
    public void gravarTentativa(
        String uid,
        TentativaQuizLeitura tentativa,
        String idSessaoDispositivo,
        String rotuloDispositivo
    ) {
      this.tentativa = tentativa;
    }

    @Override
    public Optional<TentativaQuizLeitura> buscarTentativa(String uid, String quizId) {
      return Optional.ofNullable(tentativa)
          .filter(valor -> valor.quizId().equals(quizId));
    }
  }
}
