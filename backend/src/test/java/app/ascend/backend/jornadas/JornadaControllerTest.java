package app.ascend.backend.jornadas;

import static org.hamcrest.Matchers.hasSize;
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
import java.time.Instant;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(JornadaController.class)
@Import({FiltroAutenticacao.class, ResolvedorArgumentoUsuarioAutenticado.class, ConfiguracaoWeb.class})
class JornadaControllerTest {

  @Autowired private MockMvc mockMvc;

  @MockitoBean private VerificadorTokenFirebaseAuth tokenVerifier;
  @MockitoBean private JornadaService service;

  @Test
  void listarRequerAutenticacao() throws Exception {
    mockMvc.perform(get("/api/v1/journeys"))
        .andExpect(status().isUnauthorized())
        .andExpect(jsonPath("$.error", is("unauthenticated")));
  }

  @Test
  void criarRetornaJornadaDoUsuarioAutenticado() throws Exception {
    configurarUsuario();
    when(service.criar(eq("user-1"), any(RequisicaoCriacaoJornada.class))).thenReturn(jornadaAtiva());

    mockMvc.perform(post("/api/v1/journeys")
            .header("Authorization", "Bearer valid-token")
            .contentType(MediaType.APPLICATION_JSON)
            .content("""
                {"titulo":"Concluir TCC","objetivo":"Entregar a versao final","motivacao":"Abrir novas oportunidades"}
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.titulo", is("Concluir TCC")))
        .andExpect(jsonPath("$.status", is("ativa")));
  }

  @Test
  void listarRetornaApenasJornadasDoUsuarioAutenticado() throws Exception {
    configurarUsuario();
    when(service.listar("user-1")).thenReturn(List.of(jornadaAtiva()));

    mockMvc.perform(get("/api/v1/journeys").header("Authorization", "Bearer valid-token"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$", hasSize(1)))
        .andExpect(jsonPath("$[0].objetivo", is("Entregar a versao final")));
  }

  @Test
  void listarMarcosRetornaRotaDoCapituloAutenticado() throws Exception {
    configurarUsuario();
    when(service.listarMarcos("user-1", "capitulo-1")).thenReturn(List.of(
        new MarcoCapitulo("marco-1", "Enviar versao", null, false, 0)));

    mockMvc.perform(get("/api/v1/journeys/chapters/capitulo-1/milestones")
            .header("Authorization", "Bearer valid-token"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$", hasSize(1)))
        .andExpect(jsonPath("$[0].titulo", is("Enviar versao")));
  }

  @Test
  void criarMarcoUsaUsuarioAutenticado() throws Exception {
    configurarUsuario();
    when(service.adicionarMarco(eq("user-1"), eq("capitulo-1"), any(RequisicaoCriacaoMarco.class)))
        .thenReturn(new MarcoCapitulo("marco-1", "Enviar versao", null, false, 0));

    mockMvc.perform(post("/api/v1/journeys/chapters/capitulo-1/milestones")
            .header("Authorization", "Bearer valid-token")
            .contentType(MediaType.APPLICATION_JSON).content("{\"titulo\":\"Enviar versao\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.indiceOrdem", is(0)));
  }

  @Test
  void concluirMarcoUsaUsuarioAutenticado() throws Exception {
    configurarUsuario();
    when(service.concluirMarco("user-1", "marco-1"))
        .thenReturn(new MarcoCapitulo("marco-1", "Enviar versao", null, true, 0));

    mockMvc.perform(post("/api/v1/journeys/milestones/marco-1/complete")
            .header("Authorization", "Bearer valid-token")
            .contentType(MediaType.APPLICATION_JSON).content("{}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.concluido", is(true)));
  }

  private void configurarUsuario() {
    when(tokenVerifier.verificar("valid-token"))
        .thenReturn(new UsuarioAutenticado("user-1", "mateus@example.com"));
  }

  private Jornada jornadaAtiva() {
    return new Jornada(
        "journey-1", "Concluir TCC", "Entregar a versao final",
        "Abrir novas oportunidades", StatusJornada.ativa,
        Instant.parse("2026-07-14T00:00:00Z")
    );
  }
}
