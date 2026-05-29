package app.ascend.backend.placar;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

import java.util.List;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.server.ResponseStatusException;

@ExtendWith(MockitoExtension.class)
class PlacarTemporadaServiceTest {

  @Mock
  private RepositorioPlacarTemporada repositorio;

  @Test
  void montaPlacarOrdenadoComoCallableTypeScript() {
    when(repositorio.buscarPorTemporadaEFaixa("2026-05", "E"))
        .thenReturn(List.of(
            new RegistroPlacarTemporada("other-low", "Seguro", 90, 4, 100),
            new RegistroPlacarTemporada("other-late", "Seguro", 120, 2, 300),
            new RegistroPlacarTemporada("user-1", "Ascendente", 120, 2, 200),
            new RegistroPlacarTemporada("other-secure", "Dominante", 120, 3, 400)
        ));

    RespostaPlacarTemporada response = new PlacarTemporadaService(repositorio)
        .buscarPlacarPorTemporadaEFaixa("user-1", "2026-05", "e", 5);

    assertThat(response.status()).isEqualTo("ok");
    assertThat(response.chaveTemporada()).isEqualTo("2026-05");
    assertThat(response.faixaRank()).isEqualTo("E");
    assertThat(response.entradas()).containsExactly(
        new EntradaPlacarTemporada(1, "HUNTER-OTHE", "Dominante | 120 pts", false),
        new EntradaPlacarTemporada(2, "VOCE", "Ascendente | 120 pts", true),
        new EntradaPlacarTemporada(3, "HUNTER-OTHE", "Seguro | 120 pts", false),
        new EntradaPlacarTemporada(4, "HUNTER-OTHE", "Seguro | 90 pts", false)
    );
  }

  @Test
  void limitaQuantidadeComoCallableTypeScript() {
    when(repositorio.buscarPorTemporadaEFaixa("2026-05", "D"))
        .thenReturn(List.of(
            new RegistroPlacarTemporada("u1", "Seguro", 10, 1, 100),
            new RegistroPlacarTemporada("u2", "Seguro", 9, 1, 100)
        ));

    RespostaPlacarTemporada response = new PlacarTemporadaService(repositorio)
        .buscarPlacarPorTemporadaEFaixa("current", "2026-05", "D", 1);

    assertThat(response.entradas()).hasSize(1);
  }

  @Test
  void rejeitaRankInvalido() {
    PlacarTemporadaService service = new PlacarTemporadaService(repositorio);

    assertThatThrownBy(() ->
        service.buscarPlacarPorTemporadaEFaixa("user-1", "2026-05", "X", 5)
    ).isInstanceOf(ResponseStatusException.class)
        .hasMessageContaining("invalid_rank_bracket");
  }

  @Test
  void rejeitaChaveTemporadaInvalida() {
    PlacarTemporadaService service = new PlacarTemporadaService(repositorio);

    assertThatThrownBy(() ->
        service.buscarPlacarPorTemporadaEFaixa("user-1", "", "E", 5)
    ).isInstanceOf(ResponseStatusException.class)
        .hasMessageContaining("invalid_season_key");
  }
}
