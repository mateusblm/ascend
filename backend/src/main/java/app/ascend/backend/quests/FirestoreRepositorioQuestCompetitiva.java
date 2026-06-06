package app.ascend.backend.quests;

import app.ascend.backend.compartilhado.ExcecaoApi;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.cloud.firestore.SetOptions;
import com.google.firebase.cloud.FirestoreClient;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.function.Function;
import org.springframework.stereotype.Repository;

@Repository
class FirestoreRepositorioQuestCompetitiva implements RepositorioQuestCompetitiva {

  @Override
  public Object executarMutacaoCompetitiva(
      String uid,
      String questId,
      String attemptId,
      String sourceActivityId,
      Function<ContextoQuestCompetitiva, EscritaQuestCompetitiva> mutacao
  ) {
    try {
      return firestore().runTransaction(transaction -> {
        var usuario = firestore().collection("users").document(uid);
        var perfilRef = usuario.collection("profile").document("current");
        var questRef = usuario.collection("quests").document(questId);
        var sessaoRef = usuario.collection("competitive_quest_sessions").document(attemptId);
        var concessaoRef = usuario.collection("competitive_quest_grants").document(attemptId);
        var conclusaoRef = usuario.collection("quest_completions").document(attemptId);
        var evidenciaRef = usuario.collection("competitive_quest_evidence").document(attemptId);
        var conclusoesRef = usuario.collection("quest_completions");

        DocumentSnapshot perfilSnap = transaction.get(perfilRef).get();
        DocumentSnapshot questSnap = transaction.get(questRef).get();
        DocumentSnapshot sessaoSnap = transaction.get(sessaoRef).get();
        DocumentSnapshot concessaoSnap = transaction.get(concessaoRef).get();
        List<Map<String, Object>> conclusoes = transaction.get(conclusoesRef)
            .get()
            .getDocuments()
            .stream()
            .map(DocumentSnapshot::getData)
            .toList();
        boolean sourceActivityIdJaUsado = false;
        if (sourceActivityId != null) {
          QuerySnapshot duplicadas = transaction.get(usuario
              .collection("competitive_quest_grants")
              .whereEqualTo("sourceActivityId", sourceActivityId)
              .limit(3)).get();
          sourceActivityIdJaUsado = duplicadas.getDocuments()
              .stream()
              .anyMatch(doc -> !attemptId.equals(doc.getId()) && !questId.equals(doc.getId()));
        }

        int indiceOrdem = 0;
        if (questSnap.exists() && questSnap.get("orderIndex") instanceof Number order) {
          indiceOrdem = Math.max(0, order.intValue());
        }

        EscritaQuestCompetitiva escrita = mutacao.apply(new ContextoQuestCompetitiva(
            perfilSnap.exists() ? perfilSnap.getData() : Map.of(),
            questSnap.exists() ? questSnap.getData() : Map.of(),
            questSnap.exists(),
            sessaoSnap.exists() ? sessaoSnap.getData() : Map.of(),
            sessaoSnap.exists(),
            concessaoSnap.exists() ? concessaoSnap.getData() : Map.of(),
            concessaoSnap.exists(),
            sourceActivityIdJaUsado,
            conclusoes,
            indiceOrdem
        ));

        if (escrita.perfil() != null) {
          transaction.set(perfilRef, escrita.perfil(), SetOptions.merge());
        }
        if (escrita.quest() != null) {
          transaction.set(questRef, escrita.quest(), SetOptions.merge());
        }
        if (escrita.sessao() != null) {
          transaction.set(sessaoRef, escrita.sessao(), SetOptions.merge());
        }
        if (escrita.concessao() != null) {
          transaction.set(concessaoRef, escrita.concessao(), SetOptions.merge());
        }
        if (escrita.conclusao() != null) {
          transaction.set(conclusaoRef, escrita.conclusao(), SetOptions.merge());
        }
        if (escrita.auditoriaEvidencia() != null) {
          transaction.set(evidenciaRef, escrita.auditoriaEvidencia(), SetOptions.merge());
        }
        return escrita.resposta();
      }).get();
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Mutacao de quest competitiva interrompida.", error);
    } catch (ExecutionException error) {
      if (error.getCause() instanceof ExcecaoApi excecaoApi) {
        throw excecaoApi;
      }
      throw new IllegalStateException("Nao foi possivel executar a mutacao de quest competitiva.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel executar a mutacao de quest competitiva.", error);
    }
  }

  private Firestore firestore() {
    return FirestoreClient.getFirestore();
  }
}
