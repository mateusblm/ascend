package app.ascend.backend.quests;

import com.google.cloud.Timestamp;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Cria uma quest individual sem reenviar ou remover o restante do inventário. */
@Service
public class CriacaoQuestPessoalService {
  private final RepositorioInventarioQuest repositorio;
  private final GuardaSessaoAtiva sessoes;
  private final ValidadorRequisicaoInventarioQuest validador;
  private final MapeadorDocumentoInventarioQuest mapeador;

  public CriacaoQuestPessoalService(
      RepositorioInventarioQuest repositorio,
      GuardaSessaoAtiva sessoes,
      ValidadorRequisicaoInventarioQuest validador,
      MapeadorDocumentoInventarioQuest mapeador
  ) {
    this.repositorio = repositorio;
    this.sessoes = sessoes;
    this.validador = validador;
    this.mapeador = mapeador;
  }

  @Transactional
  public Map<String, Object> criar(String uid, RequisicaoCriacaoQuestPessoal requisicao) {
    String sessao = ValidadorPayloadInventarioQuest.requireString(
        requisicao == null ? null : requisicao.idSessaoDispositivo(), "idSessaoDispositivo", 120);
    String rotulo = ValidadorPayloadInventarioQuest.optionalString(
        requisicao.rotuloDispositivo(), "rotuloDispositivo", 120, "device");
    sessoes.exigirSessaoAtiva(uid, sessao);
    QuestInventarioValidada quest = validador.validarQuestPessoalDoComando(
        String.valueOf(requisicao.quest().id()), requisicao.quest());
    EscritaInventarioQuest escrita = mapeador.paraEscrita(quest, sessao, rotulo, Timestamp.now());
    repositorio.salvarQuestIndividual(uid, escrita);
    return Map.of("quest", escrita.data());
  }
}
