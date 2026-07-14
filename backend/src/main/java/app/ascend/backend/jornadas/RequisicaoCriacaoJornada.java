package app.ascend.backend.jornadas;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Dados minimos para iniciar uma Jornada sem alongar a ativacao do jogador. */
public record RequisicaoCriacaoJornada(
    @NotBlank(message = "O titulo da Jornada e obrigatorio.")
    @Size(max = 100, message = "O titulo da Jornada deve ter no maximo 100 caracteres.")
    String titulo,
    @NotBlank(message = "O objetivo da Jornada e obrigatorio.")
    @Size(max = 240, message = "O objetivo da Jornada deve ter no maximo 240 caracteres.")
    String objetivo,
    @Size(max = 320, message = "A motivacao da Jornada deve ter no maximo 320 caracteres.")
    String motivacao
) {}
