package app.ascend.backend.atividades;

import java.util.List;

public record ModalidadeAtividade(String id, String nome, List<DefinicaoAtividade> atividades) {}
