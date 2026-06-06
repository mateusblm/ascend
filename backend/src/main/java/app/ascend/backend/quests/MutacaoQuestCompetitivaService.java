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
import java.util.Set;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class MutacaoQuestCompetitivaService {

  private static final String SYNC_SOURCE = "callable_server_authoritative";
  private static final ZoneId ZONA_DATA = ZoneId.systemDefault();
  private static final Set<String> PROVEDORES_VALIDOS = Set.of("manual", "appTimer", "mockEvidence", "healthConnect");
  private static final Set<String> TIPOS_EVIDENCIA_VALIDOS = Set.of(
      "timedFocus",
      "runningDistance",
      "readingComprehension",
      "workoutSession",
      "studySession"
  );

  private final GuardaSessaoAtiva guardaSessaoAtiva;
  private final ValidadorRequisicaoInventarioQuest validadorQuest;
  private final CatalogoQuestCompetitiva catalogo;
  private final RepositorioQuestCompetitiva repositorio;

  public MutacaoQuestCompetitivaService(
      GuardaSessaoAtiva guardaSessaoAtiva,
      ValidadorRequisicaoInventarioQuest validadorQuest,
      CatalogoQuestCompetitiva catalogo,
      RepositorioQuestCompetitiva repositorio
  ) {
    this.guardaSessaoAtiva = guardaSessaoAtiva;
    this.validadorQuest = validadorQuest;
    this.catalogo = catalogo;
    this.repositorio = repositorio;
  }

  /**
   * Inicia uma tentativa competitiva autoritativa para o dia atual. O backend
   * sempre usa o horario do servidor para impedir que uma sessao local antiga
   * ressuscite uma tentativa de outro dia.
   */
  public RespostaInicioQuestCompetitiva iniciarSessao(String uid, RequisicaoQuestCompetitiva request) {
    DadosComando dados = validarComando(request, false);
    guardaSessaoAtiva.exigirSessaoAtiva(uid, dados.idSessaoDispositivo());
    Timestamp now = Timestamp.now();
    String attemptId = attemptId(dados.questId(), dayKey(now));
    return (RespostaInicioQuestCompetitiva) repositorio.executarMutacaoCompetitiva(
        uid,
        dados.questId(),
        attemptId,
        null,
        contexto -> iniciarNoContexto(dados, now)
    );
  }

  /**
   * Valida evidencia competitiva, grava auditoria e concede recompensa uma vez.
   * O cliente pode coletar a evidencia, mas a decisao aceita/rejeitada e os
   * efeitos em perfil, quest e grant sao sempre calculados neste backend.
   */
  public RespostaVerificacaoQuestCompetitiva verificarConclusao(
      String uid,
      String nomeFallback,
      RequisicaoQuestCompetitiva request
  ) {
    DadosComando dados = validarComando(request, true);
    guardaSessaoAtiva.exigirSessaoAtiva(uid, dados.idSessaoDispositivo());
    Timestamp now = Timestamp.now();
    String attemptId = attemptId(dados.questId(), dayKey(firstNonNull(dados.quest().verificationStartedAt(), now)));
    return (RespostaVerificacaoQuestCompetitiva) repositorio.executarMutacaoCompetitiva(
        uid,
        dados.questId(),
        attemptId,
        dados.evidencia().sourceActivityId(),
        contexto -> verificarNoContexto(contexto, dados, nomeFallback, now, attemptId)
    );
  }

  private EscritaQuestCompetitiva iniciarNoContexto(DadosComando dados, Timestamp now) {
    Map<String, Object> sessao = new MapBuilder()
        .put("questId", dados.questId())
        .put("title", dados.quest().title())
        .put("dayKey", dayKey(now))
        .put("templateType", dados.quest().templateType())
        .put("verificationMode", dados.quest().verificationMode())
        .put("targetDurationMinutes", dados.quest().targetDurationMinutes())
        .put("xpReward", dados.quest().xpReward())
        .put("rewardAttribute", dados.quest().rewardAttribute())
        .put("startedAt", now)
        .put("status", "inProgress")
        .put("updatedAt", now)
        .build();
    return new EscritaQuestCompetitiva(
        null,
        null,
        sessao,
        null,
        null,
        null,
        new RespostaInicioQuestCompetitiva("started", now.toDate().toInstant().toString())
    );
  }

  private EscritaQuestCompetitiva verificarNoContexto(
      ContextoQuestCompetitiva contexto,
      DadosComando dados,
      String nomeFallback,
      Timestamp now,
      String attemptId
  ) {
    PerfilJogador perfilAtual = perfilDe(contexto.perfil(), nomeFallback, dados, now);
    QuestInventarioValidada questExistente = contexto.questExiste()
        ? questDeDocumento(dados.questId(), contexto.quest())
        : null;
    QuestInventarioValidada quest = questExistente != null ? questExistente : dados.quest();
    exigirQuestCompetitiva(quest);

    if (contexto.concessaoExiste()) {
      Timestamp completedAt = timestamp(contexto.concessao().get("completedAt"), now);
      Map<String, Object> questResposta = documentoQuest(
          questConcluidaSemRecompensa(quest, completedAt),
          contexto.indiceOrdem(),
          dados,
          now
      );
      return new EscritaQuestCompetitiva(
          null,
          null,
          null,
          null,
          null,
          null,
          new RespostaVerificacaoQuestCompetitiva(
              "already_verified",
              completedAt.toDate().toInstant().toString(),
              null,
              perfilAtual.paraDocumento(dados.idSessaoDispositivo(), dados.rotuloDispositivo(), now, perfilAtual.syncSource()),
              dados.questId(),
              questResposta
          )
      );
    }

    exigirSessaoIniciada(contexto, quest, now);
    if ("timerWithReflection".equals(quest.verificationMode())
        && (dados.respostaReflexao() == null || dados.respostaReflexao().isBlank())) {
      throw precondition("missing_reflection", "A resposta curta ainda nao foi enviada.");
    }

    DecisaoEvidenciaCompetitiva decisao = avaliarEvidencia(dados.definicao(), dados.evidencia(), now);
    if (contexto.sourceActivityIdJaUsado()) {
      throw precondition(
          "duplicate_source_activity_id",
          "Evidencia competitiva insuficiente: duplicateSourceActivityId."
      );
    }
    if (!decisao.aceita()) {
      throw precondition(
          "competitive_evidence_insufficient",
          "Evidencia competitiva insuficiente: "
              + (decisao.riskFlags().isEmpty() ? decisao.status() : String.join(",", decisao.riskFlags()))
              + "."
      );
    }

    PerfilJogador recompensado = aplicarXp(perfilAtual, quest.xpReward());
    AtributosJogador atributos = recompensado.attributes().incrementar(quest.rewardAttribute());
    List<Timestamp> historico = historicoComDia(perfilAtual.activityHistory(), now);
    List<Timestamp> historicoCompetitivo = historicoComDia(perfilAtual.competitiveActivityHistory(), now);
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
        now,
        historicoCompetitivo,
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
        dados.respostaReflexao() != null ? dados.respostaReflexao() : quest.reflectionAnswer(),
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
        perfilAtual.attributes().agility()
    );
    Map<String, Object> perfilDoc = proximoPerfil.paraDocumento(
        dados.idSessaoDispositivo(),
        dados.rotuloDispositivo(),
        now,
        SYNC_SOURCE
    );
    Map<String, Object> questDoc = documentoQuest(questAtualizada, contexto.indiceOrdem(), dados, now);
    return new EscritaQuestCompetitiva(
        perfilDoc,
        questDoc,
        documentoSessaoVerificada(dados, now),
        documentoConcessao(quest, dados, decisao, now),
        documentoConclusao(questAtualizada, perfilAtual, now),
        documentoAuditoria(quest, dados, decisao, now),
        new RespostaVerificacaoQuestCompetitiva(
            "verified",
            now.toDate().toInstant().toString(),
            decisao,
            perfilDoc,
            dados.questId(),
            questDoc
        )
    );
  }

  private DadosComando validarComando(RequisicaoQuestCompetitiva request, boolean exigeEvidencia) {
    if (request == null) {
      throw ValidadorPayloadInventarioQuest.badRequest("invalid_competitive_quest_payload");
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
    if (request.quest() == null) {
      throw ValidadorPayloadInventarioQuest.badRequest("invalid_quest");
    }
    QuestInventarioValidada quest = validadorQuest.validarQuestCompetitivaDoComando(questId, request.quest());
    DefinicaoQuestCompetitiva definicao = catalogo.buscarCompativel(
            quest.title(),
            quest.templateType(),
            quest.verificationMode(),
            quest.targetDurationMinutes(),
            quest.xpReward(),
            quest.rewardAttribute()
        )
        .orElseThrow(() -> ValidadorPayloadInventarioQuest.badRequest("invalid_quest"));
    EvidenciaCompetitivaValidada evidencia = exigeEvidencia
        ? validarEvidencia(request.evidencia(), questId)
        : null;
    String respostaReflexao = ValidadorPayloadInventarioQuest.optionalString(
        request.respostaReflexao(),
        "reflectionAnswer",
        500,
        null
    );
    return new DadosComando(idSessaoDispositivo, rotuloDispositivo, questId, quest, definicao, evidencia, respostaReflexao);
  }

  @SuppressWarnings("unchecked")
  private EvidenciaCompetitivaValidada validarEvidencia(EvidenciaQuestCompetitiva evidencia, String questIdEsperado) {
    if (evidencia == null) {
      throw ValidadorPayloadInventarioQuest.badRequest("invalid_evidence");
    }
    String questId = ValidadorPayloadInventarioQuest.requireString(evidencia.questId(), "evidence.questId", 120);
    if (!questIdEsperado.equals(questId)) {
      throw new ExcecaoApi(
          HttpStatus.FORBIDDEN,
          "evidence_quest_mismatch",
          "Evidencia enviada para quest diferente."
      );
    }
    String provider = ValidadorPayloadInventarioQuest.requireAllowed(
        evidencia.provider(),
        "evidence.provider",
        PROVEDORES_VALIDOS
    );
    String type = ValidadorPayloadInventarioQuest.requireAllowed(
        evidencia.type(),
        "evidence.type",
        TIPOS_EVIDENCIA_VALIDOS
    );
    List<String> answers = evidencia.answers() instanceof List<?> list
        ? ((List<Object>) list).stream()
            .filter(String.class::isInstance)
            .map(String.class::cast)
            .map(String::trim)
            .filter(text -> !text.isEmpty())
            .limit(20)
            .toList()
        : List.of();
    return new EvidenciaCompetitivaValidada(
        questId,
        provider,
        type,
        ValidadorPayloadInventarioQuest.optionalTimestamp(evidencia.startedAt(), "evidence.startedAt"),
        ValidadorPayloadInventarioQuest.optionalTimestamp(evidencia.completedAt(), "evidence.completedAt"),
        ValidadorPayloadInventarioQuest.optionalNonNegativeInt(evidencia.durationMinutes(), "evidence.durationMinutes"),
        ValidadorPayloadInventarioQuest.optionalNonNegativeInt(evidencia.distanceMeters(), "evidence.distanceMeters"),
        ValidadorPayloadInventarioQuest.optionalString(evidencia.sourceActivityId(), "evidence.sourceActivityId", 160, null),
        ValidadorPayloadInventarioQuest.optionalNonNegativeInt(evidencia.quizScore(), "evidence.quizScore"),
        ValidadorPayloadInventarioQuest.optionalString(evidencia.quizId(), "evidence.quizId", 160, null),
        answers,
        ValidadorPayloadInventarioQuest.optionalString(evidencia.reflection(), "evidence.reflection", 500, null)
    );
  }

  private DecisaoEvidenciaCompetitiva avaliarEvidencia(
      DefinicaoQuestCompetitiva requisito,
      EvidenciaCompetitivaValidada evidencia,
      Timestamp now
  ) {
    List<String> flags = new ArrayList<>();
    if (!evidencia.type().equals(requisito.evidenceType()) || !requisito.allowedProviders().contains(evidencia.provider())) {
      flags.add("invalidProvider");
    }
    if (evidencia.completedAt().toDate().before(evidencia.startedAt().toDate())) {
      flags.add("completedBeforeStart");
    }
    int elapsedMinutes = (int) ((evidencia.completedAt().toSqlTimestamp().getTime()
        - evidencia.startedAt().toSqlTimestamp().getTime()) / 60000);
    int effectiveDuration = evidencia.durationMinutes() == null ? elapsedMinutes : evidencia.durationMinutes();
    if (effectiveDuration <= 0) {
      flags.add("missingDuration");
    } else if (effectiveDuration < requisito.minimumDurationMinutes()) {
      flags.add("durationTooShort");
    }
    if (requisito.minimumDistanceMeters() > 0) {
      int distance = evidencia.distanceMeters() == null ? 0 : evidencia.distanceMeters();
      if (distance <= 0) {
        flags.add("missingDistance");
      } else if (distance < requisito.minimumDistanceMeters()) {
        flags.add("distanceTooShort");
      }
      if (distance > 0 && effectiveDuration > 0) {
        double metersPerMinute = (double) distance / effectiveDuration;
        if (metersPerMinute > 420) {
          flags.add("impossiblePace");
        } else if (metersPerMinute > 300) {
          flags.add("unusuallyFastPace");
        }
      }
    }
    if (requisito.minimumQuizScore() > 0 && (evidencia.quizScore() == null || evidencia.quizScore() < requisito.minimumQuizScore())) {
      flags.add(requisito.evidenceType().equals("readingComprehension") ? "missingQuizAttempt" : "missingQuiz");
    }
    if (evidencia.completedAt().toSqlTimestamp().getTime() < now.toSqlTimestamp().getTime() - 2L * 24 * 60 * 60 * 1000) {
      flags.add("staleEvidence");
    }
    if (flags.stream().anyMatch(Set.of("invalidProvider", "completedBeforeStart", "impossiblePace", "staleEvidence")::contains)) {
      return new DecisaoEvidenciaCompetitiva("rejected", 0, flags);
    }
    if (flags.stream().anyMatch(Set.of(
        "missingDuration",
        "durationTooShort",
        "missingDistance",
        "distanceTooShort",
        "missingQuiz",
        "missingQuizAttempt"
    )::contains)) {
      return new DecisaoEvidenciaCompetitiva("insufficientEvidence", 15, flags);
    }
    int baseConfidence = switch (evidencia.provider()) {
      case "manual" -> 35;
      case "appTimer" -> 65;
      case "healthConnect" -> 85;
      default -> 75;
    };
    int confidence = flags.contains("unusuallyFastPace") ? Math.max(0, baseConfidence - 25) : baseConfidence;
    return new DecisaoEvidenciaCompetitiva(
        flags.contains("unusuallyFastPace") ? "needsReview" : "accepted",
        confidence,
        flags
    );
  }

  private void exigirSessaoIniciada(ContextoQuestCompetitiva contexto, QuestInventarioValidada quest, Timestamp now) {
    if (!("timer".equals(quest.verificationMode()) || "timerWithReflection".equals(quest.verificationMode()))) {
      return;
    }
    Timestamp startedAt = timestamp(contexto.sessao().get("startedAt"), null);
    if (!contexto.sessaoExiste() || startedAt == null) {
      throw precondition("competitive_session_not_started", "A sessao ainda nao foi iniciada.");
    }
    long elapsedMinutes = (now.toSqlTimestamp().getTime() - startedAt.toSqlTimestamp().getTime()) / 60000;
    if (elapsedMinutes < quest.targetDurationMinutes()) {
      throw precondition("competitive_timer_too_short", "Ainda falta tempo para validar essa quest.");
    }
  }

  private Map<String, Object> documentoSessaoVerificada(DadosComando dados, Timestamp now) {
    return new MapBuilder()
        .put("dayKey", dayKey(dados.quest().verificationStartedAt() == null ? now : dados.quest().verificationStartedAt()))
        .put("status", "verified")
        .put("completedAt", now)
        .put("updatedAt", now)
        .build();
  }

  private Map<String, Object> documentoConcessao(
      QuestInventarioValidada quest,
      DadosComando dados,
      DecisaoEvidenciaCompetitiva decisao,
      Timestamp now
  ) {
    return new MapBuilder()
        .put("questId", quest.id())
        .put("title", quest.title())
        .put("dayKey", dayKey(dados.quest().verificationStartedAt() == null ? now : dados.quest().verificationStartedAt()))
        .put("templateType", quest.templateType())
        .put("verificationMode", quest.verificationMode())
        .put("targetDurationMinutes", quest.targetDurationMinutes())
        .put("xpReward", quest.xpReward())
        .put("rewardAttribute", quest.rewardAttribute())
        .put("evidenceType", dados.evidencia().type())
        .put("evidenceProvider", dados.evidencia().provider())
        .put("confidenceScore", decisao.confidenceScore())
        .put("riskFlags", decisao.riskFlags())
        .put("sourceActivityId", dados.evidencia().sourceActivityId())
        .put("completedAt", now)
        .put("approvedAt", now)
        .build();
  }

  private Map<String, Object> documentoAuditoria(
      QuestInventarioValidada quest,
      DadosComando dados,
      DecisaoEvidenciaCompetitiva decisao,
      Timestamp now
  ) {
    return new MapBuilder()
        .put("questId", quest.id())
        .put("title", quest.title())
        .put("templateType", quest.templateType())
        .put("evidenceType", dados.evidencia().type())
        .put("evidenceProvider", dados.evidencia().provider())
        .put("startedAt", dados.evidencia().startedAt())
        .put("completedAt", dados.evidencia().completedAt())
        .put("durationMinutes", dados.evidencia().durationMinutes())
        .put("distanceMeters", dados.evidencia().distanceMeters())
        .put("sourceActivityId", dados.evidencia().sourceActivityId())
        .put("quizId", dados.evidencia().quizId())
        .put("quizScore", dados.evidencia().quizScore())
        .put("quizRiskFlags", List.of())
        .put("confidenceScore", decisao.confidenceScore())
        .put("riskFlags", decisao.riskFlags())
        .put("status", decisao.status())
        .put("auditedAt", now)
        .put("syncSource", "backend")
        .put("activeDeviceSessionId", dados.idSessaoDispositivo())
        .put("activeDeviceLabel", dados.rotuloDispositivo())
        .build();
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
        .put("countsTowardCompetitive", true)
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

  @SuppressWarnings("unchecked")
  private PerfilJogador perfilDe(Map<String, Object> data, String nomeFallback, DadosComando dados, Timestamp now) {
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
        timestamp(data.get("lastCompetitiveQuestCompletionDate"), null),
        timestampsUnicosPorDia(listaTimestamps(data.get("competitiveActivityHistory"))),
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
    return validadorQuest.validarQuestCompetitivaDoComando(questId, new QuestFonteInventario(
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
        data.get("preRewardAgility")
    ));
  }

  private Map<String, Object> documentoQuest(QuestInventarioValidada quest, int indiceOrdem, DadosComando dados, Timestamp now) {
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
    data.put("orderIndex", indiceOrdem);
    data.put("syncSchemaVersion", 1);
    data.put("syncSource", SYNC_SOURCE);
    data.put("activeDeviceSessionId", dados.idSessaoDispositivo());
    data.put("activeDeviceLabel", dados.rotuloDispositivo());
    data.put("updatedAt", now);
    return data;
  }

  private QuestInventarioValidada questConcluidaSemRecompensa(QuestInventarioValidada quest, Timestamp completedAt) {
    return new QuestInventarioValidada(
        quest.id(), quest.title(), quest.rewardAttribute(), quest.xpReward(), quest.category(),
        quest.templateType(), quest.verificationMode(), "verified", quest.targetDurationMinutes(),
        quest.reflectionPrompt(), quest.reflectionAnswer(), quest.verificationStartedAt(),
        completedAt, completedAt, true, quest.preRewardLevel(), quest.preRewardXp(), quest.preRewardMaxXp(),
        quest.preRewardStatPoints(), quest.preRewardStrength(), quest.preRewardIntelligence(),
        quest.preRewardVitality(), quest.preRewardAgility()
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
        perfil.lastCompetitiveQuestCompletionDate(), perfil.competitiveActivityHistory(),
        perfil.primaryFocus(), perfil.hasCompletedOnboarding(), perfil.weeklyBossLastClaimedAt(),
        perfil.authoritativeQuestXp(), perfil.authoritativeWeeklyBossXp(),
        perfil.authoritativeWeeklyBossStatPoints(), perfil.authoritativeAllocatedStatPoints(),
        perfil.syncSchemaVersion(), perfil.syncSource(), perfil.activeDeviceSessionId(),
        perfil.activeDeviceLabel(), perfil.updatedAt()
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

  private void exigirQuestCompetitiva(QuestInventarioValidada quest) {
    if (!"competitive".equals(quest.category())) {
      throw precondition("competitive_quest_required", "Apenas quests competitivas usam este comando.");
    }
  }

  private ExcecaoApi precondition(String codigo, String mensagem) {
    return new ExcecaoApi(HttpStatus.PRECONDITION_FAILED, codigo, mensagem);
  }

  private String attemptId(String questId, String dayKey) {
    return questId + "__" + dayKey;
  }

  private String dayKey(Timestamp timestamp) {
    return dataLocal(timestamp).toString();
  }

  private Timestamp timestamp(Object value, Timestamp fallback) {
    return value instanceof Timestamp timestamp ? timestamp : fallback;
  }

  private Timestamp firstNonNull(Timestamp first, Timestamp second) {
    return first != null ? first : second;
  }

  private int inteiro(Object value, int fallback) {
    if (!(value instanceof Number number)) {
      return fallback;
    }
    int asInt = number.intValue();
    return asInt < 0 ? fallback : asInt;
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
      QuestInventarioValidada quest,
      DefinicaoQuestCompetitiva definicao,
      EvidenciaCompetitivaValidada evidencia,
      String respostaReflexao
  ) {
  }

  private record Streaks(int atual, int melhor) {
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
