package app.ascend.backend.quests;

import com.google.cloud.Timestamp;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.springframework.stereotype.Service;

/**
 * Coordena a sincronizacao do inventario apos validar payload e sessao ativa.
 */
@Service
public class SincronizacaoInventarioQuestService {

  private final RepositorioInventarioQuest repositorio;
  private final GuardaSessaoAtiva guardaSessaoAtiva;
  private final ValidadorRequisicaoInventarioQuest validadorRequisicao;
  private final MapeadorDocumentoInventarioQuest mapeadorDocumento;

  public SincronizacaoInventarioQuestService(
      RepositorioInventarioQuest repositorio,
      GuardaSessaoAtiva guardaSessaoAtiva,
      ValidadorRequisicaoInventarioQuest validadorRequisicao,
      MapeadorDocumentoInventarioQuest mapeadorDocumento
  ) {
    this.repositorio = repositorio;
    this.guardaSessaoAtiva = guardaSessaoAtiva;
    this.validadorRequisicao = validadorRequisicao;
    this.mapeadorDocumento = mapeadorDocumento;
  }

  public RespostaSincronizacaoInventarioQuest sincronizarInventario(
      String uid,
      RequisicaoSincronizacaoInventarioQuest request
  ) {
    DadosRequisicaoInventarioQuest dadosRequisicao = validadorRequisicao.validar(request);
    guardaSessaoAtiva.exigirSessaoAtiva(uid, dadosRequisicao.idSessaoDispositivo());

    Timestamp now = Timestamp.now();
    List<EscritaInventarioQuest> escritas = mapeadorDocumento.paraEscritas(
        dadosRequisicao.quests(),
        dadosRequisicao.idSessaoDispositivo(),
        dadosRequisicao.rotuloDispositivo(),
        now
    );
    Set<String> idsQuestsParaExcluir = idsQuestsAusentesNoProximoInventario(uid, escritas);

    repositorio.sincronizarInventario(
        uid,
        escritas,
        mapeadorDocumento.paraDocumentoMeta(
            escritas.size(),
            dadosRequisicao.idSessaoDispositivo(),
            dadosRequisicao.rotuloDispositivo(),
            now
        ),
        idsQuestsParaExcluir
    );
    return new RespostaSincronizacaoInventarioQuest("synced", escritas.size());
  }

  private Set<String> idsQuestsAusentesNoProximoInventario(
      String uid,
      List<EscritaInventarioQuest> escritas
  ) {
    Set<String> idsQuestsAtuais = repositorio.buscarIdsQuests(uid);
    Set<String> proximosIdsQuests = new HashSet<>();
    for (EscritaInventarioQuest escrita : escritas) {
      proximosIdsQuests.add(escrita.id());
    }
    idsQuestsAtuais.removeAll(proximosIdsQuests);
    return idsQuestsAtuais;
  }
}
