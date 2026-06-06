package app.ascend.backend.quests;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import app.ascend.backend.compartilhado.ExcecaoApi;
import com.google.cloud.Timestamp;
import java.time.Instant;
import java.util.Map;
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

  private RepositorioInventarioQuestEmMemoria repositorioComSessaoAtiva() {
    RepositorioInventarioQuestEmMemoria repositorio = new RepositorioInventarioQuestEmMemoria();
    repositorio.activeSession = new RegistroSessaoAtiva(
        "device-1",
        timestamp("2099-01-01T00:00:00Z")
    );
    return repositorio;
  }

  private MutacaoQuestCompetitivaService service(RepositorioInventarioQuestEmMemoria repositorio) {
    CatalogoQuestCompetitiva catalogo = new CatalogoQuestCompetitiva();
    return new MutacaoQuestCompetitivaService(
        new GuardaSessaoAtiva(repositorio),
        new ValidadorRequisicaoInventarioQuest(catalogo),
        catalogo,
        repositorio
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
}
