package app.ascend.backend.atividades;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import app.ascend.backend.quests.MutacaoQuestPessoalService;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Registra fatos de execução sem conceder recompensa adicional por métricas. */
@Service
public class ExecucaoAtividadeService {
  private final JdbcTemplate jdbc;
  private final GuardaSessaoAtiva sessoes;
  private final CatalogoAtividadesService catalogo;
  private final MutacaoQuestPessoalService mutacoes;
  public ExecucaoAtividadeService(JdbcTemplate jdbc, GuardaSessaoAtiva sessoes, CatalogoAtividadesService catalogo, MutacaoQuestPessoalService mutacoes) {
    this.jdbc = jdbc; this.sessoes = sessoes; this.catalogo = catalogo; this.mutacoes = mutacoes;
  }
  @Transactional
  public RespostaExecucaoAtividade registrar(String uid, RequisicaoExecucaoAtividade request) {
    if (request == null || emBranco(request.deviceSessionId()) || emBranco(request.executionId()) || emBranco(request.questId()))
      throw new ExcecaoApi(HttpStatus.BAD_REQUEST, "invalid_activity_execution", "Execução de atividade inválida.");
    sessoes.exigirSessaoAtiva(uid, request.deviceSessionId());
    DefinicaoAtividade atividade = catalogo.atividade(request.activityId());
    if (atividade == null || !atividade.modeloExecucao().equals(request.executionType()) || atividade.versaoSchema() != request.schemaVersion())
      throw new ExcecaoApi(HttpStatus.UNPROCESSABLE_ENTITY, "invalid_activity_contract", "Atividade ou modelo de execução inválido.");
    Map<String, Object> metricas = request.metrics() == null ? Map.of() : request.metrics();
    for (DefinicaoMetricaAtividade metrica : atividade.metricas()) {
      Object valor = metricas.get(metrica.id());
      if (metrica.obrigatoria() && !metrica.calculada() && !(valor instanceof Number))
        throw new ExcecaoApi(HttpStatus.UNPROCESSABLE_ENTITY, "required_activity_metric", "Métrica obrigatória ausente: " + metrica.id());
      if (valor instanceof Number numero && (numero.doubleValue() < metrica.minimo() || numero.doubleValue() > metrica.maximo()))
        throw new ExcecaoApi(HttpStatus.UNPROCESSABLE_ENTITY, "invalid_activity_metric", "Métrica fora do limite: " + metrica.id());
    }
    if (!Boolean.TRUE.equals(jdbc.queryForObject("select exists(select 1 from quests where uid = ? and id = ?)", Boolean.class, uid, request.questId())))
      throw new ExcecaoApi(HttpStatus.NOT_FOUND, "personal_quest_not_found", "Missão não encontrada.");
    Map<String, Object> calculadas = calcular(atividade.modeloExecucao(), metricas);
    int inserida = jdbc.update("""
        insert into execucoes_atividades(uid, id, quest_id, activity_id, execution_type, schema_version, metricas, metricas_calculadas, observacao)
        values (?, ?, ?, ?, ?, ?, cast(? as jsonb), cast(? as jsonb), ?) on conflict (uid, id) do nothing
        """,
        uid, request.executionId(), request.questId(), atividade.id(), atividade.modeloExecucao(), atividade.versaoSchema(), json(metricas), json(calculadas), request.observation());
    return new RespostaExecucaoAtividade(inserida == 1 ? "recorded" : "already_recorded", request.executionId(), calculadas);
  }
  @Transactional
  public RespostaExecucaoConcluida registrarEConcluir(String uid, String email, RequisicaoExecucaoAtividade request) {
    RespostaExecucaoAtividade execucao = registrar(uid, request);
    var conclusao = mutacoes.concluirGuiada(uid, email, request.deviceSessionId(), request.questId(),
        request.activityId(), request.executionType(), request.schemaVersion());
    return new RespostaExecucaoConcluida(execucao.status(), execucao.executionId(), execucao.calculatedMetrics(), conclusao);
  }
  private Map<String, Object> calcular(String tipo, Map<String, Object> metricas) {
    Map<String, Object> calculadas = new LinkedHashMap<>();
    if ("strengthSets".equals(tipo)) calculadas.put("volumeKg", numero(metricas, "repetitions") * numero(metricas, "loadKg"));
    if ("distanceDuration".equals(tipo)) calculadas.put("paceSecondsPerKm", numero(metricas, "durationMinutes") * 60 / numero(metricas, "distanceKm"));
    if ("studySession".equals(tipo) && metricas.get("questionsAnswered") instanceof Number)
      calculadas.put("accuracyPercent", numero(metricas, "correctAnswers") * 100 / numero(metricas, "questionsAnswered"));
    return calculadas;
  }
  private double numero(Map<String, Object> metricas, String chave) { Object valor = metricas.get(chave); return valor instanceof Number n ? n.doubleValue() : 0; }
  private boolean emBranco(String valor) { return valor == null || valor.isBlank(); }
  private String json(Map<String, Object> valor) { try { return new com.fasterxml.jackson.databind.ObjectMapper().writeValueAsString(valor); } catch (Exception e) { throw new IllegalStateException(e); } }
}
