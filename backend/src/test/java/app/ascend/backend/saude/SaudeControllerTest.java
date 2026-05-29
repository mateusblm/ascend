package app.ascend.backend.saude;

import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import app.ascend.backend.autenticacao.VerificadorTokenFirebaseAuth;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(SaudeController.class)
class SaudeControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @MockitoBean
  private VerificadorTokenFirebaseAuth tokenVerifier;

  @Test
  void healthReturnsOk() throws Exception {
    mockMvc.perform(get("/health"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is("ok")))
        .andExpect(jsonPath("$.service", is("ascend-backend")));
  }
}
