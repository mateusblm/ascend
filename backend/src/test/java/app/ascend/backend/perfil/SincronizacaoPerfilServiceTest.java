package app.ascend.backend.perfil;

import static org.assertj.core.api.Assertions.assertThat;

import app.ascend.backend.quests.CatalogoQuestCompetitiva;
import app.ascend.backend.quests.EscritaInventarioQuest;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import app.ascend.backend.quests.QuestFonteInventario;
import app.ascend.backend.quests.RegistroSessaoAtiva;
import app.ascend.backend.quests.RepositorioInventarioQuest;
import app.ascend.backend.quests.ValidadorRequisicaoInventarioQuest;
import com.google.cloud.Timestamp;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import org.junit.jupiter.api.Test;

class SincronizacaoPerfilServiceTest {

  @Test
  void sincronizacaoRecalculaPerfilAPartirDeQuestsEClaimsDeBoss() {
    RepositorioSincronizacaoPerfilEmMemoria repositorio =
        new RepositorioSincronizacaoPerfilEmMemoria();
    repositorio.claims.add(new ClaimBossSemanalPerfil(
        timestamp("2026-06-06T12:00:00Z"),
        95,
        2
    ));

    RespostaPerfil resposta = service(repositorio).sincronizar(
        "user-1",
        new RequisicaoSincronizacaoPerfil(
            "device-1",
            "android",
            new FontePerfilJogador(
                "Mateus",
                new AtributosFontePerfil(12, 11, 10, 10),
                "2026-06-07T00:00:00Z",
                "study",
                true,
                List.of(
                    quest("q-1", "Treinar", "strength", 15, "2026-06-05T10:00:00Z"),
                    quest("q-2", "Ler", "intelligence", 15, "2026-06-06T10:00:00Z")
                )
            )
        )
    );

    assertThat(resposta.status()).isEqualTo("synced");
    assertThat(repositorio.perfilSalvo)
        .containsEntry("name", "Mateus")
        .containsEntry("level", 2)
        .containsEntry("xp", 25)
        .containsEntry("maxXp", 120)
        .containsEntry("statPoints", 6)
        .containsEntry("currentStreak", 2)
        .containsEntry("bestStreak", 2)
        .containsEntry("primaryFocus", "study")
        .containsEntry("authoritativeQuestXp", 30)
        .containsEntry("authoritativeWeeklyBossXp", 95)
        .containsEntry("authoritativeWeeklyBossStatPoints", 2)
        .containsEntry("authoritativeAllocatedStatPoints", 1)
        .containsEntry("syncSource", "callable_server_authoritative")
        .containsEntry("activeDeviceSessionId", "device-1");
    assertThat((Map<String, Object>) repositorio.perfilSalvo.get("attributes"))
        .containsEntry("strength", 12)
        .containsEntry("intelligence", 11)
        .containsEntry("vitality", 10)
        .containsEntry("agility", 10);
  }

  private SincronizacaoPerfilService service(RepositorioSincronizacaoPerfil repositorio) {
    RepositorioSessaoEmMemoria sessao = new RepositorioSessaoEmMemoria();
    sessao.sessao = new RegistroSessaoAtiva(
        "device-1",
        timestamp("2099-01-01T00:00:00Z")
    );
    return new SincronizacaoPerfilService(
        new GuardaSessaoAtiva(sessao),
        new ValidadorRequisicaoInventarioQuest(new CatalogoQuestCompetitiva()),
        repositorio
    );
  }

  private QuestFonteInventario quest(
      String id,
      String titulo,
      String atributo,
      int xp,
      String completedAt
  ) {
    return new QuestFonteInventario(
        id,
        titulo,
        atributo,
        xp,
        "personal",
        "custom",
        "manual",
        "verified",
        0,
        null,
        null,
        null,
        completedAt,
        completedAt,
        true,
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

  private static class RepositorioSincronizacaoPerfilEmMemoria
      implements RepositorioSincronizacaoPerfil {
    List<ClaimBossSemanalPerfil> claims = new ArrayList<>();
    Map<String, Object> perfilSalvo;

    @Override
    public List<ClaimBossSemanalPerfil> buscarClaimsBossSemanal(String uid) {
      return claims;
    }

    @Override
    public void salvarPerfil(String uid, Map<String, Object> perfil) {
      perfilSalvo = perfil;
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
