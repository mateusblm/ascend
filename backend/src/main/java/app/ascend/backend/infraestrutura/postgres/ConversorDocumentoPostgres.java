package app.ascend.backend.infraestrutura.postgres;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.cloud.Timestamp;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

/**
 * Converte os documentos usados pelos agregados para JSONB sem vazar detalhes
 * do PostgreSQL para a camada de dominio. Datas continuam sendo expostas como
 * {@link Timestamp}, preservando o contrato atual das rotas Java.
 */
@Component
public class ConversorDocumentoPostgres {

  private final ObjectMapper objectMapper;

  public ConversorDocumentoPostgres(ObjectMapper objectMapper) {
    this.objectMapper = objectMapper;
  }

  public String paraJson(Map<String, Object> documento) {
    try {
      return objectMapper.writeValueAsString(normalizarParaJson(documento));
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel serializar os dados do jogo.", error);
    }
  }

  public Map<String, Object> paraDocumento(String json) {
    if (json == null || json.isBlank()) {
      return Map.of();
    }
    try {
      Map<String, Object> bruto = objectMapper.readValue(json, new TypeReference<>() { });
      return normalizarDoJson(bruto);
    } catch (Exception error) {
      throw new IllegalStateException("Nao foi possivel ler os dados do jogo.", error);
    }
  }

  private Object normalizarParaJson(Object valor) {
    if (valor instanceof Timestamp timestamp) {
      return timestamp.toDate().toInstant().toString();
    }
    if (valor instanceof Map<?, ?> mapa) {
      Map<String, Object> normalizado = new LinkedHashMap<>();
      mapa.forEach((chave, item) -> normalizado.put(String.valueOf(chave), normalizarParaJson(item)));
      return normalizado;
    }
    if (valor instanceof List<?> lista) {
      return lista.stream().map(this::normalizarParaJson).toList();
    }
    return valor;
  }

  @SuppressWarnings("unchecked")
  private Map<String, Object> normalizarDoJson(Map<String, Object> mapa) {
    Map<String, Object> normalizado = new LinkedHashMap<>();
    for (Map.Entry<String, Object> entrada : mapa.entrySet()) {
      normalizado.put(entrada.getKey(), normalizarValorDoJson(entrada.getKey(), entrada.getValue()));
    }
    return normalizado;
  }

  @SuppressWarnings("unchecked")
  private Object normalizarValorDoJson(String chave, Object valor) {
    if (valor instanceof Map<?, ?> mapa) {
      return normalizarDoJson((Map<String, Object>) mapa);
    }
    if (valor instanceof List<?> lista) {
      List<Object> normalizada = new ArrayList<>(lista.size());
      for (Object item : lista) {
        normalizada.add(normalizarValorDoJson(chave, item));
      }
      return normalizada;
    }
    if (valor instanceof String texto && eCampoTemporal(chave)) {
      try {
        Instant instant = Instant.parse(texto);
        return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
      } catch (Exception ignored) {
        return texto;
      }
    }
    return valor;
  }

  private boolean eCampoTemporal(String chave) {
    return chave.endsWith("At") || chave.endsWith("Date") || chave.endsWith("Em");
  }
}
