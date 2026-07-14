package app.ascend.backend.perfil;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.quests.DadosRequisicaoInventarioQuest;
import app.ascend.backend.quests.FonteInventarioQuest;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import app.ascend.backend.quests.QuestInventarioValidada;
import app.ascend.backend.quests.RequisicaoSincronizacaoInventarioQuest;
import app.ascend.backend.quests.ValidadorRequisicaoInventarioQuest;
import com.google.cloud.Timestamp;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.temporal.ChronoUnit;
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
public class SincronizacaoPerfilService {

  private static final Set<String> FOCOS_VALIDOS = Set.of(
      "discipline",
      "study",
      "training",
      "health",
      "productivity"
  );

  private final GuardaSessaoAtiva guardaSessaoAtiva;
  private final ValidadorRequisicaoInventarioQuest validadorInventario;
  private final RepositorioSincronizacaoPerfil repositorio;

  public SincronizacaoPerfilService(
      GuardaSessaoAtiva guardaSessaoAtiva,
      ValidadorRequisicaoInventarioQuest validadorInventario,
      RepositorioSincronizacaoPerfil repositorio
  ) {
    this.guardaSessaoAtiva = guardaSessaoAtiva;
    this.validadorInventario = validadorInventario;
    this.repositorio = repositorio;
  }

  /**
   * Reconstroi o perfil autoritativo a partir do inventario enviado pelo app e
   * dos clears de boss semanal gravados no backend. Esta rota e uma ferramenta
   * de reparo/migracao: ela nao aceita XP livre do cliente, recalcula nivel,
   * streak e pontos a partir de fatos validados.
   */
  public RespostaPerfil sincronizar(
      String uid,
      RequisicaoSincronizacaoPerfil request
  ) {
    DadosPerfilValidado dados = validar(request);
    guardaSessaoAtiva.exigirSessaoAtiva(uid, dados.idSessaoDispositivo());
    Timestamp agora = Timestamp.now();
    List<ClaimBossSemanalPerfil> claimsBoss = repositorio.buscarClaimsBossSemanal(uid);
    Map<String, Object> perfil = montarPerfil(dados, claimsBoss, agora);
    repositorio.salvarPerfil(uid, perfil);
    return new RespostaPerfil("synced", perfil);
  }

  private DadosPerfilValidado validar(RequisicaoSincronizacaoPerfil request) {
    if (request == null || request.fonte() == null) {
      throw payloadInvalido("source obrigatorio.");
    }
    FontePerfilJogador fonte = request.fonte();
    if (fonte.attributes() == null) {
      throw payloadInvalido("attributes invalidos.");
    }
    DadosRequisicaoInventarioQuest inventario = validadorInventario.validar(
        new RequisicaoSincronizacaoInventarioQuest(
            request.idSessaoDispositivo(),
            request.rotuloDispositivo(),
            new FonteInventarioQuest(fonte.quests() == null ? List.of() : fonte.quests())
        )
    );
    return new DadosPerfilValidado(
        inventario.idSessaoDispositivo(),
        inventario.rotuloDispositivo(),
        textoObrigatorio(fonte.name(), "name", 40),
        atributos(fonte.attributes()),
        timestampObrigatorio(fonte.lastResetDate(), "lastResetDate"),
        foco(fonte.primaryFocus()),
        booleanoObrigatorio(fonte.hasCompletedOnboarding(), "hasCompletedOnboarding"),
        inventario.quests()
    );
  }

