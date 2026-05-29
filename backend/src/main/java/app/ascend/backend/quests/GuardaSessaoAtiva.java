package app.ascend.backend.quests;

import com.google.cloud.Timestamp;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

/**
 * Aplica a regra de dispositivo ativo antes de escritas sensiveis a sessao.
 */
@Service
public class GuardaSessaoAtiva {

  private final RepositorioInventarioQuest repositorio;

  public GuardaSessaoAtiva(RepositorioInventarioQuest repositorio) {
    this.repositorio = repositorio;
  }

  public void exigirSessaoAtiva(String uid, String idSessaoDispositivo) {
    RegistroSessaoAtiva session = repositorio.buscarSessaoAtiva(uid)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.PRECONDITION_FAILED,
            "active_session_missing"
        ));
    Timestamp now = Timestamp.now();
    if (session.idSessaoDispositivo() == null
        || session.idSessaoDispositivo().isBlank()
        || !session.idSessaoDispositivo().equals(idSessaoDispositivo)
        || session.expiresAt() == null
        || session.expiresAt().compareTo(now) <= 0) {
      throw new ResponseStatusException(
          HttpStatus.PRECONDITION_FAILED,
          "active_session_conflict"
      );
    }
  }
}
