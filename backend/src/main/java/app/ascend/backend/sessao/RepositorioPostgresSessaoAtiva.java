package app.ascend.backend.sessao;

import app.ascend.backend.infraestrutura.postgres.ConversorDocumentoPostgres;
import app.ascend.backend.infraestrutura.postgres.SuporteRepositorioPostgres;
import com.google.cloud.Timestamp;
import java.time.Instant;
import java.util.Optional;
import java.util.function.Function;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

/** Adaptador transacional da sessao ativa para PostgreSQL. */
@Repository
public class RepositorioPostgresSessaoAtiva extends SuporteRepositorioPostgres
    implements RepositorioSessaoAtiva {

  public RepositorioPostgresSessaoAtiva(
      JdbcTemplate jdbcTemplate,
      ConversorDocumentoPostgres conversor
  ) {
    super(jdbcTemplate, conversor);
  }

  @Override
  @Transactional
  public RespostaRegistroSessaoAtiva executarRegistro(
      String uid,
      Function<Optional<SessaoAtiva>, EscritaRegistroSessaoAtiva> mutacao
  ) {
    garantirUsuario(uid);
    EscritaRegistroSessaoAtiva escrita = mutacao.apply(buscar(uid));
    var sessao = escrita.sessao();
    jdbcTemplate.update("""
        insert into sessoes_ativas (uid, id_sessao_dispositivo, rotulo_dispositivo, expira_em,
          criada_em, atualizada_em)
        values (?, ?, ?, ?, ?, ?)
        on conflict (uid) do update set
          id_sessao_dispositivo = excluded.id_sessao_dispositivo,
          rotulo_dispositivo = excluded.rotulo_dispositivo,
          expira_em = excluded.expira_em,
          atualizada_em = excluded.atualizada_em
        """,
        uid,
        texto(sessao.get("deviceSessionId")),
        textoOu(sessao.get("deviceLabel"), "device"),
        timestampJdbc(instant(sessao.get("expiresAt"))),
        timestampJdbc(instantOuAgora(sessao.get("registeredAt"))),
        timestampJdbc(instantOuAgora(sessao.get("updatedAt")))
    );
    return escrita.resposta();
  }

  @Override
  @Transactional
  public RespostaLiberacaoSessaoAtiva executarLiberacao(
      String uid,
      Function<Optional<SessaoAtiva>, EscritaLiberacaoSessaoAtiva> mutacao
  ) {
    EscritaLiberacaoSessaoAtiva escrita = mutacao.apply(buscar(uid));
    if (escrita.excluirSessao()) {
      jdbcTemplate.update("delete from sessoes_ativas where uid = ?", uid);
    }
    return escrita.resposta();
  }

  private Optional<SessaoAtiva> buscar(String uid) {
    return jdbcTemplate.query("""
        select id_sessao_dispositivo, rotulo_dispositivo, criada_em, atualizada_em, expira_em
        from sessoes_ativas where uid = ? for update
        """, (resultado, linha) -> new SessaoAtiva(
        resultado.getString("id_sessao_dispositivo"),
        resultado.getString("rotulo_dispositivo"),
        timestamp(resultado.getTimestamp("criada_em").toInstant()),
        timestamp(resultado.getTimestamp("atualizada_em").toInstant()),
        timestamp(resultado.getTimestamp("expira_em").toInstant()),
        timestamp(resultado.getTimestamp("atualizada_em").toInstant())
    ), uid).stream().findFirst();
  }

  private String texto(Object valor) {
    return valor instanceof String texto ? texto : "";
  }

  private String textoOu(Object valor, String padrao) {
    String texto = texto(valor);
    return texto.isBlank() ? padrao : texto;
  }

  private Instant instant(Object valor) {
    if (valor instanceof Timestamp timestamp) {
      return timestamp.toDate().toInstant();
    }
    throw new IllegalStateException("A sessao ativa nao possui data de expiracao valida.");
  }

  private Instant instantOuAgora(Object valor) {
    return valor instanceof Timestamp timestamp ? timestamp.toDate().toInstant() : Instant.now();
  }

  private Timestamp timestamp(Instant instant) {
    return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
  }

  /** Converte o instante de dominio para o tipo esperado pelo driver JDBC. */
  private java.sql.Timestamp timestampJdbc(Instant instant) {
    return java.sql.Timestamp.from(instant);
  }
}
