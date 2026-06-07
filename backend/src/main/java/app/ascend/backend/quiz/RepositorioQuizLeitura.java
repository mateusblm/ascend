package app.ascend.backend.quiz;

public interface RepositorioQuizLeitura {

  void gravarTentativa(
      String uid,
      TentativaQuizLeitura tentativa,
      String idSessaoDispositivo,
      String rotuloDispositivo
  );
}
