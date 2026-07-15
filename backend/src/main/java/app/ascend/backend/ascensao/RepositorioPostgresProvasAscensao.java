package app.ascend.backend.ascensao;

import app.ascend.backend.infraestrutura.postgres.ConversorDocumentoPostgres;
import app.ascend.backend.infraestrutura.postgres.SuporteRepositorioPostgres;
import java.util.Map;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class RepositorioPostgresProvasAscensao extends SuporteRepositorioPostgres
    implements RepositorioProvasAscensao {

  public RepositorioPostgresProvasAscensao(
      JdbcTemplate jdbcTemplate, ConversorDocumentoPostgres conversor
  ) {
    super(jdbcTemplate, conversor);
  }

  @Override
  public boolean talentoDesbloqueado(String uid, String talentoId) {
    return !jdbcTemplate.queryForList(
        "select talento_id from resgates_provas_ascensao where uid = ? and talento_id = ?",
        String.class, uid, talentoId
    ).isEmpty();
  }

  @Override
  public boolean registrarResgate(
      String uid, String provaId, String talentoId, Map<String, Object> dados
  ) {
    garantirUsuario(uid);
    return jdbcTemplate.update("""
        insert into resgates_provas_ascensao (uid, prova_id, talento_id, dados)
        values (?, ?, ?, cast(? as jsonb))
        on conflict (uid, prova_id) do nothing
        """, uid, provaId, talentoId, json(dados)) == 1;
  }
}
