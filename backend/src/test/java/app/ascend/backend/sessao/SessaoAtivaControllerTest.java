package app.ascend.backend.sessao;

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
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(SessaoAtivaController.class)
@Import({FiltroAutenticacao.class, ResolvedorArgumentoUsuarioAutenticado.class, ConfiguracaoWeb.class})
class SessaoAtivaControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @MockitoBean
  private VerificadorTokenFirebaseAuth tokenVerifier;

  @MockitoBean
  private SessaoAtivaService service;

  @Test
  void registrarRequerAutenticacao() throws Exception {
    mockMvc.perform(post("/api/v1/session/active:register")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{}"))
        .andExpect(status().isUnauthorized())
        .andExpect(jsonPath("$.error", is("unauthenticated")));
  }

  @Test
  void registrarRetornaLease() throws Exception {
    when(tokenVerifier.verificar("valid-token"))
        .thenReturn(new UsuarioAutenticado("user-1", "mateus@example.com"));
    when(service.registrar(eq("user-1"), any(RequisicaoSessaoAtiva.class)))
        .thenReturn(new RespostaRegistroSessaoAtiva(
            "registered",
            "2026-06-07T12:05:00Z"
        ));

    mockMvc.perform(post("/api/v1/session/active:register")
            .header("Authorization", "Bearer valid-token")
            .contentType(MediaType.APPLICATION_JSON)
            .content("""
                {
                  "deviceSessionId": "device-1",
                  "deviceLabel": "android"
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is("registered")))
        .andExpect(jsonPath("$.expiresAt", is("2026-06-07T12:05:00Z")));
  }

  @Test
  void liberarRetornaStatusIdempotente() throws Exception {
    when(tokenVerifier.verificar("valid-token"))
        .thenReturn(new UsuarioAutenticado("user-1", "mateus@example.com"));
    when(service.liberar(eq("user-1"), any(RequisicaoSessaoAtiva.class)))
        .thenReturn(new RespostaLiberacaoSessaoAtiva("released"));

    mockMvc.perform(post("/api/v1/session/active:release")
            .header("Authorization", "Bearer valid-token")
            .contentType(MediaType.APPLICATION_JSON)
            .content("""
                {
                  "deviceSessionId": "device-1",
                  "deviceLabel": "android"
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is("released")));
  }
}
