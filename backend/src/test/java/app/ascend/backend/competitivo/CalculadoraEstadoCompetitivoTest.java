package app.ascend.backend.competitivo;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Instant;
import java.util.List;
import org.junit.jupiter.api.Test;

class CalculadoraEstadoCompetitivoTest {

  private final CalculadoraEstadoCompetitivo calculadora = new CalculadoraEstadoCompetitivo();

  @Test
  void avaliaPromocaoProntaComContratoTypeScript() {
    Instant agora = Instant.parse("2026-06-10T12:00:00Z");

    SnapshotRankCompetitivo snapshot = calculadora.avaliarRank(
        new FonteEstadoRankCompetitivo(
            10,
            List.of(
                Instant.parse("2026-06-08T10:00:00Z"),
                Instant.parse("2026-06-09T10:00:00Z"),
                Instant.parse("2026-06-10T10:00:00Z"),
                Instant.parse("2026-06-11T10:00:00Z"),
                Instant.parse("2026-06-12T10:00:00Z")
            ),
            snapshotAnterior("D", "D", "2026W0608", 0)
        ),
        agora
    );

    assertThat(snapshot.currentRank()).isEqualTo("D");
    assertThat(snapshot.peakRank()).isEqualTo("D");
    assertThat(snapshot.highestEligibleRank()).isEqualTo("C");
    assertThat(snapshot.weekKey()).isEqualTo("2026W0608");
    assertThat(snapshot.activeDays()).isEqualTo(5);
    assertThat(snapshot.requiredActiveDays()).isEqualTo(4);
    assertThat(snapshot.status()).isEqualTo("promotionReady");
    assertThat(snapshot.promotionReady()).isTrue();
    assertThat(snapshot.promotionTargetRank()).isEqualTo("C");
    assertThat(snapshot.targetRequiredLevel()).isEqualTo(10);
    assertThat(snapshot.targetLevelGateMet()).isTrue();
    assertThat(snapshot.advancementMode()).isEqualTo("ascension");
    assertThat(snapshot.eventType()).isEqualTo("promotionUnlocked");
    assertThat(snapshot.syncSchemaVersion()).isEqualTo(3);
    assertThat(snapshot.syncSource()).isEqualTo("backend");
    assertThat(snapshot.summary()).isEqualTo("Exame de promocao pronto para o rank C.");
  }

  @Test
  void aplicaQuedaAposNovaSemanaSemManutencao() {
    Instant agora = Instant.parse("2026-06-15T12:00:00Z");
    SnapshotRankCompetitivo anterior = snapshotAnterior("D", "D", "2026W0608", 1);

    SnapshotRankCompetitivo snapshot = calculadora.avaliarRank(
        new FonteEstadoRankCompetitivo(6, List.of(), anterior),
        agora
    );

    assertThat(snapshot.currentRank()).isEqualTo("E");
    assertThat(snapshot.peakRank()).isEqualTo("D");
    assertThat(snapshot.weekKey()).isEqualTo("2026W0615");
    assertThat(snapshot.status()).isEqualTo("demoted");
    assertThat(snapshot.demotionStrikes()).isZero();
    assertThat(snapshot.eventType()).isEqualTo("demotionApplied");
    assertThat(snapshot.summary()).isEqualTo("Queda confirmada para o rank E.");
    assertThat(snapshot.detail()).contains("pico historico continua registrado em D");
  }

  @Test
  void avaliaIntegridadeComPadroesSuspeitosComoTypeScript() {
    Instant agora = Instant.parse("2026-06-10T12:00:00Z");

    SnapshotIntegridadeCompetitiva snapshot = calculadora.avaliarIntegridade(
        new FonteIntegridadeCompetitiva(
            List.of(
                Instant.parse("2026-06-08T09:00:00Z"),
                Instant.parse("2026-06-09T09:00:00Z")
            ),
            List.of(),
            List.of(
                quest("Alongar", 10, false, false, Instant.parse("2026-06-10T08:00:00Z")),
                quest("Alongar", 10, false, false, Instant.parse("2026-06-10T08:01:00Z")),
                quest("Ler", 10, false, false, Instant.parse("2026-06-10T08:02:00Z")),
                quest("Beber agua", 10, false, false, Instant.parse("2026-06-10T08:03:00Z")),
                quest("Estudar", 10, false, false, Instant.parse("2026-06-10T08:04:00Z"))
            )
        ),
        agora
    );

    assertThat(snapshot.weekKey()).isEqualTo("2026W0608");
    assertThat(snapshot.weeklyActiveDays()).isEqualTo(2);
    assertThat(snapshot.weeklyCompetitiveDays()).isZero();
    assertThat(snapshot.personalQuestCompletionsToday()).isEqualTo(5);
    assertThat(snapshot.competitiveQuestCompletionsToday()).isZero();
    assertThat(snapshot.personalXpToday()).isEqualTo(50);
    assertThat(snapshot.competitiveXpToday()).isZero();
    assertThat(snapshot.suspiciousPatternCount()).isEqualTo(5);
    assertThat(snapshot.trustScore()).isZero();
    assertThat(snapshot.trustBand()).isEqualTo("restricted");
    assertThat(snapshot.summary()).isEqualTo("Integridade restrita");
    assertThat(snapshot.detail()).contains("Padroes suspeitos detectados: 5.");
    assertThat(snapshot.syncSchemaVersion()).isEqualTo(3);
    assertThat(snapshot.syncSource()).isEqualTo("backend");
  }

  private SnapshotRankCompetitivo snapshotAnterior(
      String rank,
      String peakRank,
      String weekKey,
      int demotionStrikes
  ) {
    return new SnapshotRankCompetitivo(
        rank,
        peakRank,
        rank,
        weekKey,
        0,
        4,
        false,
        false,
        "critical",
        demotionStrikes,
        false,
        "C",
        10,
        false,
        "ascension",
        "warning",
        "",
        "",
        3,
        "backend",
        Instant.parse("2026-06-08T12:00:00Z")
    );
  }

  private QuestFonteIntegridadeCompetitiva quest(
      String titulo,
      int xp,
      boolean competitiva,
      boolean contaCompetitivo,
      Instant concluidaEm
  ) {
    return new QuestFonteIntegridadeCompetitiva(
        titulo,
        xp,
        competitiva,
        contaCompetitivo,
        true,
        concluidaEm
    );
  }
}
