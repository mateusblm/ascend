package app.ascend.backend.jornadas;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Dados minimos para adicionar uma etapa a Jornada ativa. */
public record RequisicaoCriacaoCapitulo(
    @NotBlank(message = "O titulo do capitulo e obrigatorio.")
    @Size(max = 120, message = "O titulo do capitulo deve ter no maximo 120 caracteres.")
    String titulo
) {}
