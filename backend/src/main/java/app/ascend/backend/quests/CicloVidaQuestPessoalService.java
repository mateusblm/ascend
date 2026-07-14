package app.ascend.backend.quests;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.infraestrutura.postgres.ConversorDocumentoPostgres;
import com.google.cloud.Timestamp;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Mantem o ciclo de vida de quests pessoais sem tocar em XP, atributos ou
 * historico de conclusoes. Os comandos sao naturalmente idempotentes.
 */
@Service
public class CicloVidaQuestPessoalService {
  private final GuardaSessaoAtiva guardaSessaoAtiva;
  private final JdbcTemplate jdbcTemplate;
  private final ConversorDocumentoPostgres conversor;
  private final RepositorioPostgresInventarioQuest repositorio;

  public CicloVidaQuestPessoalService(
      GuardaSessaoAtiva guardaSessaoAtiva,
      JdbcTemplate jdbcTemplate,
      ConversorDocumentoPostgres conversor,
      RepositorioPostgresInventarioQuest repositorio
  ) {
    this.guardaSessaoAtiva = guardaSessaoAtiva;
    this.jdbcTemplate = jdbcTemplate;
    this.conversor = conversor;
    this.repositorio = repositorio;
  }

  @Transactional
  public Map<String, Object> arquivar(String uid, RequisicaoCicloVidaQuest requisicao) {
    Dados dados = validar(requisicao, false);
    guardaSessaoAtiva.exigirSessaoAtiva(uid, dados.idSessaoDispositivo());
    Map<String, Object> quest = buscarParaAtualizar(uid, dados.questId());
    exigirPendente(quest);
    quest.put("isArchived", true);
    salvar(uid, dados.questId(), quest);
    return quest;
  }

  @Transactional
  public Map<String, Object> reagendar(String uid, RequisicaoCicloVidaQuest requisicao) {
    Dados dados = validar(requisicao, true);
    guardaSessaoAtiva.exigirSessaoAtiva(uid, dados.idSessaoDispositivo());
    Map<String, Object> quest = buscarParaAtualizar(uid, dados.questId());
    exigirPendente(quest);
    if (Boolean.TRUE.equals(quest.get("isArchived"))) {
      throw new ExcecaoApi(HttpStatus.PRECONDITION_FAILED, "archived_quest", "Uma missao arquivada nao pode ser reagendada.");
    }
    quest.put("plannedFor", Timestamp.ofTimeSecondsAndNanos(
        dados.planejadaPara().atStartOfDay(ZoneId.systemDefault()).toEpochSecond(), 0));
    salvar(uid, dados.questId(), quest);
    return quest;
  }

  private Map<String, Object> buscarParaAtualizar(String uid, String questId) {
    List<Map<String, Object>> linhas = jdbcTemplate.query("select dados::text from quests where uid = ? and id = ? for update",
        (resultado, linha) -> conversor.paraDocumento(resultado.getString(1)), uid, questId);
    if (linhas.isEmpty()) throw new ExcecaoApi(HttpStatus.NOT_FOUND, "personal_quest_not_found", "Quest pessoal nao encontrada.");
    return new LinkedHashMap<>(linhas.getFirst());
  }

  private void exigirPendente(Map<String, Object> quest) {
    if (!"personal".equals(quest.get("category"))) {
      throw new ExcecaoApi(HttpStatus.PRECONDITION_FAILED, "personal_quest_required", "Apenas quests pessoais usam este comando.");
    }
    if (Boolean.TRUE.equals(quest.get("isCompleted"))) {
      throw new ExcecaoApi(HttpStatus.PRECONDITION_FAILED, "completed_quest", "Uma missao concluida permanece no seu registro.");
    }
  }

  private void salvar(String uid, String questId, Map<String, Object> quest) {
    repositorio.salvarQuest(uid, questId, quest);
  }

  private Dados validar(RequisicaoCicloVidaQuest requisicao, boolean exigeData) {
    if (requisicao == null || requisicao.deviceSessionId() == null || requisicao.deviceSessionId().isBlank()
        || requisicao.questId() == null || requisicao.questId().isBlank()) {
      throw new ExcecaoApi(HttpStatus.BAD_REQUEST, "invalid_quest_lifecycle", "Comando de missao invalido.");
    }
    LocalDate data = null;
    if (exigeData) {
      try { data = LocalDate.parse(requisicao.plannedFor()); }
      catch (RuntimeException erro) { throw new ExcecaoApi(HttpStatus.BAD_REQUEST, "invalid_planned_for", "Data de reagendamento invalida."); }
    }
    return new Dados(requisicao.deviceSessionId().trim(), requisicao.questId().trim(), data);
  }

  private record Dados(String idSessaoDispositivo, String questId, LocalDate planejadaPara) { }
}
