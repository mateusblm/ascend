package app.ascend.backend.placar;

import com.google.cloud.Timestamp;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.firebase.cloud.FirestoreClient;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import org.springframework.stereotype.Repository;

@Repository
public class FirestoreRepositorioPlacarTemporada implements RepositorioPlacarTemporada {

  @Override
  public List<RegistroPlacarTemporada> buscarPorTemporadaEFaixa(
      String chaveTemporada,
      String faixaRank
  ) {
    try {
      Firestore firestore = FirestoreClient.getFirestore();
      return firestore
          .collectionGroup("season_rewards")
          .whereEqualTo("seasonKey", chaveTemporada)
          .whereEqualTo("currentRankBracket", faixaRank)
          .get()
          .get()
          .getDocuments()
          .stream()
          .map(this::paraRegistro)
          .filter(Objects::nonNull)
          .toList();
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Leitura do placar da temporada interrompida.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel ler o placar da temporada.", error);
    }
  }

  private RegistroPlacarTemporada paraRegistro(QueryDocumentSnapshot document) {
    Map<String, Object> data = document.getData();
    Object seasonScore = data.get("seasonScore");
    Object secureWeeks = data.get("secureWeeks");
    Object updatedAt = data.get("updatedAt");
    Object playerStandingLabel = data.get("playerStandingLabel");
    if (!(seasonScore instanceof Number score)
        || !(secureWeeks instanceof Number weeks)
        || !(updatedAt instanceof Timestamp timestamp)
        || !(playerStandingLabel instanceof String label)) {
      return null;
    }

    String uid = "";
    if (document.getReference().getParent().getParent() != null) {
      uid = document.getReference().getParent().getParent().getId();
    }

    return new RegistroPlacarTemporada(
        uid,
        label,
        score.intValue(),
        weeks.intValue(),
        timestamp.toDate().getTime()
    );
  }
}
