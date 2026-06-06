package app.ascend.backend.temporada;

import app.ascend.backend.compartilhado.ExcecaoApi;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.SetOptions;
import com.google.firebase.cloud.FirestoreClient;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Repository;

@Repository
public class FirestoreRepositorioRecompensaTemporada implements RepositorioRecompensaTemporada {

  @Override
  public ResultadoResgateRecompensaTemporada resgatarRecompensaAtual(
      String uid,
      String chaveTemporadaSolicitada,
      Instant agora,
      ResolvedorResgateRecompensaTemporada resolvedor
  ) {
    try {
      return firestore().runTransaction(transaction -> {
        var usuario = usuario(uid);
        var recompensaRef = usuario.collection("season_rewards").document("current");
        DocumentSnapshot snapshot = transaction.get(recompensaRef).get();
        RecompensaTemporada recompensaAtual = snapshot.exists() && snapshot.getData() != null
            ? paraRecompensa(snapshot.getData())
            : null;

        if (recompensaAtual != null
            && chaveTemporadaSolicitada != null
            && !chaveTemporadaSolicitada.isBlank()
            && !chaveTemporadaSolicitada.equals(recompensaAtual.seasonKey())) {
          throw new ExcecaoApi(
              HttpStatus.PRECONDITION_FAILED,
              "season_reward_changed",
              "A recompensa sazonal atual mudou."
          );
        }

        ResolucaoResgateRecompensaTemporada resolucao =
            resolvedor.resolver(recompensaAtual, agora);
        if ("claimed".equals(resolucao.status())) {
          transaction.set(recompensaRef, mapaRecompensa(resolucao.recompensa()), SetOptions.merge());
          transaction.set(
              usuario.collection("season_reward_history")
                  .document(resolucao.recompensa().seasonKey()),
              mapaRecompensa(resolucao.recompensa()),
              SetOptions.merge()
          );
          transaction.set(
              usuario.collection("season_legacy").document(resolucao.recompensa().seasonKey()),
              mapaLegado(resolucao.legado()),
              SetOptions.merge()
          );
          transaction.set(
              usuario.collection("season_profile").document("current"),
              mapaPerfil(resolucao.perfil()),
              SetOptions.merge()
          );
        }
        return new ResultadoResgateRecompensaTemporada(
            resolucao.status(),
            resolucao.recompensa(),
            resolucao.legado(),
            resolucao.perfil()
        );
      }).get();
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Resgate de recompensa sazonal interrompido.", error);
    } catch (ExcecaoApi error) {
      throw error;
    } catch (Exception error) {
      if (error.getCause() instanceof ExcecaoApi excecaoApi) {
        throw excecaoApi;
      }
      throw new IllegalStateException("Nao foi possivel resgatar a recompensa sazonal.", error);
    }
  }

  private RecompensaTemporada paraRecompensa(Map<String, Object> data) {
    return new RecompensaTemporada(
        stringOuPadrao(data.get("seasonKey"), ""),
        stringOuPadrao(data.get("seasonLabel"), ""),
        normalizarRank(stringOuPadrao(data.get("currentRankBracket"), "E")),
        stringOuPadrao(data.get("rewardTierLabel"), "EM FORMACAO"),
        stringOuPadrao(data.get("rewardStatusLabel"), "BLOQUEADA"),
        booleanoOuPadrao(data.get("rewardUnlocked"), false),
        stringOuPadrao(data.get("rewardName"), "Trilha sazonal bloqueada"),
        stringOuPadrao(data.get("rewardBadgeLabel"), "SEM EMBLEMA"),
        stringOuPadrao(data.get("rewardTitleLabel"), "Sem titulo sazonal"),
        stringOuPadrao(data.get("rewardBonusLabel"), "Nenhum pacote sazonal liberado."),
        inteiroOuPadrao(data.get("recordedWeeks"), 0),
        inteiroOuPadrao(data.get("secureWeeks"), 0),
        inteiroOuPadrao(data.get("seasonScore"), 0),
        stringOuPadrao(data.get("scoreBandLabel"), "RECUPERACAO"),
        stringOuPadrao(data.get("clearRateLabel"), "Clear rate aguardando lobby"),
        stringOuPadrao(data.get("playerStandingLabel"), "FORA DO CORTE"),
        stringOuPadrao(data.get("spotlightLabel"), ""),
        stringOuPadrao(data.get("resetLabel"), ""),
        stringOuPadrao(data.get("claimStatus"), "locked"),
        inteiroOuPadrao(data.get("syncSchemaVersion"), 1),
        stringOuPadrao(data.get("syncSource"), "backend"),
        instantOuAgora(data.get("updatedAt")),
        instantOuNulo(data.get("claimedAt"))
    );
  }

