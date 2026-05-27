package app.ascend.backend.auth;

public interface FirebaseAuthTokenVerifier {

  AuthenticatedUser verify(String idToken);
}
