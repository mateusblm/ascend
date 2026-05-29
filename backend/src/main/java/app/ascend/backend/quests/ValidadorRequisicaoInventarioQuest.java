package app.ascend.backend.quests;

import static app.ascend.backend.quests.ValidadorPayloadInventarioQuest.badRequest;
import static app.ascend.backend.quests.ValidadorPayloadInventarioQuest.optionalNonNegativeInt;
import static app.ascend.backend.quests.ValidadorPayloadInventarioQuest.optionalString;
import static app.ascend.backend.quests.ValidadorPayloadInventarioQuest.optionalTimestamp;
import static app.ascend.backend.quests.ValidadorPayloadInventarioQuest.requireAllowed;
import static app.ascend.backend.quests.ValidadorPayloadInventarioQuest.requireBoolean;
import static app.ascend.backend.quests.ValidadorPayloadInventarioQuest.requireInt;
import static app.ascend.backend.quests.ValidadorPayloadInventarioQuest.requireLowerAllowed;
import static app.ascend.backend.quests.ValidadorPayloadInventarioQuest.requireString;

import app.ascend.backend.compartilhado.ExcecaoApi;
import com.google.cloud.Timestamp;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

/**
 * Converte o payload REST nao confiavel em dados de dominio normalizados.
 */
@Component
public class ValidadorRequisicaoInventarioQuest {

  private static final int MAX_QUESTS_PER_USER = 200;
  private static final Set<String> VALID_ATTRIBUTES = Set.of(
      "strength",
      "intelligence",
      "vitality",
      "agility"
  );
  private static final Set<String> VALID_CATEGORIES = Set.of("personal", "competitive");
  private static final Set<String> VALID_TEMPLATE_TYPES = Set.of(
      "custom",
      "focusSession",
      "studySession",
      "readingSession",
      "runningSession",
      "workoutSession"
  );
  private static final Set<String> VALID_VERIFICATION_MODES = Set.of(
      "manual",
      "timer",
      "timerWithReflection"
  );
  private static final Set<String> VALID_VERIFICATION_STATUSES = Set.of(
      "none",
      "ready",
      "inProgress",
      "verified"
  );

  private final CatalogoQuestCompetitiva catalogoQuestCompetitiva;

  public ValidadorRequisicaoInventarioQuest(CatalogoQuestCompetitiva catalogoQuestCompetitiva) {
    this.catalogoQuestCompetitiva = catalogoQuestCompetitiva;
  }

  /**
   * Valida a requisicao completa e normaliza os dados antes de qualquer escrita
   * no Firestore. O cliente pode sugerir quests, mas o backend sempre revalida
   * limites, enums, XP e templates competitivos oficiais.
   */
  public DadosRequisicaoInventarioQuest validar(RequisicaoSincronizacaoInventarioQuest request) {
    if (request == null) {
      throw badRequest("invalid_session_payload");
    }
    return new DadosRequisicaoInventarioQuest(
        requireString(request.idSessaoDispositivo(), "idSessaoDispositivo", 120),
        optionalString(request.rotuloDispositivo(), "rotuloDispositivo", 120, "device"),
        validarFonte(request.fonte())
    );
  }

  private List<QuestInventarioValidada> validarFonte(FonteInventarioQuest fonte) {
    if (fonte == null || fonte.quests() == null || fonte.quests().size() > MAX_QUESTS_PER_USER) {
      throw badRequest("invalid_quests");
    }

    Set<String> templatesCompetitivosAtivosVistos = new HashSet<>();
    List<QuestInventarioValidada> quests = new ArrayList<>(fonte.quests().size());
    for (int index = 0; index < fonte.quests().size(); index++) {
      QuestFonteInventario quest = fonte.quests().get(index);
      if (quest == null) {
        throw badRequest("invalid_quest");
      }
      quests.add(validarQuest(quest, index, templatesCompetitivosAtivosVistos));
    }
    return quests;
  }

  private QuestInventarioValidada validarQuest(
      QuestFonteInventario quest,
      int index,
      Set<String> templatesCompetitivosAtivosVistos
  ) {
    String prefix = "quest[" + index + "]";
    String id = requireString(quest.id(), prefix + ".id", 120);
    String title = requireString(quest.title(), prefix + ".title", 120);
    String rewardAttribute = requireLowerAllowed(
        quest.rewardAttribute(),
        prefix + ".rewardAttribute",
        VALID_ATTRIBUTES
    );
    String category = requireLowerAllowed(
        quest.category(),
        prefix + ".category",
        VALID_CATEGORIES
    );
    String templateType = requireAllowed(
        quest.templateType(),
        prefix + ".templateType",
        VALID_TEMPLATE_TYPES
    );
    String verificationMode = requireAllowed(
        quest.verificationMode(),
        prefix + ".verificationMode",
        VALID_VERIFICATION_MODES
    );
    String verificationStatus = requireAllowed(
        quest.verificationStatus(),
        prefix + ".verificationStatus",
        VALID_VERIFICATION_STATUSES
    );
    boolean isCompleted = requireBoolean(quest.isCompleted(), prefix + ".isCompleted");
    int targetDurationMinutes = requireInt(
        quest.targetDurationMinutes(),
        prefix + ".targetDurationMinutes",
        0
    );
    Timestamp verificationStartedAt = optionalTimestamp(
        quest.verificationStartedAt(),
        prefix + ".verificationStartedAt"
    );
    Timestamp completedAt = optionalTimestamp(quest.completedAt(), prefix + ".completedAt");
    Timestamp verifiedAt = optionalTimestamp(quest.verifiedAt(), prefix + ".verifiedAt");
    String reflectionPrompt = optionalString(
        quest.reflectionPrompt(),
        prefix + ".reflectionPrompt",
        240,
        null
    );
    String reflectionAnswer = optionalString(
        quest.reflectionAnswer(),
        prefix + ".reflectionAnswer",
        500,
        null
    );

    if ("personal".equals(category)) {
      return validarQuestPessoal(
          quest,
          prefix,
          id,
          title,
          rewardAttribute,
          completedAt,
          verifiedAt,
          isCompleted
      );
    }
    return validarQuestCompetitiva(
        quest,
        prefix,
        id,
        title,
        rewardAttribute,
        templateType,
        verificationMode,
        verificationStatus,
        targetDurationMinutes,
        reflectionPrompt,
        reflectionAnswer,
        verificationStartedAt,
        completedAt,
        verifiedAt,
        isCompleted,
        templatesCompetitivosAtivosVistos
    );
  }

