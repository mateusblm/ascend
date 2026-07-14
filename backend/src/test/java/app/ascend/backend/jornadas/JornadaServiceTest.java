package app.ascend.backend.jornadas;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import app.ascend.backend.compartilhado.ExcecaoApi;
import java.time.Instant;
import java.util.List;
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

  @Test
  void adicionarCapituloRejeitaJornadaPausada() {
    when(repositorio.buscarPorId("user-1", "jornada-1")).thenReturn(Optional.of(new Jornada(
        "jornada-1", "TCC", "Entregar", null, StatusJornada.pausada, Instant.now())));

    ExcecaoApi erro = assertThrows(ExcecaoApi.class, () -> service.adicionarCapitulo(
        "user-1", "jornada-1", new RequisicaoCriacaoCapitulo("Revisao final")));

    assertEquals("jornada_nao_esta_ativa", erro.codigo());
  }

  @Test
  void adicionarMarcoRejeitaCapituloDeJornadaPausada() {
    when(repositorio.buscarContextoCapitulo("user-1", "capitulo-1")).thenReturn(Optional.of(
        new ContextoCapituloJornada("capitulo-1", "jornada-1", StatusJornada.pausada)));

    ExcecaoApi erro = assertThrows(ExcecaoApi.class, () -> service.adicionarMarco(
        "user-1", "capitulo-1", new RequisicaoCriacaoMarco("Enviar versao", null)));

    assertEquals("jornada_nao_esta_ativa", erro.codigo());
  }

  @Test
  void adicionarMarcoRejeitaMissaoDeOutraJornada() {
    when(repositorio.buscarContextoCapitulo("user-1", "capitulo-1")).thenReturn(Optional.of(
        new ContextoCapituloJornada("capitulo-1", "jornada-1", StatusJornada.ativa)));
    when(repositorio.questPertenceAJornada("user-1", "quest-2", "jornada-1")).thenReturn(false);

    ExcecaoApi erro = assertThrows(ExcecaoApi.class, () -> service.adicionarMarco(
        "user-1", "capitulo-1", new RequisicaoCriacaoMarco("Enviar versao", "quest-2")));

    assertEquals("missao_invalida_para_marco", erro.codigo());
  }

  @Test
  void concluirMarcoManualEIdempotenteNoRepositorio() {
    MarcoCapitulo pendente = new MarcoCapitulo("marco-1", "Enviar", null, false, 0);
    MarcoCapitulo concluido = new MarcoCapitulo("marco-1", "Enviar", null, true, 0);
    when(repositorio.buscarMarco("user-1", "marco-1")).thenReturn(Optional.of(pendente));
    when(repositorio.concluirMarco("user-1", "marco-1")).thenReturn(concluido);

    assertEquals(concluido, service.concluirMarco("user-1", "marco-1"));
    verify(repositorio).concluirMarco("user-1", "marco-1");
  }

  @Test
  void concluirMarcoVinculadoExigeConclusaoDaMissao() {
    when(repositorio.buscarMarco("user-1", "marco-1")).thenReturn(Optional.of(
        new MarcoCapitulo("marco-1", "Enviar", "quest-1", false, 0)));

    ExcecaoApi erro = assertThrows(ExcecaoApi.class, () -> service.concluirMarco("user-1", "marco-1"));

    assertEquals("marco_vinculado_a_missao", erro.codigo());
  }

  @Test
  void concluirCapituloExigeTodosOsMarcosConcluidos() {
    when(repositorio.buscarContextoCapitulo("user-1", "capitulo-1")).thenReturn(Optional.of(
        new ContextoCapituloJornada("capitulo-1", "jornada-1", StatusJornada.ativa)));
    when(repositorio.listarMarcos("user-1", "capitulo-1")).thenReturn(List.of(
        new MarcoCapitulo("marco-1", "Enviar", null, false, 0)));

    ExcecaoApi erro = assertThrows(ExcecaoApi.class, () -> service.concluirCapitulo("user-1", "capitulo-1"));

    assertEquals("marcos_pendentes", erro.codigo());
  }

  @Test
  void concluirJornadaExigeCapitulosConcluidos() {
    when(repositorio.buscarPorId("user-1", "jornada-1")).thenReturn(Optional.of(new Jornada(
        "jornada-1", "TCC", "Entregar", null, StatusJornada.ativa, Instant.now())));
    when(repositorio.todosCapitulosConcluidos("user-1", "jornada-1")).thenReturn(false);

    ExcecaoApi erro = assertThrows(ExcecaoApi.class, () -> service.concluir("user-1", "jornada-1"));

    assertEquals("capitulos_pendentes", erro.codigo());
  }

  @Test
  void concluirJornadaRegistraLegadoUmaVez() {
    Jornada ativa = new Jornada("jornada-1", "TCC", "Entregar", null, StatusJornada.ativa, Instant.now());
    Jornada concluida = new Jornada("jornada-1", "TCC", "Entregar", null, StatusJornada.concluida, Instant.now());
    when(repositorio.buscarPorId("user-1", "jornada-1")).thenReturn(Optional.of(ativa));
    when(repositorio.todosCapitulosConcluidos("user-1", "jornada-1")).thenReturn(true);
    when(repositorio.atualizarStatus("user-1", "jornada-1", StatusJornada.concluida)).thenReturn(concluida);

    assertEquals(concluida, service.concluir("user-1", "jornada-1"));
    verify(repositorio).registrarConclusaoNoLegado("user-1", concluida);
  }
}