  private Map<String, Object> mapaRecompensa(RecompensaTemporada recompensa) {
    Map<String, Object> data = new HashMap<>();
    data.put("seasonKey", recompensa.seasonKey());
    data.put("seasonLabel", recompensa.seasonLabel());
    data.put("currentRankBracket", recompensa.currentRankBracket());
    data.put("rewardTierLabel", recompensa.rewardTierLabel());
    data.put("rewardStatusLabel", recompensa.rewardStatusLabel());
    data.put("rewardUnlocked", recompensa.rewardUnlocked());
    data.put("rewardName", recompensa.rewardName());
    data.put("rewardBadgeLabel", recompensa.rewardBadgeLabel());
    data.put("rewardTitleLabel", recompensa.rewardTitleLabel());
    data.put("rewardBonusLabel", recompensa.rewardBonusLabel());
    data.put("recordedWeeks", recompensa.recordedWeeks());
    data.put("secureWeeks", recompensa.secureWeeks());
    data.put("seasonScore", recompensa.seasonScore());
    data.put("scoreBandLabel", recompensa.scoreBandLabel());
    data.put("clearRateLabel", recompensa.clearRateLabel());
    data.put("playerStandingLabel", recompensa.playerStandingLabel());
    data.put("spotlightLabel", recompensa.spotlightLabel());
    data.put("resetLabel", recompensa.resetLabel());
    data.put("claimStatus", recompensa.claimStatus());
    data.put("syncSchemaVersion", recompensa.syncSchemaVersion());
    data.put("syncSource", recompensa.syncSource());
    data.put("updatedAt", timestamp(recompensa.updatedAt()));
    data.put("claimedAt", recompensa.claimedAt() == null ? null : timestamp(recompensa.claimedAt()));
    return removerNulos(data);
  }

  private Map<String, Object> mapaLegado(RecompensaLegadoTemporada legado) {
    Map<String, Object> data = new HashMap<>();
    data.put("seasonKey", legado.seasonKey());
    data.put("seasonLabel", legado.seasonLabel());
    data.put("claimedRankBracket", legado.claimedRankBracket());
    data.put("rewardTierLabel", legado.rewardTierLabel());
    data.put("rewardName", legado.rewardName());
    data.put("rewardBadgeLabel", legado.rewardBadgeLabel());
    data.put("rewardTitleLabel", legado.rewardTitleLabel());
    data.put("rewardBonusLabel", legado.rewardBonusLabel());
    data.put("scoreBandLabel", legado.scoreBandLabel());
    data.put("seasonScore", legado.seasonScore());
    data.put("playerStandingLabel", legado.playerStandingLabel());
    data.put("spotlightLabel", legado.spotlightLabel());
    data.put("cosmeticFrameLabel", legado.cosmeticFrameLabel());
    data.put("cosmeticAuraLabel", legado.cosmeticAuraLabel());
    data.put("claimedAt", timestamp(legado.claimedAt()));
    data.put("syncSchemaVersion", legado.syncSchemaVersion());
    data.put("syncSource", legado.syncSource());
    data.put("updatedAt", timestamp(legado.updatedAt()));
    return data;
  }

  private Map<String, Object> mapaPerfil(PerfilTemporada perfil) {
    Map<String, Object> data = new HashMap<>();
    data.put("activeSeasonKey", perfil.activeSeasonKey());
    data.put("activeSeasonLabel", perfil.activeSeasonLabel());
    data.put("activeRewardName", perfil.activeRewardName());
    data.put("activeBadgeLabel", perfil.activeBadgeLabel());
    data.put("activeTitleLabel", perfil.activeTitleLabel());
    data.put("cosmeticFrameLabel", perfil.cosmeticFrameLabel());
    data.put("cosmeticAuraLabel", perfil.cosmeticAuraLabel());
    data.put("equippedAt", timestamp(perfil.equippedAt()));
    data.put("syncSchemaVersion", perfil.syncSchemaVersion());
    data.put("syncSource", perfil.syncSource());
    data.put("updatedAt", timestamp(perfil.updatedAt()));
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

  private String normalizarRank(String valor) {
    String rank = valor.trim().toUpperCase();
    return switch (rank) {
      case "D", "C", "B", "A", "S" -> rank;
      default -> "E";
    };
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
