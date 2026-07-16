package app.ascend.backend.atividades;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.jdbc.core.JdbcTemplate;

class ExecucaoAtividadeServiceTest {
  @Test void exigeMetricaObrigatoriaAntesDePersistir() {
    JdbcTemplate jdbc = Mockito.mock(JdbcTemplate.class);
    GuardaSessaoAtiva sessoes = Mockito.mock(GuardaSessaoAtiva.class);
    ExecucaoAtividadeService service = new ExecucaoAtividadeService(jdbc, sessoes, new CatalogoAtividadesService());

    ExcecaoApi erro = assertThrows(ExcecaoApi.class, () -> service.registrar("u1",
        new RequisicaoExecucaoAtividade("d1", "e1", "q1", "supino-reto", "strengthSets", 1, Map.of("loadKg", 50), null)));

    verify(sessoes).exigirSessaoAtiva("u1", "d1");
    assertEquals("required_activity_metric", erro.codigo());
    Mockito.verifyNoInteractions(jdbc);
  }

  @Test void rejeitaModeloQueNaoCorrespondeAoCatalogo() {
    ExecucaoAtividadeService service = new ExecucaoAtividadeService(Mockito.mock(JdbcTemplate.class),
        Mockito.mock(GuardaSessaoAtiva.class), new CatalogoAtividadesService());

    ExcecaoApi erro = assertThrows(ExcecaoApi.class, () -> service.registrar("u1",
        new RequisicaoExecucaoAtividade("d1", "e1", "q1", "corrida-livre", "strengthSets", 1, Map.of(), null)));

    assertEquals("invalid_activity_contract", erro.codigo());
  }
}
