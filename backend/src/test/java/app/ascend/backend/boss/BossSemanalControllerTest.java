package app.ascend.backend.boss;

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
import app.ascend.backend.configuracao.ConfiguracaoWeb;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(BossSemanalController.class)
@Import({FiltroAutenticacao.class, ResolvedorArgumentoUsuarioAutenticado.class, ConfiguracaoWeb.class})
class BossSemanalControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @MockitoBean
  private VerificadorTokenFirebaseAuth tokenVerifier;

  @MockitoBean
  private ResgateBossSemanalService service;

  @Test
  void resgateRequerAutenticacao() throws Exception {
    mockMvc.perform(post("/api/v1/weekly-boss:claim")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{}"))
        .andExpect(status().isUnauthorized())
        .andExpect(jsonPath("$.error", is("unauthenticated")));
  }

  @Test
  void resgateRetornaPerfilAtualizado() throws Exception {
    when(tokenVerifier.verificar("valid-token"))
        .thenReturn(new UsuarioAutenticado("user-1", "mateus@example.com"));
    when(service.resgatar(
        eq("user-1"),
        eq("mateus@example.com"),
        any(RequisicaoResgateBossSemanal.class)
    )).thenReturn(new RespostaResgateBossSemanal(
        "claimed",
        Map.of("level", 2, "statPoints", 7)
    ));

    mockMvc.perform(post("/api/v1/weekly-boss:claim")
            .header("Authorization", "Bearer valid-token")
            .contentType(MediaType.APPLICATION_JSON)
            .content("""
                {
                  "deviceSessionId": "device-1",
                  "deviceLabel": "android",
                  "bossId": "weekly-c",
                  "displayName": "Hunter",
                  "photoUrl": "",
                  "rankAtCompletion": "C"
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is("claimed")))
        .andExpect(jsonPath("$.profile.level", is(2)))
        .andExpect(jsonPath("$.profile.statPoints", is(7)));
  }
}
