package app.ascend.backend.sessao;

import java.util.Map;

record EscritaRegistroSessaoAtiva(
    Map<String, Object> sessao,
    RespostaRegistroSessaoAtiva resposta
) {
}
