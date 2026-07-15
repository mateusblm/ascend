package app.ascend.backend.ascensao;

import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
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

@WebMvcTest(ProvaAscensaoController.class)
@Import({FiltroAutenticacao.class, ResolvedorArgumentoUsuarioAutenticado.class, ConfiguracaoWeb.class})
class ProvaAscensaoControllerTest {
  @Autowired private MockMvc mockMvc;
  @MockitoBean private VerificadorTokenFirebaseAuth tokenVerifier;
  @MockitoBean private ProvaAscensaoService service;

  @Test
  void statusRequerAutenticacao() throws Exception {
    mockMvc.perform(get("/api/v1/ascension/status"))
        .andExpect(status().isUnauthorized())
        .andExpect(jsonPath("$.error", is("unauthenticated")));
  }

  @Test
  void statusEClaimUsamUsuarioAutenticado() throws Exception {
    when(tokenVerifier.verificar("valid-token"))
        .thenReturn(new UsuarioAutenticado("user-1", "mateus@example.com"));
    when(service.consultar("user-1", "mateus@example.com")).thenReturn(resposta("available"));
    when(service.resgatar(eq("user-1"), eq("mateus@example.com"), any(RequisicaoResgateProvaAscensao.class)))
        .thenReturn(resposta("claimed"));

    mockMvc.perform(get("/api/v1/ascension/status").header("Authorization", "Bearer valid-token"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.prova.estado", is("available")))
        .andExpect(jsonPath("$.patamar.sigla", is("F")))
        .andExpect(jsonPath("$.legado.length()", is(0)));

    mockMvc.perform(post("/api/v1/ascension/trials/consistent-rhythm:claim")
            .header("Authorization", "Bearer valid-token")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{\"deviceSessionId\":\"device-1\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.prova.estado", is("claimed")));
  }

  private RespostaAscensao resposta(String estado) {
    return new RespostaAscensao(new ProvaAscensao(
        "ritmo-constante", "Ritmo Constante", "Cinco dias ativos.", 5, 5, estado,
        new TalentoAscensao("ritmo-constante", "Ritmo Constante", "Título permanente.")
    ), new PatamarAscensao("F", "Iniciante", 1), java.util.List.of());
  }
}
