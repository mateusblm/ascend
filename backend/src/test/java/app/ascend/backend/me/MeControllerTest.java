package app.ascend.backend.me;

import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import app.ascend.backend.auth.AuthenticatedUser;
import app.ascend.backend.auth.AuthenticatedUserArgumentResolver;
import app.ascend.backend.auth.AuthenticationFilter;
import app.ascend.backend.auth.FirebaseAuthTokenVerifier;
import app.ascend.backend.config.WebConfig;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.context.annotation.Import;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(MeController.class)
@Import({AuthenticationFilter.class, AuthenticatedUserArgumentResolver.class, WebConfig.class})
class MeControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @MockitoBean
  private FirebaseAuthTokenVerifier tokenVerifier;

  @Test
  void meRejectsMissingToken() throws Exception {
    mockMvc.perform(get("/api/v1/me"))
        .andExpect(status().isUnauthorized())
        .andExpect(jsonPath("$.error", is("unauthenticated")));
  }

  @Test
  void meRejectsInvalidToken() throws Exception {
    when(tokenVerifier.verify(anyString())).thenThrow(new RuntimeException("invalid"));

    mockMvc.perform(get("/api/v1/me").header("Authorization", "Bearer invalid-token"))
        .andExpect(status().isUnauthorized())
        .andExpect(jsonPath("$.error", is("unauthenticated")));
  }

  @Test
  void meReturnsAuthenticatedUser() throws Exception {
    when(tokenVerifier.verify("valid-token"))
        .thenReturn(new AuthenticatedUser("user-1", "user@example.com"));

    mockMvc.perform(get("/api/v1/me").header("Authorization", "Bearer valid-token"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.uid", is("user-1")))
        .andExpect(jsonPath("$.email", is("user@example.com")));
  }
}
