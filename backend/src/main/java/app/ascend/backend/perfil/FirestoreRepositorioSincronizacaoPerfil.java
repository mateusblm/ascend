package app.ascend.backend.perfil;

import com.google.cloud.Timestamp;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.SetOptions;
import com.google.firebase.cloud.FirestoreClient;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import org.springframework.stereotype.Repository;

@Repository
public class FirestoreRepositorioSincronizacaoPerfil implements RepositorioSincronizacaoPerfil {

  @Override
  public List<ClaimBossSemanalPerfil> buscarClaimsBossSemanal(String uid) {
    try {
      List<QueryDocumentSnapshot> docs = firestore()
          .collectionGroup("completions")
          .whereEqualTo("uid", uid)
          .get()
          .get()
          .getDocuments();
      List<ClaimBossSemanalPerfil> claims = new ArrayList<>();
      for (QueryDocumentSnapshot doc : docs) {
        Map<String, Object> data = doc.getData();
        if (data.get("completedAt") instanceof Timestamp completedAt) {
          claims.add(new ClaimBossSemanalPerfil(
              completedAt,
              inteiro(data.get("rewardXp"), 0),
              inteiro(data.get("rewardStatPoints"), 0)
          ));
        }
      }
      claims.sort(Comparator.comparing(ClaimBossSemanalPerfil::completedAt));
      return claims;
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Busca de claims do boss semanal interrompida.", error);
    } catch (ExecutionException error) {
      throw new IllegalStateException("Nao foi possivel buscar claims do boss semanal.", error);
    }
  }

  @Override
  public void salvarPerfil(String uid, Map<String, Object> perfil) {
    try {
      firestore()
          .collection("users")
          .document(uid)
          .collection("profile")
          .document("current")
          .set(perfil, SetOptions.merge())
          .get();
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Sincronizacao de perfil interrompida.", error);
    } catch (ExecutionException error) {
      throw new IllegalStateException("Nao foi possivel sincronizar o perfil.", error);
    }
  }

  private int inteiro(Object value, int fallback) {
    return value instanceof Number number ? Math.max(0, number.intValue()) : fallback;
  }

  private Firestore firestore() {
    return FirestoreClient.getFirestore();
  }
}
