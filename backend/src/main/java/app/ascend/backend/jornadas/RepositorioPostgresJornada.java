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
        update jornadas set status = ?, atualizada_em = current_timestamp
        where uid = ? and id = ?
        """, status.name(), uid, jornadaId);
    return buscarPorId(uid, jornadaId).orElseThrow();
  }

  @Override
  public Jornada atualizarProposito(String uid, String jornadaId, String titulo, String objetivo, String motivacao) {
    jdbcTemplate.update("""
        update jornadas set titulo = ?, objetivo = ?, motivacao = ?, atualizada_em = current_timestamp
        where uid = ? and id = ?
        """, titulo, objetivo, motivacao, uid, jornadaId);
    return buscarPorId(uid, jornadaId).orElseThrow();
  }

  @Override
  public List<CapituloJornada> listarCapitulos(String uid, String jornadaId) {
    return jdbcTemplate.query("""
        select c.id, c.titulo, c.indice_ordem, c.concluido from capitulos_jornada c
        join jornadas j on j.id = c.jornada_id
        where j.uid = ? and j.id = ? order by c.indice_ordem
        """, (resultado, linha) -> new CapituloJornada(
        resultado.getString("id"), resultado.getString("titulo"), resultado.getInt("indice_ordem"), resultado.getBoolean("concluido")), uid, jornadaId);
  }

  @Override
  public CapituloJornada adicionarCapitulo(String uid, String jornadaId, CapituloJornada capitulo) {
    jdbcTemplate.update("""
        insert into capitulos_jornada (id, jornada_id, titulo, indice_ordem)
        select ?, j.id, ?, ? from jornadas j where j.uid = ? and j.id = ?
        """, capitulo.id(), capitulo.titulo(), capitulo.indiceOrdem(), uid, jornadaId);
    return capitulo;
  }

  @Override
  public Optional<ContextoCapituloJornada> buscarContextoCapitulo(String uid, String capituloId) {
    return jdbcTemplate.query("""
        select c.id, j.id as jornada_id, j.status from capitulos_jornada c join jornadas j on j.id=c.jornada_id
        where j.uid=? and c.id=?
        """, (r, n) -> new ContextoCapituloJornada(
        r.getString("id"), r.getString("jornada_id"), StatusJornada.valueOf(r.getString("status"))), uid, capituloId).stream().findFirst();
  }

  @Override
  public List<MarcoCapitulo> listarMarcos(String uid, String capituloId) {
    return jdbcTemplate.query("""
        select m.id, m.titulo, m.quest_id, m.concluido, m.indice_ordem
        from marcos_capitulo m join capitulos_jornada c on c.id = m.capitulo_id
        join jornadas j on j.id = c.jornada_id
        where j.uid = ? and c.id = ? order by m.indice_ordem, m.criado_em, m.id
        """, (r, n) -> mapearMarco(r), uid, capituloId);
  }

  @Override
  public MarcoCapitulo adicionarMarco(String capituloId, String titulo, String questId) {
    String id = java.util.UUID.randomUUID().toString();
    int indice = jdbcTemplate.queryForObject(
        "select coalesce(max(indice_ordem), -1) + 1 from marcos_capitulo where capitulo_id = ?", Integer.class, capituloId);
    jdbcTemplate.update("insert into marcos_capitulo (id, capitulo_id, titulo, quest_id, concluido, indice_ordem) values (?, ?, ?, ?, false, ?)",
        id, capituloId, titulo, questId, indice);
    return new MarcoCapitulo(id, titulo, questId, false, indice);
  }

  @Override
  public Optional<MarcoCapitulo> buscarMarco(String uid, String marcoId) {
    return jdbcTemplate.query("""
        select m.id, m.titulo, m.quest_id, m.concluido, m.indice_ordem
        from marcos_capitulo m join capitulos_jornada c on c.id = m.capitulo_id
        join jornadas j on j.id = c.jornada_id where j.uid = ? and m.id = ?
        """, (r, n) -> mapearMarco(r), uid, marcoId).stream().findFirst();
  }

  @Override
  public MarcoCapitulo concluirMarco(String uid, String marcoId) {
    jdbcTemplate.update("""
        update marcos_capitulo m set concluido = true
        from capitulos_jornada c join jornadas j on j.id = c.jornada_id
        where m.capitulo_id = c.id and j.uid = ? and m.id = ? and m.concluido = false
        """, uid, marcoId);
    return buscarMarco(uid, marcoId).orElseThrow();
  }

  @Override
  public boolean questPertenceAJornada(String uid, String questId, String jornadaId) {
    return Boolean.TRUE.equals(jdbcTemplate.queryForObject(
        "select exists(select 1 from quests where uid = ? and id = ? and jornada_id = ?)",
        Boolean.class, uid, questId, jornadaId));
  }

  @Override
  public CapituloJornada concluirCapitulo(String uid, String capituloId) {
    jdbcTemplate.update("""
        update capitulos_jornada c set concluido = true, concluido_em = current_timestamp
        from jornadas j where c.jornada_id = j.id and j.uid = ? and c.id = ?
        """, uid, capituloId);
    return jdbcTemplate.query("""
        select c.id, c.titulo, c.indice_ordem, c.concluido from capitulos_jornada c join jornadas j on j.id = c.jornada_id
        where j.uid = ? and c.id = ?
        """, (r, n) -> new CapituloJornada(r.getString("id"), r.getString("titulo"), r.getInt("indice_ordem"), r.getBoolean("concluido")), uid, capituloId).getFirst();
  }

  @Override
  public boolean todosCapitulosConcluidos(String uid, String jornadaId) {
    return Boolean.TRUE.equals(jdbcTemplate.queryForObject("""
        select exists(select 1 from capitulos_jornada c join jornadas j on j.id = c.jornada_id
          where j.uid = ? and j.id = ?) and not exists(select 1 from capitulos_jornada c join jornadas j on j.id = c.jornada_id
          where j.uid = ? and j.id = ? and c.concluido = false)
        """, Boolean.class, uid, jornadaId, uid, jornadaId));
  }

  @Override
  public void registrarConclusaoNoLegado(String uid, Jornada jornada) {
    jdbcTemplate.update("""
        insert into legado_jornadas (id, uid, jornada_id, titulo)
        values (?, ?, ?, ?) on conflict (jornada_id) do nothing
        """, java.util.UUID.randomUUID().toString(), uid, jornada.id(), jornada.titulo());
  }

  @Override
  public List<RegistroLegadoJornada> listarLegado(String uid) {
    return jdbcTemplate.query("""
        select id, jornada_id, titulo, concluida_em from legado_jornadas
        where uid = ? order by concluida_em desc, id desc
        """, (r, n) -> new RegistroLegadoJornada(r.getString("id"), r.getString("jornada_id"),
        r.getString("titulo"), r.getTimestamp("concluida_em").toInstant()), uid);
  }

  private MarcoCapitulo mapearMarco(java.sql.ResultSet resultado) throws java.sql.SQLException {
    return new MarcoCapitulo(resultado.getString("id"), resultado.getString("titulo"),
        resultado.getString("quest_id"), resultado.getBoolean("concluido"), resultado.getInt("indice_ordem"));
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
