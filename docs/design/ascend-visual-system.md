# Sistema visual — Cartografia da Ascensão

## Princípios

- Fundo Abismo, conteúdo legível e uma única cor funcional dominante por tela.
- `Eixo de Ascensão` é estrutura de percurso, não decoração contínua.
- Painéis agrupam decisões e marcos; listas usam faixas e divisores.
- O glifo é vetor Flutter e recebe semântica textual quando representa estado.

## Fluxos implementados

- Criação e edição de Jornada usam tela dedicada, etapas visíveis e ação
  persistente acima do teclado, preservando os mesmos comandos Riverpod.
- Capítulos usam tela dedicada: a rota mostra ordem, conclusão e acesso a
  marcos; a inclusão acontece na ação fixa da própria tela.
- Missões usam faixas no Eixo de Ascensão, com altura elástica para respeitar
  escala de fonte e títulos longos.

## Tokens

- Espaçamento: 4, 8, 12, 16, 20, 24, 32, 48 e 64.
- Raio: 14 para controles, 16 para painéis e 20 somente em sheets.
- Paleta: Abismo `#07090D`, Basalto `#0D1218`, Ardósia `#151D26`, Osso
  `#E8E4DA`, Névoa `#A9B2BC`, Ascensão `#63D6C5`, Recompensa `#D9A85F` e
  Boss `#E36F6A`.
- Tipografia: Sora em títulos/números; Manrope no corpo e interface; mono só
  para telemetria curta.

## Componentes-base

- `AscentBackground`: no máximo dois agrupamentos topográficos suaves.
- `AscendPanel`: superfície sólida, borda sutil e canto de assinatura;
  sem listras, gradiente ou sombra pesada.
- `AscendBottomNavigation`: barra sólida de 64–72 px, indicador fino e labels
  em português.
- `AscendFormField` e sheets: labels persistentes, 52–56 px, ação fixa fora do
  teclado.
- `AscendMissionRow`: faixa com nó do eixo, contexto, recompensa e uma ação.
- `AscendJourneyRoute`: mapa vertical com nós de capítulo/marco e estados.

## Acessibilidade e estados

- Texto essencial usa contraste AA e não depende só de cor.
- Nós, progresso e sincronização possuem rótulos semânticos.
- Carregamento preserva a estrutura; erro/offline apresentam ação de retomada.
- Movimento curto (160–220 ms), sem animação decorativa contínua.
