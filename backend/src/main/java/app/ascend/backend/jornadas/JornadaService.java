package app.ascend.backend.jornadas;

import app.ascend.backend.compartilhado.ExcecaoApi;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

/** Aplica as regras de negocio para iniciar e administrar Jornadas pessoais. */
@Service
public class JornadaService {

  private final RepositorioJornada repositorio;

  public JornadaService(RepositorioJornada repositorio) {
    this.repositorio = repositorio;
  }

  public List<Jornada> listar(String uid) {
    return repositorio.listarPorUsuario(uid);
  }

  public List<CapituloJornada> listarCapitulos(String uid, String jornadaId) {
    return repositorio.listarCapitulos(uid, jornadaId);
  }

  /**
   * Inicia uma Jornada independente das missoes para permitir planejamento progressivo.
   * A vinculacao de missoes sera adicionada sem alterar este contrato de criacao.
   */
  public Jornada criar(String uid, RequisicaoCriacaoJornada requisicao) {
    return repositorio.salvar(uid, new Jornada(
        UUID.randomUUID().toString(),
        requisicao.titulo().trim(),
        requisicao.objetivo().trim(),
        textoOpcional(requisicao.motivacao()),
        StatusJornada.ativa,
        Instant.now()
    ));
  }

  /** Pausa uma Jornada sem apagar seu proposito nem o historico que sera associado a ela. */
  public Jornada pausar(String uid, String jornadaId) {
    Jornada jornada = repositorio.buscarPorId(uid, jornadaId).orElseThrow(() ->
        new ExcecaoApi(HttpStatus.NOT_FOUND, "jornada_nao_encontrada", "Jornada nao encontrada."));
    if (jornada.status() != StatusJornada.ativa) {
      throw new ExcecaoApi(
          HttpStatus.CONFLICT,
          "jornada_nao_esta_ativa",
          "Somente uma Jornada ativa pode ser pausada."
      );
    }
    return repositorio.atualizarStatus(uid, jornadaId, StatusJornada.pausada);
  }

  /** Adiciona um capitulo somente enquanto a Jornada ainda pode receber novos objetivos. */
  public CapituloJornada adicionarCapitulo(
      String uid, String jornadaId, RequisicaoCriacaoCapitulo requisicao
  ) {
    Jornada jornada = repositorio.buscarPorId(uid, jornadaId).orElseThrow(() ->
        new ExcecaoApi(HttpStatus.NOT_FOUND, "jornada_nao_encontrada", "Jornada nao encontrada."));
    if (jornada.status() != StatusJornada.ativa) {
      throw new ExcecaoApi(HttpStatus.CONFLICT, "jornada_nao_esta_ativa",
          "Somente uma Jornada ativa pode receber capitulos.");
    }
    int proximoIndice = repositorio.listarCapitulos(uid, jornadaId).size();
    return repositorio.adicionarCapitulo(uid, jornadaId, new CapituloJornada(
        UUID.randomUUID().toString(), requisicao.titulo().trim(), proximoIndice));
  }

  /** Cria um marco apenas em um capitulo pertencente a uma Jornada ativa do usuario. */
  public MarcoCapitulo adicionarMarco(
      String uid, String capituloId, RequisicaoCriacaoMarco requisicao
  ) {
    ContextoCapituloJornada contexto = contextoCapituloAtivo(uid, capituloId);
    String questId = textoOpcional(requisicao.questId());
    if (questId != null && !repositorio.questPertenceAJornada(uid, questId, contexto.jornadaId())) {
      throw new ExcecaoApi(HttpStatus.UNPROCESSABLE_ENTITY, "missao_invalida_para_marco",
          "A missao vinculada deve pertencer a esta Jornada.");
    }
    return repositorio.adicionarMarco(capituloId, requisicao.titulo().trim(), questId);
  }

  /** Lista a rota de marcos somente para o dono do capitulo solicitado. */
  public List<MarcoCapitulo> listarMarcos(String uid, String capituloId) {
    contextoCapitulo(uid, capituloId);
    return repositorio.listarMarcos(uid, capituloId);
  }

  /**
   * Conclui um marco manual de forma idempotente. Marcos ligados a missao sao
   * atualizados somente pela conclusao autoritativa da missao no banco.
   */
  public MarcoCapitulo concluirMarco(String uid, String marcoId) {
    MarcoCapitulo marco = repositorio.buscarMarco(uid, marcoId).orElseThrow(() ->
        new ExcecaoApi(HttpStatus.NOT_FOUND, "marco_nao_encontrado", "Marco nao encontrado."));
    if (marco.questId() != null) {
      throw new ExcecaoApi(HttpStatus.CONFLICT, "marco_vinculado_a_missao",
          "Este marco avanca quando a missao vinculada for concluida.");
    }
    return repositorio.concluirMarco(uid, marcoId);
  }

  /** Fecha um capitulo somente quando sua rota possui marcos e todos foram atendidos. */
  public CapituloJornada concluirCapitulo(String uid, String capituloId) {
    contextoCapituloAtivo(uid, capituloId);
    List<MarcoCapitulo> marcos = repositorio.listarMarcos(uid, capituloId);
    if (marcos.isEmpty() || marcos.stream().anyMatch(marco -> !marco.concluido())) {
      throw new ExcecaoApi(HttpStatus.CONFLICT, "marcos_pendentes",
          "Conclua todos os marcos antes de encerrar o capitulo.");
    }
    return repositorio.concluirCapitulo(uid, capituloId);
  }

  /** Conclui uma Jornada ativa apenas depois de todos os seus capitulos. */
  public Jornada concluir(String uid, String jornadaId) {
    Jornada jornada = repositorio.buscarPorId(uid, jornadaId).orElseThrow(() ->
        new ExcecaoApi(HttpStatus.NOT_FOUND, "jornada_nao_encontrada", "Jornada nao encontrada."));
    if (jornada.status() != StatusJornada.ativa) {
      throw new ExcecaoApi(HttpStatus.CONFLICT, "jornada_nao_esta_ativa",
          "Somente uma Jornada ativa pode ser concluida.");
    }
    if (!repositorio.todosCapitulosConcluidos(uid, jornadaId)) {
      throw new ExcecaoApi(HttpStatus.CONFLICT, "capitulos_pendentes",
          "Conclua todos os capitulos antes de encerrar a Jornada.");
    }
    Jornada concluida = repositorio.atualizarStatus(uid, jornadaId, StatusJornada.concluida);
    repositorio.registrarConclusaoNoLegado(uid, concluida);
    return concluida;
  }

  private ContextoCapituloJornada contextoCapituloAtivo(String uid, String capituloId) {
    ContextoCapituloJornada contexto = contextoCapitulo(uid, capituloId);
    if (contexto.status() != StatusJornada.ativa) {
      throw new ExcecaoApi(HttpStatus.CONFLICT, "jornada_nao_esta_ativa",
          "Somente uma Jornada ativa pode receber marcos.");
    }
    return contexto;
  }

  private ContextoCapituloJornada contextoCapitulo(String uid, String capituloId) {
    return repositorio.buscarContextoCapitulo(uid, capituloId).orElseThrow(() ->
        new ExcecaoApi(HttpStatus.NOT_FOUND, "capitulo_nao_encontrado", "Capitulo nao encontrado."));
  }

  private String textoOpcional(String valor) {
    if (valor == null || valor.isBlank()) return null;
    return valor.trim();
  }
}
