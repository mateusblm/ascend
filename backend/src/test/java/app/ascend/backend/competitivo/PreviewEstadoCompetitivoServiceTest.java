package app.ascend.backend.competitivo;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import app.ascend.backend.compartilhado.ExcecaoApi;
import java.time.Instant;
import java.util.List;
import org.junit.jupiter.api.Test;

class PreviewEstadoCompetitivoServiceTest {

  private final PreviewEstadoCompetitivoService service =
      new PreviewEstadoCompetitivoService(new CalculadoraEstadoCompetitivo());

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
  }
}
