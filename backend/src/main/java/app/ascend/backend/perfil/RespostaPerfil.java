package app.ascend.backend.perfil;

import java.util.Map;

public record RespostaPerfil(
    String status,
    Map<String, Object> profile
) {
}
