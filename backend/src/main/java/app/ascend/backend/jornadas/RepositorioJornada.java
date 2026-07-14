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
}
