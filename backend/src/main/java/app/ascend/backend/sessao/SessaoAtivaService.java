package app.ascend.backend.sessao;

import app.ascend.backend.compartilhado.ExcecaoApi;
import com.google.cloud.Timestamp;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class SessaoAtivaService {

  private static final long DURACAO_LEASE_MILLIS = 5 * 60 * 1000;

  private final RepositorioSessaoAtiva repositorio;

  public SessaoAtivaService(RepositorioSessaoAtiva repositorio) {
    this.repositorio = repositorio;
  }

  /**
   * Registra ou renova a sessao ativa do dispositivo. Enquanto a sessao atual
   * estiver dentro da janela de lease, apenas o mesmo `deviceSessionId` pode
   * renovar; outro dispositivo recebe conflito para proteger a conta.
   */
  public RespostaRegistroSessaoAtiva registrar(String uid, RequisicaoSessaoAtiva request) {
    DadosSessao dados = validar(request);
    Timestamp now = Timestamp.now();
    Timestamp expiresAt = adicionarMillis(now, DURACAO_LEASE_MILLIS);
    return repositorio.executarRegistro(uid, atual -> {
      if (atual.isPresent()
          && !atual.get().deviceSessionId().isBlank()
          && !atual.get().deviceSessionId().equals(dados.deviceSessionId())
          && atual.get().expiresAt() != null
          && atual.get().expiresAt().compareTo(now) > 0) {
        throw new ExcecaoApi(
            HttpStatus.PRECONDITION_FAILED,
            "active_session_conflict",
            "Sessao ativa em outro dispositivo."
        );
      }

      Map<String, Object> sessao = new HashMap<>();
      sessao.put("deviceSessionId", dados.deviceSessionId());
      sessao.put("deviceLabel", dados.deviceLabel());
      sessao.put("registeredAt", atual.map(SessaoAtiva::registeredAt).orElse(null) == null
          ? now
          : atual.map(SessaoAtiva::registeredAt).orElse(now));
      sessao.put("lastSeenAt", now);
      sessao.put("expiresAt", expiresAt);
      sessao.put("updatedAt", now);
      return new EscritaRegistroSessaoAtiva(
          sessao,
          new RespostaRegistroSessaoAtiva("registered", iso(expiresAt))
      );
    });
  }

  /**
   * Libera a sessao ativa somente quando o dispositivo solicitante e o dono
   * atual. Requisicoes de logout antigas ou de outro dispositivo sao
   * idempotentes e nao removem a sessao vigente.
   */
  public RespostaLiberacaoSessaoAtiva liberar(String uid, RequisicaoSessaoAtiva request) {
    DadosSessao dados = validar(request);
    return repositorio.executarLiberacao(uid, atual -> new EscritaLiberacaoSessaoAtiva(
        atual.isPresent() && atual.get().deviceSessionId().equals(dados.deviceSessionId()),
        new RespostaLiberacaoSessaoAtiva("released")
    ));
  }

  private DadosSessao validar(RequisicaoSessaoAtiva request) {
    if (request == null) {
      throw payloadInvalido("Payload de sessao invalido.");
    }
    String deviceSessionId = textoObrigatorio(request.deviceSessionId(), "deviceSessionId");
    if (deviceSessionId.length() > 120) {
      throw payloadInvalido("deviceSessionId invalido.");
    }
    String deviceLabel = request.deviceLabel() == null || request.deviceLabel().isBlank()
        ? "device"
        : request.deviceLabel().trim();
    if (deviceLabel.length() > 120) {
      throw payloadInvalido("deviceLabel invalido.");
    }
    return new DadosSessao(deviceSessionId, deviceLabel);
  }

  private String textoObrigatorio(String value, String fieldName) {
    if (value == null || value.isBlank()) {
      throw payloadInvalido(fieldName + " obrigatorio.");
    }
    return value.trim();
  }

  private Timestamp adicionarMillis(Timestamp timestamp, long millis) {
    Instant instant = Instant.ofEpochSecond(timestamp.getSeconds(), timestamp.getNanos())
        .plusMillis(millis);
    return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
  }

  private String iso(Timestamp timestamp) {
    return Instant.ofEpochSecond(timestamp.getSeconds(), timestamp.getNanos()).toString();
  }

  private ExcecaoApi payloadInvalido(String mensagem) {
    return new ExcecaoApi(HttpStatus.BAD_REQUEST, "invalid_session_payload", mensagem);
  }

  private record DadosSessao(String deviceSessionId, String deviceLabel) {
  }
}
