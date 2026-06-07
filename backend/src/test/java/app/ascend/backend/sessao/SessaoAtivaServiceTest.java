package app.ascend.backend.sessao;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import app.ascend.backend.compartilhado.ExcecaoApi;
import com.google.cloud.Timestamp;
import java.time.Instant;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import org.junit.jupiter.api.Test;

class SessaoAtivaServiceTest {

  @Test
  void registraNovaSessaoComLeaseDeCincoMinutos() {
    RepositorioSessaoAtivaEmMemoria repositorio = new RepositorioSessaoAtivaEmMemoria();

    RespostaRegistroSessaoAtiva resposta = service(repositorio)
        .registrar("user-1", new RequisicaoSessaoAtiva("device-1", "android"));

    assertThat(resposta.status()).isEqualTo("registered");
    assertThat(repositorio.sessaoSalva)
        .containsEntry("deviceSessionId", "device-1")
        .containsEntry("deviceLabel", "android");
    assertThat(repositorio.sessaoSalva.get("registeredAt")).isInstanceOf(Timestamp.class);
    assertThat(repositorio.sessaoSalva.get("lastSeenAt")).isInstanceOf(Timestamp.class);
    assertThat(repositorio.sessaoSalva.get("expiresAt")).isInstanceOf(Timestamp.class);
  }

  @Test
  void renovaMesmaSessaoPreservandoRegisteredAt() {
    RepositorioSessaoAtivaEmMemoria repositorio = new RepositorioSessaoAtivaEmMemoria();
    Timestamp registeredAt = timestamp("2026-06-07T10:00:00Z");
    repositorio.sessaoAtual = new SessaoAtiva(
        "device-1",
        "android",
        registeredAt,
        timestamp("2026-06-07T10:01:00Z"),
        timestamp("2099-01-01T00:00:00Z"),
        timestamp("2026-06-07T10:01:00Z")
    );

    service(repositorio).registrar(
        "user-1",
        new RequisicaoSessaoAtiva("device-1", "android")
    );

    assertThat(repositorio.sessaoSalva).containsEntry("registeredAt", registeredAt);
  }

  @Test
  void rejeitaOutroDispositivoEnquantoSessaoAnteriorNaoExpirou() {
    RepositorioSessaoAtivaEmMemoria repositorio = new RepositorioSessaoAtivaEmMemoria();
    repositorio.sessaoAtual = new SessaoAtiva(
        "device-1",
        "android",
        timestamp("2026-06-07T10:00:00Z"),
        timestamp("2026-06-07T10:01:00Z"),
        timestamp("2099-01-01T00:00:00Z"),
        timestamp("2026-06-07T10:01:00Z")
    );

    assertThatThrownBy(() -> service(repositorio)
        .registrar("user-1", new RequisicaoSessaoAtiva("device-2", "windows")))
        .isInstanceOfSatisfying(ExcecaoApi.class, error -> {
          assertThat(error.codigo()).isEqualTo("active_session_conflict");
          assertThat(error.getMessage()).isEqualTo("Sessao ativa em outro dispositivo.");
        });
    assertThat(repositorio.sessaoSalva).isNull();
  }

  @Test
  void permiteOutroDispositivoQuandoSessaoAnteriorExpirou() {
    RepositorioSessaoAtivaEmMemoria repositorio = new RepositorioSessaoAtivaEmMemoria();
    repositorio.sessaoAtual = new SessaoAtiva(
        "device-1",
        "android",
        timestamp("2026-06-07T10:00:00Z"),
        timestamp("2026-06-07T10:01:00Z"),
        timestamp("2020-01-01T00:00:00Z"),
        timestamp("2026-06-07T10:01:00Z")
    );

    service(repositorio).registrar(
        "user-1",
        new RequisicaoSessaoAtiva("device-2", "windows")
    );

    assertThat(repositorio.sessaoSalva)
        .containsEntry("deviceSessionId", "device-2")
        .containsEntry("deviceLabel", "windows");
  }

  @Test
  void liberaSomenteSessaoDoMesmoDispositivo() {
    RepositorioSessaoAtivaEmMemoria repositorio = new RepositorioSessaoAtivaEmMemoria();
    repositorio.sessaoAtual = new SessaoAtiva(
        "device-1",
        "android",
        timestamp("2026-06-07T10:00:00Z"),
        timestamp("2026-06-07T10:01:00Z"),
        timestamp("2099-01-01T00:00:00Z"),
        timestamp("2026-06-07T10:01:00Z")
    );

    service(repositorio).liberar(
        "user-1",
        new RequisicaoSessaoAtiva("device-2", "windows")
    );
    assertThat(repositorio.excluiuSessao).isFalse();

    service(repositorio).liberar(
        "user-1",
        new RequisicaoSessaoAtiva("device-1", "android")
    );
    assertThat(repositorio.excluiuSessao).isTrue();
  }

  private SessaoAtivaService service(RepositorioSessaoAtivaEmMemoria repositorio) {
    return new SessaoAtivaService(repositorio);
  }

  private Timestamp timestamp(String value) {
    Instant instant = Instant.parse(value);
    return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
  }

  private static class RepositorioSessaoAtivaEmMemoria implements RepositorioSessaoAtiva {
    SessaoAtiva sessaoAtual;
    Map<String, Object> sessaoSalva;
    boolean excluiuSessao;

    @Override
    public RespostaRegistroSessaoAtiva executarRegistro(
        String uid,
        Function<Optional<SessaoAtiva>, EscritaRegistroSessaoAtiva> mutacao
    ) {
      EscritaRegistroSessaoAtiva escrita = mutacao.apply(Optional.ofNullable(sessaoAtual));
      sessaoSalva = escrita.sessao();
      return escrita.resposta();
    }

    @Override
    public RespostaLiberacaoSessaoAtiva executarLiberacao(
        String uid,
        Function<Optional<SessaoAtiva>, EscritaLiberacaoSessaoAtiva> mutacao
    ) {
      EscritaLiberacaoSessaoAtiva escrita = mutacao.apply(Optional.ofNullable(sessaoAtual));
      excluiuSessao = escrita.excluirSessao();
      return escrita.resposta();
    }
  }
}
