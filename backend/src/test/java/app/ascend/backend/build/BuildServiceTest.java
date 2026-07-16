package app.ascend.backend.build;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.times;
import static org.mockito.ArgumentMatchers.startsWith;
import static org.mockito.ArgumentMatchers.eq;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.jdbc.core.JdbcTemplate;

class BuildServiceTest {
  @Test void servicoEInstanciadoPeloSpringComAsDependenciasObrigatorias() {
    JdbcTemplate jdbc = Mockito.mock(JdbcTemplate.class);
    GuardaSessaoAtiva sessoes = Mockito.mock(GuardaSessaoAtiva.class);

    try (AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext()) {
      context.registerBean(JdbcTemplate.class, () -> jdbc);
      context.registerBean(GuardaSessaoAtiva.class, () -> sessoes);
      context.register(BuildService.class);
      context.refresh();

      assertNotNull(context.getBean(BuildService.class));
    }
  }

  @Test void escolhaExigeSessaoAtivaAntesDeConsultarOuGravar() {
    JdbcTemplate jdbc = Mockito.mock(JdbcTemplate.class);
    GuardaSessaoAtiva sessoes = Mockito.mock(GuardaSessaoAtiva.class);
    BuildService service = new BuildService(jdbc, sessoes);

    ExcecaoApi erro = assertThrows(ExcecaoApi.class,
        () -> service.selecionar("u1", new RequisicaoBuild("estrategista", "")));

    assertEquals("sessao_obrigatoria", erro.codigo());
    Mockito.verifyNoInteractions(jdbc, sessoes);
  }

  @Test void buildIndisponivelNaoESelecionadaMesmoComSessaoValida() {
    JdbcTemplate jdbc = Mockito.mock(JdbcTemplate.class);
    GuardaSessaoAtiva sessoes = Mockito.mock(GuardaSessaoAtiva.class);
    BuildService service = new BuildService(jdbc, sessoes);

    ExcecaoApi erro = assertThrows(ExcecaoApi.class,
        () -> service.selecionar("u1", new RequisicaoBuild("inexistente", "d1")));

    verify(sessoes).exigirSessaoAtiva("u1", "d1");
    assertEquals("build_indisponivel", erro.codigo());
    Mockito.verifyNoInteractions(jdbc);
  }

  @Test void pontoDaRevisaoEConcedidoUmaUnicaVezPeloRegistroCanonico() {
    JdbcTemplate jdbc = Mockito.mock(JdbcTemplate.class);
    BuildService service = new BuildService(jdbc, Mockito.mock(GuardaSessaoAtiva.class));
    Mockito.when(jdbc.update(startsWith("insert into concessoes_pontos_talento"), eq("u1"), eq("2026-07-13")))
        .thenReturn(1);

    service.concederPontoPorRevisaoSemanal("u1", "2026-07-13");

    verify(jdbc).update(startsWith("insert into concessoes_pontos_talento"), eq("u1"), eq("2026-07-13"));
    verify(jdbc, times(1)).update(startsWith("insert into pontos_talento_usuario"), eq("u1"));
  }

  @Test void concessaoIdempotenteNaoDuplicaPonto() {
    JdbcTemplate jdbc = Mockito.mock(JdbcTemplate.class);
    BuildService service = new BuildService(jdbc, Mockito.mock(GuardaSessaoAtiva.class));
    Mockito.when(jdbc.update(startsWith("insert into concessoes_pontos_talento"), eq("u1"), eq("2026-07-13")))
        .thenReturn(0);

    service.concederPontoPorRevisaoSemanal("u1", "2026-07-13");

    verify(jdbc, Mockito.never()).update(startsWith("insert into pontos_talento_usuario"), eq("u1"));
  }
}
