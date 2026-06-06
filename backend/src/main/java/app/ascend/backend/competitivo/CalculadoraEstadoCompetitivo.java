package app.ascend.backend.competitivo;

import java.time.DayOfWeek;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.temporal.TemporalAdjusters;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.TreeSet;

public class CalculadoraEstadoCompetitivo {

  static final int VERSAO_SCHEMA_SINCRONIZACAO = 3;
  static final String FONTE_BACKEND = "backend";

  /**
   * Avalia o snapshot competitivo a partir de historico autoritativo de dias
   * competitivos. Esta regra ainda roda em modo de paridade: ela replica o
   * contrato TypeScript sem escrever no Firestore nem conceder recompensa.
   */
  public SnapshotRankCompetitivo avaliarRank(FonteEstadoRankCompetitivo fonte, Instant agora) {
    Instant dataCalculo = agora == null ? Instant.now() : agora;
    String weekKey = chaveSemana(dataCalculo);
    String highestEligibleRank = rankPorLevel(fonte.playerLevel());
    String seedRank = fonte.previousSnapshot() == null
        ? rankPorLevel(fonte.playerLevel())
        : normalizarRank(fonte.previousSnapshot().currentRank());
    String previousPeakRank = fonte.previousSnapshot() == null
        ? seedRank
        : normalizarRank(valorOuPadrao(
            fonte.previousSnapshot().peakRank(),
            fonte.previousSnapshot().currentRank(),
            seedRank
        ));
    String peakRank = rankMaior(previousPeakRank, seedRank);
    RegraRankCompetitivo baseRule = regraParaRank(seedRank);
    int bossTargetDays = regraParaRank(seedRank).diasAtivosObrigatorios();
    int activeDaysBase = datasDaSemana(fonte.competitiveActivityHistory(), dataCalculo).size();
    boolean bossCompletedBase = activeDaysBase >= bossTargetDays;
    boolean maintenanceMetBase = manutencaoCumprida(
        activeDaysBase,
        baseRule.diasAtivosObrigatorios(),
        baseRule.exigeBossConcluido(),
        bossCompletedBase
    );
    boolean isNewWeek = fonte.previousSnapshot() == null
        || !Objects.equals(fonte.previousSnapshot().weekKey(), weekKey);

    String currentRank = seedRank;
    int demotionStrikes = fonte.previousSnapshot() == null
        ? 0
        : fonte.previousSnapshot().demotionStrikes();
    String status = "secure";

    if (maintenanceMetBase) {
      demotionStrikes = 0;
    } else if (isNewWeek) {
      demotionStrikes += 1;
      if (demotionStrikes >= baseRule.maximoSemanasFalhasAntesDaQueda()) {
        String previousRank = rankAntes(seedRank);
        if (previousRank != null) {
          currentRank = previousRank;
          demotionStrikes = 0;
          status = "demoted";
        }
      }
    }

    RegraRankCompetitivo currentRule = regraParaRank(currentRank);
    int currentActiveDays = activeDaysBase;
    boolean currentBossCompleted = currentActiveDays >= currentRule.diasAtivosObrigatorios();
    boolean currentMaintenanceMet = manutencaoCumprida(
        currentActiveDays,
        currentRule.diasAtivosObrigatorios(),
        currentRule.exigeBossConcluido(),
        currentBossCompleted
    );
    String nextRank = rankDepois(currentRank);
    RegraRankCompetitivo nextRule = nextRank == null ? null : regraParaRank(nextRank);
    boolean nextBossCompleted = nextRule != null
        && currentActiveDays >= nextRule.diasAtivosObrigatorios();
    int targetRequiredLevel = nextRule == null ? fonte.playerLevel() : nextRule.levelMinimo();
    boolean targetLevelGateMet = nextRule == null || fonte.playerLevel() >= nextRule.levelMinimo();
    String advancementMode = nextRank == null ? null : modoPromocao(currentRank, peakRank);

    if (!"demoted".equals(status)) {
      boolean promotionReady = promocaoPronta(
          currentRank,
          currentActiveDays,
          nextBossCompleted,
          fonte.playerLevel()
      );
      if (promotionReady) {
        status = "promotionReady";
      } else if (currentMaintenanceMet) {
        status = "secure";
      } else {
        int missingDays = Math.max(0, currentRule.diasAtivosObrigatorios() - currentActiveDays);
        boolean bossBlocked = currentRule.exigeBossConcluido() && !currentBossCompleted;
        status = missingDays <= 1 && !bossBlocked ? "warning" : "critical";
      }
    }

    String eventType = tipoEventoRank(
        status,
        currentActiveDays,
        currentRule.diasAtivosObrigatorios(),
        currentBossCompleted,
        advancementMode
    );

    return new SnapshotRankCompetitivo(
        currentRank,
        peakRank,
        highestEligibleRank,
        weekKey,
        currentActiveDays,
        currentRule.diasAtivosObrigatorios(),
        currentRule.exigeBossConcluido(),
        currentBossCompleted,
        status,
        demotionStrikes,
        "promotionReady".equals(status),
        nextRank,
        targetRequiredLevel,
        targetLevelGateMet,
        advancementMode,
        eventType,
        resumoStatus(status, currentRank, nextRank, advancementMode),
        detalheStatus(
            status,
            currentRank,
            peakRank,
            highestEligibleRank,
            currentRule,
            currentActiveDays,
            currentBossCompleted,
            demotionStrikes,
            nextRank,
            targetRequiredLevel,
            targetLevelGateMet,
            advancementMode
        ),
        VERSAO_SCHEMA_SINCRONIZACAO,
        FONTE_BACKEND,
        dataCalculo
    );
  }

