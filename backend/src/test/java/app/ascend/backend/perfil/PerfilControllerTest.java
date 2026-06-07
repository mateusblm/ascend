package app.ascend.backend.perfil;

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

@WebMvcTest(PerfilController.class)
@Import({FiltroAutenticacao.class, ResolvedorArgumentoUsuarioAutenticado.class, ConfiguracaoWeb.class})
class PerfilControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @MockitoBean
  private VerificadorTokenFirebaseAuth tokenVerifier;

  @MockitoBean
  private MutacaoPerfilService service;

  @Test
  void atualizarConfiguracoesRequerAutenticacao() throws Exception {
    mockMvc.perform(post("/api/v1/profile/settings:update")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{}"))
        .andExpect(status().isUnauthorized())
        .andExpect(jsonPath("$.error", is("unauthenticated")));
  }

  @Test
  void atualizarConfiguracoesRetornaPerfilAtualizado() throws Exception {
    when(tokenVerifier.verificar("valid-token"))
        .thenReturn(new UsuarioAutenticado("user-1", "mateus@example.com"));
    when(service.atualizarConfiguracoes(
        eq("user-1"),
        eq("mateus@example.com"),
        any(RequisicaoAtualizacaoPerfil.class)
    )).thenReturn(new RespostaPerfil("updated", Map.of("name", "Mateus")));

    mockMvc.perform(post("/api/v1/profile/settings:update")
            .header("Authorization", "Bearer valid-token")
            .contentType(MediaType.APPLICATION_JSON)
            .content("""
                {
                  "deviceSessionId": "device-1",
                  "deviceLabel": "android",
                  "name": "Mateus",
                  "primaryFocus": "study",
                  "hasCompletedOnboarding": true,
                  "lastResetDate": "2026-06-07T00:00:00Z"
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is("updated")))
        .andExpect(jsonPath("$.profile.name", is("Mateus")));
  }

  @Test
  void alocarAtributoRetornaPerfilAtualizado() throws Exception {
    when(tokenVerifier.verificar("valid-token"))
        .thenReturn(new UsuarioAutenticado("user-1", "mateus@example.com"));
    when(service.alocarPonto(
        eq("user-1"),
        eq("mateus@example.com"),
        any(RequisicaoAlocacaoAtributo.class)
    )).thenReturn(new RespostaPerfil("allocated", Map.of("statPoints", 0)));

    mockMvc.perform(post("/api/v1/profile/attributes:allocate")
            .header("Authorization", "Bearer valid-token")
            .contentType(MediaType.APPLICATION_JSON)
            .content("""
                {
                  "deviceSessionId": "device-1",
                  "deviceLabel": "android",
                  "attribute": "strength"
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is("allocated")))
        .andExpect(jsonPath("$.profile.statPoints", is(0)));
  }
}
