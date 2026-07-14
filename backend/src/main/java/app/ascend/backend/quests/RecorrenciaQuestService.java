package app.ascend.backend.quests;

import app.ascend.backend.compartilhado.ExcecaoApi;
import com.google.cloud.Timestamp;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Mantem definicoes semanais e materializa ocorrencias independentes por 30 dias. */
@Service
public class RecorrenciaQuestService {
  private static final Set<String> ATRIBUTOS = Set.of("strength", "intelligence", "vitality", "agility");
  private final GuardaSessaoAtiva guardaSessaoAtiva;
  private final JdbcTemplate jdbcTemplate;
  private final RepositorioPostgresInventarioQuest repositorioQuest;

  public RecorrenciaQuestService(GuardaSessaoAtiva guardaSessaoAtiva, JdbcTemplate jdbcTemplate,
      RepositorioPostgresInventarioQuest repositorioQuest) {
    this.guardaSessaoAtiva = guardaSessaoAtiva;
    this.jdbcTemplate = jdbcTemplate;
    this.repositorioQuest = repositorioQuest;
  }

  @Transactional
  public Map<String, Object> criar(String uid, RequisicaoCriacaoRecorrenciaQuest requisicao) {
    if (requisicao == null || requisicao.deviceSessionId() == null || requisicao.deviceSessionId().isBlank()
        || requisicao.title() == null || requisicao.title().isBlank() || !ATRIBUTOS.contains(requisicao.rewardAttribute())
        || requisicao.weekdays() == null || requisicao.weekdays().isEmpty()
        || requisicao.weekdays().stream().anyMatch(dia -> dia == null || dia < 1 || dia > 7)) {
      throw new ExcecaoApi(HttpStatus.BAD_REQUEST, "invalid_recurrence", "Definicao de recorrencia invalida.");
    }
    guardaSessaoAtiva.exigirSessaoAtiva(uid, requisicao.deviceSessionId().trim());
    String id = UUID.randomUUID().toString();
    jdbcTemplate.update("""
        insert into recorrencias_quest(id, uid, titulo, atributo_recompensa, xp_recompensa, jornada_id, dias_semana)
        values (?, ?, ?, ?, ?, ?, ?)
        """, id, uid, requisicao.title().trim(), requisicao.rewardAttribute(), 12,
        textoNulo(requisicao.journeyId()), requisicao.weekdays().toArray(Integer[]::new));
    gerarOcorrencias(uid);
    return Map.of("id", id, "active", true);
  }

  @Transactional
  public void pausar(String uid, String recorrenciaId, String idSessaoDispositivo) {
    guardaSessaoAtiva.exigirSessaoAtiva(uid, idSessaoDispositivo);
    int alteradas = jdbcTemplate.update("update recorrencias_quest set ativa = false, atualizado_em = current_timestamp where id = ? and uid = ? and ativa = true", recorrenciaId, uid);
    if (alteradas == 0) throw new ExcecaoApi(HttpStatus.NOT_FOUND, "recurrence_not_found", "Rotina nao encontrada.");
    jdbcTemplate.update("""
        update quests set arquivada = true, dados = jsonb_set(dados, '{isArchived}', 'true'::jsonb), atualizado_em = current_timestamp
        where uid = ? and recorrencia_id = ? and concluida = false
        """, uid, recorrenciaId);
  }

  /** Materializa somente os proximos 30 dias; repetidas leituras nao duplicam ocorrencias. */
  @Transactional
  public void gerarOcorrencias(String uid) {
    List<Definicao> definicoes = jdbcTemplate.query("""
        select id, titulo, atributo_recompensa, xp_recompensa, jornada_id, dias_semana
        from recorrencias_quest where uid = ? and ativa = true
        """, (resultado, linha) -> new Definicao(resultado.getString(1), resultado.getString(2),
        resultado.getString(3), resultado.getInt(4), resultado.getString(5),
        resultado.getArray(6) == null ? List.of() : List.of((Integer[]) resultado.getArray(6).getArray())), uid);
    LocalDate hoje = LocalDate.now(ZoneId.systemDefault());
    for (Definicao definicao : definicoes) {
      for (int deslocamento = 0; deslocamento < 30; deslocamento++) {
        LocalDate dia = hoje.plusDays(deslocamento);
        if (definicao.diasSemana().contains(dia.getDayOfWeek().getValue())) criarOcorrenciaSeAusente(uid, definicao, dia);
      }
    }
  }

  private void criarOcorrenciaSeAusente(String uid, Definicao definicao, LocalDate dia) {
    Integer existe = jdbcTemplate.queryForObject("select count(*) from quests where recorrencia_id = ? and ocorrencia_em = ?", Integer.class, definicao.id(), java.sql.Date.valueOf(dia));
    if (existe != null && existe > 0) return;
    Timestamp quando = Timestamp.ofTimeSecondsAndNanos(dia.atStartOfDay(ZoneId.systemDefault()).toEpochSecond(), 0);
    String questId = "ocorrencia-" + UUID.randomUUID();
    Map<String, Object> quest = new LinkedHashMap<>();
    quest.put("title", definicao.titulo()); quest.put("rewardAttribute", definicao.atributo()); quest.put("xpReward", definicao.xp());
    quest.put("category", "personal"); quest.put("templateType", "custom"); quest.put("verificationMode", "manual"); quest.put("verificationStatus", "none");
    quest.put("targetDurationMinutes", 0); quest.put("isCompleted", false); quest.put("isArchived", false);
    quest.put("plannedFor", quando); quest.put("occursOn", quando); quest.put("recurrenceId", definicao.id()); quest.put("journeyId", definicao.jornadaId());
    quest.put("orderIndex", dia.toEpochDay()); quest.put("syncSchemaVersion", 1); quest.put("syncSource", "backend_recurrence");
    repositorioQuest.salvarQuest(uid, questId, quest);
  }

  private String textoNulo(String valor) { return valor == null || valor.isBlank() ? null : valor; }
  private record Definicao(String id, String titulo, String atributo, int xp, String jornadaId, List<Integer> diasSemana) { }
}
