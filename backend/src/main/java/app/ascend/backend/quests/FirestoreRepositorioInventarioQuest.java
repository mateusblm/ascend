package app.ascend.backend.quests;

import com.google.cloud.Timestamp;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.SetOptions;
import com.google.cloud.firestore.WriteBatch;
import com.google.firebase.cloud.FirestoreClient;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.stereotype.Repository;

@Repository
public class FirestoreRepositorioInventarioQuest implements RepositorioInventarioQuest {

  @Override
  public Optional<RegistroSessaoAtiva> buscarSessaoAtiva(String uid) {
    try {
      DocumentSnapshot snapshot = userDocument(uid)
          .collection("session")
          .document("current")
          .get()
          .get();
      if (!snapshot.exists()) {
        return Optional.empty();
      }

      Object idSessaoDispositivo = snapshot.get("deviceSessionId");
      Object expiresAt = snapshot.get("expiresAt");
      if (!(idSessaoDispositivo instanceof String sessionId)
          || !(expiresAt instanceof Timestamp timestamp)) {
        return Optional.of(new RegistroSessaoAtiva("", null));
      }
      return Optional.of(new RegistroSessaoAtiva(sessionId, timestamp));
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Interrupted while reading active session.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Unable to read active session.", error);
    }
  }

  @Override
  public Set<String> buscarIdsQuests(String uid) {
    try {
      return userDocument(uid)
          .collection("quests")
          .get()
          .get()
          .getDocuments()
          .stream()
          .map(QueryDocumentSnapshot::getId)
          .collect(Collectors.toSet());
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Interrupted while reading quests.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Unable to read quests.", error);
    }
  }

  @Override
  public void sincronizarInventario(
      String uid,
      List<EscritaInventarioQuest> escritas,
      Map<String, Object> meta,
      Set<String> idsQuestsParaExcluir
  ) {
    try {
      WriteBatch batch = firestore().batch();
      var userDocument = userDocument(uid);
      var quests = userDocument.collection("quests");

      for (String questId : idsQuestsParaExcluir) {
        batch.delete(quests.document(questId));
      }
      for (EscritaInventarioQuest escrita : escritas) {
        batch.set(quests.document(escrita.id()), escrita.data(), SetOptions.merge());
      }
      batch.set(
          userDocument.collection("quests_meta").document("current"),
          meta,
          SetOptions.merge()
      );
      batch.commit().get();
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Interrupted while syncing quest inventory.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Unable to sync quest inventory.", error);
    }
  }

  private Firestore firestore() {
    return FirestoreClient.getFirestore();
  }

  private com.google.cloud.firestore.DocumentReference userDocument(String uid) {
    return firestore().collection("users").document(uid);
  }
}
