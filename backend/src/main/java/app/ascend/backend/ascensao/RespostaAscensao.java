package app.ascend.backend.ascensao;

import java.util.List;

/** Leitura canônica de Ascensão; o cliente apenas apresenta estes fatos. */
public record RespostaAscensao(
    ProvaAscensao prova,
    PatamarAscensao patamar,
    List<RegistroLegadoAscensao> legado
) {}
