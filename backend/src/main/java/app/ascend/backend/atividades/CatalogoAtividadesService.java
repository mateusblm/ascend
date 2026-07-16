package app.ascend.backend.atividades;

import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;

/** Fonte canônica e versionada das atividades guiadas disponíveis no MVP. */
@Service
public class CatalogoAtividadesService {
  private static final int VERSAO = 1;

  public RespostaCatalogoAtividades consultar() {
    return new RespostaCatalogoAtividades(VERSAO, List.of(
        categoria("corpoMovimento", "Corpo e movimento", List.of(
            modalidade("musculacao", "Musculação", List.of(
                atividade("supino-reto", "Supino reto", "strengthSets", pesos(85, 0, 15, 0),
                    metricasForca()), personalizada("outra-atividade-corpo", pesos(70, 0, 20, 10)))),
            modalidade("corrida", "Corrida", List.of(
                atividade("corrida-livre", "Corrida livre", "distanceDuration", pesos(0, 0, 70, 30),
                    metricasDistancia()), personalizada("outra-atividade-corrida", pesos(0, 0, 70, 30))))
        )),
        categoria("estudosFormacao", "Estudos e formação", List.of(
            modalidade("sessao-estudo", "Sessão de estudo", List.of(
                atividade("estudo-livre", "Estudo livre", "studySession", pesos(0, 85, 0, 15), metricasEstudo()),
                personalizada("outra-atividade-estudos", pesos(0, 70, 0, 30))))
        )),
        categoria("leituraConhecimento", "Leitura e conhecimento", List.of(
            modalidade("leitura", "Leitura", List.of(
                atividade("leitura-livre", "Leitura livre", "readingProgress", pesos(0, 90, 0, 10), metricasLeitura()),
                personalizada("outra-atividade-leitura", pesos(0, 90, 0, 10))))
        )),
        categoria("trabalhoProjetos", "Trabalho e projetos", List.of(
            modalidade("trabalho-profundo", "Trabalho profundo", List.of(
                atividade("bloco-foco", "Bloco de foco", "timedSession", pesos(0, 55, 0, 45), metricasTempo()),
                personalizada("outra-atividade-trabalho", pesos(0, 55, 0, 45))))
        )),
        categoria("saudeBemEstar", "Saúde e bem-estar", List.of(
            modalidade("sono", "Sono", List.of(
                atividade("registrar-sono", "Registrar noite de sono", "sleepTracking", pesos(0, 0, 80, 20), metricasSono()),
                personalizada("outra-atividade-saude", pesos(0, 0, 80, 20))))
        )),
        categoria("organizacaoPessoalCasa", "Organização pessoal e casa", List.of(
            modalidade("planejamento", "Planejamento", List.of(
                atividade("planejar-dia", "Planejar o dia", "reflectionSession", pesos(0, 0, 20, 80), metricasReflexao()),
                personalizada("outra-atividade-organizacao", pesos(0, 0, 20, 80))))
        )),
        categoria("financas", "Finanças", List.of(
            modalidade("registro-financeiro", "Registro financeiro", List.of(
                atividade("registrar-despesa", "Registrar despesa", "moneyTracking", pesos(0, 60, 0, 40), metricasFinanceiras()),
                personalizada("outra-atividade-financas", pesos(0, 60, 0, 40))))
        )),
        categoria("relacionamentosContribuicao", "Relacionamentos e contribuição", List.of(
            modalidade("contribuicao", "Contribuição", List.of(
                atividade("acao-de-cuidado", "Ação de cuidado", "reflectionSession", pesos(0, 0, 65, 35), metricasReflexao()),
                personalizada("outra-atividade-relacionamentos", pesos(0, 0, 65, 35))))
        )),
        categoria("criatividadeHabilidades", "Criatividade e habilidades", List.of(
            modalidade("pratica-criativa", "Prática criativa", List.of(
                atividade("pratica-musical", "Prática musical", "timedSession", pesos(0, 40, 0, 60), metricasTempo()),
                personalizada("outra-atividade-criativa", pesos(0, 55, 0, 45))))
        ))
    ));
  }