  /**
   * Avalia sinais de integridade competitiva sem aplicar punicao direta. O
   * score resultante serve como read-model de confianca e precisa continuar
   * separado de grants de XP ou promocao.
   */
  public SnapshotIntegridadeCompetitiva avaliarIntegridade(
      FonteIntegridadeCompetitiva fonte,
      Instant agora
  ) {
    Instant dataCalculo = agora == null ? Instant.now() : agora;
    LocalDate hoje = dataNormalizada(dataCalculo);
    String weekKey = chaveSemana(dataCalculo);
    Set<LocalDate> activeWeekDates = datasDaSemana(fonte.activityHistory(), dataCalculo);
    Set<LocalDate> competitiveWeekDates =
        datasDaSemana(fonte.competitiveActivityHistory(), dataCalculo);
    List<QuestFonteIntegridadeCompetitiva> completedToday = fonte.quests().stream()
        .filter(QuestFonteIntegridadeCompetitiva::isCompleted)
        .filter(quest -> quest.completedAt() != null)
        .filter(quest -> dataNormalizada(quest.completedAt()).equals(hoje))
        .toList();
    List<QuestFonteIntegridadeCompetitiva> personalCompletedToday = completedToday.stream()
        .filter(quest -> !quest.isCompetitive())
        .toList();
    List<QuestFonteIntegridadeCompetitiva> competitiveCompletedToday = completedToday.stream()
        .filter(QuestFonteIntegridadeCompetitiva::countsTowardCompetitive)
        .toList();
    int personalXpToday = personalCompletedToday.stream()
        .mapToInt(QuestFonteIntegridadeCompetitiva::xpReward)
        .sum();
    int competitiveXpToday = competitiveCompletedToday.stream()
        .mapToInt(QuestFonteIntegridadeCompetitiva::xpReward)
        .sum();
    int suspiciousPatternCount = contarPadroesSuspeitos(
        personalCompletedToday,
        competitiveCompletedToday,
        personalXpToday,
        activeWeekDates.size(),
        competitiveWeekDates.size()
    );
    int trustScore = calcularScoreConfianca(
        activeWeekDates.size(),
        competitiveWeekDates.size(),
        personalCompletedToday.size(),
        competitiveCompletedToday.size(),
        personalXpToday,
        competitiveXpToday,
        suspiciousPatternCount
    );
    String trustBand = faixaConfianca(trustScore);

    return new SnapshotIntegridadeCompetitiva(
        weekKey,
        trustScore,
        trustBand,
        activeWeekDates.size(),
        competitiveWeekDates.size(),
        personalCompletedToday.size(),
        competitiveCompletedToday.size(),
        personalXpToday,
        competitiveXpToday,
        suspiciousPatternCount,
        resumoIntegridade(trustBand),
        detalheIntegridade(
            trustBand,
            activeWeekDates.size(),
            competitiveWeekDates.size(),
            personalCompletedToday.size(),
            competitiveCompletedToday.size(),
            suspiciousPatternCount
        ),
        VERSAO_SCHEMA_SINCRONIZACAO,
        FONTE_BACKEND,
        dataCalculo
    );
  }

