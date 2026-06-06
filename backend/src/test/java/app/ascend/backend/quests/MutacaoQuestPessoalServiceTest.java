package app.ascend.backend.quests;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import app.ascend.backend.compartilhado.ExcecaoApi;
import com.google.cloud.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;

class MutacaoQuestPessoalServiceTest {

  @Test
  void primeiraConclusaoConcedeXpAtributoESnapshotPreRecompensa() {
    RepositorioInventarioQuestEmMemoria repositorio = repositorioComSessaoAtiva();
    repositorio.perfil = perfilBase(90, 100, 1, 0);

    RespostaMutacaoQuestPessoal resposta = service(repositorio)
        .concluir("user-1", "Mateus", new RequisicaoMutacaoQuestPessoal(
            "device-1",
            "Notebook",
            "personal-1",
            questPessoal("personal-1", 15, false)
        ));

    assertThat(resposta.status()).isEqualTo("completed");
    assertThat(repositorio.perfilSalvo)
        .containsEntry("level", 2)
        .containsEntry("xp", 5)
        .containsEntry("maxXp", 120)
        .containsEntry("statPoints", 5)
        .containsEntry("authoritativeQuestXp", 15)
        .containsEntry("syncSource", "callable_server_authoritative");
    assertThat((Map<String, Object>) repositorio.perfilSalvo.get("attributes"))
        .containsEntry("strength", 11)
        .containsEntry("intelligence", 10);
    assertThat(repositorio.questSalva)
        .containsEntry("isCompleted", true)
        .containsEntry("verificationStatus", "verified")
        .containsEntry("preRewardLevel", 1)
        .containsEntry("preRewardXp", 90)
        .containsEntry("preRewardMaxXp", 100)
        .containsEntry("preRewardStatPoints", 0);
    assertThat(repositorio.conclusaoSalva)
        .containsEntry("questId", "personal-1")
        .containsEntry("xpReward", 15)
        .containsEntry("countsTowardCompetitive", false);
  }

  @Test
  void conclusaoDuplicadaNaoConcedeRecompensaNovamente() {
    RepositorioInventarioQuestEmMemoria repositorio = repositorioComSessaoAtiva();
    repositorio.perfil = perfilBase(5, 120, 2, 5);
    repositorio.questExiste = true;
    repositorio.quest = questDocumentoConcluida();
    repositorio.conclusaoExiste = true;

    RespostaMutacaoQuestPessoal resposta = service(repositorio)
        .concluir("user-1", "Mateus", new RequisicaoMutacaoQuestPessoal(
            "device-1",
            null,
            "personal-1",
            questPessoal("personal-1", 15, false)
        ));

    assertThat(resposta.status()).isEqualTo("already_completed");
    assertThat(repositorio.perfilSalvo).isNull();
    assertThat(repositorio.conclusaoSalva).isNull();
  }

  @Test
  void revogacaoRestauraSnapshotPreRecompensaERemoveConclusao() {
    RepositorioInventarioQuestEmMemoria repositorio = repositorioComSessaoAtiva();
    repositorio.perfil = perfilBase(5, 120, 2, 5);
    repositorio.questExiste = true;
    repositorio.quest = questDocumentoConcluida();
    repositorio.conclusaoExiste = true;
    repositorio.conclusoes = List.of(Map.of(
        "questId", "personal-1",
        "xpReward", 15,
        "countsTowardCompetitive", false,
        "completedAt", timestamp("2026-06-06T10:00:00Z")
    ));

    RespostaMutacaoQuestPessoal resposta = service(repositorio)
        .revogar("user-1", "Mateus", new RequisicaoMutacaoQuestPessoal(
            "device-1",
            "Notebook",
            "personal-1",
            null
        ));

    assertThat(resposta.status()).isEqualTo("revoked");
    assertThat(repositorio.perfilSalvo)
        .containsEntry("level", 1)
        .containsEntry("xp", 90)
        .containsEntry("maxXp", 100)
        .containsEntry("statPoints", 0)
        .containsEntry("authoritativeQuestXp", 0);
    assertThat((Map<String, Object>) repositorio.perfilSalvo.get("attributes"))
        .containsEntry("strength", 10);
    assertThat(repositorio.questSalva)
        .containsEntry("isCompleted", false)
        .containsEntry("verificationStatus", "none")
        .containsEntry("completedAt", null)
        .containsEntry("preRewardLevel", null);
    assertThat(repositorio.conclusaoExcluida).isTrue();
  }

