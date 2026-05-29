package app.ascend.backend.conta;

import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import app.ascend.backend.autenticacao.ResolvedorArgumentoUsuarioAutenticado;
import app.ascend.backend.autenticacao.FiltroAutenticacao;
import app.ascend.backend.autenticacao.VerificadorTokenFirebaseAuth;
import app.ascend.backend.configuracao.ConfiguracaoWeb;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.context.annotation.Import;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(MinhaContaController.class)
@Import({FiltroAutenticacao.class, ResolvedorArgumentoUsuarioAutenticado.class, ConfiguracaoWeb.class})
class MinhaContaControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @MockitoBean
  private VerificadorTokenFirebaseAuth tokenVerifier;

  @Test
  void meRejectsMissingToken() throws Exception {
    mockMvc.perform(get("/api/v1/me"))
        .andExpect(status().isUnauthorized())
        .andExpect(jsonPath("$.error", is("unauthenticated")))
        .andExpect(jsonPath("$.message", is("Autenticacao obrigatoria.")));
  }

  @Test
  void meRejectsInvalidToken() throws Exception {
    when(tokenVerifier.verificar(anyString())).thenThrow(new RuntimeException("invalid"));

    mockMvc.perform(get("/api/v1/me").header("Authorization", "Bearer invalid-token"))
        .andExpect(status().isUnauthorized())
        .andExpect(jsonPath("$.error", is("unauthenticated")));
  }

  @Test
  void meReturnsUsuarioAutenticado() throws Exception {
    when(tokenVerifier.verificar("valid-token"))
        .thenReturn(new UsuarioAutenticado("user-1", "user@example.com"));

    mockMvc.perform(get("/api/v1/me").header("Authorization", "Bearer valid-token"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.uid", is("user-1")))
        .andExpect(jsonPath("$.email", is("user@example.com")));
  }
}
