package app.ascend.backend.quiz;

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
import java.time.Instant;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(QuizLeituraController.class)
@Import({
    FiltroAutenticacao.class,
    ResolvedorArgumentoUsuarioAutenticado.class,
    ConfiguracaoWeb.class,
    TratadorExcecoesApi.class
})
class QuizLeituraControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @MockitoBean
  private VerificadorTokenFirebaseAuth tokenVerifier;

  @MockitoBean
  private InicioQuizLeituraService service;

  @Test
  void tentativaRequerAutenticacao() throws Exception {
    mockMvc.perform(post("/api/v1/reading-quiz:attempt")
            .contentType("application/json")
            .content("{}"))
        .andExpect(status().isUnauthorized());
  }

  @Test
  void tentativaRetornaContratoPublico() throws Exception {
    when(tokenVerifier.verificar("valid-token"))
        .thenReturn(new UsuarioAutenticado("user-1", "user@example.com"));
    when(service.iniciar(eq("user-1"), any()))
        .thenReturn(new RespostaInicioQuizLeitura(
            "quiz-1",
            "reading-20-123",
            "Livro",
            70,
            "deterministic_contract_v1",
            Instant.parse("2026-06-07T10:00:00Z"),
            Instant.parse("2026-06-07T12:00:00Z"),
            List.of(new PerguntaPublicaQuizLeitura("main-idea", "Pergunta publica"))
        ));

    mockMvc.perform(post("/api/v1/reading-quiz:attempt")
            .header("Authorization", "Bearer valid-token")
            .contentType("application/json")
            .content("""
                {
                  "deviceSessionId": "device-1",
                  "questId": "reading-20-123",
                  "templateCatalogId": "reading-20",
                  "topic": "Livro"
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.quizId", is("quiz-1")))
        .andExpect(jsonPath("$.minimumScore", is(70)))
        .andExpect(jsonPath("$.questions[0].id", is("main-idea")))
        .andExpect(jsonPath("$.questions[0].prompt", is("Pergunta publica")));
  }
}
