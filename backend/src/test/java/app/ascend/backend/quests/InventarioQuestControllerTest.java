package app.ascend.backend.quests;

import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import app.ascend.backend.autenticacao.ResolvedorArgumentoUsuarioAutenticado;
import app.ascend.backend.autenticacao.FiltroAutenticacao;
import app.ascend.backend.autenticacao.VerificadorTokenFirebaseAuth;
import app.ascend.backend.configuracao.ConfiguracaoWeb;
import app.ascend.backend.compartilhado.TratadorExcecoesApi;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(InventarioQuestController.class)
@Import({
    FiltroAutenticacao.class,
    ResolvedorArgumentoUsuarioAutenticado.class,
    ConfiguracaoWeb.class,
    TratadorExcecoesApi.class
})
class InventarioQuestControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @MockitoBean
  private VerificadorTokenFirebaseAuth tokenVerifier;

  @MockitoBean
  private SincronizacaoInventarioQuestService service;

  @Test
  void sincronizarInventarioRequerAutenticacao() throws Exception {
    mockMvc.perform(post("/api/v1/quests/inventory:sync")
            .contentType("application/json")
            .content("{}"))
        .andExpect(status().isUnauthorized());
  }

  @Test
  void sincronizarInventarioRetornaStatusNoContratoPublico() throws Exception {
    when(tokenVerifier.verificar("valid-token"))
        .thenReturn(new UsuarioAutenticado("user-1", "user@example.com"));
    when(service.sincronizarInventario(eq("user-1"), any()))
        .thenReturn(new RespostaSincronizacaoInventarioQuest("synced", 1));

    mockMvc.perform(post("/api/v1/quests/inventory:sync")
            .header("Authorization", "Bearer valid-token")
            .contentType("application/json")
            .content("""
                {
                  "deviceSessionId": "device-1",
                  "source": {"quests": []}
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is("synced")))
        .andExpect(jsonPath("$.questCount", is(1)));
  }
}
