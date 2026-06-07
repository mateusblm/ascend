package app.ascend.backend.boss;

import java.util.Map;

record EscritaResgateBossSemanal(
    Map<String, Object> perfil,
    Map<String, Object> conclusao,
    Map<String, Object> resgateUsuario,
    boolean incrementarConclusoes,
    RespostaResgateBossSemanal resposta
) {
}
