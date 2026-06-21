# Game System Design Plan

## Objetivo

Transformar a experiencia visual e interativa do Ascend de um app com cara de
lista de tarefas para um sistema original de evolucao pessoal com linguagem de
jogo, sem copiar nomes, arte, lore, icones ou elementos protegidos de qualquer
obra existente.

Este plano usa a inspiracao permitida do genero RPG/anime apenas no nivel de
fantasia emocional:
- receber missoes
- evoluir atributos
- sentir pressao de rank
- enfrentar provas e bosses
- visualizar crescimento acumulado

O resultado deve continuar sendo um app util, legivel e confiavel. A imersao
nao pode esconder a acao principal nem transformar o produto em interface
confusa.

## Agentes Usados

- Orchestrator Agent: consolidar produto, frontend, backend, QA e game design.
- PO Agent: transformar a vontade de "mais sistema de jogo" em requisitos.
- Game Design Agent: proteger fantasia, retencao, originalidade e diferenca
  contra to-do lists.
- Dev Agent: manter a execucao compativel com Flutter, Riverpod, Isar e backend
  Java.
- QA Agent: definir metricas, riscos, testes e smoke path.

## Base De Evidencia

Este plano parte de quatro ideias sustentadas por literatura e guidelines:

1. Gamificacao precisa apoiar competencia, autonomia e pertencimento, nao apenas
   despejar pontos e badges. A Self-Determination Theory aplicada a gamificacao
   destaca esses tres requisitos psicologicos como base para motivacao mais
   duravel.
   Referencia: https://selfdeterminationtheory.org/wp-content/uploads/2020/10/2018_RutledgeWalshEtAl_Gamification.pdf

2. Pontos, niveis e leaderboards podem melhorar performance quando funcionam
   como indicadores de progresso, mas nao sustentam motivacao sozinhos.
   Referencia: https://edoc.unibas.ch/entities/publication/cd323935-e832-4bee-bf7a-4adf7365d4d7

3. Leaderboards podem aumentar engajamento em certas condicoes quando criam
   desafio, metas claras e avaliacao, mas devem ser usados com cuidado para nao
   punir usuarios iniciantes ou menos competitivos.
   Referencia: https://journals.sagepub.com/doi/abs/10.1177/1046878114563662

4. Movimento e hierarquia visual devem comunicar relacao espacial, foco e
   proxima acao. Animacao nao deve ser enfeite; deve explicar estado.
   Referencia: https://m1.material.io/motion/material-motion.html

5. Navegacao mobile deve preservar secoes principais estaveis e reconheciveis.
   A tab bar deve ser usada para areas de topo, nao para acoes.
   Referencia: https://developer.apple.com/design/human-interface-guidelines/tab-bars

## Decisao De Produto

Ascend deve virar um "Sistema de Ascensao" original.

Nao e:
- uma copia de anime
- uma dashboard de produtividade com neon
- uma lista de tasks com XP no canto

E:
- um sistema de evolucao pessoal
- uma interface de personagem
- um painel de missoes
- uma arena de prova
- um registro de legado

## Fantasia Central

O usuario nao esta "checando tarefas".

O usuario esta:
- recebendo missoes
- fortalecendo uma build
- mantendo uma campanha semanal
- provando competencia em desafios verificaveis
- defendendo ou subindo rank
- acumulando legado

Frase guia:

> Cada acao real fortalece uma versao persistente de voce.

## Principios De Design

### 1. Competencia Visivel

Toda tela principal deve responder:
- o que eu conquistei?
- o que mudou no meu personagem?
- o que falta para o proximo marco?

Aplicacao:
- XP e nivel devem parecer crescimento, nao contador.
- atributos devem parecer build, nao tabela.
- rank deve parecer status competitivo, nao filtro.

### 2. Autonomia Guiada

O usuario escolhe foco, classe/build e quests, mas o sistema recomenda a proxima
acao sem esmagar a tela com opcoes.

Aplicacao:
- uma acao primaria forte por tela.
- escolhas secundarias em sheets.
- detalhes avancados por tap.

### 3. Pertencimento E Rivalidade Justa

O sistema pode usar rivalidade, mas sem fazer o usuario iniciante se sentir
humilhado.

Aplicacao:
- rival fantasma e bracket local antes de ranking amplo.
- copy competitiva deve ser intensa, mas nao toxica.
- Arena mostra risco e oportunidade, nao vergonha.

### 4. Consequencia Clara

Rank, boss e temporada precisam mostrar risco, manutencao e recompensa.

Aplicacao:
- estados como seguro, em risco, prova disponivel, reconquista e bloqueado.
- feedback visual para perda de janela ou manutencao incompleta.

### 5. Imersao Util

Toda camada visual deve melhorar entendimento ou motivacao.

Permitido:
- molduras de sistema
- glows contidos
- iconografia de rank/atributo
- microinteracoes de progresso
- linguagem de "missao", "prova", "build", "campanha"

Evitar:
- excesso de cards iguais
- textos longos explicando o proprio app
- efeitos que competem com legibilidade
- copia visual/literal de obras existentes

## Direcao Visual

### Identidade

