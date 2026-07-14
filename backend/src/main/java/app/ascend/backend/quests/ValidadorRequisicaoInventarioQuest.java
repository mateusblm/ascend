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
        optionalNonNegativeInt(quest.preRewardAgility(), prefixo + ".preRewardAgility"));
  }
}
