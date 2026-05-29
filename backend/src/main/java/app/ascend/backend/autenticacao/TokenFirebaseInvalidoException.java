package app.ascend.backend.autenticacao;

public class TokenFirebaseInvalidoException extends RuntimeException {

  public TokenFirebaseInvalidoException(String message, Throwable cause) {
    super(message, cause);
  }
}
