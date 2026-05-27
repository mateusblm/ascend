package app.ascend.backend.shared;

import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

@RestControllerAdvice
public class ApiExceptionHandler {

  @ExceptionHandler(ResponseStatusException.class)
  ResponseEntity<Map<String, String>> handleResponseStatus(ResponseStatusException error) {
    return ResponseEntity
        .status(error.getStatusCode())
        .body(Map.of("error", error.getReason() == null ? "request_failed" : error.getReason()));
  }

  @ExceptionHandler(MethodArgumentNotValidException.class)
  ResponseEntity<Map<String, String>> handleValidation() {
    return ResponseEntity.badRequest().body(Map.of("error", "invalid_request"));
  }
}