  private QuestInventarioValidada validarQuestPessoal(
      QuestFonteInventario quest,
      String prefix,
      String id,
      String title,
      String rewardAttribute,
      Timestamp completedAt,
      Timestamp verifiedAt,
      boolean isCompleted
  ) {
    // Quests pessoais ficam na faixa leve de XP e sempre usam verificacao manual.
    int xpReward = Math.max(
        8,
        Math.min(15, requireInt(quest.xpReward(), prefix + ".xpReward", 0))
    );
    return new QuestInventarioValidada(
        id,
        title,
        rewardAttribute,
        xpReward,
        "personal",
        "custom",
        "manual",
        isCompleted ? "verified" : "none",
        0,
        null,
        null,
        null,
        completedAt,
        isCompleted ? firstNonNull(verifiedAt, completedAt) : null,
        isCompleted,
        optionalNonNegativeInt(quest.preRewardLevel(), prefix + ".preRewardLevel"),
        optionalNonNegativeInt(quest.preRewardXp(), prefix + ".preRewardXp"),
        optionalNonNegativeInt(quest.preRewardMaxXp(), prefix + ".preRewardMaxXp"),
        optionalNonNegativeInt(quest.preRewardStatPoints(), prefix + ".preRewardStatPoints"),
        optionalNonNegativeInt(quest.preRewardStrength(), prefix + ".preRewardStrength"),
        optionalNonNegativeInt(quest.preRewardIntelligence(), prefix + ".preRewardIntelligence"),
        optionalNonNegativeInt(quest.preRewardVitality(), prefix + ".preRewardVitality"),
        optionalNonNegativeInt(quest.preRewardAgility(), prefix + ".preRewardAgility")
    );
  }

  private QuestInventarioValidada validarQuestCompetitiva(
      QuestFonteInventario quest,
      String prefix,
      String id,
      String title,
      String rewardAttribute,
      String templateType,
      String verificationMode,
      String verificationStatus,
      int targetDurationMinutes,
      String reflectionPrompt,
      String reflectionAnswer,
      Timestamp verificationStartedAt,
      Timestamp completedAt,
      Timestamp verifiedAt,
      boolean isCompleted,
      Set<String> templatesCompetitivosAtivosVistos
  ) {
    int xpReward = requireInt(quest.xpReward(), prefix + ".xpReward", 0);
    DefinicaoQuestCompetitiva definicaoCompativel = catalogoQuestCompetitiva
        .buscarCompativel(
            title,
            templateType,
            verificationMode,
            targetDurationMinutes,
            xpReward,
            rewardAttribute
        )
        .orElseThrow(() -> badRequest("invalid_quest"));

    if (!isCompleted && !templatesCompetitivosAtivosVistos.add(definicaoCompativel.templateType())) {
      throw new ExcecaoApi(
          HttpStatus.PRECONDITION_FAILED,
          "duplicate_competitive_template",
          "Template competitivo ativo duplicado."
      );
    }

    return new QuestInventarioValidada(
        id,
        definicaoCompativel.title(),
        definicaoCompativel.rewardAttribute(),
        definicaoCompativel.xpReward(),
        "competitive",
        definicaoCompativel.templateType(),
        definicaoCompativel.verificationMode(),
        isCompleted ? "verified" : verificationStatus,
        definicaoCompativel.targetDurationMinutes(),
        reflectionPrompt,
        reflectionAnswer,
        verificationStartedAt,
        completedAt,
        isCompleted ? firstNonNull(verifiedAt, completedAt) : null,
        isCompleted,
        optionalNonNegativeInt(quest.preRewardLevel(), prefix + ".preRewardLevel"),
        optionalNonNegativeInt(quest.preRewardXp(), prefix + ".preRewardXp"),
        optionalNonNegativeInt(quest.preRewardMaxXp(), prefix + ".preRewardMaxXp"),
        optionalNonNegativeInt(quest.preRewardStatPoints(), prefix + ".preRewardStatPoints"),
        optionalNonNegativeInt(quest.preRewardStrength(), prefix + ".preRewardStrength"),
        optionalNonNegativeInt(quest.preRewardIntelligence(), prefix + ".preRewardIntelligence"),
        optionalNonNegativeInt(quest.preRewardVitality(), prefix + ".preRewardVitality"),
        optionalNonNegativeInt(quest.preRewardAgility(), prefix + ".preRewardAgility")
    );
  }

  private Timestamp firstNonNull(Timestamp first, Timestamp second) {
    return first != null ? first : second;
  }
}
