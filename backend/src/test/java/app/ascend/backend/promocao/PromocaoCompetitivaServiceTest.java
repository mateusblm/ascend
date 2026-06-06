package app.ascend.backend.promocao;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.competitivo.SnapshotRankCompetitivo;
import java.time.Instant;
import org.junit.jupiter.api.Test;

class PromocaoCompetitivaServiceTest {

  private final RepositorioPromocaoCompetitivaEmMemoria repositorio =
      new RepositorioPromocaoCompetitivaEmMemoria();
  private final PromocaoCompetitivaService service =
      new PromocaoCompetitivaService(repositorio, new PoliticaPromocaoCompetitiva());

  @Test
  void iniciaExameQuandoPromocaoEstaDisponivel() {
    RespostaExamePromocao resposta = service.iniciarExame(
        "user-1",
        new RequisicaoExamePromocao(snapshotPromocaoPronta())
    );

    assertThat(resposta.status()).isEqualTo("started");
    assertThat(resposta.targetRank()).isEqualTo("C");
    assertThat(repositorio.exameAtual)
        .extracting(ExamePromocao::sourceRank, ExamePromocao::targetRank, ExamePromocao::status)
        .containsExactly("D", "C", "inProgress");
    assertThat(repositorio.exameAtual.syncSource()).isEqualTo("backend");
  }

  @Test
  void inicioDeExameEmAndamentoEhIdempotente() {
    repositorio.exameAtual = exame("inProgress");

    RespostaExamePromocao resposta = service.iniciarExame(
        "user-1",
        new RequisicaoExamePromocao(snapshotPromocaoPronta())
    );

    assertThat(resposta.status()).isEqualTo("already_in_progress");
    assertThat(resposta.targetRank()).isEqualTo("C");
  }

  @Test
  void rejeitaInicioSemPromocaoLiberada() {
    SnapshotRankCompetitivo snapshot = snapshotPromocaoPronta();

    assertThatThrownBy(() -> service.iniciarExame(
        "user-1",
        new RequisicaoExamePromocao(new SnapshotRankCompetitivo(
            snapshot.currentRank(),
            snapshot.peakRank(),
            snapshot.highestEligibleRank(),
            snapshot.weekKey(),
            snapshot.activeDays(),
            snapshot.requiredActiveDays(),
            snapshot.requiresBossClear(),
            snapshot.bossCompleted(),
            "secure",
            snapshot.demotionStrikes(),
            false,
            null,
            snapshot.targetRequiredLevel(),
            snapshot.targetLevelGateMet(),
            snapshot.advancementMode(),
            "routine",
            snapshot.summary(),
            snapshot.detail(),
            snapshot.syncSchemaVersion(),
            snapshot.syncSource(),
            snapshot.updatedAt()
        ))
    ))
        .isInstanceOfSatisfying(ExcecaoApi.class, error ->
            assertThat(error.codigo()).isEqualTo("promotion_not_ready")
        );
  }

  @Test
  void confirmaPromocaoQuandoExameFoiAprovado() {
    repositorio.exameAtual = exame("passed");

    RespostaExamePromocao resposta = service.confirmarPromocao(
        "user-1",
        new RequisicaoExamePromocao(snapshotPromocaoPronta())
    );

    assertThat(resposta.status()).isEqualTo("promoted");
    assertThat(resposta.currentRank()).isEqualTo("C");
    assertThat(repositorio.snapshotPromovido.currentRank()).isEqualTo("C");
    assertThat(repositorio.snapshotPromovido.status()).isEqualTo("secure");
    assertThat(repositorio.snapshotPromovido.eventType()).isEqualTo("promotionConfirmed");
    assertThat(repositorio.examePromovido.status()).isEqualTo("promoted");
  }

  @Test
  void confirmacaoJaPromovidaEhIdempotente() {
    repositorio.exameAtual = exame("promoted");

    RespostaExamePromocao resposta = service.confirmarPromocao(
        "user-1",
        new RequisicaoExamePromocao(snapshotPromocaoPronta())
    );

    assertThat(resposta.status()).isEqualTo("already_promoted");
    assertThat(resposta.currentRank()).isEqualTo("C");
  }

  @Test
  void rejeitaConfirmacaoAntesDaProvaAprovada() {
    repositorio.exameAtual = exame("inProgress");

    assertThatThrownBy(() -> service.confirmarPromocao(
        "user-1",
        new RequisicaoExamePromocao(snapshotPromocaoPronta())
    ))
        .isInstanceOfSatisfying(ExcecaoApi.class, error ->
            assertThat(error.codigo()).isEqualTo("promotion_exam_not_passed")
        );
  }

  private SnapshotRankCompetitivo snapshotPromocaoPronta() {
    return new SnapshotRankCompetitivo(
        "D",
        "D",
        "C",
        "2026W0608",
        5,
        4,
        false,
        true,
        "promotionReady",
        0,
        true,
        "C",
        10,
        true,
        "ascension",
        "promotionUnlocked",
        "Exame de promocao pronto para o rank C.",
        "Detalhe",
        3,
        "backend",
        Instant.parse("2026-06-10T12:00:00Z")
    );
  }

  private ExamePromocao exame(String status) {
    return new ExamePromocao(
        "D",
        "C",
        "2026W0608",
        status,
        "ascension",
        5,
        1,
        true,
        10,
        Instant.parse("2026-06-10T12:00:00Z"),
        Instant.parse("2026-06-13T12:00:00Z"),
        3,
        "backend",
        status.equals("promoted") ? Instant.parse("2026-06-11T12:00:00Z") : null
    );
  }

  private static class RepositorioPromocaoCompetitivaEmMemoria
      implements RepositorioPromocaoCompetitiva {

    private ExamePromocao exameAtual;
    private SnapshotRankCompetitivo snapshotPromovido;
    private ExamePromocao examePromovido;

    @Override
    public ExamePromocao buscarExameAtual(String uid) {
      return exameAtual;
    }

    @Override
    public void gravarInicioExame(String uid, ExamePromocao exame) {
      exameAtual = exame;
    }

    @Override
    public void gravarPromocao(
        String uid,
        SnapshotRankCompetitivo snapshot,
        ExamePromocao exame
    ) {
      snapshotPromovido = snapshot;
      examePromovido = exame;
    }
  }
}