Nome interno do estilo:
- `Ascend System UI`

Tom:
- escuro
- preciso
- energetico
- adulto
- competitivo
- de alta hierarquia

Paleta sugerida:
- Fundo principal: preto azulado quase neutro
- Superficie: grafite frio
- Linha de sistema: ciano eletrico
- Alerta/risco: vermelho rubi
- Recompensa: dourado controlado
- Vitalidade: verde profundo
- Inteligencia: azul claro
- Forca: vermelho/ambar
- Agilidade: violeta frio

Regra:
- usar ciano como sinal de sistema, nao como cor unica dominante.
- cada atributo precisa ter identidade propria.
- evitar virar "tema azul neon" monotono.

### Tipografia

Direcao:
- Titulos curtos com peso alto.
- Numeros grandes para status e payoff.
- Corpo compacto e legivel.
- Labels de sistema em caixa alta apenas em pequenas doses.

Evitar:
- paragrafo grande dentro de card.
- H1 enorme em paineis compactos.
- texto decorativo que nao ajuda decisao.

### Iconografia

Sistema de icones proprio, mas abstrato:
- Rank: marcas geometricas originais.
- Atributos: simbolos simples e nao literais.
- Boss: sigilo original por evento.
- Quests: icones de tipo de esforco.

Nao usar:
- silhuetas, logos, armas, portais ou marcas parecidas com obras existentes.

### Motion

Motion deve explicar estado:
- quest aceita: pulso curto no painel de missao.
- XP ganho: barra preenche e numero estabiliza.
- level up: transicao breve com foco no novo nivel.
- rank em risco: oscilacao sutil ou borda viva, nunca piscando demais.
- boss ativo: presenca visual persistente, mas sem bloquear a tela.

Duracao guia:
- microfeedback: 150-200ms.
- mudanca de estado: 250-400ms.
- conquistas raras: ate 700ms, pulavel/reduzivel.

Sempre respeitar reducao de movimento do sistema operacional quando disponivel.

## Componentes Do Sistema

### 1. System Header

Substitui headers genericos por um bloco de identidade.

Conteudo:
- nome do jogador
- nivel
- titulo atual
- rank competitivo compacto
- foco/build

Uso:
- `Base`
- perfil resumido em `Arena`

### 2. Core Status Ring

Visual central de progresso.

Estados:
- XP atual
- proximo nivel
- momentum semanal
- risco/seguranca

Uso:
- Base como payoff primario.

### 3. Attribute Matrix

Troca tabela de atributos por leitura de build.

Conteudo:
- Forca
- Inteligencia
- Vitalidade
- Agilidade
- pontos disponiveis
- interpretacao curta da build

Interacao:
- tap abre detalhe e alocacao.

### 4. Mission Terminal

Reframing da lista de quests.

Tipos:
- Missao pessoal
- Missao competitiva
- Prova de promocao
- Evento semanal

Cada item deve mostrar:
- objetivo
- recompensa
- requisito
- status
- acao primaria

Evitar:
- cards identicos de to-do.
- checkbox como elemento central para tudo.

### 5. Rank Threat Meter

Componente de Arena para mostrar pressao semanal.

Estados:
- protegido
- atencao
- em risco
- prova disponivel
- reconquista

Uso:
- Arena
- resumo compacto na Base.

### 6. Boss Encounter Panel

Boss semanal deve parecer evento, nao card informativo.

Conteudo:
- boss atual
- janela de tempo
- requisito
- progresso
- recompensa
- CTA

Regra:
- recompensa e elegibilidade continuam backend-authoritative.

### 7. Legacy Archive

Transforma historico em legado.

Conteudo:
- titulos permanentes
- temporada anterior
- maiores feitos
- recordes pessoais

Uso:
- Arena/Perfil.

## Redesign Por Tela

### Base

Objetivo:
- ser o painel de personagem.

Primeira dobra:
- System Header
- Core Status Ring
- proximo payoff
- aviso semanal compacto

Remover/reduzir:
- blocos repetidos de metrica.
- composicao de dashboard generica.

### Quests

Objetivo:
- ser painel de missoes executaveis.

Primeira dobra:
- missao recomendada
- abas/segmentos: pessoais, competitivas, concluidas
- Mission Terminal

Mudanca principal:
- checkbox deixa de ser o simbolo dominante; CTA vira "Iniciar", "Registrar",
  "Entregar prova", "Resgatar", "Concluir".

### Arena

Objetivo:
- ser centro de pressao competitiva.

Primeira dobra:
- rank atual
- Rank Threat Meter
- prova/promocao/reconquista
- boss/evento semanal

Mudanca principal:
- mostrar risco e oportunidade antes de leaderboard.

### Plano

Objetivo:
- ser diagnostico e proximo passo, nao outro dashboard.

Primeira dobra:
- leitura da semana
- recomendacao unica
- ajuste de build ou rotina

Mudanca principal:
- parecer "relatorio de mentor/sistema", nao analytics frio.

### Conta

Objetivo:
- confianca e operacao.

Direcao:
- manter mais calma e convencional.
- nao precisa de tanta imersao quanto Base/Arena.

