package app.ascend.backend.perfil;

import java.util.Map;

record EscritaPerfil(
    Map<String, Object> perfil,
    Map<String, Object> auditoriaAlocacao,
    RespostaPerfil resposta
) {
}
