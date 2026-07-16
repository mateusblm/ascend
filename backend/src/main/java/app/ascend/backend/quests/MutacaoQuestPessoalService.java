package app.ascend.backend.quests;

import app.ascend.backend.compartilhado.ExcecaoApi;
import com.google.cloud.Timestamp;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class MutacaoQuestPessoalService {

  private static final String SYNC_SOURCE = "callable_server_authoritative";
  private static final ZoneId ZONA_DATA = ZoneId.systemDefault();

  private final GuardaSessaoAtiva guardaSessaoAtiva;
  private final ValidadorRequisicaoInventarioQuest validadorQuest;
  private final RepositorioMutacaoQuestPessoal repositorio;

  public MutacaoQuestPessoalService(
      GuardaSessaoAtiva guardaSessaoAtiva,
      ValidadorRequisicaoInventarioQuest validadorQuest,
      RepositorioMutacaoQuestPessoal repositorio
  ) {
    this.guardaSessaoAtiva = guardaSessaoAtiva;
    this.validadorQuest = validadorQuest;
    this.repositorio = repositorio;
  }

  /**
   * Conclui uma quest pessoal exatamente uma vez. A primeira conclusao concede
   * XP, incrementa o atributo da quest, grava snapshot pre-recompensa e cria o
   * documento de conclusao usado para recompor historico em revogacoes futuras.
   */
  public RespostaMutacaoQuestPessoal concluir(
      String uid,
      String nomeFallback,
      RequisicaoMutacaoQuestPessoal request
  ) {
    DadosComando dados = validarComando(request, true);
    guardaSessaoAtiva.exigirSessaoAtiva(uid, dados.idSessaoDispositivo());
    Timestamp now = Timestamp.now();
    return repositorio.executarMutacao(uid, dados.questId(), contexto ->
        concluirNoContexto(contexto, dados, nomeFallback, now)
    );
  }

  /** Conclusão interna de missão guiada: a configuração é lida do inventário
   * canônico, nunca reenviada pelo cliente. */
  public RespostaMutacaoQuestPessoal concluirGuiada(
      String uid, String nomeFallback, String idSessaoDispositivo, String questId,
      String activityId, String executionType, int schemaVersion
  ) {
    guardaSessaoAtiva.exigirSessaoAtiva(uid, idSessaoDispositivo);
    DadosComando dados = new DadosComando(idSessaoDispositivo, "device", questId, null);
    Timestamp now = Timestamp.now();
    return repositorio.executarMutacao(uid, questId, contexto -> {
      if (!contexto.questExiste() || !"guided".equals(contexto.quest().get("mode"))
          || !activityId.equals(contexto.quest().get("activityId"))
          || !executionType.equals(contexto.quest().get("executionType"))
          || !(contexto.quest().get("activitySchemaVersion") instanceof Number versao)
          || versao.intValue() != schemaVersion) {
        throw new ExcecaoApi(HttpStatus.UNPROCESSABLE_ENTITY, "invalid_guided_quest_contract",
            "A missão guiada não corresponde à atividade executada.");
      }
      return concluirNoContexto(contexto, dados, nomeFallback, now);
    });
  }

  /**
   * Revoga uma conclusao pessoal restaurando o snapshot salvo antes da
   * recompensa. O historico e o XP autoritativo sao recompostos a partir dos
   * documentos restantes em `quest_completions`.
   */
  public RespostaMutacaoQuestPessoal revogar(
      String uid,
      String nomeFallback,
      RequisicaoMutacaoQuestPessoal request
  ) {
    DadosComando dados = validarComando(request, false);
    guardaSessaoAtiva.exigirSessaoAtiva(uid, dados.idSessaoDispositivo());
    Timestamp now = Timestamp.now();
    return repositorio.executarMutacao(uid, dados.questId(), contexto ->
        revogarNoContexto(contexto, dados, nomeFallback, now)
    );
  }

  private EscritaMutacaoQuestPessoal concluirNoContexto(
      ContextoMutacaoQuestPessoal contexto,
      DadosComando dados,
      String nomeFallback,
      Timestamp now
  ) {
    PerfilJogador perfilAtual = perfilDe(contexto.perfil(), nomeFallback, dados, now);
    QuestInventarioValidada questExistente = contexto.questExiste()
        ? questDeDocumento(dados.questId(), contexto.quest())
        : null;
    QuestInventarioValidada quest = questExistente != null ? questExistente : dados.quest();
    if (quest == null) {
      throw new ExcecaoApi(HttpStatus.NOT_FOUND, "personal_quest_not_found", "Quest pessoal nao encontrada.");
    }
    exigirQuestPessoal(quest);

    if (quest.isCompleted() || contexto.conclusaoExiste()) {
      QuestInventarioValidada questRespostaFonte = quest.isCompleted()
          ? quest
          : questConcluidaSemRecompensa(quest, now);
      Map<String, Object> questResposta = documentoQuest(
          questRespostaFonte,
          contexto.indiceOrdem(),
          dados,
          now
      );
      return new EscritaMutacaoQuestPessoal(
          null,
          quest.isCompleted() ? null : questResposta,
          null,
          false,
          new RespostaMutacaoQuestPessoal("already_completed", perfilAtual.paraDocumento(
              dados.idSessaoDispositivo(),
              dados.rotuloDispositivo(),
              now,
              perfilAtual.syncSource()
          ), dados.questId(), questResposta)
      );
    }

    PerfilJogador recompensado = aplicarXp(perfilAtual, quest.xpReward());
    AtributosJogador atributos = recompensado.attributes().incrementar(quest.rewardAttribute());
    List<Timestamp> historico = historicoComDia(perfilAtual.activityHistory(), now);
    Streaks streaks = streaks(historico, now);
    PerfilJogador proximoPerfil = new PerfilJogador(
        recompensado.name(),
        recompensado.level(),
        recompensado.xp(),
        recompensado.maxXp(),
        recompensado.statPoints(),
        atributos,
        recompensado.lastResetDate(),
        streaks.atual(),
        streaks.melhor(),
        now,
        historico,
        recompensado.primaryFocus(),
        recompensado.hasCompletedOnboarding(),
        recompensado.weeklyBossLastClaimedAt(),
        perfilAtual.authoritativeQuestXp() + quest.xpReward(),
        recompensado.authoritativeWeeklyBossXp(),
        recompensado.authoritativeWeeklyBossStatPoints(),
        recompensado.authoritativeAllocatedStatPoints(),
        1,
        SYNC_SOURCE,
        dados.idSessaoDispositivo(),
        dados.rotuloDispositivo(),
        now
    );
    QuestInventarioValidada questAtualizada = new QuestInventarioValidada(
        quest.id(),
        quest.title(),
        quest.rewardAttribute(),
        quest.xpReward(),
        quest.category(),
        quest.templateType(),
        quest.verificationMode(),
        "verified",
        quest.targetDurationMinutes(),
        quest.reflectionPrompt(),
        quest.reflectionAnswer(),
        quest.verificationStartedAt(),
        now,
        now,
        true,
        perfilAtual.level(),
        perfilAtual.xp(),
        perfilAtual.maxXp(),
        perfilAtual.statPoints(),
        perfilAtual.attributes().strength(),
        perfilAtual.attributes().intelligence(),
        perfilAtual.attributes().vitality(),
        perfilAtual.attributes().agility(),
        quest.journeyId(), quest.isArchived(), quest.plannedFor(), quest.recurrenceId(), quest.occursOn(),
        quest.mode(), quest.activityCategoryId(), quest.activityModalityId(), quest.activityId(),
        quest.executionType(), quest.activitySchemaVersion(), quest.targetStrengthSets(),
        quest.targetStrengthRepetitions(), quest.targetStrengthLoadKg()
    );
    Map<String, Object> perfilDoc = proximoPerfil.paraDocumento(
        dados.idSessaoDispositivo(),
        dados.rotuloDispositivo(),
        now,
        SYNC_SOURCE
    );
    Map<String, Object> questDoc = documentoQuest(questAtualizada, contexto.indiceOrdem(), dados, now);
    return new EscritaMutacaoQuestPessoal(
        perfilDoc,
        questDoc,
        documentoConclusao(questAtualizada, perfilAtual, now),
        false,
        new RespostaMutacaoQuestPessoal("completed", perfilDoc, dados.questId(), questDoc)
    );
  }

  private EscritaMutacaoQuestPessoal revogarNoContexto(
      ContextoMutacaoQuestPessoal contexto,
      DadosComando dados,
      String nomeFallback,
      Timestamp now
  ) {
    PerfilJogador perfilAtual = perfilDe(contexto.perfil(), nomeFallback, dados, now);
    if (!contexto.questExiste()) {
      throw new ExcecaoApi(HttpStatus.NOT_FOUND, "personal_quest_not_found", "Quest pessoal nao encontrada.");
    }
    QuestInventarioValidada quest = questDeDocumento(dados.questId(), contexto.quest());
    exigirQuestPessoal(quest);
    if (!quest.isCompleted() || !contexto.conclusaoExiste()) {
      Map<String, Object> questDoc = documentoQuest(quest, contexto.indiceOrdem(), dados, now);
      return new EscritaMutacaoQuestPessoal(
          null,
          null,
          null,
          false,
          new RespostaMutacaoQuestPessoal("already_pending", perfilAtual.paraDocumento(
              dados.idSessaoDispositivo(),
              dados.rotuloDispositivo(),
              now,
              perfilAtual.syncSource()
          ), dados.questId(), questDoc)
      );
    }

    ProjecaoConclusoes projecao = projetarConclusoesRestantes(contexto.conclusoes(), dados.questId(), now);
    Streaks streaks = streaks(projecao.activityHistory(), now);
    PerfilJogador proximoPerfil = new PerfilJogador(
        perfilAtual.name(),
        valorOuAtual(quest.preRewardLevel(), perfilAtual.level()),
        valorOuAtual(quest.preRewardXp(), perfilAtual.xp()),
        valorOuAtual(quest.preRewardMaxXp(), perfilAtual.maxXp()),
        valorOuAtual(quest.preRewardStatPoints(), perfilAtual.statPoints()),
        new AtributosJogador(
            valorOuAtual(quest.preRewardStrength(), perfilAtual.attributes().strength()),
            valorOuAtual(quest.preRewardIntelligence(), perfilAtual.attributes().intelligence()),
            valorOuAtual(quest.preRewardVitality(), perfilAtual.attributes().vitality()),
            valorOuAtual(quest.preRewardAgility(), perfilAtual.attributes().agility())
        ),
        perfilAtual.lastResetDate(),
        streaks.atual(),
        streaks.melhor(),
        projecao.lastQuestCompletionDate(),
        projecao.activityHistory(),
        perfilAtual.primaryFocus(),
        perfilAtual.hasCompletedOnboarding(),
        perfilAtual.weeklyBossLastClaimedAt(),
        projecao.questXp(),
        perfilAtual.authoritativeWeeklyBossXp(),
        perfilAtual.authoritativeWeeklyBossStatPoints(),
        perfilAtual.authoritativeAllocatedStatPoints(),
        1,
        SYNC_SOURCE,
        dados.idSessaoDispositivo(),
        dados.rotuloDispositivo(),
        now
    );
    QuestInventarioValidada questRevertida = new QuestInventarioValidada(
        quest.id(),
        quest.title(),
        quest.rewardAttribute(),
        quest.xpReward(),
        quest.category(),
        quest.templateType(),
        quest.verificationMode(),
        "none",
        quest.targetDurationMinutes(),
        quest.reflectionPrompt(),
        quest.reflectionAnswer(),
        quest.verificationStartedAt(),
        null,
        null,
        false,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        quest.journeyId(), quest.isArchived(), quest.plannedFor(), quest.recurrenceId(), quest.occursOn(),
        quest.mode(), quest.activityCategoryId(), quest.activityModalityId(), quest.activityId(),
        quest.executionType(), quest.activitySchemaVersion(), quest.targetStrengthSets(),
        quest.targetStrengthRepetitions(), quest.targetStrengthLoadKg()
    );
    Map<String, Object> perfilDoc = proximoPerfil.paraDocumento(
        dados.idSessaoDispositivo(),
        dados.rotuloDispositivo(),
        now,
        SYNC_SOURCE
    );
    Map<String, Object> questDoc = documentoQuest(questRevertida, contexto.indiceOrdem(), dados, now);
    return new EscritaMutacaoQuestPessoal(
        perfilDoc,
        questDoc,
        null,
        true,
        new RespostaMutacaoQuestPessoal("revoked", perfilDoc, dados.questId(), questDoc)
    );
  }

  private DadosComando validarComando(RequisicaoMutacaoQuestPessoal request, boolean exigeQuest) {
    if (request == null) {
      throw ValidadorPayloadInventarioQuest.badRequest("invalid_personal_quest_payload");
    }
    String idSessaoDispositivo = ValidadorPayloadInventarioQuest.requireString(
        request.idSessaoDispositivo(),
        "idSessaoDispositivo",
        120
    );
    String rotuloDispositivo = ValidadorPayloadInventarioQuest.optionalString(
        request.rotuloDispositivo(),
        "rotuloDispositivo",
        120,
        "device"
    );
    String questId = ValidadorPayloadInventarioQuest.requireString(request.questId(), "questId", 120);
    QuestInventarioValidada quest = null;
    if (exigeQuest) {
      if (request.quest() == null) {
        throw ValidadorPayloadInventarioQuest.badRequest("invalid_quest");
      }
      quest = validadorQuest.validarQuestPessoalDoComando(questId, request.quest());
    }
    return new DadosComando(idSessaoDispositivo, rotuloDispositivo, questId, quest);
  }

  @SuppressWarnings("unchecked")
  private PerfilJogador perfilDe(
      Map<String, Object> data,
      String nomeFallback,
      DadosComando dados,
      Timestamp now
  ) {
    Map<String, Object> attributes = data.get("attributes") instanceof Map<?, ?> raw
        ? (Map<String, Object>) raw
        : Map.of();
    int level = Math.max(1, inteiro(data.get("level"), 1));
    int maxXp = Math.max(1, inteiro(data.get("maxXp"), maxXpParaLevel(level)));
    return new PerfilJogador(
        nome(data.get("name"), nomeFallback),
        level,
        Math.min(inteiro(data.get("xp"), 0), Math.max(0, maxXp - 1)),
        maxXp,
        inteiro(data.get("statPoints"), 0),
        new AtributosJogador(
            Math.max(10, inteiro(attributes.get("strength"), 10)),
            Math.max(10, inteiro(attributes.get("intelligence"), 10)),
            Math.max(10, inteiro(attributes.get("vitality"), 10)),
            Math.max(10, inteiro(attributes.get("agility"), 10))
        ),
        timestamp(data.get("lastResetDate"), now),
        inteiro(data.get("currentStreak"), 0),
        inteiro(data.get("bestStreak"), 0),
        timestamp(data.get("lastQuestCompletionDate"), null),
        timestampsUnicosPorDia(listaTimestamps(data.get("activityHistory"))),
        foco(data.get("primaryFocus")),
        data.get("hasCompletedOnboarding") instanceof Boolean done && done,
        timestamp(data.get("weeklyBossLastClaimedAt"), null),
        inteiro(data.get("authoritativeQuestXp"), 0),
        inteiro(data.get("authoritativeWeeklyBossXp"), 0),
        inteiro(data.get("authoritativeWeeklyBossStatPoints"), 0),
        inteiro(data.get("authoritativeAllocatedStatPoints"), 0),
        1,
        data.get("syncSource") instanceof String source ? source : SYNC_SOURCE,
        data.get("activeDeviceSessionId") instanceof String session ? session : dados.idSessaoDispositivo(),
        data.get("activeDeviceLabel") instanceof String label ? label : dados.rotuloDispositivo(),
        timestamp(data.get("updatedAt"), now)
    );
  }

  private QuestInventarioValidada questDeDocumento(String questId, Map<String, Object> data) {
    return validadorQuest.validarQuestPessoalDoComando(questId, new QuestFonteInventario(
        questId,
        data.get("title"),
        data.get("rewardAttribute"),
        data.get("xpReward"),
        data.get("category"),
        data.get("templateType"),
        data.get("verificationMode"),
        data.get("verificationStatus"),
        data.get("targetDurationMinutes"),
        data.get("reflectionPrompt"),
        data.get("reflectionAnswer"),
        data.get("verificationStartedAt"),
        data.get("completedAt"),
        data.get("verifiedAt"),
        data.get("isCompleted"),
        data.get("preRewardLevel"),
        data.get("preRewardXp"),
        data.get("preRewardMaxXp"),
        data.get("preRewardStatPoints"),
        data.get("preRewardStrength"),
        data.get("preRewardIntelligence"),
        data.get("preRewardVitality"),
        data.get("preRewardAgility"),
        data.get("journeyId"),
        data.get("isArchived"),
        data.get("plannedFor"),
        data.get("recurrenceId"),
        data.get("occursOn"),
        data.get("mode"), data.get("activityCategoryId"), data.get("activityModalityId"),
        data.get("activityId"), data.get("executionType"), data.get("activitySchemaVersion"),
        data.get("targetStrengthSets"), data.get("targetStrengthRepetitions"),
        data.get("targetStrengthLoadKg")
    ));
  }

  private Map<String, Object> documentoQuest(
      QuestInventarioValidada quest,
      int indiceOrdem,
      DadosComando dados,
      Timestamp now
  ) {
    Map<String, Object> data = new LinkedHashMap<>();
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
    data.put("journeyId", quest.journeyId());
    data.put("isArchived", quest.isArchived());
    data.put("plannedFor", quest.plannedFor());
    data.put("recurrenceId", quest.recurrenceId());
    data.put("occursOn", quest.occursOn());
    data.put("mode", quest.mode());
    data.put("activityCategoryId", quest.activityCategoryId());
    data.put("activityModalityId", quest.activityModalityId());
    data.put("activityId", quest.activityId());
    data.put("executionType", quest.executionType());
    data.put("activitySchemaVersion", quest.activitySchemaVersion());
    data.put("targetStrengthSets", quest.targetStrengthSets());
    data.put("targetStrengthRepetitions", quest.targetStrengthRepetitions());
    data.put("targetStrengthLoadKg", quest.targetStrengthLoadKg());
    data.put("orderIndex", indiceOrdem);
    data.put("syncSchemaVersion", 1);
    data.put("syncSource", SYNC_SOURCE);
    data.put("activeDeviceSessionId", dados.idSessaoDispositivo());
    data.put("activeDeviceLabel", dados.rotuloDispositivo());
    data.put("updatedAt", now);
    return data;
  }

  private Map<String, Object> documentoConclusao(
      QuestInventarioValidada quest,
      PerfilJogador perfilAtual,
      Timestamp now
  ) {
    return new MapBuilder()
        .put("questId", quest.id())
        .put("title", quest.title())
        .put("rewardAttribute", quest.rewardAttribute())
        .put("xpReward", quest.xpReward())
        .put("completedAt", now)
        .put("preRewardLevel", perfilAtual.level())
        .put("preRewardXp", perfilAtual.xp())
        .put("preRewardMaxXp", perfilAtual.maxXp())
        .put("preRewardStatPoints", perfilAtual.statPoints())
        .put("preRewardStrength", perfilAtual.attributes().strength())
        .put("preRewardIntelligence", perfilAtual.attributes().intelligence())
        .put("preRewardVitality", perfilAtual.attributes().vitality())
        .put("preRewardAgility", perfilAtual.attributes().agility())
        .put("syncSource", "backend")
        .build();
  }

  private QuestInventarioValidada questConcluidaSemRecompensa(QuestInventarioValidada quest, Timestamp now) {
    return new QuestInventarioValidada(
        quest.id(), quest.title(), quest.rewardAttribute(), quest.xpReward(), quest.category(),
        quest.templateType(), quest.verificationMode(), "verified", quest.targetDurationMinutes(),
        quest.reflectionPrompt(), quest.reflectionAnswer(), quest.verificationStartedAt(),
        quest.completedAt() == null ? now : quest.completedAt(),
        quest.verifiedAt() == null ? now : quest.verifiedAt(),
        true, quest.preRewardLevel(), quest.preRewardXp(), quest.preRewardMaxXp(),
        quest.preRewardStatPoints(), quest.preRewardStrength(), quest.preRewardIntelligence(),
        quest.preRewardVitality(), quest.preRewardAgility(), quest.journeyId(), quest.isArchived(), quest.plannedFor(), quest.recurrenceId(), quest.occursOn(),
        quest.mode(), quest.activityCategoryId(), quest.activityModalityId(), quest.activityId(),
        quest.executionType(), quest.activitySchemaVersion(), quest.targetStrengthSets(),
        quest.targetStrengthRepetitions(), quest.targetStrengthLoadKg()
    );
  }

  private PerfilJogador aplicarXp(PerfilJogador perfil, int xpReward) {
    int xpAtual = perfil.xp() + xpReward;
    int levelAtual = perfil.level();
    int maxXpAtual = perfil.maxXp();
    int pontos = perfil.statPoints();
    while (xpAtual >= maxXpAtual) {
      xpAtual -= maxXpAtual;
      levelAtual += 1;
      pontos += 5;
      maxXpAtual = maxXpParaLevel(levelAtual);
    }
    return new PerfilJogador(
        perfil.name(), levelAtual, xpAtual, maxXpAtual, pontos, perfil.attributes(),
        perfil.lastResetDate(), perfil.currentStreak(), perfil.bestStreak(),
        perfil.lastQuestCompletionDate(), perfil.activityHistory(),
        perfil.primaryFocus(), perfil.hasCompletedOnboarding(), perfil.weeklyBossLastClaimedAt(),
        perfil.authoritativeQuestXp(), perfil.authoritativeWeeklyBossXp(),
        perfil.authoritativeWeeklyBossStatPoints(), perfil.authoritativeAllocatedStatPoints(),
        perfil.syncSchemaVersion(), perfil.syncSource(), perfil.activeDeviceSessionId(),
        perfil.activeDeviceLabel(), perfil.updatedAt()
    );
  }

  private ProjecaoConclusoes projetarConclusoesRestantes(
      List<Map<String, Object>> conclusoes,
      String questIdRevogada,
      Timestamp now
  ) {
    List<Map<String, Object>> restantes = conclusoes.stream()
        .filter(data -> !questIdRevogada.equals(data.get("questId")))
        .toList();
    List<Timestamp> historico = timestampsUnicosPorDia(restantes.stream()
        .map(data -> timestamp(data.get("completedAt"), null))
        .filter(value -> value != null)
        .toList());
    int questXp = restantes.stream()
        .mapToInt(data -> inteiro(data.get("xpReward"), 0))
        .sum();
    return new ProjecaoConclusoes(
        historico,
        historico.isEmpty() ? null : historico.getLast(),
        questXp
    );
  }

  private List<Timestamp> historicoComDia(List<Timestamp> historico, Timestamp now) {
    List<Timestamp> novo = new ArrayList<>(historico);
    novo.add(now);
    return timestampsUnicosPorDia(novo);
  }

  private List<Timestamp> timestampsUnicosPorDia(List<Timestamp> timestamps) {
    Map<LocalDate, Timestamp> porDia = new HashMap<>();
    for (Timestamp timestamp : timestamps) {
      porDia.put(dataLocal(timestamp), timestamp);
    }
    return porDia.values().stream()
        .sorted(Comparator.comparing(Timestamp::toDate))
        .toList();
  }

  private Streaks streaks(List<Timestamp> historico, Timestamp now) {
    if (historico.isEmpty()) {
      return new Streaks(0, 0);
    }
    List<LocalDate> dias = historico.stream().map(this::dataLocal).toList();
    int melhor = 1;
    int sequencia = 1;
    for (int index = 1; index < dias.size(); index++) {
      long diff = dias.get(index - 1).datesUntil(dias.get(index)).count();
      if (diff == 1) {
        sequencia += 1;
        melhor = Math.max(melhor, sequencia);
      } else {
        sequencia = 1;
      }
    }
    long gap = dias.getLast().datesUntil(dataLocal(now)).count();
    if (gap > 1) {
      return new Streaks(0, melhor);
    }
    int atual = 1;
    for (int index = dias.size() - 1; index > 0; index--) {
      long diff = dias.get(index - 1).datesUntil(dias.get(index)).count();
      if (diff != 1) {
        break;
      }
      atual += 1;
    }
    return new Streaks(atual, melhor);
  }

  private void exigirQuestPessoal(QuestInventarioValidada quest) {
    if (!"personal".equals(quest.category())) {
      throw new ExcecaoApi(
          HttpStatus.PRECONDITION_FAILED,
          "personal_quest_required",
          "Apenas quests pessoais usam este comando."
      );
    }
  }

  @SuppressWarnings("unchecked")
  private List<Timestamp> listaTimestamps(Object value) {
    if (!(value instanceof List<?> list)) {
      return List.of();
    }
    return ((List<Object>) list).stream()
        .map(entry -> timestamp(entry, null))
        .filter(entry -> entry != null)
        .toList();
  }

  private Timestamp timestamp(Object value, Timestamp fallback) {
    return value instanceof Timestamp timestamp ? timestamp : fallback;
  }

  private int inteiro(Object value, int fallback) {
    if (!(value instanceof Number number)) {
      return fallback;
    }
    int asInt = number.intValue();
    return asInt < 0 ? fallback : asInt;
  }

  private int valorOuAtual(Integer value, int atual) {
    return value == null ? atual : value;
  }

  private String nome(Object value, String fallback) {
    if (value instanceof String text && !text.trim().isEmpty()) {
      return text.trim().length() > 40 ? text.trim().substring(0, 40) : text.trim();
    }
    return fallback == null || fallback.isBlank() ? "Hunter" : fallback;
  }

  private String foco(Object value) {
    if (value instanceof String text && SetFoco.VALIDOS.contains(text)) {
      return text;
    }
    return "discipline";
  }

  private int maxXpParaLevel(int level) {
    int current = 100;
    for (int index = 1; index < level; index++) {
      current = (int) Math.floor(current * 1.2);
    }
    return current;
  }

  private LocalDate dataLocal(Timestamp timestamp) {
    return timestamp.toDate().toInstant().atZone(ZONA_DATA).toLocalDate();
  }

  private record DadosComando(
      String idSessaoDispositivo,
      String rotuloDispositivo,
      String questId,
      QuestInventarioValidada quest
  ) {
  }

  private record Streaks(int atual, int melhor) {
  }

  private record ProjecaoConclusoes(
      List<Timestamp> activityHistory,
      Timestamp lastQuestCompletionDate,
      int questXp
  ) {
  }

  private static final class SetFoco {
    private static final List<String> VALIDOS = List.of(
        "discipline",
        "study",
        "training",
        "health",
        "productivity"
    );
  }
}
