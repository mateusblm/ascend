package app.ascend.backend.jornadas;

import java.util.List;
import java.util.Optional;

/** Porta de persistencia do agregado Jornada. */
public interface RepositorioJornada {

  List<Jornada> listarPorUsuario(String uid);

  Jornada salvar(String uid, Jornada jornada);

  Optional<Jornada> buscarPorId(String uid, String jornadaId);

  Jornada atualizarStatus(String uid, String jornadaId, StatusJornada status);

  List<CapituloJornada> listarCapitulos(String uid, String jornadaId);

  CapituloJornada adicionarCapitulo(String uid, String jornadaId, CapituloJornada capitulo);

  Optional<ContextoCapituloJornada> buscarContextoCapitulo(String uid, String capituloId);

  List<MarcoCapitulo> listarMarcos(String uid, String capituloId);

  MarcoCapitulo adicionarMarco(String capituloId, String titulo, String questId);

  Optional<MarcoCapitulo> buscarMarco(String uid, String marcoId);

  MarcoCapitulo concluirMarco(String uid, String marcoId);

  boolean questPertenceAJornada(String uid, String questId, String jornadaId);
}
