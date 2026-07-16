package app.ascend.backend.atividades;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import app.ascend.backend.quests.MutacaoQuestPessoalService;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.jdbc.core.JdbcTemplate;

class ExecucaoAtividadeServiceTest {
  @Test void exigeMetricaObrigatoriaAntesDePersistir() {
    JdbcTemplate jdbc = Mockito.mock(JdbcTemplate.class);
    GuardaSessaoAtiva sessoes = Mockito.mock(GuardaSessaoAtiva.class);
    ExecucaoAtividadeService service = new ExecucaoAtividadeService(jdbc, sessoes, new CatalogoAtividadesService(), Mockito.mock(MutacaoQuestPessoalService.class));

    ExcecaoApi erro = assertThrows(ExcecaoApi.class, () -> service.registrar("u1",
        new RequisicaoExecucaoAtividade("d1", "e1", "q1", "supino-reto", "strengthSets", 1, Map.of("loadKg", 50), null)));

    verify(sessoes).exigirSessaoAtiva("u1", "d1");
    assertEquals("required_activity_metric", erro.codigo());
    Mockito.verifyNoInteractions(jdbc);
  }

  @Test void rejeitaModeloQueNaoCorrespondeAoCatalogo() {
    ExecucaoAtividadeService service = new ExecucaoAtividadeService(Mockito.mock(JdbcTemplate.class),
        Mockito.mock(GuardaSessaoAtiva.class), new CatalogoAtividadesService(), Mockito.mock(MutacaoQuestPessoalService.class));

    ExcecaoApi erro = assertThrows(ExcecaoApi.class, () -> service.registrar("u1",
        new RequisicaoExecucaoAtividade("d1", "e1", "q1", "corrida-livre", "strengthSets", 1, Map.of(), null)));

    assertEquals("invalid_activity_contract", erro.codigo());
  }

  @Test void calculaVolumeEUmRmAPartirDasSeries() {
    JdbcTemplate jdbc = Mockito.mock(JdbcTemplate.class);
    when(jdbc.queryForObject(Mockito.anyString(), Mockito.eq(Boolean.class), Mockito.any(), Mockito.any())).thenReturn(true);
    when(jdbc.update(Mockito.anyString(), Mockito.any(), Mockito.any(), Mockito.any(), Mockito.any(), Mockito.any(), Mockito.any(), Mockito.any(), Mockito.any())).thenReturn(1);
    ExecucaoAtividadeService service = new ExecucaoAtividadeService(jdbc, Mockito.mock(GuardaSessaoAtiva.class), new CatalogoAtividadesService(), Mockito.mock(MutacaoQuestPessoalService.class));
    var resposta = service.registrar("u1", new RequisicaoExecucaoAtividade("d1", "e1", "q1", "supino-reto", "strengthSets", 1,
        Map.of("sets", java.util.List.of(Map.of("loadKg", 60, "repetitions", 8), Map.of("loadKg", 55, "repetitions", 10))), null));
    assertEquals(1030d, resposta.calculatedMetrics().get("volumeKg"));
    assertEquals(76d, resposta.calculatedMetrics().get("estimatedOneRepMaxKg"));
  }

  @Test void rejeitaSerieComRepeticoesInvalidas() {
    ExecucaoAtividadeService service = new ExecucaoAtividadeService(Mockito.mock(JdbcTemplate.class),
        Mockito.mock(GuardaSessaoAtiva.class), new CatalogoAtividadesService(), Mockito.mock(MutacaoQuestPessoalService.class));

    ExcecaoApi erro = assertThrows(ExcecaoApi.class, () -> service.registrar("u1",
        new RequisicaoExecucaoAtividade("d1", "e1", "q1", "supino-reto", "strengthSets", 1,
            Map.of("sets", java.util.List.of(Map.of("loadKg", 60, "repetitions", 0))), null)));

    assertEquals("invalid_strength_set", erro.codigo());
  }

  @Test void rejeitaAcertosAcimaDasQuestoes() {
    ExecucaoAtividadeService service = new ExecucaoAtividadeService(Mockito.mock(JdbcTemplate.class),
        Mockito.mock(GuardaSessaoAtiva.class), new CatalogoAtividadesService(), Mockito.mock(MutacaoQuestPessoalService.class));

    ExcecaoApi erro = assertThrows(ExcecaoApi.class, () -> service.registrar("u1",
        new RequisicaoExecucaoAtividade("d1", "e1", "q1", "estudo-livre", "studySession", 1,
            Map.of("durationMinutes", 30, "questionsAnswered", 8, "correctAnswers", 9, "topic", "Java"), null)));

    assertEquals("invalid_study_answers", erro.codigo());
  }
}