  private Map<String, Object> montarPerfil(
      DadosPerfilValidado dados,
      List<ClaimBossSemanalPerfil> claimsBoss,
      Timestamp agora
  ) {
    List<QuestInventarioValidada> concluidas = dados.quests().stream()
        .filter(quest -> quest.isCompleted() && quest.completedAt() != null)
        .sorted(Comparator.comparing(QuestInventarioValidada::completedAt))
        .toList();
    List<Timestamp> historicoAtividade = diasUnicos(concluidas.stream()
        .map(QuestInventarioValidada::completedAt)
        .toList());
    int xpQuests = concluidas.stream().mapToInt(QuestInventarioValidada::xpReward).sum();
    int xpBoss = claimsBoss.stream().mapToInt(ClaimBossSemanalPerfil::rewardXp).sum();
    int pontosBoss = claimsBoss.stream().mapToInt(ClaimBossSemanalPerfil::rewardStatPoints).sum();
    ProgressoXp progresso = progressoTotal(xpQuests + xpBoss);
    AtributosPerfil base = atributosBase(concluidas);
    AtributosPerfil autoritativos = new AtributosPerfil(
        Math.max(dados.attributes().strength(), base.strength()),
        Math.max(dados.attributes().intelligence(), base.intelligence()),
        Math.max(dados.attributes().vitality(), base.vitality()),
        Math.max(dados.attributes().agility(), base.agility())
    );
    int pontosAlocados = (autoritativos.strength() - base.strength())
        + (autoritativos.intelligence() - base.intelligence())
        + (autoritativos.vitality() - base.vitality())
        + (autoritativos.agility() - base.agility());
    int pontosGanhos = progresso.pontosLevelUp() + pontosBoss;
    Streaks streaks = streaks(historicoAtividade, agora);

    Map<String, Object> perfil = new HashMap<>();
    perfil.put("name", dados.name());
    perfil.put("level", progresso.level());
    perfil.put("xp", progresso.xp());
    perfil.put("maxXp", progresso.maxXp());
    perfil.put("statPoints", Math.max(0, pontosGanhos - pontosAlocados));
    perfil.put("attributes", autoritativos.paraDocumento());
    perfil.put("lastResetDate", dados.lastResetDate());
    perfil.put("currentStreak", streaks.current());
    perfil.put("bestStreak", streaks.best());
    perfil.put("lastQuestCompletionDate", ultimoOuNulo(historicoAtividade));
    perfil.put("activityHistory", historicoAtividade);
    perfil.put("primaryFocus", dados.primaryFocus());
    perfil.put("hasCompletedOnboarding", dados.hasCompletedOnboarding());
    perfil.put("weeklyBossLastClaimedAt", claimsBoss.isEmpty()
        ? null
        : claimsBoss.get(claimsBoss.size() - 1).completedAt());
    perfil.put("authoritativeQuestXp", xpQuests);
    perfil.put("authoritativeWeeklyBossXp", xpBoss);
    perfil.put("authoritativeWeeklyBossStatPoints", pontosBoss);
    perfil.put("authoritativeAllocatedStatPoints", Math.max(0, pontosAlocados));
    perfil.put("syncSchemaVersion", 1);
    perfil.put("syncSource", "callable_server_authoritative");
    perfil.put("activeDeviceSessionId", dados.idSessaoDispositivo());
    perfil.put("activeDeviceLabel", dados.rotuloDispositivo());
    perfil.put("updatedAt", agora);
    return perfil;
  }

  private AtributosPerfil atributosBase(List<QuestInventarioValidada> concluidas) {
    int strength = 10;
    int intelligence = 10;
    int vitality = 10;
    int agility = 10;
    for (QuestInventarioValidada quest : concluidas) {
      switch (quest.rewardAttribute()) {
        case "strength" -> strength += 1;
        case "intelligence" -> intelligence += 1;
        case "vitality" -> vitality += 1;
        case "agility" -> agility += 1;
        default -> {
        }
      }
    }
    return new AtributosPerfil(strength, intelligence, vitality, agility);
  }

  private List<Timestamp> diasUnicos(List<Timestamp> timestamps) {
    Map<LocalDate, Timestamp> porDia = new LinkedHashMap<>();
    timestamps.stream()
        .filter(timestamp -> timestamp != null)
        .sorted()
        .forEach(timestamp -> porDia.put(dia(timestamp), timestamp));
    return new ArrayList<>(porDia.values());
  }

  private Streaks streaks(List<Timestamp> historico, Timestamp agora) {
    if (historico.isEmpty()) {
      return new Streaks(0, 0);
    }
    List<LocalDate> dias = historico.stream().map(this::dia).toList();
    int best = 1;
    int running = 1;
    for (int index = 1; index < dias.size(); index++) {
      if (ChronoUnit.DAYS.between(dias.get(index - 1), dias.get(index)) == 1) {
        running += 1;
        best = Math.max(best, running);
      } else {
        running = 1;
      }
    }
    if (ChronoUnit.DAYS.between(dias.get(dias.size() - 1), dia(agora)) > 1) {
      return new Streaks(0, best);
    }
    int current = 1;
    for (int index = dias.size() - 1; index > 0; index--) {
      if (ChronoUnit.DAYS.between(dias.get(index - 1), dias.get(index)) != 1) {
        break;
      }
      current += 1;
    }
    return new Streaks(current, best);
  }

