# Ascend System UI - Plano Operacional De Design

## Objetivo

Transformar o Ascend de um app com cara de lista de tarefas para um sistema
original de evolucao pessoal com linguagem de jogo, mantendo clareza,
performance, acessibilidade e boas praticas de produto mobile.

A referencia emocional continua sendo a fantasia de "sistema de ascensao":
- receber missoes
- evoluir uma build
- sentir pressao de rank
- enfrentar provas e bosses
- acumular legado

Esta direcao nao deve copiar nomes, arte, lore, icones, composicoes ou marcas de
qualquer obra existente. A inspiracao permitida e de genero, nao de propriedade
intelectual.

## Decisao De Produto

Ascend deve parecer um software de progressao pessoal, nao um gerenciador de
tarefas com XP.

Nao e:
- dashboard de produtividade com neon
- lista infinita de cards
- tela cheia de explicacoes
- fan app de anime/jogo

E:
- painel de personagem
- terminal de missoes
- arena de pressao competitiva
- recomendacao de plano sob demanda
- arquivo de legado

Frase guia:

> Cada acao real fortalece uma versao persistente de voce.

## Base De Evidencia

As decisoes abaixo seguem estas referencias praticas:

1. Gamificacao sustentavel precisa apoiar competencia, autonomia e pertencimento,
   nao apenas distribuir pontos e badges.
   Referencia:
   https://selfdeterminationtheory.org/wp-content/uploads/2020/10/2018_RutledgeWalshEtAl_Gamification.pdf

2. Pontos, niveis e leaderboards ajudam quando tornam progresso e metas mais
   claros, mas nao sustentam motivacao sozinhos.
   Referencia:
   https://edoc.unibas.ch/entities/publication/cd323935-e832-4bee-bf7a-4adf7365d4d7

3. Leaderboards podem aumentar desafio e engajamento, mas devem ser usados com
   cuidado para nao punir iniciantes ou usuarios em recuperacao.
   Referencia:
   https://journals.sagepub.com/doi/abs/10.1177/1046878114563662

4. Movimento deve explicar foco, mudanca de estado e relacao espacial. Animacao
   decorativa demais aumenta ruido cognitivo.
   Referencia:
   https://m1.material.io/motion/material-motion.html

5. Navegacao mobile deve preservar areas principais estaveis e reconheciveis.
   A tab bar e para destinos, nao para acoes.
   Referencia:
   https://developer.apple.com/design/human-interface-guidelines/tab-bars

## Principios De Design

### 1. Competencia Visivel

Toda tela principal deve responder em poucos segundos:
- quem eu sou agora?
- o que mudou no meu personagem?
- qual e a proxima conquista concreta?

### 2. Autonomia Guiada

O usuario escolhe foco, build e missoes, mas o sistema aponta uma proxima acao
sem esmagar a tela com opcoes equivalentes.

Regra:
- uma acao primaria por tela
- escolhas secundarias em sheet, detalhe ou fluxo dedicado
- detalhes avancados sob demanda

### 3. Imersao Util

Cada elemento visual precisa melhorar entendimento, orientacao ou payoff.

Permitido:
- molduras de sistema
- linhas, sigilos e paines abstratos originais
- glows contidos
- nucleo de progresso
- badges de estado
- microinteracoes de progresso

Evitar:
- cards iguais empilhados
- textos longos explicando a propria interface
- repeticao da mesma metrica em varias telas
- efeitos que competem com legibilidade

### 4. Pressao Sem Humilhacao

Arena deve criar tensao e risco, mas com caminho de recuperacao claro.

Regra:
- mostrar estado competitivo como "seguro", "em risco", "prova", "reconquista"
  ou "bloqueado"
- evitar copy que pareca punicao moral
- manter progresso pessoal separado de queda competitiva

### 5. Originalidade Obrigatoria

O Ascend pode ter fantasia de RPG, mas seus nomes, simbolos, hierarquia visual e
microcopy precisam ser proprios.

## Regras De Densidade Mobile

Estas regras valem para qualquer tela nova ou refatorada.

### Hierarquia

- A primeira dobra deve ter no maximo uma decisao principal.
- O bloco hero deve comunicar estado, nao explicar o app.
- Numero importante pode ser grande; paragrafo explicativo nao.
- Repetir informacao so e permitido quando o papel muda entre telas.

### Texto

- Preferir labels de 1 a 3 palavras.
- Body copy so deve existir se mudar a decisao do usuario.
- Evitar mais de 2 linhas de texto em cards recorrentes.
- Descricao longa deve ir para sheet, tooltip ou tela de detalhe.
- Labels de sistema em caixa alta devem ser curtas e raras.

### Listas