  private boolean manutencaoCumprida(
      int activeDays,
      int requiredActiveDays,
      boolean requiresBossClear,
      boolean bossCompleted
  ) {
    return activeDays >= requiredActiveDays && (!requiresBossClear || bossCompleted);
  }

  private boolean promocaoPronta(
      String currentRank,
      int activeDays,
      boolean bossCompleted,
      int playerLevel
  ) {
    String nextRank = rankDepois(currentRank);
    if (nextRank == null) {
      return false;
    }

    RegraRankCompetitivo nextRule = regraParaRank(nextRank);
    return playerLevel >= nextRule.levelMinimo()
        && activeDays >= nextRule.diasAtivosObrigatorios()
        && (!nextRule.exigeBossConcluido() || bossCompleted);
  }

  private String tipoEventoRank(
      String status,
      int activeDays,
      int requiredActiveDays,
      boolean bossCompleted,
      String advancementMode
  ) {
    if ("demoted".equals(status)) {
      return "demotionApplied";
    }
    if ("promotionReady".equals(status)) {
      return "reconquest".equals(advancementMode) ? "reconquestUnlocked" : "promotionUnlocked";
    }
    if ("warning".equals(status) || "critical".equals(status)) {
      return "warning";
    }
    if (activeDays >= requiredActiveDays + 1 && bossCompleted) {
      return "perfectWeek";
    }
    return "routine";
  }

  private String resumoStatus(
      String status,
      String currentRank,
      String nextRank,
      String advancementMode
  ) {
    return switch (status) {
      case "secure" -> "Rank " + currentRank + " estabilizado.";
      case "warning" -> "Rank " + currentRank + " em alerta.";
      case "critical" -> "Rank " + currentRank + " em risco real.";
      case "promotionReady" -> "reconquest".equals(advancementMode)
          ? "Reconquista pronta para o rank " + valorOuPadrao(nextRank, currentRank) + "."
          : "Exame de promocao pronto para o rank " + valorOuPadrao(nextRank, currentRank) + ".";
      case "demoted" -> "Queda confirmada para o rank " + currentRank + ".";
      default -> "Rank " + currentRank + " estabilizado.";
    };
  }

  private String detalheStatus(
      String status,
      String currentRank,
      String peakRank,
      String highestEligibleRank,
      RegraRankCompetitivo currentRule,
      int activeDays,
      boolean bossCompleted,
      int demotionStrikes,
      String nextRank,
      int targetRequiredLevel,
      boolean targetLevelGateMet,
      String advancementMode
  ) {
    String bossLine = currentRule.exigeBossConcluido()
        ? bossCompleted ? "Boss competitivo confirmado." : "Boss competitivo ainda pendente."
        : "Boss competitivo nao e exigido neste rank.";
    String levelLine = nextRank == null
        ? "Voce ja esta no topo do sistema."
        : targetLevelGateMet
            ? "Seu level ja libera a tentativa do rank " + nextRank + "."
            : "Seu level atual ainda nao libera o rank " + nextRank
                + ". Necessario: level " + targetRequiredLevel + ".";
    String reconquestLine = ordemRank(currentRank) < ordemRank(peakRank)
        ? "Seu pico historico e " + peakRank
            + ". O sistema abriu uma rota de reconquista acelerada."
        : "Seu teto atual por level chega ate o rank " + highestEligibleRank + ".";

    return switch (status) {
      case "secure" -> "Voce garantiu " + activeDays + "/"
          + currentRule.diasAtivosObrigatorios()
          + " dias competitivos validados. " + bossLine + " " + reconquestLine + " " + levelLine;
      case "warning" -> "Voce tem " + activeDays + "/"
          + currentRule.diasAtivosObrigatorios()
          + " dias competitivos validados. Falhar esta semana deixa o sistema em pressao real. "
          + levelLine;
      case "critical" -> "Voce esta abaixo da manutencao do rank " + currentRank
          + ". Strikes atuais: " + demotionStrikes + ". " + bossLine;
      case "promotionReady" -> "reconquest".equals(advancementMode)
          ? "Voce sustentou o padrao com atividade competitiva validada para reconquistar o rank "
              + valorOuPadrao(nextRank, currentRank)
              + ". O exame agora valida a retomada do seu pico historico."
          : "Voce atingiu o padrao competitivo validado do proximo rank"
              + (nextRank == null ? "" : " " + nextRank)
              + ". Agora falta transformar isso em exame de promocao.";
      case "demoted" -> "A manutencao falhou por semanas seguidas. O sistema aplicou queda "
          + "de rank para preservar a seriedade da progressao. Seu pico historico continua "
          + "registrado em " + peakRank + ".";
      default -> "";
    };
  }

