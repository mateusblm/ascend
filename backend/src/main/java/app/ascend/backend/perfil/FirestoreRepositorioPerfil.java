package app.ascend.backend.perfil;

import app.ascend.backend.compartilhado.ExcecaoApi;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.SetOptions;
import com.google.firebase.cloud.FirestoreClient;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.function.Function;
import org.springframework.stereotype.Repository;

@Repository
public class FirestoreRepositorioPerfil implements RepositorioPerfil {

  @Override
  public RespostaPerfil executarMutacao(
      String uid,
      Function<Map<String, Object>, EscritaPerfil> mutacao
  ) {
    try {
      return firestore().runTransaction(transaction -> {
        var perfilRef = firestore()
            .collection("users")
            .document(uid)
            .collection("profile")
            .document("current");
        DocumentSnapshot perfilSnap = transaction.get(perfilRef).get();
        EscritaPerfil escrita = mutacao.apply(
            perfilSnap.exists() && perfilSnap.getData() != null ? perfilSnap.getData() : Map.of()
        );
        transaction.set(perfilRef, escrita.perfil(), SetOptions.merge());
        if (escrita.auditoriaAlocacao() != null) {
          var auditoriaRef = firestore()
              .collection("users")
              .document(uid)
              .collection("attribute_allocations")
              .document();
          transaction.set(auditoriaRef, escrita.auditoriaAlocacao(), SetOptions.merge());
        }
        return escrita.resposta();
      }).get();
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Mutacao de perfil interrompida.", error);
    } catch (ExecutionException error) {
      if (error.getCause() instanceof ExcecaoApi excecaoApi) {
        throw excecaoApi;
      }
      throw new IllegalStateException("Nao foi possivel executar a mutacao de perfil.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel executar a mutacao de perfil.", error);
    }
  }

  private Firestore firestore() {
    return FirestoreClient.getFirestore();
  }
}
