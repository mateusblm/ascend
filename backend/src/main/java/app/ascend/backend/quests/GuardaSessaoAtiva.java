package app.ascend.backend.quests;

import app.ascend.backend.compartilhado.ExcecaoApi;
import com.google.cloud.Timestamp;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

/**
 * Aplica a regra de dispositivo ativo antes de escritas sensiveis a sessao.
 */
@Service
public class GuardaSessaoAtiva {

  private final RepositorioInventarioQuest repositorio;

  public GuardaSessaoAtiva(RepositorioInventarioQuest repositorio) {
    this.repositorio = repositorio;
  }

  /**
   * Garante que apenas o dispositivo dono da sessao ativa possa executar
   * escritas sensiveis. Sessao ausente, expirada ou de outro dispositivo gera
   * erro de pre-condicao para impedir concorrencia entre aparelhos.
   */
  public void exigirSessaoAtiva(String uid, String idSessaoDispositivo) {
    RegistroSessaoAtiva session = repositorio.buscarSessaoAtiva(uid)
        .orElseThrow(() -> new ExcecaoApi(
            HttpStatus.PRECONDITION_FAILED,
            "active_session_missing",
            "Sessao ativa nao encontrada."
        ));
    Timestamp now = Timestamp.now();
    if (session.idSessaoDispositivo() == null
        || session.idSessaoDispositivo().isBlank()
        || !session.idSessaoDispositivo().equals(idSessaoDispositivo)
        || session.expiresAt() == null
        || session.expiresAt().compareTo(now) <= 0) {
      throw new ExcecaoApi(
          HttpStatus.PRECONDITION_FAILED,
          "active_session_conflict",
          "Sessao ativa em outro dispositivo."
      );
    }
  }
}