  private int calcularScoreConfianca(
      int weeklyActiveDays,
      int weeklyCompetitiveDays,
      int personalQuestCompletionsToday,
      int competitiveQuestCompletionsToday,
      int personalXpToday,
      int competitiveXpToday,
      int suspiciousPatternCount
  ) {
    int score = 78;
    score += weeklyCompetitiveDays * 4;
    score += Math.min(12, competitiveQuestCompletionsToday * 3);
    score += weeklyCompetitiveDays > 0 && weeklyCompetitiveDays >= weeklyActiveDays ? 6 : 0;
    score -= Math.max(0, personalQuestCompletionsToday - 3) * 4;
    score -= personalXpToday > competitiveXpToday && weeklyCompetitiveDays == 0 ? 10 : 0;
    score -= suspiciousPatternCount * 12;
    return Math.max(0, Math.min(100, score));
  }

  private int contarPadroesSuspeitos(
      List<QuestFonteIntegridadeCompetitiva> personalCompletedToday,
      List<QuestFonteIntegridadeCompetitiva> competitiveCompletedToday,
      int personalXpToday,
      int weeklyActiveDays,
      int weeklyCompetitiveDays
  ) {
    int count = 0;
    if (personalCompletedToday.size() >= 5) {
      count += 1;
    }
    if (personalXpToday >= 45) {
      count += 1;
    }
    if (competitiveCompletedToday.isEmpty()
        && personalCompletedToday.size() >= 3
        && weeklyActiveDays > weeklyCompetitiveDays) {
      count += 1;
    }

    Map<String, Integer> titulosNormalizados = new HashMap<>();
    for (QuestFonteIntegridadeCompetitiva quest : personalCompletedToday) {
      String key = quest.title().trim().toLowerCase(Locale.ROOT);
      titulosNormalizados.put(key, titulosNormalizados.getOrDefault(key, 0) + 1);
    }
    if (titulosNormalizados.values().stream().anyMatch(valor -> valor >= 2)) {
      count += 1;
    }

    List<Instant> orderedTimes = personalCompletedToday.stream()
        .map(QuestFonteIntegridadeCompetitiva::completedAt)
        .filter(Objects::nonNull)
        .sorted()
        .toList();
    int burstPairs = 0;
    for (int index = 1; index < orderedTimes.size(); index += 1) {
      long gapMinutes = (orderedTimes.get(index).toEpochMilli()
          - orderedTimes.get(index - 1).toEpochMilli()) / 60000;
      if (gapMinutes <= 2) {
        burstPairs += 1;
      }
    }
    if (burstPairs >= 2) {
      count += 1;
    }
    return count;
  }

  private String faixaConfianca(int score) {
    if (score >= 85) {
      return "high";
    }
    if (score >= 65) {
      return "stable";
    }
    if (score >= 45) {
      return "attention";
    }
    return "restricted";
  }

  private String resumoIntegridade(String band) {
    return switch (band) {
      case "high" -> "Integridade alta";
      case "stable" -> "Integridade estavel";
      case "attention" -> "Integridade em atencao";
      case "restricted" -> "Integridade restrita";
      default -> "Integridade estavel";
    };
  }

  private String detalheIntegridade(
      String trustBand,
      int weeklyActiveDays,
      int weeklyCompetitiveDays,
      int personalQuestCompletionsToday,
      int competitiveQuestCompletionsToday,
      int suspiciousPatternCount
  ) {
    String base = "Semana com " + weeklyCompetitiveDays
        + " dia(s) competitivos validados em " + weeklyActiveDays + " dia(s) ativos.";
    String volume = "Hoje: " + competitiveQuestCompletionsToday + " competitiva(s) e "
        + personalQuestCompletionsToday + " pessoal(is).";
    String risk = suspiciousPatternCount == 0
        ? "Nenhum padrao suspeito relevante foi detectado."
        : "Padroes suspeitos detectados: " + suspiciousPatternCount + ".";
    return switch (trustBand) {
      case "high" -> base + " " + volume
          + " Sua trilha competitiva esta muito consistente. " + risk;
      case "stable" -> base + " " + volume + " Sua trilha competitiva segue confiavel. " + risk;
      case "attention" -> base + " " + volume
          + " O sistema esta pedindo mais consistencia validada para sustentar o standing. "
          + risk;
      case "restricted" -> base + " " + volume
          + " O peso competitivo desta conta precisa de mais consistencia validada antes "
          + "de ganhar forca total. " + risk;
      default -> base + " " + volume + " " + risk;
    };
  }

