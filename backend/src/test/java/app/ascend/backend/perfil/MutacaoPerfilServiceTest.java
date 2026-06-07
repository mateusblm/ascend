package app.ascend.backend.perfil;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.quests.EscritaInventarioQuest;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import app.ascend.backend.quests.RegistroSessaoAtiva;
import app.ascend.backend.quests.RepositorioInventarioQuest;
import com.google.cloud.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.function.Function;
import org.junit.jupiter.api.Test;

class MutacaoPerfilServiceTest {

  @Test
  void atualizacaoDeConfiguracoesResetaStreakQuandoResetPassaDaJanelaDiaria() {
    RepositorioPerfilEmMemoria repositorioPerfil = repositorioPerfil();
    repositorioPerfil.perfil = perfilBase(3, 2);

    RespostaPerfil resposta = service(repositorioPerfil)
        .atualizarConfiguracoes("user-1", "Mateus", new RequisicaoAtualizacaoPerfil(
            "device-1",
            "android",
            "Novo Nome",
            "study",
            true,
            "2026-06-07T00:00:00Z"
        ));

    assertThat(resposta.status()).isEqualTo("updated");
    assertThat(repositorioPerfil.perfilSalvo)
        .containsEntry("name", "Novo Nome")
        .containsEntry("primaryFocus", "study")
        .containsEntry("currentStreak", 0)
        .containsEntry("bestStreak", 3)
        .containsEntry("syncSource", "callable_server_authoritative")
        .containsEntry("activeDeviceSessionId", "device-1")
        .containsEntry("activeDeviceLabel", "android");
  }

  @Test
  void alocacaoIncrementaAtributoDiminuiPontoLivreERegistraAuditoria() {
    RepositorioPerfilEmMemoria repositorioPerfil = repositorioPerfil();
    repositorioPerfil.perfil = perfilBase(2, 2);

    RespostaPerfil resposta = service(repositorioPerfil)
        .alocarPonto("user-1", "Mateus", new RequisicaoAlocacaoAtributo(
            "device-1",
            "android",
            "intelligence"
        ));

    assertThat(resposta.status()).isEqualTo("allocated");
    assertThat(repositorioPerfil.perfilSalvo)
        .containsEntry("statPoints", 1)
        .containsEntry("authoritativeAllocatedStatPoints", 3);
    assertThat((Map<String, Object>) repositorioPerfil.perfilSalvo.get("attributes"))
        .containsEntry("strength", 10)
        .containsEntry("intelligence", 11);
    assertThat(repositorioPerfil.auditoriaSalva)
        .containsEntry("attribute", "intelligence")
        .containsEntry("syncSource", "callable_server_authoritative")
        .containsEntry("activeDeviceSessionId", "device-1")
        .containsEntry("activeDeviceLabel", "android");
    assertThat(repositorioPerfil.auditoriaSalva.get("allocatedAt")).isInstanceOf(Timestamp.class);
  }

  @Test
  void rejeitaAlocacaoSemPontosLivres() {
    RepositorioPerfilEmMemoria repositorioPerfil = repositorioPerfil();
    repositorioPerfil.perfil = perfilBase(0, 2);

    assertThatThrownBy(() -> service(repositorioPerfil)
        .alocarPonto("user-1", "Mateus", new RequisicaoAlocacaoAtributo(
            "device-1",
            "android",
            "strength"
        )))
        .isInstanceOfSatisfying(ExcecaoApi.class, error -> {
          assertThat(error.codigo()).isEqualTo("no_stat_points_available");
          assertThat(error.getMessage()).isEqualTo("Nenhum ponto disponivel.");
        });
    assertThat(repositorioPerfil.perfilSalvo).isNull();
    assertThat(repositorioPerfil.auditoriaSalva).isNull();
  }

  private MutacaoPerfilService service(RepositorioPerfilEmMemoria repositorioPerfil) {
    RepositorioSessaoEmMemoria repositorioSessao = new RepositorioSessaoEmMemoria();
    repositorioSessao.sessao = new RegistroSessaoAtiva(
        "device-1",
        timestamp("2099-01-01T00:00:00Z")
    );
    return new MutacaoPerfilService(new GuardaSessaoAtiva(repositorioSessao), repositorioPerfil);
  }

  private RepositorioPerfilEmMemoria repositorioPerfil() {
    return new RepositorioPerfilEmMemoria();
  }

  private Map<String, Object> perfilBase(int statPoints, int allocatedPoints) {
    return Map.ofEntries(
        Map.entry("name", "Mateus"),
        Map.entry("level", 4),
        Map.entry("xp", 25),
        Map.entry("maxXp", 120),
        Map.entry("statPoints", statPoints),
        Map.entry("attributes", Map.of(
            "strength", 10,
            "intelligence", 10,
            "vitality", 10,
            "agility", 10
        )),
        Map.entry("lastResetDate", timestamp("2026-06-04T00:00:00Z")),
        Map.entry("currentStreak", 3),
        Map.entry("bestStreak", 3),
        Map.entry("lastQuestCompletionDate", timestamp("2026-06-04T10:00:00Z")),
        Map.entry("primaryFocus", "discipline"),
        Map.entry("hasCompletedOnboarding", true),
        Map.entry("authoritativeAllocatedStatPoints", allocatedPoints)
    );
  }

  private Timestamp timestamp(String value) {
    Instant instant = Instant.parse(value);
    return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
  }

  private static class RepositorioPerfilEmMemoria implements RepositorioPerfil {
    Map<String, Object> perfil = Map.of();
    Map<String, Object> perfilSalvo;
    Map<String, Object> auditoriaSalva;

    @Override
    public RespostaPerfil executarMutacao(
        String uid,
        Function<Map<String, Object>, EscritaPerfil> mutacao
    ) {
      EscritaPerfil escrita = mutacao.apply(perfil);
      perfilSalvo = escrita.perfil();
      auditoriaSalva = escrita.auditoriaAlocacao();
      if (perfilSalvo != null) {
        perfil = perfilSalvo;
      }
      return escrita.resposta();
    }
  }

  private static class RepositorioSessaoEmMemoria implements RepositorioInventarioQuest {
    RegistroSessaoAtiva sessao;

    @Override
    public Optional<RegistroSessaoAtiva> buscarSessaoAtiva(String uid) {
      return Optional.ofNullable(sessao);
    }

    @Override
    public Set<String> buscarIdsQuests(String uid) {
      return Set.of();
    }

    @Override
    public void sincronizarInventario(
        String uid,
        List<EscritaInventarioQuest> escritas,
        Map<String, Object> meta,
        Set<String> idsQuestsParaExcluir
    ) {
    }
  }
}
