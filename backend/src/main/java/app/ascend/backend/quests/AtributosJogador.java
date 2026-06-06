package app.ascend.backend.quests;

record AtributosJogador(
    int strength,
    int intelligence,
    int vitality,
    int agility
) {

  AtributosJogador incrementar(String atributo) {
    return switch (atributo) {
      case "strength" -> new AtributosJogador(strength + 1, intelligence, vitality, agility);
      case "intelligence" -> new AtributosJogador(strength, intelligence + 1, vitality, agility);
      case "vitality" -> new AtributosJogador(strength, intelligence, vitality + 1, agility);
      case "agility" -> new AtributosJogador(strength, intelligence, vitality, agility + 1);
      default -> this;
    };
  }

  MapBuilder paraMap() {
    return new MapBuilder()
        .put("strength", strength)
        .put("intelligence", intelligence)
        .put("vitality", vitality)
        .put("agility", agility);
  }
}
