package app.ascend.backend.build;

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
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(BuildController.class)
@Import({FiltroAutenticacao.class, ResolvedorArgumentoUsuarioAutenticado.class, ConfiguracaoWeb.class})
class BuildControllerTest {
  @Autowired private MockMvc mockMvc;
  @MockitoBean private VerificadorTokenFirebaseAuth tokens;
  @MockitoBean private BuildService service;

  @Test void exigeAutenticacao() throws Exception {
    mockMvc.perform(get("/api/v1/build")).andExpect(status().isUnauthorized());
  }

  @Test void encaminhaEscolhaAutenticada() throws Exception {
    when(tokens.verificar("token")).thenReturn(new UsuarioAutenticado("u1", "u@a.com"));
    when(service.selecionar(eq("u1"), any())).thenReturn(new RespostaBuild("estrategista", List.of("rota-clara"), false));
    mockMvc.perform(post("/api/v1/build/select").header("Authorization", "Bearer token")
        .contentType(MediaType.APPLICATION_JSON).content("{\"buildId\":\"estrategista\",\"deviceSessionId\":\"d1\"}"))
        .andExpect(status().isOk()).andExpect(jsonPath("$.buildId", is("estrategista")))
        .andExpect(jsonPath("$.talentosDesbloqueados[0]", is("rota-clara")));
  }
}
