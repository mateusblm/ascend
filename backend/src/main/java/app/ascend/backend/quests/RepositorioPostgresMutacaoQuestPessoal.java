package app.ascend.backend.quests;

import app.ascend.backend.infraestrutura.postgres.ConversorDocumentoPostgres;
import app.ascend.backend.infraestrutura.postgres.SuporteRepositorioPostgres;
import app.ascend.backend.perfil.RepositorioPostgresPerfil;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

/** Executa conclusao e revogacao pessoal como uma unica transacao SQL. */
@Repository
public class RepositorioPostgresMutacaoQuestPessoal extends SuporteRepositorioPostgres
    implements RepositorioMutacaoQuestPessoal {

  private final RepositorioPostgresInventarioQuest repositorioQuest;
  private final RepositorioPostgresPerfil repositorioPerfil;

  public RepositorioPostgresMutacaoQuestPessoal(
      JdbcTemplate jdbcTemplate,
      ConversorDocumentoPostgres conversor,
      RepositorioPostgresInventarioQuest repositorioQuest,
      RepositorioPostgresPerfil repositorioPerfil
  ) {
    super(jdbcTemplate, conversor);
    this.repositorioQuest = repositorioQuest;
    this.repositorioPerfil = repositorioPerfil;
  }

  @Override
  @Transactional
  public RespostaMutacaoQuestPessoal executarMutacao(
      String uid,
      String questId,
      Function<ContextoMutacaoQuestPessoal, EscritaMutacaoQuestPessoal> mutacao
  ) {
    garantirUsuario(uid);
    Map<String, Object> perfil = documentoOuVazio(
        "select dados::text from perfis_jogador where uid = ? for update", uid
    );
    List<Map<String, Object>> quests = jdbcTemplate.query("""
        select dados::text from quests where uid = ? and id = ? for update
        """, (resultado, linha) -> conversor.paraDocumento(resultado.getString(1)), uid, questId);
    List<Map<String, Object>> conclusoes = jdbcTemplate.query("""
        select dados::text from conclusoes_quest where uid = ? order by concluida_em for update
        """, (resultado, linha) -> conversor.paraDocumento(resultado.getString(1)), uid);
    List<Map<String, Object>> conclusaoDaQuest = jdbcTemplate.query("""
        select dados::text from conclusoes_quest
        where uid = ? and quest_id = ? for update
        """, (resultado, linha) -> conversor.paraDocumento(resultado.getString(1)), uid, questId);

    int indiceOrdem = quests.isEmpty() ? 0 : inteiro(quests.getFirst().get("orderIndex"));
    EscritaMutacaoQuestPessoal escrita = mutacao.apply(new ContextoMutacaoQuestPessoal(
        perfil, quests.isEmpty() ? Map.of() : quests.getFirst(), !quests.isEmpty(),
        !conclusaoDaQuest.isEmpty(), conclusoes, indiceOrdem
    ));
    if (escrita.perfil() != null) {
      repositorioPerfil.salvarPerfil(uid, escrita.perfil());
    }
    if (escrita.quest() != null) {
      repositorioQuest.salvarQuest(uid, questId, escrita.quest());
    }
    if (escrita.conclusao() != null) {
      salvarConclusao(uid, questId, escrita.conclusao());
    }
    if (escrita.excluirConclusao()) {
      jdbcTemplate.update("""
          delete from conclusoes_quest
          where uid = ? and quest_id = ?
          """, uid, questId);
    }
    return escrita.resposta();
  }

  private void salvarConclusao(String uid, String questId, Map<String, Object> conclusao) {
    jdbcTemplate.update("""
        insert into conclusoes_quest (id, uid, quest_id, titulo, atributo_recompensa, xp_recompensa,
          concluida_em, dados)
        values (?, ?, ?, ?, ?, ?, ?, cast(? as jsonb))
        on conflict (id) do update set dados = excluded.dados, concluida_em = excluded.concluida_em
        """, "pessoal-" + uid + "-" + questId, uid, questId,
        textoOu(conclusao.get("title"), "Quest"), textoOu(conclusao.get("rewardAttribute"), "strength"),
        inteiro(conclusao.get("xpReward")), timestampJdbc(instanteOuAgora(conclusao.get("completedAt"))),
        json(conclusao));
  }

  private int inteiro(Object valor) {
    return valor instanceof Number numero ? Math.max(0, numero.intValue()) : 0;
  }

  private String textoOu(Object valor, String padrao) {
    return valor instanceof String texto && !texto.isBlank() ? texto : padrao;
  }

  private Instant instanteOuAgora(Object valor) {
    return valor instanceof com.google.cloud.Timestamp timestamp
        ? timestamp.toDate().toInstant()
        : Instant.now();
  }

  /** Converte o instante de dominio para o tipo temporal aceito pelo driver JDBC. */
  private java.sql.Timestamp timestampJdbc(Instant instant) {
    return java.sql.Timestamp.from(instant);
  }
}
