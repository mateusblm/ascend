package app.ascend.backend.boss;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.quests.EscritaInventarioQuest;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import app.ascend.backend.quests.RegistroSessaoAtiva;
import app.ascend.backend.quests.RepositorioInventarioQuest;
import com.google.cloud.Timestamp;
import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.function.Function;
import org.junit.jupiter.api.Test;

class ResgateBossSemanalServiceTest {

  @Test
  void resgataBossSemanalAplicaRecompensaERegistraConclusao() {
    RepositorioBossSemanalEmMemoria repositorioBoss = repositorioBoss();
    repositorioBoss.boss = bossAtivo("C", 140, 2);
    repositorioBoss.perfil = perfilBase();

    RespostaResgateBossSemanal resposta = service(repositorioBoss).resgatar(
        "user-1",
        "Mateus",
        requisicao("weekly-c", "C")
    );

    assertThat(resposta.status()).isEqualTo("claimed");
    assertThat(repositorioBoss.incrementouConclusoes).isTrue();
    assertThat(repositorioBoss.conclusaoSalva)
        .containsEntry("uid", "user-1")
        .containsEntry("displayName", "Hunter")
        .containsEntry("rankAtCompletion", "C")
        .containsEntry("rewardXp", 140)
        .containsEntry("rewardStatPoints", 2);
    assertThat(repositorioBoss.resgateSalvo)
        .containsEntry("bossId", "weekly-c")
        .containsEntry("syncSource", "backend")
        .containsEntry("activeDeviceSessionId", "device-1");
    assertThat(repositorioBoss.perfilSalvo)
        .containsEntry("level", 2)
        .containsEntry("xp", 40)
        .containsEntry("maxXp", 120)
        .containsEntry("statPoints", 7)
        .containsEntry("authoritativeWeeklyBossXp", 140)
        .containsEntry("authoritativeWeeklyBossStatPoints", 2)
        .containsEntry("syncSource", "callable_server_authoritative");
  }

  @Test
  void resgateRepetidoRetornaPerfilAtualSemDuplicarEscrita() {
    RepositorioBossSemanalEmMemoria repositorioBoss = repositorioBoss();
    repositorioBoss.boss = bossAtivo("C", 140, 2);
    repositorioBoss.perfil = perfilBase();
    repositorioBoss.conclusaoExiste = true;

    RespostaResgateBossSemanal resposta = service(repositorioBoss).resgatar(
        "user-1",
        "Mateus",
        requisicao("weekly-c", "C")
    );

    assertThat(resposta.status()).isEqualTo("already_completed");
    assertThat(repositorioBoss.perfilSalvo).isNull();
    assertThat(repositorioBoss.conclusaoSalva).isNull();
    assertThat(repositorioBoss.resgateSalvo).isNull();
    assertThat(repositorioBoss.incrementouConclusoes).isFalse();
  }

  @Test
  void rejeitaRankDivergente() {
    RepositorioBossSemanalEmMemoria repositorioBoss = repositorioBoss();
    repositorioBoss.boss = bossAtivo("B", 140, 2);

    assertThatThrownBy(() -> service(repositorioBoss).resgatar(
        "user-1",
        "Mateus",
        requisicao("weekly-b", "C")
    ))
        .isInstanceOfSatisfying(ExcecaoApi.class, error -> {
          assertThat(error.codigo()).isEqualTo("weekly_boss_rank_mismatch");
          assertThat(error.getMessage()).isEqualTo("Rank enviado nao corresponde ao boss.");
        });
  }

  @Test
  void rejeitaBossForaDaJanelaAtiva() {
    RepositorioBossSemanalEmMemoria repositorioBoss = repositorioBoss();
    repositorioBoss.boss = new HashMap<>(bossAtivo("C", 140, 2));
    repositorioBoss.boss.put("endsAt", timestamp("2000-01-01T00:00:00Z"));

    assertThatThrownBy(() -> service(repositorioBoss).resgatar(
        "user-1",
        "Mateus",
        requisicao("weekly-c", "C")
    ))
        .isInstanceOfSatisfying(ExcecaoApi.class, error ->
            assertThat(error.codigo()).isEqualTo("weekly_boss_outside_window")
        );
  }

  private ResgateBossSemanalService service(RepositorioBossSemanalEmMemoria repositorioBoss) {
    RepositorioSessaoEmMemoria repositorioSessao = new RepositorioSessaoEmMemoria();
    repositorioSessao.sessao = new RegistroSessaoAtiva(
        "device-1",
        timestamp("2099-01-01T00:00:00Z")
    );
    return new ResgateBossSemanalService(
        new GuardaSessaoAtiva(repositorioSessao),
        repositorioBoss
    );
  }

  private RepositorioBossSemanalEmMemoria repositorioBoss() {
    return new RepositorioBossSemanalEmMemoria();
  }

  private RequisicaoResgateBossSemanal requisicao(String bossId, String rank) {
    return new RequisicaoResgateBossSemanal(
        "device-1",
        "android",
        bossId,
        "Hunter",
        "https://example.com/photo.png",
        rank
    );
  }

  private Map<String, Object> bossAtivo(String rank, int recompensaXp, int recompensaPontos) {
    Map<String, Object> data = new HashMap<>();
    data.put("isActive", true);
    data.put("startsAt", timestamp("2000-01-01T00:00:00Z"));
    data.put("endsAt", timestamp("2099-01-01T00:00:00Z"));
    data.put("rank", rank);
    data.put("rewardXp", recompensaXp);
    data.put("rewardStatPoints", recompensaPontos);
    return data;
  }

  private Map<String, Object> perfilBase() {
    Map<String, Object> data = new HashMap<>();
    data.put("name", "Mateus");
    data.put("level", 1);
    data.put("xp", 0);
    data.put("maxXp", 100);
    data.put("statPoints", 0);
    data.put("attributes", Map.of(
        "strength", 10,
        "intelligence", 10,
        "vitality", 10,
        "agility", 10
    ));
    data.put("lastResetDate", timestamp("2026-06-01T00:00:00Z"));
    data.put("currentStreak", 0);
    data.put("bestStreak", 0);
    data.put("primaryFocus", "discipline");
    data.put("hasCompletedOnboarding", true);
    return data;
  }

  private Timestamp timestamp(String value) {
    Instant instant = Instant.parse(value);
    return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
  }

  private static class RepositorioBossSemanalEmMemoria implements RepositorioBossSemanal {
    Map<String, Object> boss = Map.of();
    boolean bossExiste = true;
    boolean conclusaoExiste;
    boolean resgateExiste;
    Map<String, Object> perfil = Map.of();
    Map<String, Object> perfilSalvo;
    Map<String, Object> conclusaoSalva;
    Map<String, Object> resgateSalvo;
    boolean incrementouConclusoes;

    @Override
    public RespostaResgateBossSemanal executarResgate(
        String uid,
        String bossId,
        Function<ContextoResgateBossSemanal, EscritaResgateBossSemanal> mutacao
    ) {
      EscritaResgateBossSemanal escrita = mutacao.apply(new ContextoResgateBossSemanal(
          boss,
          bossExiste,
          conclusaoExiste,
          resgateExiste,
          perfil
      ));
      perfilSalvo = escrita.perfil();
      conclusaoSalva = escrita.conclusao();
      resgateSalvo = escrita.resgateUsuario();
      incrementouConclusoes = escrita.incrementarConclusoes();
      if (perfilSalvo != null) {
        perfil = perfilSalvo;
      }
      if (conclusaoSalva != null) {
        conclusaoExiste = true;
      }
      if (resgateSalvo != null) {
        resgateExiste = true;
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
