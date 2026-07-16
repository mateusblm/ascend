# Sistema de missões orientadas por atividade

## Decisão de produto

O Ascend evolui de uma lista de tarefas gamificada para um sistema de registro
de evolução pessoal. Uma missão continua podendo ser simples e rápida, mas uma
missão guiada conecta uma atividade real a uma execução estruturada, histórico
e progresso pessoal.

O sistema não cria diagnóstico, prescrição médica, recomendação de investimento
nem avaliação de terceiros. Ele registra a ação declarada pelo usuário e mostra
seu próprio histórico.

## Modos de missão

| Modo | Objetivo | Compatibilidade |
| --- | --- | --- |
| `quick` | Concluir uma ação, quantidade, duração ou missão livre. | É o comportamento atual; quests antigas são `quick`. |
| `guided` | Criar uma missão a partir de categoria, modalidade e atividade do catálogo. | Adiciona configuração e registro de execução, sem alterar a recompensa pelo cliente. |

Hierarquia de uma missão guiada:

```text
categoria → modalidade → atividade → modelo de execução → métricas/meta
```

Uma atividade usa um único modelo reutilizável. A interface não deve criar uma
tela independente para cada atividade.

## Modelos universais de execução

| ID | Uso inicial | Dados principais |
| --- | --- | --- |
| `simpleCompletion` | ações simples | conclusão, observação |
| `timedSession` | foco, meditação, prática | duração, interrupções, avaliação |
| `quantityTracking` | água, unidades, repetições | quantidade, unidade |
| `strengthSets` | musculação e calistenia | séries, carga, repetições, esforço |
| `distanceDuration` | corrida, caminhada, ciclismo | distância, duração, ritmo calculado |
| `studySession` | estudo e exercícios | duração, tópico, questões, acertos |
| `readingProgress` | livros e artigos | páginas, capítulo, duração, notas |
| `sleepTracking` | sono | início, término, despertares, qualidade |
| `moneyTracking` | finanças pessoais | valor, tipo, descrição |
| `reflectionSession` | revisões e relações | duração, avaliação, anotação |

Cada definição de métrica declara ID estável, tipo, unidade, faixa permitida,
obrigatoriedade, se é informada ou calculada e o tipo de evolução:
`ACCUMULATIVE`, `CONSISTENCY` ou `INFORMATIONAL`.

## Catálogo inicial

Os IDs são slugs estáveis e não dependem do texto exibido. O catálogo inicial
tem nove categorias: `corpoMovimento`, `estudosFormacao`,
`leituraConhecimento`, `trabalhoProjetos`, `saudeBemEstar`,
`organizacaoPessoalCasa`, `financas`, `relacionamentosContribuicao` e
`criatividadeHabilidades`.

O primeiro vertical slice prioriza atividades que comprovam os modelos sem
duplicar fluxos: supino reto (`strengthSets`), corrida livre
(`distanceDuration`), estudo livre (`studySession`), leitura
(`readingProgress`), sono (`sleepTracking`) e uma atividade personalizada.
Cada modalidade também oferece `custom`/“Outra atividade”.

As distribuições de atributos são defaults do catálogo, aplicados e limitados
somente pelo backend. Exemplos: musculação (força 85%, vitalidade 15%), corrida
(vitalidade 70%, agilidade 30%) e estudo (inteligência 85%, agilidade 15%).
Elas não podem ser manipuladas pelo cliente para obter recompensa.

## Autoridade e persistência

O PostgreSQL é a fonte de verdade para catálogo publicado, execuções,
agregados, recordes e recompensa. O Flutter pode armazenar o catálogo e
rascunhos no Isar, mas não concede XP definitivo offline.

O contrato de conclusão guiada deve conter `executionId` estável, `questId`,
`activityId`, `executionType`, `schemaVersion`, métricas informadas,
observação e horários. O backend deve:

