package app.ascend.backend.quiz;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.quests.CatalogoQuestCompetitiva;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.mock.env.MockEnvironment;

class InicioQuizLeituraServiceTest {

  private final RepositorioQuizLeituraEmMemoria repositorio =
      new RepositorioQuizLeituraEmMemoria();
  private final GuardaSessaoAtiva guardaSessaoAtiva = Mockito.mock(GuardaSessaoAtiva.class);
  private final InicioQuizLeituraService service = new InicioQuizLeituraService(
      guardaSessaoAtiva,
      new CatalogoQuestCompetitiva(),
      new FabricaGeradorQuizLeitura(new MockEnvironment(), new ObjectMapper()),
      repositorio
  );

  @Test
  void iniciaQuizDeLeituraComContratoPublicoSemRespostaAceita() {
    RespostaInicioQuizLeitura resposta = service.iniciar(
        "user-1",
        new RequisicaoInicioQuizLeitura(
            "device-1",
            "android",
            "reading-20-123",
            "reading-20",
            "Livro de estrategia"
        )
    );

    assertThat(resposta.quizId()).startsWith("reading-20-123__");
    assertThat(resposta.questId()).isEqualTo("reading-20-123");
    assertThat(resposta.topic()).isEqualTo("Livro de estrategia");
    assertThat(resposta.minimumScore()).isEqualTo(70);
    assertThat(resposta.generator()).isEqualTo("deterministic_contract_v1");
    assertThat(resposta.questions()).hasSize(2);
    assertThat(resposta.questions().getFirst().prompt())
        .contains("Livro de estrategia");
    assertThat(repositorio.tentativaGravada.questions().getFirst().acceptedAnswer())
        .isEqualTo("ideia principal");
    assertThat(repositorio.idSessaoDispositivo).isEqualTo("device-1");
    Mockito.verify(guardaSessaoAtiva).exigirSessaoAtiva("user-1", "device-1");
  }

  @Test
  void rejeitaQuestSemTemplateDeLeitura() {
    assertThatThrownBy(() -> service.iniciar(
        "user-1",
        new RequisicaoInicioQuizLeitura(
            "device-1",
            "android",
            "focus-25-123",
            "focus-25",
            "Foco"
        )
    ))
        .isInstanceOfSatisfying(ExcecaoApi.class, error ->
            assertThat(error.codigo()).isEqualTo("reading_quiz_unavailable")
        );
  }

  private static class RepositorioQuizLeituraEmMemoria implements RepositorioQuizLeitura {

    private TentativaQuizLeitura tentativaGravada;
    private String idSessaoDispositivo;

    @Override
    public void gravarTentativa(
        String uid,
        TentativaQuizLeitura tentativa,
        String idSessaoDispositivo,
        String rotuloDispositivo
    ) {
      this.tentativaGravada = tentativa;
      this.idSessaoDispositivo = idSessaoDispositivo;
    }

    @Override
    public Optional<TentativaQuizLeitura> buscarTentativa(String uid, String quizId) {
      return Optional.ofNullable(tentativaGravada)
          .filter(tentativa -> tentativa.quizId().equals(quizId));
    }
  }
}
