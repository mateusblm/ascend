# Auditoria do redesign do Ascend

Data: 2026-07-14. Escopo: Base, Missões, Jornadas e navegação móvel.

## Inventário atual

- Tema: `AppColors` e `AppTheme`, com Sora e Plus Jakarta Sans.
- Motivos reaproveitáveis: `GlifoAscensao`, `EixoAscensao`, cores funcionais e
  o cache responsivo/autoritativo existente.
- Superfícies atuais: `AscendSystemPanel`, painéis locais e campos Material.
- Navegação: dock flutuante em `MainNavigationScreen`.
- Telas: `HomeScreen`, `QuestsScreen`, `JornadasScreen`; criação e edição de
  Jornada ainda usam diálogos; capítulos usam sheet.

## Problemas confirmados

- `AscendSystemPanel` aplica gradiente, sombra e linhas de canto a quase todo
  agrupamento; isso cria uma pilha de cartões e faixas decorativas.
- `_SystemAtmosphere` desenha topografia e uma rota central em todas as telas,
  competindo com a leitura.
- A navegação é um cartão separado com caixas para cada ícone e contém o texto
  visível `Quests`.
- Jornadas são cartões de resumo, não um percurso; concluídas já foram
  separadas do Legado no domínio, mas a composição ainda não exprime a rota.
- A Base concentra indicadores e painéis, aproximando-se de dashboard.
- Missões reservam altura fixa e apresentaram overflows em dispositivos reais.
- Criação e edição de Jornada comprimem fluxos centrais em diálogos.
- Contraste inconsistente: texto reduzido, bordas e acentos dependem demais de
  opacidade. As cores de atributo também foram usadas como tema de tela.

## Textos e referências a remover

- `Quests` na navegação e mensagens de onboarding; a superfície deve dizer
  `Missões`.
- Aliases antigos como `neonBlue`, `neonPurple`, `arenaAccent` e `planAccent`
  não pertencem ao novo vocabulário visual. Compatibilidade temporária só pode
  existir até a migração dos consumidores.
- Referências competitivas em analytics são legado técnico fora deste slice;
  não serão expostas nem reintroduzidas.

## Decisões de preservação

- Não alterar contratos Java, Riverpod, Isar, Firebase Auth, analytics ou
  regras de recompensa.
- Preservar o glifo e o eixo, redesenhando seu uso para que sejam funcionais.
- Preservar as ações de missão, reorganização e Jornada; mudar apenas sua
  composição e pontos de entrada.

## Implementação desta entrega

- A navegação móvel foi reduzida a uma barra estrutural com labels em português.
- Jornadas passaram a usar rota vertical e fluxos dedicados para criar, editar
  e organizar capítulos.
- O Eixo e o glifo têm alternativa semântica para leitores de tela.
- A tentativa de captura no emulador foi bloqueada pela geração do APK local;
  a validação de build Android permanece uma pendência do ambiente.

## Riscos

- Há alterações locais preexistentes e arquivos gerados que não podem entrar
  nos commits deste redesign.
- O backend local e o APK podem executar versões diferentes; validação visual
  não substitui a reconciliação autoritativa.
- A escala de fonte e larguras de 320 px exigem evitar alturas fixas em faixas
  de missão e formulários.
- A documentação antiga que cita Firestore/competição conflita com
  `docs/ai/source-of-truth.md`; esta última e o código Java autoritativo
  prevalecem.
