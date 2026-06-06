package app.ascend.backend.temporada;

import java.time.Instant;

@FunctionalInterface
public interface ResolvedorResgateRecompensaTemporada {

  ResolucaoResgateRecompensaTemporada resolver(RecompensaTemporada recompensaAtual, Instant agora);
}
