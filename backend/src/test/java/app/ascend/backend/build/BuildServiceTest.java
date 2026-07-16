package app.ascend.backend.build;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.verify;

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
}
