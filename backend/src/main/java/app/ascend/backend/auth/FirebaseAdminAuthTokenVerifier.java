package app.ascend.backend.auth;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import org.springframework.stereotype.Component;

@Component
public class FirebaseAdminAuthTokenVerifier implements FirebaseAuthTokenVerifier {

  @Override
  public AuthenticatedUser verify(String idToken) {
    try {
      FirebaseToken token = FirebaseAuth.getInstance().verifyIdToken(idToken);
      return new AuthenticatedUser(token.getUid(), token.getEmail());
    } catch (FirebaseAuthException error) {
      throw new InvalidFirebaseAuthTokenException("Invalid Firebase ID token.", error);
    }
  }
}
