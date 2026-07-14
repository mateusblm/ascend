package app.ascend.backend.configuracao;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

@Configuration
public class ConfiguracaoFirebaseAdmin {
  private static final String CHAVE_CREDENCIAL_RAILWAY = "FIREBASE_SERVICE_ACCOUNT_JSON";

  private final Environment environment;

  public ConfiguracaoFirebaseAdmin(Environment environment) {
    this.environment = environment;
  }

  @Bean
  FirebaseApp firebaseApp() throws IOException {
    if (!FirebaseApp.getApps().isEmpty()) {
      return FirebaseApp.getInstance();
    }

    FirebaseOptions options = FirebaseOptions.builder()
        .setCredentials(credenciaisFirebase())
        .build();
    return FirebaseApp.initializeApp(options);
  }

  /**
   * Usa a service account injetada pelo Railway no ambiente remoto e ADC no desenvolvimento local.
   * A verificacao de tokens Firebase depende desta credencial; por isso a chave nunca e lida de arquivo
   * versionado.
   */
  private GoogleCredentials credenciaisFirebase() throws IOException {
    String credencialRailway = environment.getProperty(CHAVE_CREDENCIAL_RAILWAY, "").trim();
    if (credencialRailway.isBlank()) {
      return GoogleCredentials.getApplicationDefault();
    }
    try (ByteArrayInputStream entrada = new ByteArrayInputStream(
        credencialRailway.getBytes(StandardCharsets.UTF_8))) {
      return GoogleCredentials.fromStream(entrada);
    }
  }
}