- Listas longas precisam de filtro, agrupamento ou resumo.
- A tela nunca deve depender de scroll infinito para revelar a acao principal.
- Itens concluidos devem colapsar ou ir para arquivo do dia.
- Se dois cards usam a mesma estrutura visual, um deles provavelmente precisa
  virar badge, linha compacta ou detalhe.

### Metricas

- Metricas repetidas viram badges.
- Metricas com consequencia viram painel.
- Metricas historicas viram detalhe.
- Uma tela nao deve mostrar XP, rank, streak, boss e leaderboard com o mesmo peso.

### Acoes

- CTA principal deve ficar acima da dobra ou fixo de forma segura.
- FAB nao pode competir com bottom navigation.
- Acoes destrutivas ou raras ficam em menu/sheet.
- Botao primario deve dizer o verbo do estado atual: `Iniciar`, `Registrar`,
  `Concluir`, `Resgatar`, `Promover`, `Recuperar`.

## Linguagem Visual Oficial

Nome interno:
- `Ascend System UI`

Tom:
- escuro
- preciso
- intenso
- adulto
- competitivo
- legivel

Paleta:
- fundo principal: preto azulado quase neutro
- superficie: grafite frio
- linha de sistema: ciano contido
- alerta/risco: rubi
- recompensa: dourado controlado
- vitalidade: verde profundo
- inteligencia: azul claro
- forca: ambar/vermelho
- agilidade: violeta frio

Regra:
- ciano e sinal de sistema, nao tema unico.
- cada atributo deve ter identidade propria.
- evitar monotonia azul/neon.

Tipografia:
- titulos curtos e fortes
- numeros como payoff
- corpo compacto
- labels tecnicas em pequenas doses

Motion:
- microfeedback: 150-200ms
- mudanca de estado: 250-400ms
- conquista rara: ate 700ms, pulavel quando possivel
- respeitar reducao de movimento do sistema

## Componentes Padrao

### System Panel

Uso:
- envolver blocos de estado importante
- criar moldura de sistema sem virar card generico

Nao usar para:
- todos os itens de lista
- informacao secundaria demais

### System Badge

Uso:
- estado curto
- metrica compacta
- classificacao de risco

Exemplos:
- `SEGURO`
- `EM RISCO`
- `BOSS 2/4`
- `XP +120`

### Progress Core

Uso:
- payoff central de XP, nivel, boss ou rank
- primeira dobra da Base e estados raros da Arena

Regra:
- nao duplicar barra comum logo abaixo do nucleo.

### Mission Card

Uso:
- item acionavel de quest

Deve mostrar:
- objetivo
- recompensa
- status
- CTA

Nao deve mostrar:
- explicacao longa de regra
- historico completo
- todas as metricas do jogador

### Threat Meter

Uso:
- pressao competitiva
- manutencao semanal
- promocao/reconquista

Estados:
- protegido
- atencao
- em risco
- prova disponivel
- reconquista

### Legacy Archive

Uso:
- conquistas permanentes
- temporadas anteriores
- recordes

Regra:
- nao competir com a acao principal de Arena ou Base.

## Contratos Por Tela

### Base

Papel:
- painel de personagem.

Primeira dobra:
- identidade do jogador
- nivel e XP
- build/foco
- proximo payoff
- sinal semanal compacto

Pode mostrar:
- leitura curta da build
- boss semanal resumido
- pontos disponiveis

Nao deve mostrar:
- leaderboard completo
- historico longo
- explicacao detalhada de rank
- segunda versao do Plano

Principal pergunta:
- "Como esta meu personagem agora?"

### Quests

Papel:
- terminal de missoes executaveis.

Primeira dobra:
- missao recomendada
- frentes ativas
- alternancia pessoal/competitiva/concluidas
- criacao ou inicio rapido sem ficar sob a bottom nav

Pode mostrar:
- recompensa
- requisito
- tempo
- estado

Nao deve mostrar:
- dashboard de progresso geral
- explicacao longa de atributos
- lista infinita sem agrupamento

Principal pergunta:
- "O que eu faco agora?"

### Arena

Papel:
- centro de pressao competitiva.

Primeira dobra:
- rank atual
- risco semanal
- prova/promocao/reconquista
- evento competitivo atual

Pode mostrar:
- leaderboard compacto
- bracket/temporada
- boss competitivo
- integridade competitiva

Nao deve mostrar:
- build pessoal como protagonista
- copy longa sobre cada regra
- ranking que humilha usuario iniciante

Principal pergunta:
- "Estou seguro, em risco ou pronto para subir?"

### Plano

Papel:
- diagnostico e proximo movimento sob demanda, nao aba principal.

Quando aberto:
- leitura da semana
- uma recomendacao principal
- ajuste sugerido de rotina/build
- risco de abandono ou oportunidade de push

Pode mostrar:
- tendencias
- lacunas
- sugestoes
- interpretacao de cadencia