## Fases De Implementacao

### Fase 1 - Fundacao Visual

Escopo:
- definir tokens de cor, spacing, borda, elevation e motion.
- criar componentes base:
  - `AscendSurface`
  - `SystemHeader`
  - `StatusBadge`
  - `ProgressArc` ou equivalente Flutter
  - `AttributeChip`
  - `MissionCard`

Arquivos provaveis:
- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_theme.dart`
- novo `lib/core/theme/ascend_design_tokens.dart`
- novo `lib/core/widgets/system/`

Aceite:
- app ainda compila.
- nenhum texto quebra em telas pequenas.
- contraste minimo preservado.

### Fase 2 - Base Como Painel De Personagem

Escopo:
- redesenhar primeira dobra da Base.
- destacar identidade, nivel, XP, build e proximo payoff.

Arquivos provaveis:
- `lib/features/profile/presentation/home_screen.dart`
- novos widgets locais em `lib/features/profile/presentation/widgets/`

Aceite:
- usuario entende o estado do personagem em menos de 5 segundos.
- proxima acao fica clara sem scroll longo.

### Fase 3 - Quests Como Mission Terminal

Escopo:
- mudar quest cards para linguagem de missao.
- separar pessoal, competitiva e concluida com hierarquia visual.
- reforcar CTAs por estado.

Arquivos provaveis:
- `lib/features/quests/presentation/quests_screen.dart`
- `lib/features/quests/presentation/widgets/quest_card.dart`

Aceite:
- quest pessoal continua rapida.
- quest competitiva comunica requisito/prova.
- fluxo nao parece lista generica com checkbox.

### Fase 4 - Arena Como Centro De Pressao

Escopo:
- Rank Threat Meter.
- boss semanal com presenca de evento.
- promocao/reconquista com estado visual forte.

Arquivos provaveis:
- `lib/features/profile/presentation/rank_screen.dart`
- `lib/features/weekly_boss/presentation/weekly_boss_provider.dart`

Aceite:
- usuario sabe se esta seguro, em risco ou pronto para prova.
- rank nao depende de explicacao longa.

### Fase 5 - Motion E Payoff

Escopo:
- microinteracoes de XP, level up, claim, risco e boss.
- reducao de movimento.

Aceite:
- movimento comunica estado.
- nao atrasa interacao.
- acessibilidade preservada.

### Fase 6 - Onboarding Narrativo Leve

Escopo:
- reframe do onboarding como configuracao de build.
- foco do usuario vira arquipo/build inicial.

Arquivos provaveis:
- `lib/features/profile/presentation/awakening_onboarding_screen.dart`
- `lib/features/profile/presentation/focus_selection_sheet.dart`

Aceite:
- usuario sai com objetivo, foco e primeira missao.
- nao parece fan app.

## Metricas De Sucesso

Produto:
- aumento de D1/D7 retention.
- aumento de quest start rate.
- aumento de competitive quest start rate.
- aumento de completion rate da primeira semana.
- aumento de retorno para Base/Arena.

UX:
- tempo ate entender proxima acao em teste moderado.
- taxa de erro em iniciar/concluir quest.
- usuarios conseguem explicar rank, XP e boss com suas palavras.

Tecnico:
- `flutter analyze`
- `flutter test`
- smoke em emulador Android
- screenshots desktop/mobile se houver web preview

## Riscos

### Risco De Copia

Mitigacao:
- nomes, simbolos, arte, ranks e lore originais.
- sem referencias diretas a obras existentes.
- inspiracao limitada a padroes amplos de RPG/progressao.

### Risco De Confusao

Mitigacao:
- uma acao primaria por tela.
- progressive disclosure.
- labels claros.
- Conta permanece convencional.

### Risco De Gamificacao Rasa

Mitigacao:
- cada visual precisa representar regra real.
- XP/rank/boss sempre conectados a progresso ou consequencia.
- badges/titulos nao substituem crescimento e orientacao.

### Risco De Frustracao

Mitigacao:
- Arena mostra recuperacao, nao so perda.
- rank competitivo separado de progresso pessoal.
- primeiras semanas priorizam competencia e clareza.

## Fora De Escopo Inicial

- avatar 3D.
- loja cosmetica.
- multiplayer/social amplo.
- novas regras de recompensa.
- novos ranks copiados de qualquer obra.
- mudanca no backend Java, exceto se alguma nova metrica/evento precisar ser
  registrada depois.

## Primeira Issue Recomendada

Titulo:
- Criar fundacao visual Ascend System UI

Escopo:
- tokens de cor/motion/elevation.
- widgets base reutilizaveis.
- aplicar somente na Base acima da dobra.

Porque:
- entrega mudanca perceptivel sem reescrever todas as telas.
- cria linguagem reutilizavel para Quests e Arena.
- permite validar se o novo estilo aumenta imersao sem quebrar usabilidade.

Critérios de aceite:
- Base parece painel de personagem, nao dashboard.
- contraste e legibilidade continuam bons.
- nenhum texto quebra em viewport pequena.
- sem copia direta de anime/jogo.
- `flutter analyze` passa.
- smoke manual no emulador Android passa.
