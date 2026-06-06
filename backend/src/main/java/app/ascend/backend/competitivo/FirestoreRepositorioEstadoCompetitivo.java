package app.ascend.backend.competitivo;

import com.google.cloud.Timestamp;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.SetOptions;
import com.google.cloud.firestore.WriteBatch;
import com.google.firebase.cloud.FirestoreClient;
import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Repository;

@Repository
public class FirestoreRepositorioEstadoCompetitivo implements RepositorioEstadoCompetitivo {

  @Override
  public SnapshotRankCompetitivo buscarSnapshotRankAtual(String uid) {
    try {
      DocumentSnapshot snapshot = usuario(uid)
          .collection("progression")
          .document("current")
          .get()
          .get();
      return snapshot.exists() && snapshot.getData() != null
          ? paraSnapshotRank(snapshot.getData())
          : null;
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Leitura do rank competitivo interrompida.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel ler o rank competitivo.", error);
    }
  }

  @Override
  public List<Instant> buscarHistoricoCompetitivoAutorizado(String uid) {
    try {
      return usuario(uid)
          .collection("competitive_quest_grants")
          .orderBy("completedAt", com.google.cloud.firestore.Query.Direction.DESCENDING)
          .limit(180)
          .get()
          .get()
          .getDocuments()
          .stream()
          .map(this::dataConclusao)
          .filter(data -> data != null)
          .toList();
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Leitura dos grants competitivos interrompida.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel ler os grants competitivos.", error);
    }
  }

  @Override
  public void gravarSnapshotRank(String uid, SnapshotRankCompetitivo snapshot) {
    try {
      WriteBatch batch = firestore().batch();
      var usuario = usuario(uid);
      Map<String, Object> data = mapaRank(snapshot);
      batch.set(usuario.collection("progression").document("current"), data, SetOptions.merge());
      batch.set(
          usuario.collection("progression_history").document(snapshot.weekKey()),
          data,
          SetOptions.merge()
      );
      batch.commit().get();
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Gravacao do rank competitivo interrompida.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel gravar o rank competitivo.", error);
    }
  }

  @Override
  public void gravarSnapshotIntegridade(String uid, SnapshotIntegridadeCompetitiva snapshot) {
    try {
      WriteBatch batch = firestore().batch();
      var usuario = usuario(uid);
      Map<String, Object> data = mapaIntegridade(snapshot);
      batch.set(usuario.collection("integrity").document("current"), data, SetOptions.merge());
      batch.set(
          usuario.collection("integrity_history").document(snapshot.weekKey()),
          data,
          SetOptions.merge()
      );
      batch.commit().get();
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Gravacao da integridade competitiva interrompida.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel gravar a integridade competitiva.", error);
    }
  }

  private SnapshotRankCompetitivo paraSnapshotRank(Map<String, Object> data) {
    String currentRank = stringOuPadrao(data.get("currentRank"), "E").trim().toUpperCase();
    return new SnapshotRankCompetitivo(
        currentRank,
        stringOuPadrao(data.get("peakRank"), currentRank).trim().toUpperCase(),
        stringOuPadrao(data.get("highestEligibleRank"), currentRank).trim().toUpperCase(),
        stringOuPadrao(data.get("weekKey"), ""),
        inteiroOuPadrao(data.get("activeDays"), 0),
        inteiroOuPadrao(data.get("requiredActiveDays"), 3),
        booleanoOuPadrao(data.get("requiresBossClear"), false),
        booleanoOuPadrao(data.get("bossCompleted"), false),
        stringOuPadrao(data.get("status"), "warning"),
        inteiroOuPadrao(data.get("demotionStrikes"), 0),
        booleanoOuPadrao(data.get("promotionReady"), false),
        stringOuNulo(data.get("promotionTargetRank")),
        inteiroOuPadrao(data.get("targetRequiredLevel"), 1),
        booleanoOuPadrao(data.get("targetLevelGateMet"), true),
        stringOuNulo(data.get("advancementMode")),
        stringOuPadrao(data.get("eventType"), "routine"),
        stringOuPadrao(data.get("summary"), ""),
        stringOuPadrao(data.get("detail"), ""),
        inteiroOuPadrao(data.get("syncSchemaVersion"), 1),
        stringOuPadrao(data.get("syncSource"), "backend"),
        instantOuAgora(data.get("updatedAt"))
    );
  }

