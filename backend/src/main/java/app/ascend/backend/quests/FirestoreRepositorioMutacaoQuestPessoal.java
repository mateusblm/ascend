package app.ascend.backend.quests;

import app.ascend.backend.compartilhado.ExcecaoApi;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.SetOptions;
import com.google.firebase.cloud.FirestoreClient;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.function.Function;
import org.springframework.stereotype.Repository;

@Repository
public class FirestoreRepositorioMutacaoQuestPessoal implements RepositorioMutacaoQuestPessoal {

  @Override
  public RespostaMutacaoQuestPessoal executarMutacao(
      String uid,
      String questId,
      Function<ContextoMutacaoQuestPessoal, EscritaMutacaoQuestPessoal> mutacao
  ) {
    try {
      return firestore().runTransaction(transaction -> {
        var usuario = userDocument(uid);
        var perfilRef = usuario.collection("profile").document("current");
        var questRef = usuario.collection("quests").document(questId);
        var conclusaoRef = usuario.collection("quest_completions").document(questId);
        var conclusoesRef = usuario.collection("quest_completions");

        DocumentSnapshot perfilSnap = transaction.get(perfilRef).get();
        DocumentSnapshot questSnap = transaction.get(questRef).get();
        DocumentSnapshot conclusaoSnap = transaction.get(conclusaoRef).get();
        List<Map<String, Object>> conclusoes = transaction.get(conclusoesRef)
            .get()
            .getDocuments()
            .stream()
            .map(DocumentSnapshot::getData)
            .toList();

        int indiceOrdem = 0;
        if (questSnap.exists() && questSnap.get("orderIndex") instanceof Number order) {
          indiceOrdem = Math.max(0, order.intValue());
        }

        EscritaMutacaoQuestPessoal escrita = mutacao.apply(new ContextoMutacaoQuestPessoal(
            perfilSnap.exists() ? perfilSnap.getData() : Map.of(),
            questSnap.exists() ? questSnap.getData() : Map.of(),
            questSnap.exists(),
            conclusaoSnap.exists(),
            conclusoes,
            indiceOrdem
        ));

        if (escrita.perfil() != null) {
          transaction.set(perfilRef, escrita.perfil(), SetOptions.merge());
        }
        if (escrita.quest() != null) {
          transaction.set(questRef, escrita.quest(), SetOptions.merge());
        }
        if (escrita.conclusao() != null) {
          transaction.set(conclusaoRef, escrita.conclusao(), SetOptions.merge());
        }
        if (escrita.excluirConclusao()) {
          transaction.delete(conclusaoRef);
        }
        return escrita.resposta();
      }).get();
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Mutacao de quest pessoal interrompida.", error);
    } catch (ExecutionException error) {
      if (error.getCause() instanceof ExcecaoApi excecaoApi) {
        throw excecaoApi;
      }
      throw new IllegalStateException("Nao foi possivel executar a mutacao de quest pessoal.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel executar a mutacao de quest pessoal.", error);
    }
  }

  private Firestore firestore() {
    return FirestoreClient.getFirestore();
  }

  private com.google.cloud.firestore.DocumentReference userDocument(String uid) {
    return firestore().collection("users").document(uid);
  }
}
