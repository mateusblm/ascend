package app.ascend.backend.atividades;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import app.ascend.backend.quests.MutacaoQuestPessoalService;
import java.util.LinkedHashMap;
import java.util.List;
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
    Map<String, Object> metricas = normalizarMetricas(atividade, request.metrics());
    for (DefinicaoMetricaAtividade metrica : atividade.metricas()) {
      Object valor = metricas.get(metrica.id());
      if (metrica.obrigatoria() && !metrica.calculada() && !valorValido(metrica, valor))
        throw new ExcecaoApi(HttpStatus.UNPROCESSABLE_ENTITY, "required_activity_metric", "Métrica obrigatória ausente: " + metrica.id());
      if (valor instanceof Number numero && (numero.doubleValue() < metrica.minimo() || numero.doubleValue() > metrica.maximo()))
        throw new ExcecaoApi(HttpStatus.UNPROCESSABLE_ENTITY, "invalid_activity_metric", "Métrica fora do limite: " + metrica.id());
    }
    if ("studySession".equals(atividade.modeloExecucao())
        && numero(metricas, "correctAnswers") > numero(metricas, "questionsAnswered"))
      throw new ExcecaoApi(HttpStatus.UNPROCESSABLE_ENTITY, "invalid_study_answers", "Os acertos nao podem exceder as questoes.");
    if ("readingProgress".equals(atividade.modeloExecucao()) && numero(metricas, "pagesRead") < 1)
      throw new ExcecaoApi(HttpStatus.UNPROCESSABLE_ENTITY, "required_reading_progress", "Informe as paginas lidas.");
    if ("sleepTracking".equals(atividade.modeloExecucao()) && numero(metricas, "durationMinutes") < 1)
      throw new ExcecaoApi(HttpStatus.UNPROCESSABLE_ENTITY, "required_sleep_window", "Informe os horarios de sono.");
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
  /** A revogacao da quest invalida seus fatos guiados sem apagar o historico auditavel. */
  @Transactional
  public int marcarExecucoesRevogadas(String uid, String questId) {
    return jdbc.update("update execucoes_atividades set revogada_em = current_timestamp "
        + "where uid = ? and quest_id = ? and revogada_em is null", uid, questId);
  }
  @SuppressWarnings("unchecked")
  private Map<String, Object> normalizarMetricas(DefinicaoAtividade atividade, Map<String, Object> recebidas) {
    Map<String, Object> metricas = new LinkedHashMap<>(recebidas == null ? Map.of() : recebidas);
    atividade.metricas().stream().filter(DefinicaoMetricaAtividade::calculada)
        .map(DefinicaoMetricaAtividade::id).forEach(metricas::remove);
    String tipo = atividade.modeloExecucao();
    if ("readingProgress".equals(tipo)) {
      Object inicio = metricas.get("startPage"); Object fim = metricas.get("endPage");
      if (inicio == null && fim == null) return metricas;
      if (!(inicio instanceof Number paginaInicial) || !(fim instanceof Number paginaFinal)
          || paginaInicial.doubleValue() < 1 || paginaFinal.doubleValue() < paginaInicial.doubleValue())
        throw new ExcecaoApi(HttpStatus.UNPROCESSABLE_ENTITY, "invalid_reading_progress", "Intervalo de paginas invalido.");
      metricas.put("pagesRead", paginaFinal.doubleValue() - paginaInicial.doubleValue() + 1);
      return metricas;
    }
    if ("sleepTracking".equals(tipo)) {
      Object inicio = metricas.get("sleepStart"); Object fim = metricas.get("wakeEnd");
      if (inicio == null && fim == null) return metricas;
      int inicioMinutos = minutosDoHorario(inicio); int fimMinutos = minutosDoHorario(fim);
      if (inicioMinutos < 0 || fimMinutos < 0)
        throw new ExcecaoApi(HttpStatus.UNPROCESSABLE_ENTITY, "invalid_sleep_window", "Horario de sono invalido.");
      int duracao = fimMinutos - inicioMinutos;
      if (duracao <= 0) duracao += 24 * 60;
      metricas.put("durationMinutes", duracao);
      return metricas;
    }
    if (!"strengthSets".equals(tipo) || !(metricas.get("sets") instanceof List<?> series)) return metricas;
    double repeticoes = 0, maiorCarga = 0;
    for (Object item : series) {
      if (!(item instanceof Map<?, ?> serie) || !(serie.get("repetitions") instanceof Number reps)
          || !(serie.get("loadKg") instanceof Number carga) || reps.doubleValue() < 1 || reps.doubleValue() > 500
          || carga.doubleValue() < 0 || carga.doubleValue() > 1000)
        throw new ExcecaoApi(HttpStatus.UNPROCESSABLE_ENTITY, "invalid_strength_set", "Série de musculação inválida.");
      repeticoes += reps.doubleValue(); maiorCarga = Math.max(maiorCarga, carga.doubleValue());
    }
    if (series.isEmpty()) throw new ExcecaoApi(HttpStatus.UNPROCESSABLE_ENTITY, "required_strength_sets", "Informe ao menos uma série.");
    metricas.put("repetitions", repeticoes); metricas.put("loadKg", maiorCarga);
    return metricas;
  }
  private boolean valorValido(DefinicaoMetricaAtividade metrica, Object valor) {
    if ("text".equals(metrica.tipo()))
      return valor instanceof String texto && !texto.isBlank() && texto.length() <= metrica.maximo();
    if ("timeOfDay".equals(metrica.tipo())) return minutosDoHorario(valor) >= 0;
    return valor instanceof Number;
  }
  @SuppressWarnings("unchecked")
  private Map<String, Object> calcular(String tipo, Map<String, Object> metricas) {
    Map<String, Object> calculadas = new LinkedHashMap<>();
    if ("strengthSets".equals(tipo)) {
      double volume = 0, estimado = 0;
      if (metricas.get("sets") instanceof List<?> series) for (Object item : series) {
        Map<?, ?> serie = (Map<?, ?>) item; double carga = numero((Map<String, Object>) serie, "loadKg"); double reps = numero((Map<String, Object>) serie, "repetitions");
        volume += carga * reps; estimado = Math.max(estimado, carga * (1 + reps / 30));
      } else volume = numero(metricas, "repetitions") * numero(metricas, "loadKg");
      calculadas.put("volumeKg", volume); calculadas.put("maxLoadKg", numero(metricas, "loadKg")); calculadas.put("estimatedOneRepMaxKg", estimado);
    }
    if ("distanceDuration".equals(tipo)) calculadas.put("paceSecondsPerKm", numero(metricas, "durationMinutes") * 60 / numero(metricas, "distanceKm"));
    if ("studySession".equals(tipo) && metricas.get("questionsAnswered") instanceof Number)
      calculadas.put("accuracyPercent", numero(metricas, "correctAnswers") * 100 / numero(metricas, "questionsAnswered"));
    if ("readingProgress".equals(tipo)) calculadas.put("pagesRead", numero(metricas, "pagesRead"));
    if ("sleepTracking".equals(tipo)) calculadas.put("durationMinutes", numero(metricas, "durationMinutes"));
    return calculadas;
  }
  private double numero(Map<String, Object> metricas, String chave) { Object valor = metricas.get(chave); return valor instanceof Number n ? n.doubleValue() : 0; }
  private int minutosDoHorario(Object valor) {
    if (!(valor instanceof String horario) || !horario.matches("\\d{2}:\\d{2}")) return -1;
    int horas = Integer.parseInt(horario.substring(0, 2)); int minutos = Integer.parseInt(horario.substring(3, 5));
    return horas < 24 && minutos < 60 ? horas * 60 + minutos : -1;
  }
  private boolean emBranco(String valor) { return valor == null || valor.isBlank(); }
  private String json(Map<String, Object> valor) { try { return new com.fasterxml.jackson.databind.ObjectMapper().writeValueAsString(valor); } catch (Exception e) { throw new IllegalStateException(e); } }
}