  private Instant dataConclusao(QueryDocumentSnapshot document) {
    Object completedAt = document.get("completedAt");
    return completedAt instanceof Timestamp timestamp ? timestamp.toDate().toInstant() : null;
  }

  private Map<String, Object> mapaRank(SnapshotRankCompetitivo snapshot) {
    Map<String, Object> data = new HashMap<>();
    data.put("currentRank", snapshot.currentRank());
    data.put("peakRank", snapshot.peakRank());
    data.put("highestEligibleRank", snapshot.highestEligibleRank());
    data.put("weekKey", snapshot.weekKey());
    data.put("activeDays", snapshot.activeDays());
    data.put("requiredActiveDays", snapshot.requiredActiveDays());
    data.put("requiresBossClear", snapshot.requiresBossClear());
    data.put("bossCompleted", snapshot.bossCompleted());
    data.put("status", snapshot.status());
    data.put("demotionStrikes", snapshot.demotionStrikes());
    data.put("promotionReady", snapshot.promotionReady());
    data.put("promotionTargetRank", snapshot.promotionTargetRank());
    data.put("targetRequiredLevel", snapshot.targetRequiredLevel());
    data.put("targetLevelGateMet", snapshot.targetLevelGateMet());
    data.put("advancementMode", snapshot.advancementMode());
    data.put("eventType", snapshot.eventType());
    data.put("summary", snapshot.summary());
    data.put("detail", snapshot.detail());
    data.put("syncSchemaVersion", snapshot.syncSchemaVersion());
    data.put("syncSource", snapshot.syncSource());
    data.put("updatedAt", timestamp(snapshot.updatedAt()));
    return removerNulos(data);
  }

  private Map<String, Object> mapaIntegridade(SnapshotIntegridadeCompetitiva snapshot) {
    Map<String, Object> data = new HashMap<>();
    data.put("weekKey", snapshot.weekKey());
    data.put("trustScore", snapshot.trustScore());
    data.put("trustBand", snapshot.trustBand());
    data.put("weeklyActiveDays", snapshot.weeklyActiveDays());
    data.put("weeklyCompetitiveDays", snapshot.weeklyCompetitiveDays());
    data.put("personalQuestCompletionsToday", snapshot.personalQuestCompletionsToday());
    data.put("competitiveQuestCompletionsToday", snapshot.competitiveQuestCompletionsToday());
    data.put("personalXpToday", snapshot.personalXpToday());
    data.put("competitiveXpToday", snapshot.competitiveXpToday());
    data.put("suspiciousPatternCount", snapshot.suspiciousPatternCount());
    data.put("summary", snapshot.summary());
    data.put("detail", snapshot.detail());
    data.put("syncSchemaVersion", snapshot.syncSchemaVersion());
    data.put("syncSource", snapshot.syncSource());
    data.put("updatedAt", timestamp(snapshot.updatedAt()));
    return data;
  }

  private Map<String, Object> removerNulos(Map<String, Object> data) {
    Map<String, Object> resultado = new HashMap<>();
    data.forEach((key, value) -> {
      if (value != null) {
        resultado.put(key, value);
      }
    });
    return resultado;
  }

  private Timestamp timestamp(Instant instant) {
    return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
  }

  private String stringOuPadrao(Object valor, String padrao) {
    return valor instanceof String texto && !texto.isBlank() ? texto : padrao;
  }

  private String stringOuNulo(Object valor) {
    return valor instanceof String texto && !texto.isBlank() ? texto : null;
  }

  private int inteiroOuPadrao(Object valor, int padrao) {
    return valor instanceof Number numero ? numero.intValue() : padrao;
  }

  private boolean booleanoOuPadrao(Object valor, boolean padrao) {
    return valor instanceof Boolean booleano ? booleano : padrao;
  }

  private Instant instantOuAgora(Object valor) {
    return valor instanceof Timestamp timestamp ? timestamp.toDate().toInstant() : Instant.now();
  }

  private Firestore firestore() {
    return FirestoreClient.getFirestore();
  }

  private com.google.cloud.firestore.DocumentReference usuario(String uid) {
    return firestore().collection("users").document(uid);
  }
}
