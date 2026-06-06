package app.ascend.backend.promocao;

import app.ascend.backend.competitivo.SnapshotRankCompetitivo;

public interface RepositorioPromocaoCompetitiva {

  ExamePromocao buscarExameAtual(String uid);

  void gravarInicioExame(String uid, ExamePromocao exame);

  void gravarPromocao(String uid, SnapshotRankCompetitivo snapshot, ExamePromocao exame);
}
