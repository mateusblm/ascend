package app.ascend.backend.jornadas;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Ajusta o proposito de uma Jornada ativa sem alterar sua rota ou Legado. */
public record RequisicaoAtualizacaoJornada(
    @NotBlank @Size(max = 120) String titulo,
    @NotBlank @Size(max = 500) String objetivo,
    @Size(max = 500) String motivacao
) { }
