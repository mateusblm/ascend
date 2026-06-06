package app.ascend.backend.promocao;

import app.ascend.backend.competitivo.SnapshotRankCompetitivo;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.SetOptions;
import com.google.cloud.firestore.WriteBatch;
import com.google.firebase.cloud.FirestoreClient;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import org.springframework.stereotype.Repository;

@Repository
public class FirestoreRepositorioPromocaoCompetitiva implements RepositorioPromocaoCompetitiva {

  @Override
  public ExamePromocao buscarExameAtual(String uid) {
    try {
      DocumentSnapshot snapshot = usuario(uid)
          .collection("promotion_exam")
          .document("current")
          .get()
          .get();
      return snapshot.exists() && snapshot.getData() != null
          ? paraExame(snapshot.getData())
          : null;
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Leitura da prova de promocao interrompida.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel ler a prova de promocao.", error);
    }
  }

  @Override
  public void gravarInicioExame(String uid, ExamePromocao exame) {
    try {
      usuario(uid)
          .collection("promotion_exam")
          .document("current")
          .set(mapaExame(exame), SetOptions.merge())
          .get();
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Gravacao da prova de promocao interrompida.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel gravar a prova de promocao.", error);
    }
  }

  @Override
  public void gravarPromocao(String uid, SnapshotRankCompetitivo snapshot, ExamePromocao exame) {
    try {
      WriteBatch batch = firestore().batch();
      var usuario = usuario(uid);
      Map<String, Object> rank = mapaRank(snapshot);
      batch.set(usuario.collection("progression").document("current"), rank, SetOptions.merge());
      batch.set(usuario.collection("progression_history").document(snapshot.weekKey()), rank, SetOptions.merge());
      batch.set(usuario.collection("promotion_exam").document("current"), mapaExame(exame), SetOptions.merge());
      batch.commit().get();
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Confirmacao da promocao interrompida.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel confirmar a promocao.", error);
    }
  }

  private ExamePromocao paraExame(Map<String, Object> data) {
    return new ExamePromocao(
        stringOuPadrao(data.get("sourceRank"), "E"),
        stringOuPadrao(data.get("targetRank"), "E"),
        stringOuPadrao(data.get("sourceWeekKey"), ""),
        stringOuPadrao(data.get("status"), "inProgress"),
        stringOuPadrao(data.get("mode"), "ascension"),
        inteiroOuPadrao(data.get("baselineActiveDays"), 0),
        inteiroOuPadrao(data.get("requiredExtraActiveDays"), 1),
        booleanoOuPadrao(data.get("bossRequired"), false),
        inteiroOuPadrao(data.get("requiredLevel"), 1),
        instantOuAgora(data.get("startedAt")),
        instantOuAgora(data.get("expiresAt")),
        inteiroOuPadrao(data.get("syncSchemaVersion"), 1),
        stringOuPadrao(data.get("syncSource"), "backend"),
        instantOuNulo(data.get("resolvedAt"))
    );
  }

  private Map<String, Object> mapaExame(ExamePromocao exame) {
    Map<String, Object> data = new HashMap<>();
    data.put("sourceRank", exame.sourceRank());
    data.put("targetRank", exame.targetRank());
    data.put("sourceWeekKey", exame.sourceWeekKey());
    data.put("status", exame.status());
    data.put("mode", exame.mode());
    data.put("baselineActiveDays", exame.baselineActiveDays());
    data.put("requiredExtraActiveDays", exame.requiredExtraActiveDays());
    data.put("bossRequired", exame.bossRequired());
    data.put("requiredLevel", exame.requiredLevel());
    data.put("startedAt", timestamp(exame.startedAt()));
    data.put("expiresAt", timestamp(exame.expiresAt()));
    data.put("syncSchemaVersion", exame.syncSchemaVersion());
    data.put("syncSource", exame.syncSource());
    data.put("resolvedAt", exame.resolvedAt() == null ? null : timestamp(exame.resolvedAt()));
    return removerNulos(data);
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

  private int inteiroOuPadrao(Object valor, int padrao) {
    return valor instanceof Number numero ? numero.intValue() : padrao;
  }

  private boolean booleanoOuPadrao(Object valor, boolean padrao) {
    return valor instanceof Boolean booleano ? booleano : padrao;
  }

  private Instant instantOuAgora(Object valor) {
    Instant instant = instantOuNulo(valor);
    return instant == null ? Instant.now() : instant;
  }

  private Instant instantOuNulo(Object valor) {
    if (valor instanceof Timestamp timestamp) {
      return timestamp.toDate().toInstant();
    }
    if (valor instanceof String texto) {
      return Instant.parse(texto);
    }
    return null;
  }

  private Firestore firestore() {
    return FirestoreClient.getFirestore();
  }

  private com.google.cloud.firestore.DocumentReference usuario(String uid) {
    return firestore().collection("users").document(uid);
  }
}
