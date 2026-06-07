package app.ascend.backend.quiz;

import app.ascend.backend.compartilhado.ExcecaoApi;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.cloud.secretmanager.v1.AccessSecretVersionResponse;
import com.google.cloud.secretmanager.v1.SecretManagerServiceClient;
import com.google.cloud.secretmanager.v1.SecretVersionName;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.ArrayList;
import java.util.List;
import org.springframework.http.HttpStatus;

public class ProvedorGeminiQuizLeitura implements ProvedorPerguntasQuizLeitura {

  private final ObjectMapper objectMapper;
  private final HttpClient httpClient;
  private final String projectId;
  private final String secretId;
  private final String model;

  public ProvedorGeminiQuizLeitura(
      ObjectMapper objectMapper,
      String projectId,
      String secretId,
      String model
  ) {
    this.objectMapper = objectMapper;
    this.httpClient = HttpClient.newHttpClient();
    this.projectId = projectId;
    this.secretId = secretId == null || secretId.isBlank() ? "GEMINI_API_KEY" : secretId;
    this.model = model == null || model.isBlank() ? "gemini-2.5-flash-lite" : model;
  }

  @Override
  public List<PerguntaQuizLeitura> gerarPerguntas(RequisicaoGeracaoQuizLeitura requisicao) {
    try {
      String apiKey = carregarApiKey();
      HttpRequest request = HttpRequest.newBuilder()
          .uri(URI.create("https://generativelanguage.googleapis.com/v1beta/models/"
              + model + ":generateContent"))
          .header("Content-Type", "application/json")
          .header("x-goog-api-key", apiKey)
          .POST(HttpRequest.BodyPublishers.ofString(corpoGemini(requisicao)))
          .build();
      HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
      if (response.statusCode() < 200 || response.statusCode() >= 300) {
        throw new ExcecaoApi(
            HttpStatus.SERVICE_UNAVAILABLE,
            "reading_quiz_gemini_unavailable",
            "Gemini nao conseguiu gerar o quiz de leitura."
        );
      }
      return perguntasDaResposta(response.body());
    } catch (ExcecaoApi error) {
      throw error;
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Geracao do quiz de leitura interrompida.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel gerar quiz de leitura com Gemini.", error);
    }
  }

  private String carregarApiKey() throws Exception {
    String env = System.getenv("GEMINI_API_KEY");
    if (env != null && !env.isBlank()) {
      return env;
    }
    if (projectId == null || projectId.isBlank()) {
      throw new ExcecaoApi(
          HttpStatus.PRECONDITION_FAILED,
          "reading_quiz_secret_project_missing",
          "Projeto do Secret Manager nao configurado."
      );
    }
    try (SecretManagerServiceClient client = SecretManagerServiceClient.create()) {
      SecretVersionName name = SecretVersionName.of(projectId, secretId, "latest");
      AccessSecretVersionResponse response = client.accessSecretVersion(name);
      return response.getPayload().getData().toStringUtf8();
    }
  }

  private String corpoGemini(RequisicaoGeracaoQuizLeitura requisicao) throws Exception {
    return objectMapper.writeValueAsString(java.util.Map.of(
        "contents",
        List.of(java.util.Map.of(
            "parts",
            List.of(java.util.Map.of("text", prompt(requisicao)))
        )),
        "generationConfig",
        java.util.Map.of("temperature", 0.2, "responseMimeType", "application/json")
    ));
  }

  private String prompt(RequisicaoGeracaoQuizLeitura requisicao) {
    return String.join("\n",
        "Voce gera quizzes curtos de compreensao de leitura para o app Ascend.",
        "Responda somente JSON com a chave questions.",
        "Crie 2 perguntas em portugues brasileiro.",
        "Cada pergunta deve ter id, prompt e acceptedAnswer.",
        "acceptedAnswer deve conter 2 a 5 palavras-chave.",
        "Nao inclua dados pessoais, explicacoes ou markdown.",
        "Topico declarado pelo usuario: " + requisicao.topic()
    );
  }

  private List<PerguntaQuizLeitura> perguntasDaResposta(String body) throws Exception {
    JsonNode root = objectMapper.readTree(body);
    String text = root.path("candidates").path(0).path("content").path("parts").path(0).path("text").asText("");
    if (text.isBlank()) {
      throw new ExcecaoApi(
          HttpStatus.SERVICE_UNAVAILABLE,
          "reading_quiz_gemini_empty",
          "Texto de quiz ausente no Gemini."
      );
    }
    JsonNode parsed = objectMapper.readTree(text);
    JsonNode questions = parsed.path("questions");
    List<PerguntaQuizLeitura> resultado = new ArrayList<>();
    if (questions.isArray()) {
      for (JsonNode question : questions) {
        resultado.add(new PerguntaQuizLeitura(
            question.path("id").asText("gemini-question-" + (resultado.size() + 1)),
            question.path("prompt").asText(),
            question.path("acceptedAnswer").asText()
        ));
      }
    }
    return resultado;
  }
}
