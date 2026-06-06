package app.ascend.backend.competitivo;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import app.ascend.backend.compartilhado.ExcecaoApi;
import java.time.Instant;
import java.util.List;
import org.junit.jupiter.api.Test;

class PreviewEstadoCompetitivoServiceTest {

  private final RepositorioEstadoCompetitivoEmMemoria repositorio =
      new RepositorioEstadoCompetitivoEmMemoria();
  private final PreviewEstadoCompetitivoService service =
      new PreviewEstadoCompetitivoService(new CalculadoraEstadoCompetitivo(), repositorio);

  @Test
  void rejeitaFonteObrigatoriaAusente() {
    assertThatThrownBy(() -> service.prever(new RequisicaoPreviewEstadoCompetitivo(null, null)))
        .isInstanceOfSatisfying(ExcecaoApi.class, error ->
            assertThat(error.codigo()).isEqualTo("invalid_competitive_preview_source")
        );
  }

  @Test
  void retornaPreviewSemPersistencia() {
    RespostaPreviewEstadoCompetitivo resposta = service.prever(
        new RequisicaoPreviewEstadoCompetitivo(
            new FonteEstadoRankCompetitivo(
                1,
                List.of(Instant.parse("2026-06-08T10:00:00Z")),
                null
            ),
            new FonteIntegridadeCompetitiva(List.of(), List.of(), List.of())
        )
    );

    assertThat(resposta.status()).isEqualTo("preview");
    assertThat(resposta.rankSnapshot().syncSource()).isEqualTo("backend");
    assertThat(resposta.integritySnapshot().syncSource()).isEqualTo("backend");
    assertThat(repositorio.rankGravado).isNull();
    assertThat(repositorio.integridadeGravada).isNull();
  }

  @Test
  void sincronizaRankEGravaSnapshot() {
    RespostaSincronizacaoEstadoCompetitivo resposta = service.sincronizar(
        "user-1",
        new RequisicaoSincronizacaoEstadoCompetitivo(
            new FonteEstadoRankCompetitivo(
                10,
                List.of(
                    Instant.parse("2026-06-08T10:00:00Z"),
                    Instant.parse("2026-06-09T10:00:00Z"),
                    Instant.parse("2026-06-10T10:00:00Z"),
                    Instant.parse("2026-06-11T10:00:00Z"),
                    Instant.parse("2026-06-12T10:00:00Z")
                ),
                null
            ),
            null
        )
    );

    assertThat(resposta.status()).isEqualTo("synced");
    assertThat(resposta.rankSnapshot()).isNotNull();
    assertThat(resposta.integritySnapshot()).isNull();
    assertThat(repositorio.uidRank).isEqualTo("user-1");
    assertThat(repositorio.rankGravado).isEqualTo(resposta.rankSnapshot());
  }

  @Test
  void sincronizaIntegridadeComHistoricoAutorizadoQuandoExistir() {
    Instant agora = Instant.now();
    repositorio.historicoAutorizado = List.of(agora);

    RespostaSincronizacaoEstadoCompetitivo resposta = service.sincronizar(
        "user-1",
        new RequisicaoSincronizacaoEstadoCompetitivo(
            null,
            new FonteIntegridadeCompetitiva(
                List.of(agora),
                List.of(),
                List.of()
            )
        )
    );

    assertThat(resposta.status()).isEqualTo("synced");
    assertThat(resposta.rankSnapshot()).isNull();
    assertThat(resposta.integritySnapshot()).isNotNull();
    assertThat(resposta.integritySnapshot().weeklyCompetitiveDays()).isEqualTo(1);
    assertThat(repositorio.uidIntegridade).isEqualTo("user-1");
    assertThat(repositorio.integridadeGravada).isEqualTo(resposta.integritySnapshot());
  }

  private static class RepositorioEstadoCompetitivoEmMemoria
      implements RepositorioEstadoCompetitivo {

    private List<Instant> historicoAutorizado = List.of();
    private String uidRank;
    private String uidIntegridade;
    private SnapshotRankCompetitivo rankGravado;
    private SnapshotIntegridadeCompetitiva integridadeGravada;

    @Override
    public SnapshotRankCompetitivo buscarSnapshotRankAtual(String uid) {
      return null;
    }

    @Override
    public List<Instant> buscarHistoricoCompetitivoAutorizado(String uid) {
      return historicoAutorizado;
    }

    @Override
    public void gravarSnapshotRank(String uid, SnapshotRankCompetitivo snapshot) {
      uidRank = uid;
      rankGravado = snapshot;
    }

    @Override
    public void gravarSnapshotIntegridade(
        String uid,
        SnapshotIntegridadeCompetitiva snapshot
    ) {
      uidIntegridade = uid;
      integridadeGravada = snapshot;
    }
  }
}