  public DefinicaoAtividade atividade(String activityId) {
    return consultar().categorias().stream().flatMap(c -> c.modalidades().stream())
        .flatMap(m -> m.atividades().stream()).filter(a -> a.id().equals(activityId)).findFirst().orElse(null);
  }

  private CategoriaAtividade categoria(String id, String nome, List<ModalidadeAtividade> modalidades) {
    return new CategoriaAtividade(id, nome, modalidades);
  }
  private ModalidadeAtividade modalidade(String id, String nome, List<DefinicaoAtividade> atividades) {
    return new ModalidadeAtividade(id, nome, atividades);
  }
  private DefinicaoAtividade personalizada(String id, Map<String, Integer> atributos) {
    return atividade(id, "Outra atividade", "simpleCompletion", atributos, List.of());
  }
  private DefinicaoAtividade atividade(String id, String nome, String modelo, Map<String, Integer> atributos,
      List<DefinicaoMetricaAtividade> metricas) {
    return new DefinicaoAtividade(id, nome, modelo, VERSAO, id.startsWith("outra-atividade"), atributos, metricas);
  }
  private Map<String, Integer> pesos(int strength, int intelligence, int vitality, int agility) {
    return Map.of("strength", strength, "intelligence", intelligence, "vitality", vitality, "agility", agility);
  }
  private List<DefinicaoMetricaAtividade> metricasForca() {
    return List.of(metrica("repetitions", "integer", "reps", true, false, 1, 500, "ACCUMULATIVE"),
        metrica("loadKg", "decimal", "kg", true, false, 0, 1000, "ACCUMULATIVE"),
        metrica("volumeKg", "decimal", "kg", false, true, 0, 500000, "ACCUMULATIVE"));
  }
  private List<DefinicaoMetricaAtividade> metricasDistancia() {
    return List.of(metrica("distanceKm", "decimal", "km", true, false, .01, 1000, "ACCUMULATIVE"),
        metrica("durationMinutes", "integer", "min", true, false, 1, 1440, "ACCUMULATIVE"),
        metrica("paceSecondsPerKm", "decimal", "s/km", false, true, 1, 100000, "INFORMATIONAL"));
  }
  private List<DefinicaoMetricaAtividade> metricasEstudo() {
    return List.of(metrica("durationMinutes", "integer", "min", true, false, 1, 1440, "ACCUMULATIVE"),
        metrica("questionsAnswered", "integer", "questions", false, false, 0, 10000, "ACCUMULATIVE"),
        metrica("correctAnswers", "integer", "questions", false, false, 0, 10000, "ACCUMULATIVE"),
        metrica("accuracyPercent", "decimal", "%", false, true, 0, 100, "INFORMATIONAL"));
  }
  private List<DefinicaoMetricaAtividade> metricasLeitura() { return List.of(metrica("pagesRead", "integer", "pages", true, false, 1, 10000, "ACCUMULATIVE")); }
  private List<DefinicaoMetricaAtividade> metricasTempo() { return List.of(metrica("durationMinutes", "integer", "min", true, false, 1, 1440, "ACCUMULATIVE")); }
  private List<DefinicaoMetricaAtividade> metricasSono() { return List.of(metrica("durationMinutes", "integer", "min", true, false, 1, 1440, "CONSISTENCY")); }
  private List<DefinicaoMetricaAtividade> metricasFinanceiras() { return List.of(metrica("amount", "decimal", "BRL", true, false, 0.01, 10000000, "INFORMATIONAL")); }
  private List<DefinicaoMetricaAtividade> metricasReflexao() { return List.of(metrica("rating", "integer", "score", false, false, 1, 5, "INFORMATIONAL")); }
  private DefinicaoMetricaAtividade metrica(String id, String tipo, String unidade, boolean obrigatoria, boolean calculada,
      double minimo, double maximo, String evolucao) { return new DefinicaoMetricaAtividade(id, tipo, unidade, obrigatoria, calculada, minimo, maximo, evolucao); }
}
