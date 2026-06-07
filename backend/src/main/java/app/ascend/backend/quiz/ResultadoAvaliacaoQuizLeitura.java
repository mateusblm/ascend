package app.ascend.backend.quiz;

import java.util.List;

/**
 * Resultado calculado pelo backend para uma submissao de quiz de leitura.
 * `riskFlags` segue os nomes do contrato legado para manter UI, auditoria e
 * rollback compreensiveis durante a migracao.
 */
public record ResultadoAvaliacaoQuizLeitura(
    String quizId,
    int score,
    boolean aprovado,
    List<String> riskFlags
) {
}
