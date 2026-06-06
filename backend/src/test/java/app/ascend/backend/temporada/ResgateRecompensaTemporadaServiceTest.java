package app.ascend.backend.temporada;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import app.ascend.backend.compartilhado.ExcecaoApi;
import java.time.Instant;
import org.junit.jupiter.api.Test;

class ResgateRecompensaTemporadaServiceTest {

  private final RepositorioRecompensaTemporadaEmMemoria repositorio =
      new RepositorioRecompensaTemporadaEmMemoria();
  private final ResgateRecompensaTemporadaService service =
      new ResgateRecompensaTemporadaService(
          repositorio,
          new PoliticaCosmeticoTemporada()
      );

  @Test
  void resgataRecompensaProntaEGravaLegadoPerfilEHistorico() {
    repositorio.recompensaAtual = recompensa("readyToClaim", true, null);

    RespostaResgateRecompensaTemporada resposta = service.resgatar(
        "user-1",
        new RequisicaoResgateRecompensaTemporada("2026-06")
    );

    assertThat(resposta.status()).isEqualTo("claimed");
    assertThat(resposta.seasonKey()).isEqualTo("2026-06");
    assertThat(resposta.rewardName()).isEqualTo("Pacote de Manutencao");
    assertThat(resposta.activeTitleLabel()).isEqualTo("VIGIA DO CICLO");
    assertThat(repositorio.recompensaGravada.claimStatus()).isEqualTo("claimed");
    assertThat(repositorio.legadoGravado.cosmeticFrameLabel()).isEqualTo("QUADRO DE BRONZE");
    assertThat(repositorio.perfilGravado.activeRewardName()).isEqualTo("Pacote de Manutencao");
  }

  @Test
  void resgateJaFeitoEhIdempotenteSemNovaEscrita() {
    repositorio.recompensaAtual = recompensa(
        "claimed",
        true,
        Instant.parse("2026-06-06T12:00:00Z")
    );

    RespostaResgateRecompensaTemporada resposta = service.resgatar(
        "user-1",
        new RequisicaoResgateRecompensaTemporada("2026-06")
    );

    assertThat(resposta.status()).isEqualTo("already_claimed");
    assertThat(repositorio.recompensaGravada).isNull();
    assertThat(resposta.activeTitleLabel()).isEqualTo("VIGIA DO CICLO");
  }

  @Test
  void rejeitaRecompensaBloqueada() {
    repositorio.recompensaAtual = recompensa("locked", false, null);

    assertThatThrownBy(() -> service.resgatar(
        "user-1",
        new RequisicaoResgateRecompensaTemporada("2026-06")
    ))
        .isInstanceOfSatisfying(ExcecaoApi.class, error ->
            assertThat(error.codigo()).isEqualTo("season_reward_locked")
        );
  }

  @Test
  void rejeitaQuandoTemporadaAtualMudou() {
    repositorio.recompensaAtual = recompensa("readyToClaim", true, null);

    assertThatThrownBy(() -> service.resgatar(
        "user-1",
        new RequisicaoResgateRecompensaTemporada("2026-05")
    ))
        .isInstanceOfSatisfying(ExcecaoApi.class, error ->
            assertThat(error.codigo()).isEqualTo("season_reward_changed")
        );
  }

  private RecompensaTemporada recompensa(
      String status,
      boolean liberada,
      Instant claimedAt
  ) {
    return new RecompensaTemporada(
        "2026-06",
        "JUN 2026",
        "C",
        "MANUTENCAO",
        liberada ? "LIBERADA" : "BLOQUEADA",
        liberada,
        "Pacote de Manutencao",
        "SIGILO DE BRONZE",
        "VIGIA DO CICLO",
        "Insignia sazonal e selo de consistencia.",
        4,
        3,
        42,
        "ESTAVEL",
        "Clear rate aguardando lobby",
        "EM ROTA",
        "Sem boss ativo.",
        "7 dias",
        status,
        3,
        "backend",
        Instant.parse("2026-06-06T10:00:00Z"),
        claimedAt
    );
  }

  private static class RepositorioRecompensaTemporadaEmMemoria
      implements RepositorioRecompensaTemporada {

    private RecompensaTemporada recompensaAtual;
    private RecompensaTemporada recompensaGravada;
    private RecompensaLegadoTemporada legadoGravado;
    private PerfilTemporada perfilGravado;

    @Override
    public ResultadoResgateRecompensaTemporada resgatarRecompensaAtual(
        String uid,
        String chaveTemporadaSolicitada,
        Instant agora,
        ResolvedorResgateRecompensaTemporada resolvedor
    ) {
      if (recompensaAtual != null
          && !chaveTemporadaSolicitada.isBlank()
          && !chaveTemporadaSolicitada.equals(recompensaAtual.seasonKey())) {
        throw new ExcecaoApi(
            org.springframework.http.HttpStatus.PRECONDITION_FAILED,
            "season_reward_changed",
            "A recompensa sazonal atual mudou."
        );
      }

      ResolucaoResgateRecompensaTemporada resolucao =
          resolvedor.resolver(recompensaAtual, agora);
      if ("claimed".equals(resolucao.status())) {
        recompensaGravada = resolucao.recompensa();
        legadoGravado = resolucao.legado();
        perfilGravado = resolucao.perfil();
      }
      return new ResultadoResgateRecompensaTemporada(
          resolucao.status(),
          resolucao.recompensa(),
          resolucao.legado(),
          resolucao.perfil()
      );
    }
  }
}
