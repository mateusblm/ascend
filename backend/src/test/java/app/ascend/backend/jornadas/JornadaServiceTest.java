package app.ascend.backend.jornadas;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import app.ascend.backend.compartilhado.ExcecaoApi;
import java.time.Instant;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class JornadaServiceTest {

  @Mock private RepositorioJornada repositorio;
  @InjectMocks private JornadaService service;

  @Test
  void criarNormalizaCamposEIniciaAtiva() {
    when(repositorio.salvar(eq("user-1"), any(Jornada.class)))
        .thenAnswer(invocacao -> invocacao.getArgument(1));

    Jornada jornada = service.criar(
        "user-1", new RequisicaoCriacaoJornada("  TCC  ", "  Entregar  ", "  Formar  "));

    assertEquals("TCC", jornada.titulo());
    assertEquals("Entregar", jornada.objetivo());
    assertEquals(StatusJornada.ativa, jornada.status());
  }

  @Test
  void pausarRejeitaJornadaQueNaoEstaAtiva() {
    when(repositorio.buscarPorId("user-1", "jornada-1")).thenReturn(Optional.of(new Jornada(
        "jornada-1", "TCC", "Entregar", null, StatusJornada.pausada, Instant.now())));

    ExcecaoApi erro = assertThrows(
        ExcecaoApi.class, () -> service.pausar("user-1", "jornada-1"));

    assertEquals("jornada_nao_esta_ativa", erro.codigo());
  }

  @Test
  void pausarAtualizaSomenteJornadaAtivaDoUsuario() {
    Jornada ativa = new Jornada(
        "jornada-1", "TCC", "Entregar", null, StatusJornada.ativa, Instant.now());
    when(repositorio.buscarPorId("user-1", "jornada-1")).thenReturn(Optional.of(ativa));
    when(repositorio.atualizarStatus("user-1", "jornada-1", StatusJornada.pausada))
        .thenReturn(new Jornada(
            "jornada-1", "TCC", "Entregar", null, StatusJornada.pausada, Instant.now()));

    service.pausar("user-1", "jornada-1");

    verify(repositorio).atualizarStatus("user-1", "jornada-1", StatusJornada.pausada);
  }
}
