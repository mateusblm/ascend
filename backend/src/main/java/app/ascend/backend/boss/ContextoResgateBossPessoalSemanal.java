package app.ascend.backend.boss;

import java.util.Map;

record ContextoResgateBossPessoalSemanal(
    boolean resgateUsuarioExiste,
    Map<String, Object> perfil
) {
}
