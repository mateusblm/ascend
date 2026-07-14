package app.ascend.backend.jornadas;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Dados para criar um marco manual ou ligar uma missao existente ao capitulo. */
public record RequisicaoCriacaoMarco(
    @NotBlank @Size(max = 140) String titulo,
    @Size(max = 140) String questId
) {}
