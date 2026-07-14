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

  private String textoOpcional(String valor) {
    if (valor == null || valor.isBlank()) return null;
    return valor.trim();
  }
}
