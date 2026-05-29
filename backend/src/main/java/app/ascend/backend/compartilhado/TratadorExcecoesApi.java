package app.ascend.backend.compartilhado;

import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

@RestControllerAdvice
public class TratadorExcecoesApi {

  @ExceptionHandler(ExcecaoApi.class)
  ResponseEntity<Map<String, String>> tratarExcecaoApi(ExcecaoApi error) {
    return ResponseEntity
        .status(error.status())
        .body(Map.of("error", error.codigo(), "message", error.getMessage()));
  }

  @ExceptionHandler(ResponseStatusException.class)
  ResponseEntity<Map<String, String>> tratarStatusDaResposta(ResponseStatusException error) {
    return ResponseEntity
        .status(error.getStatusCode())
        .body(Map.of(
            "error",
            error.getReason() == null ? "request_failed" : error.getReason(),
            "message",
            "A requisicao nao pode ser processada."
        ));
  }

  @ExceptionHandler(MethodArgumentNotValidException.class)
  ResponseEntity<Map<String, String>> tratarValidacao() {
    return ResponseEntity.badRequest().body(Map.of(
        "error",
        "invalid_request",
        "message",
        "Payload invalido."
    ));
  }
}
