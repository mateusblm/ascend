package app.ascend.backend.quests;

import static app.ascend.backend.quests.ValidadorPayloadInventarioQuest.*;

import com.google.cloud.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import org.springframework.stereotype.Component;

/** Valida somente as quests pessoais disponiveis na V1. */
@Component
public class ValidadorRequisicaoInventarioQuest {
  private static final Set<String> ATRIBUTOS = Set.of("strength", "intelligence", "vitality", "agility");

  public DadosRequisicaoInventarioQuest validar(RequisicaoSincronizacaoInventarioQuest requisicao) {
    if (requisicao == null || requisicao.fonte() == null || requisicao.fonte().quests() == null) throw badRequest("invalid_quests");
    List<QuestInventarioValidada> quests = new ArrayList<>();
    for (int indice = 0; indice < requisicao.fonte().quests().size(); indice++) {
      quests.add(validarQuest(requisicao.fonte().quests().get(indice), indice));
    }
    return new DadosRequisicaoInventarioQuest(
        requireString(requisicao.idSessaoDispositivo(), "idSessaoDispositivo", 120),
        optionalString(requisicao.rotuloDispositivo(), "rotuloDispositivo", 120, "device"), quests);
  }

  public QuestInventarioValidada validarQuestPessoalDoComando(String questId, QuestFonteInventario quest) {
    QuestInventarioValidada validada = validarQuest(quest, 0);
    if (!validada.id().equals(questId)) throw badRequest("invalid_quest_id");
    return validada;
  }

  private QuestInventarioValidada validarQuest(QuestFonteInventario quest, int indice) {
    if (quest == null) throw badRequest("invalid_quest");
    String prefixo = "quest[" + indice + "]";
    String categoria = requireLowerAllowed(quest.category(), prefixo + ".category", Set.of("personal"));
    boolean concluida = requireBoolean(quest.isCompleted(), prefixo + ".isCompleted");
    Timestamp concluidaEm = optionalTimestamp(quest.completedAt(), prefixo + ".completedAt");
    Timestamp verificadaEm = optionalTimestamp(quest.verifiedAt(), prefixo + ".verifiedAt");
    int xp = Math.max(8, Math.min(15, requireInt(quest.xpReward(), prefixo + ".xpReward", 0)));
    String executionType = atividadeId(quest.executionType(), prefixo + ".executionType");
    int targetStrengthSets = 0;
    int targetStrengthRepetitions = 0;
    Double targetStrengthLoadKg = null;
    if ("strengthSets".equals(executionType)) {
      targetStrengthSets = optionalBoundedInt(quest.targetStrengthSets(), prefixo + ".targetStrengthSets", 20);
      targetStrengthRepetitions = optionalBoundedInt(quest.targetStrengthRepetitions(), prefixo + ".targetStrengthRepetitions", 500);
      targetStrengthLoadKg = optionalBoundedDecimal(quest.targetStrengthLoadKg(), prefixo + ".targetStrengthLoadKg", 1000);
    }
    return new QuestInventarioValidada(
        requireString(quest.id(), prefixo + ".id", 120),
        requireString(quest.title(), prefixo + ".title", 120),
        requireLowerAllowed(quest.rewardAttribute(), prefixo + ".rewardAttribute", ATRIBUTOS), xp,
        categoria, "custom", "manual", concluida ? "verified" : "none", 0,
        null, null, null, concluidaEm, concluida ? (verificadaEm == null ? concluidaEm : verificadaEm) : null,
        concluida, optionalNonNegativeInt(quest.preRewardLevel(), prefixo + ".preRewardLevel"),
        optionalNonNegativeInt(quest.preRewardXp(), prefixo + ".preRewardXp"),
        optionalNonNegativeInt(quest.preRewardMaxXp(), prefixo + ".preRewardMaxXp"),
        optionalNonNegativeInt(quest.preRewardStatPoints(), prefixo + ".preRewardStatPoints"),
        optionalNonNegativeInt(quest.preRewardStrength(), prefixo + ".preRewardStrength"),
        optionalNonNegativeInt(quest.preRewardIntelligence(), prefixo + ".preRewardIntelligence"),
        optionalNonNegativeInt(quest.preRewardVitality(), prefixo + ".preRewardVitality"),
        optionalNonNegativeInt(quest.preRewardAgility(), prefixo + ".preRewardAgility"),
        jornadaId(quest.journeyId(), prefixo),
        optionalBoolean(quest.isArchived()),
        optionalTimestamp(quest.plannedFor(), prefixo + ".plannedFor"),
        jornadaId(quest.recurrenceId(), prefixo + ".recurrence"),
        optionalTimestamp(quest.occursOn(), prefixo + ".occursOn"),
        modo(quest.mode(), prefixo), atividadeId(quest.activityCategoryId(), prefixo + ".activityCategoryId"),
        atividadeId(quest.activityModalityId(), prefixo + ".activityModalityId"), atividadeId(quest.activityId(), prefixo + ".activityId"),
        executionType, optionalNonNegativeInt(quest.activitySchemaVersion(), prefixo + ".activitySchemaVersion") == null ? 0 : optionalNonNegativeInt(quest.activitySchemaVersion(), prefixo + ".activitySchemaVersion"),
        targetStrengthSets, targetStrengthRepetitions, targetStrengthLoadKg);
  }

  private String jornadaId(Object valor, String prefixo) {
    String id = optionalString(valor, prefixo + ".journeyId", 36, "");
    return id.isBlank() ? null : id;
  }

  private boolean optionalBoolean(Object valor) {
    return valor instanceof Boolean resultado && resultado;
  }

  private String modo(Object valor, String prefixo) {
    String modo = optionalString(valor, prefixo + ".mode", 20, "quick");
    if (!"quick".equals(modo) && !"guided".equals(modo)) throw badRequest("invalid_quest_mode");
    return modo;
  }

  private String atividadeId(Object valor, String campo) {
    String id = optionalString(valor, campo, 100, "");
    return id.isBlank() ? null : id;
  }

  private int optionalBoundedInt(Object value, String field, int maximum) {
    if (value == null) return 0;
    int result = requireInt(value, field, 0);
    if (result > maximum) throw badRequest("invalid_" + field);
    return result;
  }

  private Double optionalBoundedDecimal(Object value, String field, double maximum) {
    if (value == null) return null;
    if (!(value instanceof Number number) || !Double.isFinite(number.doubleValue())
        || number.doubleValue() < 0 || number.doubleValue() > maximum) {
      throw badRequest("invalid_" + field);
    }
    return number.doubleValue();
  }
}
