package app.ascend.backend.sessao;

import app.ascend.backend.compartilhado.ExcecaoApi;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.SetOptions;
import com.google.firebase.cloud.FirestoreClient;
import java.util.Optional;
import java.util.concurrent.ExecutionException;
import java.util.function.Function;
import org.springframework.stereotype.Repository;

@Repository
public class FirestoreRepositorioSessaoAtiva implements RepositorioSessaoAtiva {

  @Override
  public RespostaRegistroSessaoAtiva executarRegistro(
      String uid,
      Function<Optional<SessaoAtiva>, EscritaRegistroSessaoAtiva> mutacao
  ) {
    try {
      return firestore().runTransaction(transaction -> {
        var sessaoRef = sessaoRef(uid);
        DocumentSnapshot snapshot = transaction.get(sessaoRef).get();
        EscritaRegistroSessaoAtiva escrita = mutacao.apply(sessao(snapshot));
        transaction.set(sessaoRef, escrita.sessao(), SetOptions.merge());
        return escrita.resposta();
      }).get();
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Registro de sessao ativa interrompido.", error);
    } catch (ExecutionException error) {
      if (error.getCause() instanceof ExcecaoApi excecaoApi) {
        throw excecaoApi;
      }
      throw new IllegalStateException("Nao foi possivel registrar a sessao ativa.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel registrar a sessao ativa.", error);
    }
  }

  @Override
  public RespostaLiberacaoSessaoAtiva executarLiberacao(
      String uid,
      Function<Optional<SessaoAtiva>, EscritaLiberacaoSessaoAtiva> mutacao
  ) {
    try {
      return firestore().runTransaction(transaction -> {
        var sessaoRef = sessaoRef(uid);
        DocumentSnapshot snapshot = transaction.get(sessaoRef).get();
        EscritaLiberacaoSessaoAtiva escrita = mutacao.apply(sessao(snapshot));
        if (escrita.excluirSessao()) {
          transaction.delete(sessaoRef);
        }
        return escrita.resposta();
      }).get();
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Liberacao de sessao ativa interrompida.", error);
    } catch (ExecutionException error) {
      if (error.getCause() instanceof ExcecaoApi excecaoApi) {
        throw excecaoApi;
      }
      throw new IllegalStateException("Nao foi possivel liberar a sessao ativa.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel liberar a sessao ativa.", error);
    }
  }

  private Optional<SessaoAtiva> sessao(DocumentSnapshot snapshot) {
    if (!snapshot.exists()) {
      return Optional.empty();
    }
    return Optional.of(new SessaoAtiva(
        texto(snapshot.get("deviceSessionId")),
        texto(snapshot.get("deviceLabel")),
        timestamp(snapshot.get("registeredAt")),
        timestamp(snapshot.get("lastSeenAt")),
        timestamp(snapshot.get("expiresAt")),
        timestamp(snapshot.get("updatedAt"))
    ));
  }

  private String texto(Object value) {
    return value instanceof String text ? text : "";
  }

  private Timestamp timestamp(Object value) {
    return value instanceof Timestamp timestamp ? timestamp : null;
  }

  private Firestore firestore() {
    return FirestoreClient.getFirestore();
  }

  private com.google.cloud.firestore.DocumentReference sessaoRef(String uid) {
    return firestore()
        .collection("users")
        .document(uid)
        .collection("session")
        .document("current");
  }
}
