package app.ascend.backend.quiz;

import com.google.cloud.Timestamp;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.SetOptions;
import com.google.firebase.cloud.FirestoreClient;
import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
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

  @Override
  public Optional<TentativaQuizLeitura> buscarTentativa(String uid, String quizId) {
    try {
      DocumentSnapshot snapshot = firestore()
          .collection("users")
          .document(uid)
          .collection("reading_quiz_attempts")
          .document(quizId)
          .get()
          .get();
      if (!snapshot.exists()) {
        return Optional.empty();
      }
      return tentativaDe(snapshot.getData());
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Leitura do quiz de leitura interrompida.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel ler quiz de leitura.", error);
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

  @SuppressWarnings("unchecked")
  private Optional<TentativaQuizLeitura> tentativaDe(Map<String, Object> data) {
    if (data == null
        || !(data.get("quizId") instanceof String quizId)
        || !(data.get("questId") instanceof String questId)
        || !(data.get("topic") instanceof String topic)
        || !(data.get("minimumScore") instanceof Number minimumScore)
        || !(data.get("expiresAt") instanceof Timestamp expiresAt)
        || !(data.get("issuedAt") instanceof Timestamp issuedAt)
        || !(data.get("questions") instanceof List<?> rawQuestions)) {
      return Optional.empty();
    }

    List<PerguntaQuizLeitura> questions = ((List<Object>) rawQuestions)
        .stream()
        .filter(Map.class::isInstance)
        .map(entry -> perguntaDe((Map<String, Object>) entry))
        .flatMap(Optional::stream)
        .toList();
    if (questions.isEmpty()) {
      return Optional.empty();
    }

    return Optional.of(new TentativaQuizLeitura(
        quizId,
        questId,
        topic,
        minimumScore.intValue(),
        data.get("generator") instanceof String generator ? generator : "deterministic_contract_v1",
        questions,
        instant(issuedAt),
        instant(expiresAt)
    ));
  }

  private Optional<PerguntaQuizLeitura> perguntaDe(Map<String, Object> data) {
    if (!(data.get("id") instanceof String id)
        || !(data.get("prompt") instanceof String prompt)
        || !(data.get("acceptedAnswer") instanceof String acceptedAnswer)) {
      return Optional.empty();
    }
    return Optional.of(new PerguntaQuizLeitura(id, prompt, acceptedAnswer));
  }

  private Timestamp timestamp(Instant instant) {
    return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
  }

  private Instant instant(Timestamp timestamp) {
    return Instant.ofEpochSecond(timestamp.getSeconds(), timestamp.getNanos());
  }

  private Firestore firestore() {
    return FirestoreClient.getFirestore();
  }
}