1. autenticar e validar sessão ativa;
2. localizar a quest e validar catálogo/esquema;
3. validar métricas, unidades e limites;
4. ignorar métricas derivadas enviadas pelo cliente e recalculá-las;
5. persistir a execução de forma idempotente;
6. concluir a Quest e aplicar apenas a recompensa permitida pela regra canônica;
7. atualizar agregados e recordes pessoais;
8. devolver perfil, Quest e resultado autoritativos.

Uma série de musculação é um fato separado dentro da execução. Volume,
ritmo, percentual de acerto e outros derivados são calculados no servidor.
Números informados não ampliam XP livremente; no MVP, a recompensa depende da
conclusão válida da missão e dos limites já definidos pelo backend. Recordes
geram feedback e histórico, não bônus explorável.

## Compatibilidade, cache e offline

- Quests sem categoria passam a ser tratadas como `quick`.
- Campos legados, `QuestTemplateType` e sua ordem persistida são preservados.
- Não há migração manual nem nova recompensa para conclusões históricas.
- Execuções offline ficam pendentes com ID estável, preservam o formulário e
  informam “aguardando sincronização”.
- Ao reconectar, o backend decide a idempotência, a conclusão e a recompensa.

### Revogacao de execucao guiada

Uma revogacao bem-sucedida da Quest marca no PostgreSQL todas as execucoes
guiadas ainda ativas daquela Quest e daquele usuario como revogadas. Os fatos
nao sao apagados: permanecem auditaveis, mas ficam fora de historico,
agregados, recordes e tendencias. Uma nova conclusao gera uma nova execucao
com ID proprio; a operacao de revogacao e idempotente.

## UX

O modal de criação abre com a escolha “Missão rápida” ou “Missão guiada”. A
missão rápida mantém o fluxo atual. A guiada revela gradualmente categoria,
modalidade, atividade, meta/métricas, recorrência/data, Jornada opcional e
revisão final. Uma missão especializada abre o registro do modelo associado;
o detalhe também oferece uma superfície de progresso genérica com último
resultado, melhor resultado, frequência, volume acumulado e tendência semanal
ou mensal quando aplicável.

## Execucao especializada do primeiro slice

- **Supino reto:** registra uma lista estruturada de series com carga e
  repeticoes, permite adicionar, remover e copiar a serie anterior e aceita
  esforco percebido opcional. O servidor valida cada serie e deriva volume,
  maior carga e 1RM estimado (formula de Epley).
- **Corrida:** distancia, duracao e esforco percebido sao informados; o ritmo
  e sempre calculado pelo servidor.
- **Estudo:** duracao, topico, questoes, acertos e aprendizado podem ser
  registrados. Acertos nao podem exceder questoes e o percentual e derivado
  pelo servidor.

O recibo exibe apenas as metricas calculadas retornadas pela conclusao. O
read-model de progresso retorna recordes pessoais e totais dos ultimos 7 e 30
dias, incluindo o periodo anterior equivalente; a tela apenas os apresenta.
Ritmos sao formatados no cliente apenas para exibicao (min:seg/km), a partir
do valor em segundos por quilometro calculado pelo servidor.

## Entregas incrementais

1. **Fundação:** contratos de catálogo e execução, compatibilidade `quick`,
   migration de fatos/agregados e validação canônica.
2. **Vertical slice:** supino, corrida e estudo com execução, cálculos,
   conclusão transacional, recordes e superfícies de progresso específicas por
   atividade, sustentadas por um núcleo reutilizável.
3. **Expansão de modelos:** leitura, sono, finanças e reflexão.
4. **Catálogo completo e offline:** demais atividades, customização limitada,
   cache, rascunhos e sincronização idempotente.

Cada slice exige testes Flutter e backend para catálogo, validação,
idempotência, recompensa, revogação, compatibilidade legada e isolamento por
usuário. Alterações em modelos Isar exigem regeneração de schema.

## Decisões posteriores

- Integrações de sensores, GPS, saúde e instituições financeiras.
- Regras de bônus para recordes.
- Análise clínica, nutricional, médica ou de investimento.
- Expansão do catálogo além das atividades iniciais.
