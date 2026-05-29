package app.ascend.backend.autenticacao;

public interface VerificadorTokenFirebaseAuth {

  UsuarioAutenticado verificar(String idToken);
}
