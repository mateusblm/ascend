package app.ascend.backend.ascensao;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import app.ascend.backend.compartilhado.ExcecaoApi;
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

@ExtendWith(MockitoExtension.class)
class ProvaAscensaoServiceTest {
  @Mock private RepositorioPostgresPerfil perfis;
  @Mock private RepositorioProvasAscensao provas;
  @Mock private GuardaSessaoAtiva guardaSessaoAtiva;
  private ProvaAscensaoService service;

  @BeforeEach
  void preparar() {
    service = new ProvaAscensaoService(
        perfis, provas, guardaSessaoAtiva,
        Clock.fixed(Instant.parse("2026-07-15T12:00:00Z"), ZoneOffset.UTC)
    );
  }

  @Test
  void consultaMantemProvaBloqueadaAteCincoDiasAtivos() {
    when(perfis.buscarPerfil("uid-1")).thenReturn(perfilComDias(4));
    when(provas.talentoDesbloqueado("uid-1", "ritmo-constante")).thenReturn(false);

    ProvaAscensao prova = service.consultar("uid-1", "Jogador").prova();

    assertEquals("locked", prova.estado());
    assertEquals(4, prova.progresso());
    assertEquals(5, prova.alvo());
  }

  @Test
  void resgateDisponivelRegistraTalentoUmaUnicaVez() {
    when(perfis.buscarPerfil("uid-1")).thenReturn(perfilComDias(5));
    when(provas.talentoDesbloqueado("uid-1", "ritmo-constante")).thenReturn(false, true);
    when(provas.registrarResgate(eq("uid-1"), eq("ritmo-constante"), eq("ritmo-constante"), any()))
        .thenReturn(true);

    RespostaAscensao resposta = service.resgatar(
        "uid-1", "Jogador", new RequisicaoResgateProvaAscensao("device-1"));

    assertEquals("claimed", resposta.prova().estado());
    verify(guardaSessaoAtiva).exigirSessaoAtiva("uid-1", "device-1");
    verify(provas).registrarResgate(eq("uid-1"), eq("ritmo-constante"), eq("ritmo-constante"), any());
  }

  @Test
  void resgateBloqueadoNaoRegistraTalento() {
    when(perfis.buscarPerfil("uid-1")).thenReturn(perfilComDias(2));
    when(provas.talentoDesbloqueado("uid-1", "ritmo-constante")).thenReturn(false);

    ExcecaoApi erro = assertThrows(ExcecaoApi.class, () -> service.resgatar(
        "uid-1", "Jogador", new RequisicaoResgateProvaAscensao("device-1")));

    assertEquals("ascension_trial_incomplete", erro.codigo());
    verify(provas, never()).registrarResgate(any(), any(), any(), any());
  }

  private Map<String, Object> perfilComDias(int quantidade) {
    List<Timestamp> dias = java.util.stream.IntStream.range(0, quantidade)
        .mapToObj(indice -> Timestamp.ofTimeSecondsAndNanos(
            Instant.parse("2026-07-13T12:00:00Z").plusSeconds(indice * 86_400L).getEpochSecond(), 0))
        .toList();
    return Map.of("name", "Jogador", "activityHistory", dias, "maxXp", 100);
  }
}
