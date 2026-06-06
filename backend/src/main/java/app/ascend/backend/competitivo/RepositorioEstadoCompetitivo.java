package app.ascend.backend.competitivo;

import java.time.Instant;
import java.util.List;

public interface RepositorioEstadoCompetitivo {

  SnapshotRankCompetitivo buscarSnapshotRankAtual(String uid);

  List<Instant> buscarHistoricoCompetitivoAutorizado(String uid);

  void gravarSnapshotRank(String uid, SnapshotRankCompetitivo snapshot);

  void gravarSnapshotIntegridade(String uid, SnapshotIntegridadeCompetitiva snapshot);
}
