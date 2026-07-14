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
    return jdbcTemplate.queryForList("select id from quests where uid = ?", String.class, uid)
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
          tipo_template, modo_verificacao, status_verificacao, concluida, indice_ordem, dados)
        values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, cast(? as jsonb))
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
          indice_ordem = excluded.indice_ordem,
          dados = excluded.dados,
          atualizado_em = current_timestamp
        """,
        questId, uid, textoOu(quest.get("title"), "Quest"), textoOu(quest.get("rewardAttribute"), "strength"),
        inteiro(quest.get("xpReward")), textoOu(quest.get("category"), "personal"),
        textoOu(quest.get("templateType"), "custom"), textoOu(quest.get("verificationMode"), "manual"),
        textoOu(quest.get("verificationStatus"), "none"), booleano(quest.get("isCompleted")),
        inteiro(quest.get("orderIndex")), json(quest));
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

  private Timestamp timestamp(Instant instant) {
    return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
  }
}
