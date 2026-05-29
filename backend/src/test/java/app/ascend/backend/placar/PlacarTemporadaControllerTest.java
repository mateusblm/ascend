package app.ascend.backend.placar;

import static org.hamcrest.Matchers.is;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import app.ascend.backend.autenticacao.ResolvedorArgumentoUsuarioAutenticado;
import app.ascend.backend.autenticacao.FiltroAutenticacao;
import app.ascend.backend.autenticacao.VerificadorTokenFirebaseAuth;
import app.ascend.backend.configuracao.ConfiguracaoWeb;
import app.ascend.backend.compartilhado.TratadorExcecoesApi;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(PlacarTemporadaController.class)
@Import({
    FiltroAutenticacao.class,
    ResolvedorArgumentoUsuarioAutenticado.class,
    ConfiguracaoWeb.class,
    TratadorExcecoesApi.class,
    PlacarTemporadaService.class
})
class PlacarTemporadaControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @MockitoBean
  private VerificadorTokenFirebaseAuth tokenVerifier;

  @MockitoBean
  private RepositorioPlacarTemporada repositorio;

  @Test
  void buscarPlacarRequerAutenticacao() throws Exception {
    mockMvc.perform(get("/api/v1/season-leaderboard")
            .param("seasonKey", "2026-05")
            .param("rankBracket", "E"))
        .andExpect(status().isUnauthorized());
  }

  @Test
  void buscarPlacarRetornaEntradasNoContratoPublico() throws Exception {
    when(tokenVerifier.verificar("valid-token"))
        .thenReturn(new UsuarioAutenticado("user-1", "user@example.com"));
    when(repositorio.buscarPorTemporadaEFaixa("2026-05", "E"))
        .thenReturn(List.of(
            new RegistroPlacarTemporada("user-1", "Seguro", 42, 2, 100)
        ));

    mockMvc.perform(get("/api/v1/season-leaderboard")
            .header("Authorization", "Bearer valid-token")
            .param("seasonKey", "2026-05")
            .param("rankBracket", "e"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is("ok")))
        .andExpect(jsonPath("$.seasonKey", is("2026-05")))
        .andExpect(jsonPath("$.rankBracket", is("E")))
        .andExpect(jsonPath("$.entries[0].position", is(1)))
        .andExpect(jsonPath("$.entries[0].displayName", is("VOCE")))
        .andExpect(jsonPath("$.entries[0].detail", is("Seguro | 42 pts")))
        .andExpect(jsonPath("$.entries[0].isPlayer", is(true)));
  }

  @Test
  void buscarPlacarRejeitaRankInvalido() throws Exception {
    when(tokenVerifier.verificar("valid-token"))
        .thenReturn(new UsuarioAutenticado("user-1", "user@example.com"));

    mockMvc.perform(get("/api/v1/season-leaderboard")
            .header("Authorization", "Bearer valid-token")
            .param("seasonKey", "2026-05")
            .param("rankBracket", "X"))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.error", is("invalid_rank_bracket")))
        .andExpect(jsonPath("$.message", is("Faixa de rank invalida.")));
  }
}
