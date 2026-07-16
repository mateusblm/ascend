package app.ascend.backend.revisao;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import app.ascend.backend.build.BuildService;
import app.ascend.backend.perfil.RepositorioPostgresPerfil;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import com.google.cloud.Timestamp;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

@ExtendWith(MockitoExtension.class)
class RevisaoSemanalServiceTest {
  @Mock private RepositorioPostgresPerfil perfis;
  @Mock private RepositorioRevisaoSemanal revisoes;
  @Mock private GuardaSessaoAtiva guardaSessaoAtiva;
  @Mock private BuildService builds;
  private RevisaoSemanalService service;

  @BeforeEach
  void preparar() {
    service = new RevisaoSemanalService(
        perfis, revisoes, guardaSessaoAtiva, builds,
        Clock.fixed(Instant.parse("2026-07-15T12:00:00Z"), ZoneOffset.UTC));
  }

  @Test
  void resumoUsaSomenteDiasAtivosDoPerfilCanonico() {
    when(perfis.buscarPerfil("uid-1")).thenReturn(perfilComDias(4));
    when(revisoes.confirmada("uid-1", java.time.LocalDate.parse("2026-07-13")))
        .thenReturn(false);

    RespostaRevisaoSemanal resposta = service.consultar("uid-1", "Jogador");

    assertEquals("2026-07-13", resposta.chaveSemana());
    assertEquals(4, resposta.diasAtivos());
    assertEquals("ready", resposta.statusBoss());
    assertEquals(false, resposta.confirmada());
  }

  @Test
  void confirmacaoExigeSessaoEPermaneceConfirmadaMesmoQuandoIdempotente() {
    when(perfis.buscarPerfil("uid-1")).thenReturn(perfilComDias(2));
    when(revisoes.registrarConfirmacao("uid-1", java.time.LocalDate.parse("2026-07-13")))
        .thenReturn(false);

    RespostaRevisaoSemanal resposta = service.confirmar(
        "uid-1", "Jogador", new RequisicaoConfirmacaoRevisaoSemanal("device-1"));

    verify(guardaSessaoAtiva).exigirSessaoAtiva("uid-1", "device-1");
    verify(revisoes).registrarConfirmacao("uid-1", java.time.LocalDate.parse("2026-07-13"));
    assertEquals(true, resposta.confirmada());
    assertEquals("in_progress", resposta.statusBoss());
  }

  @Test
  void springInstanciaServicoComDependenciasDeProducao() {
    try (AnnotationConfigApplicationContext contexto = new AnnotationConfigApplicationContext()) {
      contexto.registerBean(RepositorioPostgresPerfil.class,
          () -> org.mockito.Mockito.mock(RepositorioPostgresPerfil.class));
      contexto.registerBean(RepositorioRevisaoSemanal.class,
          () -> org.mockito.Mockito.mock(RepositorioRevisaoSemanal.class));
      contexto.registerBean(GuardaSessaoAtiva.class,
          () -> org.mockito.Mockito.mock(GuardaSessaoAtiva.class));
      contexto.registerBean(BuildService.class,
          () -> org.mockito.Mockito.mock(BuildService.class));
      contexto.registerBean(RevisaoSemanalService.class);
      contexto.refresh();
      org.junit.jupiter.api.Assertions.assertNotNull(contexto.getBean(RevisaoSemanalService.class));
    }
  }

  private Map<String, Object> perfilComDias(int quantidade) {
    List<Timestamp> dias = java.util.stream.IntStream.range(0, quantidade)
        .mapToObj(indice -> Timestamp.ofTimeSecondsAndNanos(
            Instant.parse("2026-07-13T12:00:00Z").plusSeconds(indice * 86_400L).getEpochSecond(), 0))
        .toList();
    return Map.of("name", "Jogador", "activityHistory", dias, "maxXp", 100);
  }
}
