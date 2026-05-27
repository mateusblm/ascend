package app.ascend.backend.auth;

public class InvalidFirebaseAuthTokenException extends RuntimeException {

  public InvalidFirebaseAuthTokenException(String message, Throwable cause) {
    super(message, cause);
  }
}
