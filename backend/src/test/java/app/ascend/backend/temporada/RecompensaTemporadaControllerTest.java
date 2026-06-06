package app.ascend.backend.temporada;

import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import app.ascend.backend.autenticacao.FiltroAutenticacao;
import app.ascend.backend.autenticacao.ResolvedorArgumentoUsuarioAutenticado;
import app.ascend.backend.autenticacao.UsuarioAutenticado;
import app.ascend.backend.autenticacao.VerificadorTokenFirebaseAuth;
import app.ascend.backend.compartilhado.TratadorExcecoesApi;
import app.ascend.backend.configuracao.ConfiguracaoWeb;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(RecompensaTemporadaController.class)
@Import({
    FiltroAutenticacao.class,
    ResolvedorArgumentoUsuarioAutenticado.class,
    ConfiguracaoWeb.class,
    TratadorExcecoesApi.class
})
class RecompensaTemporadaControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @MockitoBean
  private VerificadorTokenFirebaseAuth tokenVerifier;

  @MockitoBean
  private ResgateRecompensaTemporadaService service;

  @Test
  void resgateRequerAutenticacao() throws Exception {
    mockMvc.perform(post("/api/v1/season-rewards/current:claim")
            .contentType("application/json")
            .content("{}"))
        .andExpect(status().isUnauthorized());
  }

  @Test
  void resgateRetornaContratoPublico() throws Exception {
    when(tokenVerifier.verificar("valid-token"))
        .thenReturn(new UsuarioAutenticado("user-1", "user@example.com"));
    when(service.resgatar(eq("user-1"), any()))
        .thenReturn(new RespostaResgateRecompensaTemporada(
            "claimed",
            "2026-06",
            "Pacote de Manutencao",
            "VIGIA DO CICLO"
        ));

    mockMvc.perform(post("/api/v1/season-rewards/current:claim")
            .header("Authorization", "Bearer valid-token")
            .contentType("application/json")
            .content("""
                {"seasonKey":"2026-06"}
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is("claimed")))
        .andExpect(jsonPath("$.seasonKey", is("2026-06")))
        .andExpect(jsonPath("$.rewardName", is("Pacote de Manutencao")))
        .andExpect(jsonPath("$.activeTitleLabel", is("VIGIA DO CICLO")));
  }
}
