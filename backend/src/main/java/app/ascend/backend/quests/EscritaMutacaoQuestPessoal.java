package app.ascend.backend.quests;

import java.util.Map;

record EscritaMutacaoQuestPessoal(
    Map<String, Object> perfil,
    Map<String, Object> quest,
    Map<String, Object> conclusao,
    boolean excluirConclusao,
    RespostaMutacaoQuestPessoal resposta
) {
}
