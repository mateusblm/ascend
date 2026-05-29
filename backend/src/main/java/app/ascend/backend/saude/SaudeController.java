package app.ascend.backend.saude;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SaudeController {

  @GetMapping("/health")
  public RespostaSaude verificarSaude() {
    return new RespostaSaude("ok", "ascend-backend");
  }
}
