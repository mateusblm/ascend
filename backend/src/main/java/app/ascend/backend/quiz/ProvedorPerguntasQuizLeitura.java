package app.ascend.backend.quiz;

import java.util.List;

public interface ProvedorPerguntasQuizLeitura {

  List<PerguntaQuizLeitura> gerarPerguntas(RequisicaoGeracaoQuizLeitura requisicao);
}