  private RegraRankCompetitivo regraParaRank(String rank) {
    return switch (normalizarRank(rank)) {
      case "E" -> new RegraRankCompetitivo("E", 1, 3, false, 2);
      case "D" -> new RegraRankCompetitivo("D", 5, 4, false, 2);
      case "C" -> new RegraRankCompetitivo("C", 10, 5, true, 2);
      case "B" -> new RegraRankCompetitivo("B", 20, 5, true, 2);
      case "A" -> new RegraRankCompetitivo("A", 30, 6, true, 2);
      default -> new RegraRankCompetitivo("S", 40, 6, true, 2);
    };
  }

  private String rankDepois(String rank) {
    return switch (normalizarRank(rank)) {
      case "E" -> "D";
      case "D" -> "C";
      case "C" -> "B";
      case "B" -> "A";
      case "A" -> "S";
      default -> null;
    };
  }

  private String rankAntes(String rank) {
    return switch (normalizarRank(rank)) {
      case "D" -> "E";
      case "C" -> "D";
      case "B" -> "C";
      case "A" -> "B";
      case "S" -> "A";
      default -> null;
    };
  }

  private String rankPorLevel(int level) {
    if (level < 5) {
      return "E";
    }
    if (level < 10) {
      return "D";
    }
    if (level < 20) {
      return "C";
    }
    if (level < 30) {
      return "B";
    }
    if (level < 40) {
      return "A";
    }
    return "S";
  }

  private String modoPromocao(String currentRank, String peakRank) {
    String nextRank = rankDepois(currentRank);
    if (nextRank == null) {
      return "ascension";
    }
    return ordemRank(nextRank) <= ordemRank(peakRank) ? "reconquest" : "ascension";
  }

  private String rankMaior(String rankA, String rankB) {
    return ordemRank(rankA) >= ordemRank(rankB) ? normalizarRank(rankA) : normalizarRank(rankB);
  }

  private int ordemRank(String rank) {
    return switch (normalizarRank(rank)) {
      case "E" -> 0;
      case "D" -> 1;
      case "C" -> 2;
      case "B" -> 3;
      case "A" -> 4;
      default -> 5;
    };
  }

  private String normalizarRank(String rank) {
    if (rank == null || rank.isBlank()) {
      return "E";
    }
    return rank.trim().toUpperCase(Locale.ROOT);
  }

  private Set<LocalDate> datasDaSemana(List<Instant> datas, Instant agora) {
    LocalDate inicioSemana = inicioSemana(agora);
    LocalDate fimSemana = inicioSemana.plusDays(7);
    Set<LocalDate> resultado = new TreeSet<>();
    for (Instant data : datas) {
      LocalDate normalizada = dataNormalizada(data);
      if (!normalizada.isBefore(inicioSemana) && normalizada.isBefore(fimSemana)) {
        resultado.add(normalizada);
      }
    }
    return resultado;
  }

  private String chaveSemana(Instant instant) {
    LocalDate inicio = inicioSemana(instant);
    return "%04dW%02d%02d".formatted(inicio.getYear(), inicio.getMonthValue(), inicio.getDayOfMonth());
  }

  private LocalDate inicioSemana(Instant instant) {
    return dataNormalizada(instant).with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
  }

  private LocalDate dataNormalizada(Instant instant) {
    return instant.atZone(ZoneOffset.UTC).toLocalDate();
  }

  private String valorOuPadrao(String valor, String padrao) {
    return valor == null || valor.isBlank() ? padrao : valor;
  }

  private String valorOuPadrao(String valor, String segundoPadrao, String terceiroPadrao) {
    return valorOuPadrao(valor, valorOuPadrao(segundoPadrao, terceiroPadrao));
  }
}
