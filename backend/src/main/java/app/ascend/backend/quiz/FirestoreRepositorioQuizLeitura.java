package app.ascend.backend.quiz;

import com.google.cloud.Timestamp;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.SetOptions;
import com.google.firebase.cloud.FirestoreClient;
import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Repository;

@Repository
class FirestoreRepositorioQuizLeitura implements RepositorioQuizLeitura {

  @Override
  public void gravarTentativa(
      String uid,
      TentativaQuizLeitura tentativa,
      String idSessaoDispositivo,
      String rotuloDispositivo
  ) {
    try {
      firestore()
          .collection("users")
          .document(uid)
          .collection("reading_quiz_attempts")
          .document(tentativa.quizId())
          .set(mapaTentativa(tentativa, idSessaoDispositivo, rotuloDispositivo), SetOptions.merge())
          .get();
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Gravacao do quiz de leitura interrompida.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel gravar quiz de leitura.", error);
    }
  }

  private Map<String, Object> mapaTentativa(
      TentativaQuizLeitura tentativa,
      String idSessaoDispositivo,
      String rotuloDispositivo
  ) {
    Map<String, Object> data = new HashMap<>();
    data.put("quizId", tentativa.quizId());
    data.put("questId", tentativa.questId());
    data.put("topic", tentativa.topic());
    data.put("minimumScore", tentativa.minimumScore());
    data.put("generator", tentativa.generator());
    data.put("questions", tentativa.questions().stream().map(this::mapaPergunta).toList());
    data.put("issuedAt", timestamp(tentativa.issuedAt()));
    data.put("expiresAt", timestamp(tentativa.expiresAt()));
    data.put("deviceSessionId", idSessaoDispositivo);
    data.put("deviceLabel", rotuloDispositivo);
    data.put("updatedAt", timestamp(Instant.now()));
    return data;
  }

  private Map<String, Object> mapaPergunta(PerguntaQuizLeitura pergunta) {
    return Map.of(
        "id", pergunta.id(),
        "prompt", pergunta.prompt(),
        "acceptedAnswer", pergunta.acceptedAnswer()
    );
  }

  private Timestamp timestamp(Instant instant) {
    return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
  }

  private Firestore firestore() {
    return FirestoreClient.getFirestore();
  }
}
