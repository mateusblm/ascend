package app.ascend.backend.temporada;

import java.time.Instant;

public interface RepositorioRecompensaTemporada {

  ResultadoResgateRecompensaTemporada resgatarRecompensaAtual(
      String uid,
      String chaveTemporadaSolicitada,
      Instant agora,
      ResolvedorResgateRecompensaTemporada resolvedor
  );
}
