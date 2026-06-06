package app.ascend.backend.competitivo;

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
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(EstadoCompetitivoController.class)
@Import({
    FiltroAutenticacao.class,
    ResolvedorArgumentoUsuarioAutenticado.class,
    ConfiguracaoWeb.class,
    TratadorExcecoesApi.class
})
class EstadoCompetitivoControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @MockitoBean
  private VerificadorTokenFirebaseAuth tokenVerifier;

  @MockitoBean
  private PreviewEstadoCompetitivoService service;

  @Test
  void previewEstadoCompetitivoRequerAutenticacao() throws Exception {
    mockMvc.perform(post("/api/v1/competitive/state:preview")
            .contentType("application/json")
            .content("{}"))
        .andExpect(status().isUnauthorized());
  }

  @Test
  void previewEstadoCompetitivoRetornaContratoPublico() throws Exception {
    when(tokenVerifier.verificar("valid-token"))
        .thenReturn(new UsuarioAutenticado("user-1", "user@example.com"));
    when(service.prever(any()))
        .thenReturn(new RespostaPreviewEstadoCompetitivo(
            "preview",
            new SnapshotRankCompetitivo(
                "D",
                "D",
                "C",
                "2026W0608",
                5,
                4,
                false,
                true,
                "promotionReady",
                0,
                true,
                "C",
                10,
                true,
                "ascension",
                "promotionUnlocked",
                "Exame de promocao pronto para o rank C.",
                "Detalhe",
                3,
                "backend",
                Instant.parse("2026-06-10T12:00:00Z")
            ),
            new SnapshotIntegridadeCompetitiva(
                "2026W0608",
                90,
                "high",
                5,
                5,
                1,
                1,
                10,
                20,
                0,
                "Integridade alta",
                "Detalhe",
                3,
                "backend",
                Instant.parse("2026-06-10T12:00:00Z")
            )
        ));

    mockMvc.perform(post("/api/v1/competitive/state:preview")
            .header("Authorization", "Bearer valid-token")
            .contentType("application/json")
            .content("""
                {
                  "rankSource": {
                    "playerLevel": 10,
                    "competitiveActivityHistory": []
                  },
                  "integritySource": {
                    "activityHistory": [],
                    "competitiveActivityHistory": [],
                    "quests": []
                  }
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is("preview")))
        .andExpect(jsonPath("$.rankSnapshot.currentRank", is("D")))
        .andExpect(jsonPath("$.rankSnapshot.status", is("promotionReady")))
        .andExpect(jsonPath("$.rankSnapshot.syncSource", is("backend")))
        .andExpect(jsonPath("$.integritySnapshot.trustBand", is("high")))
        .andExpect(jsonPath("$.integritySnapshot.syncSchemaVersion", is(3)));
  }

  @Test
  void sincronizarEstadoCompetitivoRetornaContratoPublico() throws Exception {
    when(tokenVerifier.verificar("valid-token"))
        .thenReturn(new UsuarioAutenticado("user-1", "user@example.com"));
    when(service.sincronizar(eq("user-1"), any()))
        .thenReturn(new RespostaSincronizacaoEstadoCompetitivo(
            "synced",
            new SnapshotRankCompetitivo(
                "E",
                "E",
                "E",
                "2026W0608",
                3,
                3,
                false,
                true,
                "secure",
                0,
                false,
                "D",
                5,
                false,
                "ascension",
                "routine",
                "Rank E estabilizado.",
                "Detalhe",
                3,
                "backend",
                Instant.parse("2026-06-10T12:00:00Z")
            ),
            null
        ));

    mockMvc.perform(post("/api/v1/competitive/state:sync")
            .header("Authorization", "Bearer valid-token")
            .contentType("application/json")
            .content("""
                {
                  "rankSource": {
                    "playerLevel": 1,
                    "activityHistory": [],
                    "competitiveActivityHistory": []
                  }
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is("synced")))
        .andExpect(jsonPath("$.rankSnapshot.currentRank", is("E")))
        .andExpect(jsonPath("$.rankSnapshot.syncSource", is("backend")));
  }
}