Nao deve mostrar:
- a mesma build da Base
- o mesmo boss da Arena
- uma segunda lista de quests
- uma aba propria sem decisao diaria forte

Principal pergunta:
- "Qual ajuste melhora minha semana?"

### Conta

Papel:
- confianca, identidade e operacao.

Direcao:
- mais convencional
- menos imersiva
- alta clareza

Nao deve mostrar:
- gameplay analytics
- pressao competitiva
- narrativa visual pesada

## Backlog Visual

### Fase A - Guia E Auditoria

Escopo:
- consolidar este plano como guia operacional.
- auditar Base, Quests, Arena e Plano contra as regras de densidade.
- marcar textos repetidos, metricas duplicadas e cards redundantes.

Aceite:
- cada tela tem lista clara de cortes e simplificacoes.
- nenhuma mudanca de regra de negocio.

### Fase B - Quests Como Terminal

Escopo:
- reduzir scroll e repeticao.
- reposicionar acao de adicionar/criar para nao brigar com menu inferior.
- tornar pessoais, competitivas e concluidas mais compactas.
- mover detalhe longo para sheet.

Aceite:
- acao principal visivel sem scroll longo.
- itens concluidos nao dominam a tela.
- quest pessoal e competitiva continuam rapidas de executar.

### Fase C - Base Como Personagem

Escopo:
- cortar textos explicativos restantes.
- reforcar progresso, build e payoff como leitura unica.
- transformar informacoes secundarias em badges/detalhes.

Aceite:
- estado do personagem entendido em ate 5 segundos.
- proximo ganho e acao semanal ficam claros.

### Fase D - Arena Como Pressao

Escopo:
- criar ou refinar Threat Meter.
- deixar promocao, risco e reconquista autoexplicativos.
- compactar leaderboard e legado.

Aceite:
- usuario sabe se esta seguro, em risco ou pronto para prova sem ler texto longo.
- rivalidade parece justa, nao punitiva.

### Fase E - Plano Como Mentor

Escopo:
- transformar analise em uma recomendacao principal.
- cortar metricas repetidas de Base/Arena.
- criar leitura semanal compacta.

Aceite:
- Plano nao parece dashboard frio.
- usuario sai com uma decisao de ajuste.

### Fase F - Motion E Payoff

Escopo:
- microinteracoes de XP, claim, level up, risco e boss.
- feedback visual apos concluir missao.
- suporte a reducao de movimento.

Aceite:
- movimento comunica estado.
- nao atrasa interacao.
- testes de acessibilidade/manual smoke aprovados.

## Checklist De Revisao De Tela

Antes de considerar uma tela pronta:

- Existe uma acao principal clara?
- A primeira dobra responde a pergunta principal da tela?
- Alguma metrica aparece com o mesmo peso em outra aba?
- Algum card tem texto que poderia virar badge?
- Alguma explicacao poderia ir para sheet?
- A bottom navigation nao cobre CTA/FAB?
- A tela ainda funciona em viewport pequeno?
- O visual reforca progresso, build, risco ou payoff?
- Ha alguma referencia visual ou textual direta a obra existente?
- `flutter analyze` passa?
- testes relevantes passam?

## Riscos E Mitigacoes

### Copia Visual

Mitigacao:
- nomes, simbolos, ranks e lore originais.
- abstracao geometrica propria.
- sem copiar composicao reconhecivel de obra existente.

### Excesso De Informacao

Mitigacao:
- regras de densidade mobile.
- progressive disclosure.
- auditoria por tela antes de implementar.

### Gamificacao Rasa

Mitigacao:
- cada elemento visual representa uma regra real.
- badges nao substituem progresso, orientacao ou consequencia.

### Confusao Operacional

Mitigacao:
- Conta fica convencional.
- acoes primarias claras.
- detalhe sob demanda.

## Fora De Escopo Agora

- avatar 3D.
- loja cosmetica.
- multiplayer social amplo.
- novas regras de recompensa.
- novos ranks copiados de qualquer obra.
- mudanca no backend Java sem necessidade de nova metrica/evento.

## Proxima Issue Recomendada

Titulo:
- Auditar densidade mobile das telas principais

Escopo:
- revisar Base, Quests, Arena e Plano contra este documento.
- criar uma lista de cortes por tela.
- priorizar Quests primeiro, por ser a tela com maior risco de voltar a parecer
  uma lista de tarefas.

Porque:
- reduz tentativa e erro visual.
- protege mobile contra excesso de texto.
- cria criterio objetivo antes da proxima rodada de implementacao.

Criterios de aceite:
- Quests tem proposta de terminal compacto.
- Base tem proposta de painel de personagem mais direto.
- Arena tem proposta de pressao competitiva sem texto longo.
- Plano tem proposta de mentor/recomendacao unica.
- nenhuma regra de backend/progresso e alterada.
