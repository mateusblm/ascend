package app.ascend.backend.quests;

import com.google.cloud.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

/**
 * Mapeia o inventario validado para documentos compativeis com o Firestore.
 */
@Component
public class MapeadorDocumentoInventarioQuest {

  static final int SYNC_SCHEMA_VERSION = 1;
  static final String SYNC_SOURCE = "callable_session_audited";

  /**
   * Cria as escritas de quest preservando a ordem recebida apos validacao.
   * A ordem e gravada para manter a lista remota reconstituivel no Flutter.
   */
  public List<EscritaInventarioQuest> paraEscritas(
      List<QuestInventarioValidada> quests,
      String idSessaoDispositivo,
      String rotuloDispositivo,
      Timestamp now
  ) {
    List<EscritaInventarioQuest> escritas = new ArrayList<>(quests.size());
    for (int index = 0; index < quests.size(); index++) {
      escritas.add(new EscritaInventarioQuest(
          quests.get(index).id(),
          paraDocumentoQuest(quests.get(index), index, idSessaoDispositivo, rotuloDispositivo, now)
      ));
    }
    return escritas;
  }

  /**
   * Cria o documento de metadados que marca o inventario como inicializado e
   * registra qual sessao de dispositivo produziu a sincronizacao.
   */
  public Map<String, Object> paraDocumentoMeta(
      int questCount,
      String idSessaoDispositivo,
      String rotuloDispositivo,
      Timestamp now
  ) {
    Map<String, Object> meta = new HashMap<>();
    meta.put("initialized", true);
    meta.put("questCount", questCount);
    meta.put("syncSchemaVersion", SYNC_SCHEMA_VERSION);
    meta.put("syncSource", SYNC_SOURCE);
    meta.put("activeDeviceSessionId", idSessaoDispositivo);
    meta.put("activeDeviceLabel", rotuloDispositivo);
    meta.put("updatedAt", now);
    return meta;
  }

  private Map<String, Object> paraDocumentoQuest(
      QuestInventarioValidada quest,
      int orderIndex,
      String idSessaoDispositivo,
      String rotuloDispositivo,
      Timestamp now
  ) {
    Map<String, Object> data = new HashMap<>();
    data.put("title", quest.title());
    data.put("rewardAttribute", quest.rewardAttribute());
    data.put("xpReward", quest.xpReward());
    data.put("category", quest.category());
    data.put("templateType", quest.templateType());
    data.put("verificationMode", quest.verificationMode());
    data.put("verificationStatus", quest.verificationStatus());
    data.put("targetDurationMinutes", quest.targetDurationMinutes());
    data.put("reflectionPrompt", quest.reflectionPrompt());
    data.put("reflectionAnswer", quest.reflectionAnswer());
    data.put("verificationStartedAt", quest.verificationStartedAt());
    data.put("completedAt", quest.completedAt());
    data.put("verifiedAt", quest.verifiedAt());
    data.put("isCompleted", quest.isCompleted());
    data.put("preRewardLevel", quest.preRewardLevel());
    data.put("preRewardXp", quest.preRewardXp());
    data.put("preRewardMaxXp", quest.preRewardMaxXp());
    data.put("preRewardStatPoints", quest.preRewardStatPoints());
    data.put("preRewardStrength", quest.preRewardStrength());
    data.put("preRewardIntelligence", quest.preRewardIntelligence());
    data.put("preRewardVitality", quest.preRewardVitality());
    data.put("preRewardAgility", quest.preRewardAgility());
    data.put("orderIndex", orderIndex);
    data.put("syncSchemaVersion", SYNC_SCHEMA_VERSION);
    data.put("syncSource", SYNC_SOURCE);
    data.put("activeDeviceSessionId", idSessaoDispositivo);
    data.put("activeDeviceLabel", rotuloDispositivo);
    data.put("updatedAt", now);
    return data;
  }
}
