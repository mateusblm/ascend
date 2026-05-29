package app.ascend.backend.quests;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.google.cloud.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.Test;
import org.springframework.web.server.ResponseStatusException;

class SincronizacaoInventarioQuestServiceTest {

  @Test
  void sincronizaQuestPessoalComNormalizacaoTypeScript() {
    RepositorioInventarioQuestEmMemoria repositorio = repositorioComSessaoAtiva();
    repositorio.idsQuestsAtuais = Set.of("old-quest", "personal-1");

    RespostaSincronizacaoInventarioQuest response = service(repositorio)
        .sincronizarInventario("user-1", new RequisicaoSincronizacaoInventarioQuest(
            "device-1",
            null,
            new FonteInventarioQuest(List.of(personalQuest("personal-1", 100, true)))
        ));

    assertThat(response).isEqualTo(new RespostaSincronizacaoInventarioQuest("synced", 1));
    assertThat(repositorio.deletedQuestIds).containsExactly("old-quest");
    assertThat(repositorio.syncedMeta)
        .containsEntry("initialized", true)
        .containsEntry("questCount", 1)
        .containsEntry("syncSchemaVersion", 1)
        .containsEntry("syncSource", "callable_session_audited")
        .containsEntry("activeDeviceSessionId", "device-1")
        .containsEntry("activeDeviceLabel", "device");

    Map<String, Object> data = repositorio.syncedWrites.getFirst().data();
    assertThat(repositorio.syncedWrites.getFirst().id()).isEqualTo("personal-1");
    assertThat(data)
        .containsEntry("title", "Treinar mobilidade")
        .containsEntry("rewardAttribute", "strength")
        .containsEntry("xpReward", 15)
        .containsEntry("category", "personal")
        .containsEntry("templateType", "custom")
        .containsEntry("verificationMode", "manual")
        .containsEntry("verificationStatus", "verified")
        .containsEntry("targetDurationMinutes", 0)
        .containsEntry("reflectionPrompt", null)
        .containsEntry("reflectionAnswer", null)
        .containsEntry("verificationStartedAt", null)
        .containsEntry("isCompleted", true)
        .containsEntry("orderIndex", 0)
        .containsEntry("syncSchemaVersion", 1);
    assertThat(data.get("completedAt")).isInstanceOf(Timestamp.class);
    assertThat(data.get("verifiedAt")).isEqualTo(data.get("completedAt"));
  }

  @Test
  void rejeitaTemplatesCompetitivosAtivosDuplicados() {
    RepositorioInventarioQuestEmMemoria repositorio = repositorioComSessaoAtiva();
    QuestFonteInventario focusOne = competitiveQuest("focus-1", false);
    QuestFonteInventario focusTwo = competitiveQuest("focus-2", false);

    assertThatThrownBy(() -> service(repositorio)
        .sincronizarInventario("user-1", new RequisicaoSincronizacaoInventarioQuest(
            "device-1",
            "Notebook",
            new FonteInventarioQuest(List.of(focusOne, focusTwo))
        )))
        .isInstanceOf(ResponseStatusException.class)
        .hasMessageContaining("duplicate_competitive_template");
  }

  @Test
  void permiteTemplatesCompetitivosConcluidosDuplicados() {
    RepositorioInventarioQuestEmMemoria repositorio = repositorioComSessaoAtiva();

    RespostaSincronizacaoInventarioQuest response = service(repositorio)
        .sincronizarInventario("user-1", new RequisicaoSincronizacaoInventarioQuest(
            "device-1",
            "Notebook",
            new FonteInventarioQuest(List.of(
                competitiveQuest("focus-1", true),
                competitiveQuest("focus-2", true)
            ))
        ));

    assertThat(response.totalQuests()).isEqualTo(2);
    assertThat(repositorio.syncedWrites).hasSize(2);
  }

  @Test
  void rejeitaSessaoDeOutroDispositivo() {
    RepositorioInventarioQuestEmMemoria repositorio = repositorioComSessaoAtiva();

    assertThatThrownBy(() -> service(repositorio)
        .sincronizarInventario("user-1", new RequisicaoSincronizacaoInventarioQuest(
            "other-device",
            null,
            new FonteInventarioQuest(List.of())
        )))
        .isInstanceOf(ResponseStatusException.class)
        .hasMessageContaining("active_session_conflict");
  }

  @Test
  void rejeitaSessaoAusente() {
    RepositorioInventarioQuestEmMemoria repositorio = new RepositorioInventarioQuestEmMemoria();

    assertThatThrownBy(() -> service(repositorio)
        .sincronizarInventario("user-1", new RequisicaoSincronizacaoInventarioQuest(
            "device-1",
            null,
            new FonteInventarioQuest(List.of())
        )))
        .isInstanceOf(ResponseStatusException.class)
        .hasMessageContaining("active_session_missing");
  }

  private RepositorioInventarioQuestEmMemoria repositorioComSessaoAtiva() {
    RepositorioInventarioQuestEmMemoria repositorio = new RepositorioInventarioQuestEmMemoria();
    repositorio.activeSession = new RegistroSessaoAtiva(
        "device-1",
        timestamp("2099-01-01T00:00:00Z")
    );
    return repositorio;
  }

  private SincronizacaoInventarioQuestService service(RepositorioInventarioQuestEmMemoria repositorio) {
    return new SincronizacaoInventarioQuestService(
        repositorio,
        new GuardaSessaoAtiva(repositorio),
        new ValidadorRequisicaoInventarioQuest(new CatalogoQuestCompetitiva()),
        new MapeadorDocumentoInventarioQuest()
    );
  }

  private QuestFonteInventario personalQuest(String id, int xpReward, boolean completed) {
    return new QuestFonteInventario(
        id,
        "Treinar mobilidade",
        "strength",
        xpReward,
        "personal",
        "focusSession",
        "timer",
        "ready",
        25,
        "ignored",
        "ignored",
        timestamp("2026-05-01T10:00:00Z"),
        completed ? "2026-05-01T11:00:00Z" : null,
        null,
        completed,
        2,
        20,
        120,
        5,
        3,
        4,
        5,
        6
    );
  }

  private QuestFonteInventario competitiveQuest(String id, boolean completed) {
    return new QuestFonteInventario(
        id,
        "Sessao de foco de 25 minutos",
        "agility",
        30,
        "competitive",
        "focusSession",
        "timer",
        "ready",
        25,
        null,
        null,
        null,
        completed ? timestamp("2026-05-01T11:00:00Z") : null,
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

  private Timestamp timestamp(String value) {
    Instant instant = Instant.parse(value);
    return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
  }
}
