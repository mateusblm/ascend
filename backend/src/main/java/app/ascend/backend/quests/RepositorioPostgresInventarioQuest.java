package app.ascend.backend.quests;

import app.ascend.backend.infraestrutura.postgres.ConversorDocumentoPostgres;
import app.ascend.backend.infraestrutura.postgres.SuporteRepositorioPostgres;
import com.google.cloud.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

/** Adaptador PostgreSQL do inventario de quests pessoais. */
@Repository
public class RepositorioPostgresInventarioQuest extends SuporteRepositorioPostgres
    implements RepositorioInventarioQuest {

  public RepositorioPostgresInventarioQuest(
      JdbcTemplate jdbcTemplate,
      ConversorDocumentoPostgres conversor
  ) {
    super(jdbcTemplate, conversor);
  }

  @Override
  public Optional<RegistroSessaoAtiva> buscarSessaoAtiva(String uid) {
    return jdbcTemplate.query("select id_sessao_dispositivo, expira_em from sessoes_ativas where uid = ?",
        (resultado, linha) -> new RegistroSessaoAtiva(
            resultado.getString("id_sessao_dispositivo"),
            timestamp(resultado.getTimestamp("expira_em").toInstant())
        ), uid).stream().findFirst();
  }

  @Override
  public Set<String> buscarIdsQuests(String uid) {
    // A sincronizacao de inventario pertence apenas as quests criadas pelo
    // cliente. Ocorrencias recorrentes sao autoria do backend e nao podem ser
    // removidas por estarem ausentes do payload do app.
    return jdbcTemplate.queryForList("select id from quests where uid = ? and recorrencia_id is null", String.class, uid)
        .stream().collect(Collectors.toSet());
  }

  public List<Map<String, Object>> buscarQuests(String uid) {
    return jdbcTemplate.query("""
        select dados::text from quests where uid = ? order by indice_ordem, criado_em
        """, (resultado, linha) -> conversor.paraDocumento(resultado.getString(1)), uid);
  }

  @Override
  @Transactional
  public void sincronizarInventario(
      String uid,
      List<EscritaInventarioQuest> escritas,
      Map<String, Object> meta,
      Set<String> idsQuestsParaExcluir
  ) {
    garantirUsuario(uid);
    for (String questId : idsQuestsParaExcluir) {
      jdbcTemplate.update("delete from quests where uid = ? and id = ?", uid, questId);
    }
    for (EscritaInventarioQuest escrita : escritas) {
      salvarQuest(uid, escrita.id(), escrita.data());
    }
  }

  void salvarQuest(String uid, String questId, Map<String, Object> quest) {
    jdbcTemplate.update("""
        insert into quests (id, uid, titulo, atributo_recompensa, xp_recompensa, categoria,
          tipo_template, modo_verificacao, status_verificacao, concluida, arquivada, planejada_para, ocorrencia_em, recorrencia_id, indice_ordem, jornada_id, dados)
        values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, cast(? as jsonb))
        on conflict (id) do update set
          uid = excluded.uid,
          titulo = excluded.titulo,
          atributo_recompensa = excluded.atributo_recompensa,
          xp_recompensa = excluded.xp_recompensa,
          categoria = excluded.categoria,
          tipo_template = excluded.tipo_template,
          modo_verificacao = excluded.modo_verificacao,
          status_verificacao = excluded.status_verificacao,
          concluida = excluded.concluida,
          arquivada = excluded.arquivada,
          planejada_para = excluded.planejada_para,
          ocorrencia_em = excluded.ocorrencia_em,
          recorrencia_id = excluded.recorrencia_id,
          indice_ordem = excluded.indice_ordem,
          jornada_id = excluded.jornada_id,
          dados = excluded.dados,
          atualizado_em = current_timestamp
        """,
        questId, uid, textoOu(quest.get("title"), "Quest"), textoOu(quest.get("rewardAttribute"), "strength"),
        inteiro(quest.get("xpReward")), textoOu(quest.get("category"), "personal"),
        textoOu(quest.get("templateType"), "custom"), textoOu(quest.get("verificationMode"), "manual"),
        textoOu(quest.get("verificationStatus"), "none"), booleano(quest.get("isCompleted")),
        booleano(quest.get("isArchived")), dataJdbc(quest.get("plannedFor")), dataJdbc(quest.get("occursOn")), textoNulo(quest.get("recurrenceId")), inteiro(quest.get("orderIndex")), textoNulo(quest.get("journeyId")), json(quest));
  }

  private String textoOu(Object valor, String padrao) {
    return valor instanceof String texto && !texto.isBlank() ? texto : padrao;
  }

  private int inteiro(Object valor) {
    return valor instanceof Number numero ? Math.max(0, numero.intValue()) : 0;
  }

  private boolean booleano(Object valor) {
    return valor instanceof Boolean valorBooleano && valorBooleano;
  }

  /** Resolve o proximo passo pela rota ativa antes de considerar o inventario geral. */
  public Map<String, Object> buscarMissaoRecomendada(String uid) {
    return jdbcTemplate.query("""
        select q.id, q.titulo, q.jornada_id, j.titulo as jornada_titulo, m.titulo as marco_titulo,
          case when m.id is not null then 'proximo_marco_da_jornada'
               when j.id is not null then 'missao_da_jornada' else 'missao_pendente' end as motivo
        from quests q left join jornadas j on j.id = q.jornada_id and j.uid = q.uid and j.status = 'ativa'
        left join marcos_capitulo m on m.quest_id = q.id and m.concluido = false
        where q.uid = ? and q.concluida = false and q.arquivada = false
          and (q.planejada_para is null or q.planejada_para <= current_date)
        order by case when m.id is not null then 0 when j.id is not null then 1 else 2 end, q.indice_ordem, q.criado_em
        limit 1
        """, (r, n) -> Map.<String, Object>of("questId", r.getString("id"), "titulo", r.getString("titulo"),
        "jornadaId", r.getString("jornada_id") == null ? "" : r.getString("jornada_id"),
        "jornadaTitulo", r.getString("jornada_titulo") == null ? "" : r.getString("jornada_titulo"),
        "marcoTitulo", r.getString("marco_titulo") == null ? "" : r.getString("marco_titulo"),
        "motivo", r.getString("motivo")), uid).stream().findFirst().orElse(Map.of());
  }

  private String textoNulo(Object valor) {
    return valor instanceof String texto && !texto.isBlank() ? texto : null;
  }

  private Timestamp timestamp(Instant instant) {
    return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
  }

  private java.sql.Date dataJdbc(Object valor) {
    if (valor instanceof Timestamp timestamp) {
      return java.sql.Date.valueOf(timestamp.toDate().toInstant().atZone(java.time.ZoneId.systemDefault()).toLocalDate());
    }
    return null;
  }
}
