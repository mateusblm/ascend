package app.ascend.backend.perfil;

import java.util.HashMap;
import java.util.Map;

public record AtributosPerfil(
    int strength,
    int intelligence,
    int vitality,
    int agility
) {

  public AtributosPerfil incrementar(String atributo) {
    return switch (atributo) {
      case "strength" -> new AtributosPerfil(strength + 1, intelligence, vitality, agility);
      case "intelligence" -> new AtributosPerfil(strength, intelligence + 1, vitality, agility);
      case "vitality" -> new AtributosPerfil(strength, intelligence, vitality + 1, agility);
      case "agility" -> new AtributosPerfil(strength, intelligence, vitality, agility + 1);
      default -> this;
    };
  }

  public Map<String, Object> paraDocumento() {
    Map<String, Object> data = new HashMap<>();
    data.put("strength", strength);
    data.put("intelligence", intelligence);
    data.put("vitality", vitality);
    data.put("agility", agility);
    return data;
  }
}
