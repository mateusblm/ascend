package app.ascend.backend.infraestrutura.postgres;

import java.util.Map;
import org.springframework.jdbc.core.JdbcTemplate;

/** Funcoes comuns dos adaptadores PostgreSQL do dominio do jogo. */
public abstract class SuporteRepositorioPostgres {

  protected final JdbcTemplate jdbcTemplate;
  protected final ConversorDocumentoPostgres conversor;

  protected SuporteRepositorioPostgres(
      JdbcTemplate jdbcTemplate,
      ConversorDocumentoPostgres conversor
  ) {
    this.jdbcTemplate = jdbcTemplate;
    this.conversor = conversor;
  }

  /** Garante a chave estrangeira do usuario antes de persistir qualquer agregado. */
  protected void garantirUsuario(String uid) {
    jdbcTemplate.update("""
        insert into usuarios (uid) values (?)
        on conflict (uid) do update set atualizado_em = current_timestamp
        """, uid);
  }

  protected Map<String, Object> documentoOuVazio(String sql, Object... parametros) {
    return jdbcTemplate.query(sql, (resultado, numeroLinha) ->
        conversor.paraDocumento(resultado.getString(1)), parametros
    ).stream().findFirst().orElse(Map.of());
  }

  protected String json(Map<String, Object> documento) {
    return conversor.paraJson(documento);
  }
}
