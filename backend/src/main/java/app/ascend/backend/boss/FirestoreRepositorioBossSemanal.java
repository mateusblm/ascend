package app.ascend.backend.boss;

import app.ascend.backend.compartilhado.ExcecaoApi;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.FieldValue;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.SetOptions;
import com.google.firebase.cloud.FirestoreClient;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.function.Function;
import org.springframework.stereotype.Repository;

@Repository
public class FirestoreRepositorioBossSemanal implements RepositorioBossSemanal {

  @Override
  public RespostaResgateBossSemanal executarResgate(
      String uid,
      String bossId,
      Function<ContextoResgateBossSemanal, EscritaResgateBossSemanal> mutacao
  ) {
    try {
      return firestore().runTransaction(transaction -> {
        var bossRef = firestore().collection("weekly_bosses").document(bossId);
        var conclusaoRef = bossRef.collection("completions").document(uid);
        var usuarioRef = firestore().collection("users").document(uid);
        var resgateRef = usuarioRef.collection("weekly_boss_claims").document(bossId);
        var perfilRef = usuarioRef.collection("profile").document("current");

        DocumentSnapshot bossSnap = transaction.get(bossRef).get();
        DocumentSnapshot conclusaoSnap = transaction.get(conclusaoRef).get();
        DocumentSnapshot resgateSnap = transaction.get(resgateRef).get();
        DocumentSnapshot perfilSnap = transaction.get(perfilRef).get();

        EscritaResgateBossSemanal escrita = mutacao.apply(new ContextoResgateBossSemanal(
            dados(bossSnap),
            bossSnap.exists(),
            conclusaoSnap.exists(),
            resgateSnap.exists(),
            dados(perfilSnap)
        ));

        if (escrita.perfil() != null) {
          transaction.set(perfilRef, escrita.perfil(), SetOptions.merge());
        }
        if (escrita.conclusao() != null) {
          transaction.set(conclusaoRef, escrita.conclusao(), SetOptions.merge());
        }
        if (escrita.resgateUsuario() != null) {
          transaction.set(resgateRef, escrita.resgateUsuario(), SetOptions.merge());
        }
        if (escrita.incrementarConclusoes()) {
          transaction.update(bossRef, "completedCount", FieldValue.increment(1));
        }
        return escrita.resposta();
      }).get();
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Resgate do boss semanal interrompido.", error);
    } catch (ExecutionException error) {
      if (error.getCause() instanceof ExcecaoApi excecaoApi) {
        throw excecaoApi;
      }
      throw new IllegalStateException("Nao foi possivel resgatar o boss semanal.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel resgatar o boss semanal.", error);
    }
  }

  private Map<String, Object> dados(DocumentSnapshot snapshot) {
    return snapshot.exists() && snapshot.getData() != null ? snapshot.getData() : Map.of();
  }

  private Firestore firestore() {
    return FirestoreClient.getFirestore();
  }
}