  @Test
  void rejeitaSessaoDeOutroDispositivo() {
    RepositorioInventarioQuestEmMemoria repositorio = repositorioComSessaoAtiva();

    assertThatThrownBy(() -> service(repositorio)
        .concluir("user-1", "Mateus", new RequisicaoMutacaoQuestPessoal(
            "other-device",
            null,
            "personal-1",
            questPessoal("personal-1", 15, false)
        )))
        .isInstanceOfSatisfying(ExcecaoApi.class, error ->
            assertThat(error.codigo()).isEqualTo("active_session_conflict")
        );
  }

  private RepositorioInventarioQuestEmMemoria repositorioComSessaoAtiva() {
    RepositorioInventarioQuestEmMemoria repositorio = new RepositorioInventarioQuestEmMemoria();
    repositorio.activeSession = new RegistroSessaoAtiva(
        "device-1",
        timestamp("2099-01-01T00:00:00Z")
    );
    return repositorio;
  }

  private MutacaoQuestPessoalService service(RepositorioInventarioQuestEmMemoria repositorio) {
    return new MutacaoQuestPessoalService(
        new GuardaSessaoAtiva(repositorio),
        new ValidadorRequisicaoInventarioQuest(new CatalogoQuestCompetitiva()),
        repositorio
    );
  }

  private Map<String, Object> perfilBase(int xp, int maxXp, int level, int statPoints) {
    return Map.ofEntries(
        Map.entry("name", "Mateus"),
        Map.entry("level", level),
        Map.entry("xp", xp),
        Map.entry("maxXp", maxXp),
        Map.entry("statPoints", statPoints),
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

  private QuestFonteInventario questPessoal(String id, int xpReward, boolean completed) {
    return new QuestFonteInventario(
        id,
        "Treinar mobilidade",
        "strength",
        xpReward,
        "personal",
        "custom",
        "manual",
        completed ? "verified" : "none",
        0,
        null,
        null,
        null,
        completed ? timestamp("2026-06-06T10:00:00Z") : null,
        null,
        completed,
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

  private Map<String, Object> questDocumentoConcluida() {
    return new java.util.HashMap<>(Map.ofEntries(
        Map.entry("title", "Treinar mobilidade"),
        Map.entry("rewardAttribute", "strength"),
        Map.entry("xpReward", 15),
        Map.entry("category", "personal"),
        Map.entry("templateType", "custom"),
        Map.entry("verificationMode", "manual"),
        Map.entry("verificationStatus", "verified"),
        Map.entry("targetDurationMinutes", 0),
        Map.entry("isCompleted", true),
        Map.entry("completedAt", timestamp("2026-06-06T10:00:00Z")),
        Map.entry("verifiedAt", timestamp("2026-06-06T10:00:00Z")),
        Map.entry("preRewardLevel", 1),
        Map.entry("preRewardXp", 90),
        Map.entry("preRewardMaxXp", 100),
        Map.entry("preRewardStatPoints", 0),
        Map.entry("preRewardStrength", 10),
        Map.entry("preRewardIntelligence", 10),
        Map.entry("preRewardVitality", 10),
        Map.entry("preRewardAgility", 10),
        Map.entry("orderIndex", 0)
    ));
  }

  private Timestamp timestamp(String value) {
    Instant instant = Instant.parse(value);
    return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
  }
}