  private ProgressoXp progressoTotal(int totalXp) {
    int restante = Math.max(0, totalXp);
    int level = 1;
    int maxXp = 100;
    int pontosLevelUp = 0;
    while (restante >= maxXp) {
      restante -= maxXp;
      level += 1;
      pontosLevelUp += 5;
      maxXp = maxXpParaLevel(level);
    }
    return new ProgressoXp(level, restante, maxXp, pontosLevelUp);
  }

  private int maxXpParaLevel(int level) {
    int current = 100;
    for (int index = 1; index < level; index++) {
      current = (int) Math.floor(current * 1.2);
    }
    return current;
  }

  private LocalDate dia(Timestamp timestamp) {
    return Instant.ofEpochSecond(timestamp.getSeconds(), timestamp.getNanos())
        .atZone(ZoneOffset.UTC)
        .toLocalDate();
  }

  private Timestamp ultimoOuNulo(List<Timestamp> values) {
    return values.isEmpty() ? null : values.get(values.size() - 1);
  }

  private String textoObrigatorio(Object value, String field, int maxLength) {
    if (!(value instanceof String text)) {
      throw payloadInvalido(field + " invalido.");
    }
    String trimmed = text.trim();
    if (trimmed.isEmpty() || trimmed.length() > maxLength) {
      throw payloadInvalido(field + " invalido.");
    }
    return trimmed;
  }

  private AtributosPerfil atributos(AtributosFontePerfil value) {
    return new AtributosPerfil(
        inteiroMinimo(value.strength(), "attributes.strength", 10),
        inteiroMinimo(value.intelligence(), "attributes.intelligence", 10),
        inteiroMinimo(value.vitality(), "attributes.vitality", 10),
        inteiroMinimo(value.agility(), "attributes.agility", 10)
    );
  }

  private int inteiroMinimo(Object value, String field, int min) {
    if (!(value instanceof Number number)) {
      throw payloadInvalido(field + " invalido.");
    }
    int parsed = number.intValue();
    if (number.doubleValue() != parsed || parsed < min) {
      throw payloadInvalido(field + " invalido.");
    }
    return parsed;
  }

  private Timestamp timestampObrigatorio(Object value, String field) {
    Timestamp timestamp = timestamp(value);
    if (timestamp == null) {
      throw payloadInvalido(field + " invalido.");
    }
    return timestamp;
  }

  private Timestamp timestamp(Object value) {
    if (value instanceof Timestamp timestamp) {
      return timestamp;
    }
    if (value instanceof String text) {
      try {
        Instant instant = Instant.parse(text);
        return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
      } catch (Exception ignored) {
        return null;
      }
    }
    return null;
  }

  private String foco(Object value) {
    String focus = textoObrigatorio(value, "primaryFocus", 32);
    if (!FOCOS_VALIDOS.contains(focus)) {
      throw payloadInvalido("primaryFocus invalido.");
    }
    return focus;
  }

  private boolean booleanoObrigatorio(Object value, String field) {
    if (value instanceof Boolean bool) {
      return bool;
    }
    throw payloadInvalido(field + " invalido.");
  }

  private ExcecaoApi payloadInvalido(String mensagem) {
    return new ExcecaoApi(HttpStatus.BAD_REQUEST, "invalid_profile_sync_payload", mensagem);
  }

  private record DadosPerfilValidado(
      String idSessaoDispositivo,
      String rotuloDispositivo,
      String name,
      AtributosPerfil attributes,
      Timestamp lastResetDate,
      String primaryFocus,
      boolean hasCompletedOnboarding,
      List<QuestInventarioValidada> quests
  ) {
  }

  private record ProgressoXp(int level, int xp, int maxXp, int pontosLevelUp) {
  }

  private record Streaks(int current, int best) {
  }
}
