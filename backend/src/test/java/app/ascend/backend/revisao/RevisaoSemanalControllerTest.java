package app.ascend.backend.revisao;

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

@WebMvcTest(RevisaoSemanalController.class)
@Import({FiltroAutenticacao.class, ResolvedorArgumentoUsuarioAutenticado.class, ConfiguracaoWeb.class})
class RevisaoSemanalControllerTest {
  @Autowired private MockMvc mockMvc;
  @MockitoBean private VerificadorTokenFirebaseAuth tokenVerifier;
  @MockitoBean private RevisaoSemanalService service;

  @Test
  void revisaoRequerAutenticacao() throws Exception {
    mockMvc.perform(get("/api/v1/weekly-review"))
        .andExpect(status().isUnauthorized())
        .andExpect(jsonPath("$.error", is("unauthenticated")));
  }

  @Test
  void consultaEConfirmacaoUsamIdentidadeAutenticada() throws Exception {
    when(tokenVerifier.verificar("valid-token"))
        .thenReturn(new UsuarioAutenticado("user-1", "mateus@example.com"));
    when(service.consultar("user-1", "mateus@example.com")).thenReturn(resposta(false));
    when(service.confirmar(eq("user-1"), eq("mateus@example.com"),
        any(RequisicaoConfirmacaoRevisaoSemanal.class))).thenReturn(resposta(true));

    mockMvc.perform(get("/api/v1/weekly-review").header("Authorization", "Bearer valid-token"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.statusBoss", is("ready")));

    mockMvc.perform(post("/api/v1/weekly-review/confirm")
            .header("Authorization", "Bearer valid-token")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{\"deviceSessionId\":\"device-1\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.confirmada", is(true)));
  }

  private RespostaRevisaoSemanal resposta(boolean confirmada) {
    return new RespostaRevisaoSemanal("2026-07-13", 4, 4, "ready", confirmada,
        "O objetivo semanal esta pronto para ser resgatado.");
  }
}
