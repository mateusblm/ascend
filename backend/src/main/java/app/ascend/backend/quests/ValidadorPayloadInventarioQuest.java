package app.ascend.backend.quests;

import com.google.cloud.Timestamp;
import java.time.Instant;
import java.util.Map;
import java.util.Set;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

/**
 * Helpers pequenos para validar payloads nao confiaveis do inventario de quests.
 */
final class ValidadorPayloadInventarioQuest {

  private ValidadorPayloadInventarioQuest() {
  }

  static String requireString(Object value, String field, int maxLength) {
    if (!(value instanceof String text)) {
      throw badRequest("invalid_" + field);
    }
    String trimmed = text.trim();
    if (trimmed.isEmpty() || trimmed.length() > maxLength) {
      throw badRequest("invalid_" + field);
    }
    return trimmed;
  }

  static String optionalString(
      Object value,
      String field,
      int maxLength,
      String defaultValue
  ) {
    if (value == null) {
      return defaultValue;
    }
    if (!(value instanceof String text)) {
      throw badRequest("invalid_" + field);
    }
    String trimmed = text.trim();
    if (trimmed.isEmpty()) {
      return defaultValue;
    }
    if (trimmed.length() > maxLength) {
      throw badRequest("invalid_" + field);
    }
    return trimmed;
  }

  static String requireLowerAllowed(Object value, String field, Set<String> allowed) {
    return requireAllowed(requireString(value, field, 32).toLowerCase(), field, allowed);
  }

  static String requireAllowed(Object value, String field, Set<String> allowed) {
    String text = requireString(value, field, 32);
    if (!allowed.contains(text)) {
      throw badRequest("invalid_" + field);
    }
    return text;
  }

  static int requireInt(Object value, String field, int min) {
    if (!(value instanceof Number number)) {
      throw badRequest("invalid_" + field);
    }
    double asDouble = number.doubleValue();
    int asInt = number.intValue();
    if (!Double.isFinite(asDouble) || asDouble != asInt || asInt < min) {
      throw badRequest("invalid_" + field);
    }
    return asInt;
  }

  static Integer optionalNonNegativeInt(Object value, String field) {
    if (value == null) {
      return null;
    }
    return requireInt(value, field, 0);
  }

  static boolean requireBoolean(Object value, String field) {
    if (!(value instanceof Boolean bool)) {
      throw badRequest("invalid_" + field);
    }
    return bool;
  }

  @SuppressWarnings("unchecked")
  static Timestamp optionalTimestamp(Object value, String field) {
    if (value == null) {
      return null;
    }
    if (value instanceof Timestamp timestamp) {
      return timestamp;
    }
    if (value instanceof Number number && Double.isFinite(number.doubleValue())) {
      return timestampFromMillis(number.longValue());
    }
    if (value instanceof String text) {
      return parseInstant(text, field);
    }
    if (value instanceof Map<?, ?> rawMap) {
      Map<String, Object> data = (Map<String, Object>) rawMap;
      Object seconds = firstNonNull(data.get("seconds"), data.get("_seconds"));
      Object nanoseconds = firstNonNull(data.get("nanoseconds"), data.get("_nanoseconds"));
      if (seconds instanceof Number secondsNumber) {
        int nanos = nanoseconds instanceof Number nanosNumber ? nanosNumber.intValue() : 0;
        return Timestamp.ofTimeSecondsAndNanos(secondsNumber.longValue(), nanos);
      }

      Object milliseconds = firstNonNull(
          data.get("millisecondsSinceEpoch"),
          data.get("_millisecondsSinceEpoch")
      );
      if (milliseconds instanceof Number millisNumber) {
        return timestampFromMillis(millisNumber.longValue());
      }

      Object isoString = firstNonNull(data.get("iso8601"), data.get("isoString"));
      if (isoString instanceof String text) {
        return parseInstant(text, field);
      }
    }
    throw badRequest("invalid_" + field);
  }

  static ResponseStatusException badRequest(String reason) {
    return new ResponseStatusException(HttpStatus.BAD_REQUEST, reason);
  }

  private static Timestamp parseInstant(String value, String field) {
    try {
      Instant instant = Instant.parse(value);
      return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
    } catch (Exception ignored) {
      throw badRequest("invalid_" + field);
    }
  }

  private static Timestamp timestampFromMillis(long milliseconds) {
    return Timestamp.ofTimeSecondsAndNanos(
        milliseconds / 1000,
        (int) (milliseconds % 1000) * 1_000_000
    );
  }

  private static Object firstNonNull(Object first, Object second) {
    return first != null ? first : second;
  }
}
