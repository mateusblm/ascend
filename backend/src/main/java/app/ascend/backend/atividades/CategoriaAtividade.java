package app.ascend.backend.atividades;

import java.util.List;

public record CategoriaAtividade(String id, String nome, List<ModalidadeAtividade> modalidades) {}
