package app.ascend.backend.ascensao;

import java.util.Map;

public interface RepositorioProvasAscensao {
  boolean talentoDesbloqueado(String uid, String talentoId);

  /** Retorna falso quando outro dispositivo ja registrou a mesma prova. */
  boolean registrarResgate(String uid, String provaId, String talentoId, Map<String, Object> dados);
}
