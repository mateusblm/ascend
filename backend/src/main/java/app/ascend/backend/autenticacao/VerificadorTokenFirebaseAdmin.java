package app.ascend.backend.autenticacao;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import org.springframework.stereotype.Component;

@Component
public class VerificadorTokenFirebaseAdmin implements VerificadorTokenFirebaseAuth {

  @Override
  public UsuarioAutenticado verificar(String idToken) {
    try {
      FirebaseToken token = FirebaseAuth.getInstance().verifyIdToken(idToken);
      return new UsuarioAutenticado(token.getUid(), token.getEmail());
    } catch (FirebaseAuthException error) {
      throw new TokenFirebaseInvalidoException("Invalid Firebase ID token.", error);
    }
  }
}
