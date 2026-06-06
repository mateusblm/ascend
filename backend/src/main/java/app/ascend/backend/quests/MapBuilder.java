package app.ascend.backend.quests;

import java.util.HashMap;
import java.util.Map;

final class MapBuilder {

  private final Map<String, Object> data = new HashMap<>();

  MapBuilder put(String key, Object value) {
    data.put(key, value);
    return this;
  }

  Map<String, Object> build() {
    return data;
  }
}
