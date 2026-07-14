package app.ascend.backend.perfil;

import app.ascend.backend.infraestrutura.postgres.ConversorDocumentoPostgres;
import app.ascend.backend.infraestrutura.postgres.SuporteRepositorioPostgres;
import java.util.Map;
import java.util.function.Function;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

/** Persistencia transacional do agregado de perfil no PostgreSQL. */
@Repository
public class RepositorioPostgresPerfil extends SuporteRepositorioPostgres implements RepositorioPerfil {

  public RepositorioPostgresPerfil(JdbcTemplate jdbcTemplate, ConversorDocumentoPostgres conversor) {
    super(jdbcTemplate, conversor);
  }

  @Override
  @Transactional
  public RespostaPerfil executarMutacao(
      String uid,
      Function<Map<String, Object>, EscritaPerfil> mutacao
  ) {
    garantirUsuario(uid);
    EscritaPerfil escrita = mutacao.apply(documentoOuVazio(
        "select dados::text from perfis_jogador where uid = ? for update", uid
    ));
    salvarPerfil(uid, escrita.perfil());
    return escrita.resposta();
  }

  public Map<String, Object> buscarPerfil(String uid) {
    return documentoOuVazio("select dados::text from perfis_jogador where uid = ?", uid);
  }

  /**
   * Persiste o documento autoritativo de perfil dentro da transacao do caso de
   * uso chamador, mantendo quest, boss e perfil atomicamente consistentes.
   */
  public void salvarPerfil(String uid, Map<String, Object> perfil) {
    jdbcTemplate.update("""
        insert into perfis_jogador (uid, nome, dados)
        values (?, ?, cast(? as jsonb))
        on conflict (uid) do update set
          nome = excluded.nome,
          dados = excluded.dados,
          atualizado_em = current_timestamp
        """, uid, textoOu(perfil.get("name"), "Jogador"), json(perfil));
  }

  private String textoOu(Object valor, String padrao) {
    if (valor instanceof String texto && !texto.isBlank()) {
      return texto.trim();
    }
    return padrao;
  }
}
