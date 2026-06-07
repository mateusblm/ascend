package app.ascend.backend.quiz;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

@Component
class FabricaGeradorQuizLeitura {

  private final Environment environment;
  private final ObjectMapper objectMapper;

  FabricaGeradorQuizLeitura(Environment environment, ObjectMapper objectMapper) {
    this.environment = environment;
    this.objectMapper = objectMapper;
  }

  GeradorQuizLeitura criar() {
    String configurado = environment.getProperty("ASCEND_READING_QUIZ_GENERATOR", "deterministic");
    if ("ai".equals(configurado)) {
      return new GeradorIaQuizLeitura(new ProvedorGeminiQuizLeitura(
          objectMapper,
          environment.getProperty("GOOGLE_CLOUD_PROJECT"),
          environment.getProperty("GEMINI_API_KEY_SECRET", "GEMINI_API_KEY"),
          environment.getProperty("GEMINI_READING_QUIZ_MODEL", "gemini-2.5-flash-lite")
      ));
    }
    return new GeradorDeterministicoQuizLeitura();
  }
}
