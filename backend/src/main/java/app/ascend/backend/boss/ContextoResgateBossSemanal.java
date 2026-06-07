package app.ascend.backend.boss;

import java.util.Map;

record ContextoResgateBossSemanal(
    Map<String, Object> boss,
    boolean bossExiste,
    boolean conclusaoExiste,
    boolean resgateUsuarioExiste,
    Map<String, Object> perfil
) {
}
