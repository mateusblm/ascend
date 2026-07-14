package app.ascend.backend.jornadas;

import app.ascend.backend.infraestrutura.postgres.SuporteRepositorioPostgres;
import app.ascend.backend.infraestrutura.postgres.ConversorDocumentoPostgres;
import java.sql.Timestamp;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

/** Adaptador PostgreSQL responsavel por armazenar Jornadas pessoais. */
@Repository
public class RepositorioPostgresJornada extends SuporteRepositorioPostgres
    implements RepositorioJornada {

  public RepositorioPostgresJornada(JdbcTemplate jdbcTemplate, ConversorDocumentoPostgres conversor) {
    super(jdbcTemplate, conversor);
  }

  @Override
  public List<Jornada> listarPorUsuario(String uid) {
    return jdbcTemplate.query("""
        select id, titulo, objetivo, motivacao, status, criada_em
        from jornadas
        where uid = ? and status <> 'arquivada'
        order by case status when 'ativa' then 0 when 'pausada' then 1 else 2 end, criada_em desc
        """, (resultado, linha) -> mapear(resultado), uid);
  }

  @Override
  public Jornada salvar(String uid, Jornada jornada) {
    garantirUsuario(uid);
    jdbcTemplate.update("""
        insert into jornadas (id, uid, titulo, objetivo, motivacao, status, dados, criada_em)
        values (?, ?, ?, ?, ?, ?, cast(? as jsonb), ?)
        """, jornada.id(), uid, jornada.titulo(), jornada.objetivo(), jornada.motivacao(),
        jornada.status().name(), json(documento(jornada)), Timestamp.from(jornada.criadaEm()));
    jdbcTemplate.update("""
        insert into capitulos_jornada (id, jornada_id, titulo, indice_ordem)
        values (md5(?), ?, ?, ?)
        """, jornada.id() + ":capitulo-inicial", jornada.id(), "Primeiro avanço", 0);
    return jornada;
  }

  @Override
  public Optional<Jornada> buscarPorId(String uid, String jornadaId) {
    return jdbcTemplate.query("""
        select id, titulo, objetivo, motivacao, status, criada_em
        from jornadas where uid = ? and id = ?
        """, (resultado, linha) -> mapear(resultado), uid, jornadaId).stream().findFirst();
  }

  @Override
  public Jornada atualizarStatus(String uid, String jornadaId, StatusJornada status) {
    jdbcTemplate.update("""
        update jornadas set status = ?, atualizado_em = current_timestamp
        where uid = ? and id = ?
        """, status.name(), uid, jornadaId);
    return buscarPorId(uid, jornadaId).orElseThrow();
  }

  private Jornada mapear(java.sql.ResultSet resultado) throws java.sql.SQLException {
    return new Jornada(
        resultado.getString("id"),
        resultado.getString("titulo"),
        resultado.getString("objetivo"),
        resultado.getString("motivacao"),
        StatusJornada.valueOf(resultado.getString("status")),
        resultado.getTimestamp("criada_em").toInstant()
    );
  }

  private Map<String, Object> documento(Jornada jornada) {
    return Map.of(
        "id", jornada.id(),
        "titulo", jornada.titulo(),
        "objetivo", jornada.objetivo(),
        "motivacao", jornada.motivacao() == null ? "" : jornada.motivacao(),
        "status", jornada.status().name(),
        "criadaEm", jornada.criadaEm().toString()
    );
  }
}
