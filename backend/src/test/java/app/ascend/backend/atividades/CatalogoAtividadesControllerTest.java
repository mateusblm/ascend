package app.ascend.backend.atividades;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
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
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(CatalogoAtividadesController.class)
@Import({FiltroAutenticacao.class, ResolvedorArgumentoUsuarioAutenticado.class, ConfiguracaoWeb.class})
class CatalogoAtividadesControllerTest {
  @Autowired private MockMvc mockMvc;
  @MockitoBean private VerificadorTokenFirebaseAuth tokens;
  @MockitoBean private CatalogoAtividadesService service;

  @Test void exigeAutenticacao() throws Exception {
    mockMvc.perform(get("/api/v1/activity-catalog")).andExpect(status().isUnauthorized());
  }

  @Test void retornaCatalogoAutenticado() throws Exception {
    when(tokens.verificar("token")).thenReturn(new UsuarioAutenticado("u1", "u@a.com"));
    when(service.consultar()).thenReturn(new CatalogoAtividadesService().consultar());

    mockMvc.perform(get("/api/v1/activity-catalog").header("Authorization", "Bearer token"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.versao").value(1))
        .andExpect(jsonPath("$.categorias[0].id").value("corpoMovimento"));
  }
}
