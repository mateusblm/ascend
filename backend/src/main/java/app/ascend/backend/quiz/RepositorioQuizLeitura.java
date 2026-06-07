package app.ascend.backend.quiz;

import java.util.Optional;

public interface RepositorioQuizLeitura {

  /**
   * Persiste uma tentativa emitida pelo backend com respostas aceitas privadas.
   * O Flutter recebe apenas perguntas publicas; o documento completo e usado
   * depois pela verificacao competitiva para calcular o score real.
   */
  void gravarTentativa(
      String uid,
      TentativaQuizLeitura tentativa,
      String idSessaoDispositivo,
      String rotuloDispositivo
  );

  /**
   * Busca a tentativa autoritativa do usuario para avaliacao de respostas. A
   * ausencia deve virar evidencia insuficiente, nao concessao de recompensa.
   */
  Optional<TentativaQuizLeitura> buscarTentativa(String uid, String quizId);
}
