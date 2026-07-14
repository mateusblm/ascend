# 2. Conceito visual central

## Cartografia da Ascensão

A identidade visual deve tratar a evolução pessoal como uma subida registrada por um instrumento de navegação.

Metáforas visuais:

- missões são passos;
- Jornadas são rotas;
- capítulos são marcos de altitude;
- atributos são capacidades desenvolvidas;
- Momentum é o ritmo atual da subida;
- o chefe semanal é um obstáculo no caminho;
- Provas de Ascensão são passagens de nível;
- o Legado é o registro permanente da trajetória.

A interface deve parecer um **instrumento vivo de orientação e progressão**, combinando:

- precisão tecnológica;
- materialidade mineral;
- mapas topográficos;
- linhas de trajetória;
- sinais, marcas e selos;
- espaços escuros com luz controlada;
- composição editorial;
- assimetria intencional.

Não usar estética medieval genérica. Não usar visual de terminal hacker. Não copiar o “Sistema” de qualquer obra existente.

---

# 3. Assinatura visual do Ascend

Criar uma assinatura própria baseada em uma linha vertical ascendente.

Essa linha será chamada internamente de **Eixo de Ascensão**.

Ela pode aparecer de formas diferentes:

- linha de progresso no onboarding;
- trilha temporal nas missões;
- caminho da Jornada;
- ligação entre talentos;
- marcador de progresso de Patamar;
- linha central do Legado;
- animação de entrada;
- detalhe da navegação selecionada.

Características:

- nunca deve aparecer de forma decorativa excessiva;
- deve representar progresso ou continuidade;
- pode possuir pequenas quebras, marcas de altitude e nós;
- deve manter espessura e linguagem consistentes;
- deve ser implementável com `CustomPainter` ou componentes vetoriais simples.

Criar também um **glifo de Ascensão** original:

- formato geométrico simples;
- construído com linha vertical, corte diagonal e três estágios;
- utilizável como ícone, marca d’água e indicador de nível;
- sem semelhança direta com símbolos de animes ou jogos conhecidos.

Não gerar uma imagem por IA para esse glifo. Criar geometricamente em Flutter ou SVG desenhado de forma consistente.

---

# 4. Paleta de cores

A base deve ser escura, mas não totalmente preta e não dominada por roxo.

## Cores estruturais

```text
Abismo          #07090D
Basalto         #0D1218
Ardósia         #151D26
Cinza mineral   #232D38
Osso            #E8E4DA
Névoa           #A9B2BC
Texto reduzido  #707B86
Linha sutil     rgba(232, 228, 218, 0.08)
Linha forte     rgba(232, 228, 218, 0.18)
```

## Cores funcionais

```text
Ascensão        #63D6C5
Âmbar            #D9A85F
Vitalidade      #6DBA83
Perigo/Boss     #E36F6A
Intelecto       #8878E6
Informação      #6CA8D8
```

Regras:

- `Ascensão` é a cor principal da marca, mas não deve preencher toda a tela.
- `Âmbar` representa conquista, recompensa, nível e marco.
- `Perigo/Boss` deve ser reservado para ameaça, falha crítica e chefe.
- `Intelecto` é uma cor de atributo, não a cor principal do aplicativo.
- não criar gradiente roxo-azul como padrão universal;
- usar gradientes apenas em áreas hero, com baixa saturação e propósito;
- não usar glow em todos os elementos;
- cada tela deve ter no máximo um foco luminoso dominante;
- garantir contraste WCAG nas informações essenciais.

Migrar o tema atual com compatibilidade temporária quando necessário. Remover nomes de cor ligados à competição quando não tiverem mais função.

---

# 5. Tipografia

Usar tipografia com personalidade, mas legível.

Sugestão:

- **Sora** para títulos, números grandes e marcos;
- **Manrope** para textos, botões e formulários;
- **IBM Plex Mono** apenas para dados curtos, nível, XP, horário e indicadores técnicos.

Regras:

- no máximo duas famílias visíveis na maioria das telas;
- mono apenas como acento;
- evitar excesso de texto em caixa alta;
- não usar espaçamento exagerado entre letras em textos longos;
- títulos devem parecer editoriais, não banners de jogo;
- números de nível e progresso podem ter maior presença visual;
- corpo mínimo confortável para mobile;
- respeitar escala de fonte do sistema.

Criar tokens tipográficos claros:

```text
displayHero
displayLevel
heading1
heading2
heading3
bodyLarge
body
bodySmall
label
telemetry
button
```

---

# 6. Formas e materiais

Não usar o mesmo cartão arredondado para tudo.

Criar três famílias de contêiner:

## 6.1 Painel estrutural

Para dados agrupados:

- fundo Basalto ou Ardósia;
- borda fina;
- raio de 14 a 18;
- sem sombra pesada;
- pode ter um pequeno corte no canto superior direito.

## 6.2 Faixa de missão

Para listas:

- formato horizontal;
- separação por linha e espaço, não por cartões empilhados;
- marcador lateral conectado ao Eixo de Ascensão;
- estado de conclusão integrado ao item;
- densidade confortável.

## 6.3 Painel de marco

Para Jornada, Boss, Prova e recompensa:

- composição assimétrica;
- título com forte hierarquia;
- número ou estado dominante;
- detalhe gráfico exclusivo;
- pode ocupar largura total;
- não deve ser repetido várias vezes na mesma tela.

Criar uma forma assinatura, como um canto recortado de 8 px ou uma pequena marca diagonal. Usar com moderação e consistência.

Evitar:

- glassmorphism;
- blur pesado;
- sombras difusas;
- blobs abstratos;
- bordas coloridas em todos os componentes;
- cartões dentro de cartões;
- arredondamento excessivo;
- divisores sem função.

---

# 7. Textura e fundo

O fundo não pode ser apenas uma cor sólida, mas também não pode distrair.

Criar um `AscentBackground` reutilizável com variações:

- base Abismo;
- leve vinheta;
- linhas topográficas em 2% a 5% de opacidade;
- ruído procedural muito sutil, se performático;
- foco luminoso localizado de acordo com a tela;
- sem assets raster gigantes;
- sem imagens de IA.

Variações sugeridas:

```text
base
missions
journey
ascension
recovery
legacy
```

As variações devem manter a identidade, mas impedir que todas as telas pareçam iguais.

---

# 8. Diferenciação entre áreas

A coerência deve vir dos tokens e do Eixo de Ascensão. A composição não deve ser idêntica entre telas.

## 8.1 Base — Observatório pessoal

Sensação:

- visão do estado atual;
- silêncio;
- domínio;
- orientação.

Composição:

1. cabeçalho compacto com saudação contextual e acesso ao perfil;
2. área hero com:
   - glifo/personagem;
   - nível;
   - barra de XP;
   - Momentum;
   - próximo desbloqueio;
3. uma única ação principal:
   - “Continuar evolução”;
   - direciona para a missão mais relevante;
4. atributos em selos ou medidores compactos, não em seis cartões;
5. trecho da Jornada como caminho, não como barra genérica;
6. Boss semanal aparecendo como ameaça distante, sem dominar a Base.

Evitar dashboard com grade de KPIs.

A tela deve responder rapidamente:

- quem estou me tornando;
- como estou hoje;
- qual é o próximo passo.

## 8.2 Missões — Quadro de campo

Sensação:

- ação;
- clareza;
- ritmo;
- baixa fricção.

Composição:

1. cabeçalho com data e progresso do dia;
2. missão recomendada em destaque;
3. linha temporal:
   - Agora;
   - Hoje;
   - Depois;
4. missões como faixas ligadas por uma linha vertical;
5. ação de concluir grande o suficiente para toque;
6. gestos para reagendar e pausar;
7. criação rápida persistente, sem FAB genérico gigante;
8. concluídas recolhidas, sem ocupar a primeira dobra.

Cada item deve mostrar apenas:

- nome;
- horário ou contexto;
- Jornada, quando existir;
- recompensa resumida;
- estado de sincronização, quando necessário.

Não mostrar todas as configurações dentro da lista.

## 8.3 Jornada — Mapa vertical

Sensação:

- direção;
- distância;
- descoberta;
- progresso acumulado.

Esta deve ser a tela visualmente mais diferencial.

Composição:

- caminho vertical desenhado com `CustomPainter`;
- capítulos alternando levemente entre esquerda e direita;
- marcos com glifos próprios;
- trechos concluídos iluminados;
- trecho atual com animação discreta;
- trechos futuros com baixo contraste;
- objetivo e motivação no topo;
- próximo marco claramente acionável;
- missões vinculadas acessíveis pelo marco, sem transformar a tela em lista.

Evitar:

- barra percentual como único progresso;
- lista de capítulos em cartões iguais;
- mapa horizontal difícil de usar no mobile.

## 8.4 Ascensão — Limiar e desafio

Sensação:

- tensão;
- importância;
- conquista;
- passagem.

Conteúdo:

- chefe semanal;
- Prova de Ascensão;
- Patamar;
- acesso ao Legado.

Chefe semanal:

- fundo mais dramático;
- grande forma/silhueta vetorial abstrata;
- não usar arte gerada por IA;
- criar uma pequena biblioteca de formas autorais:
  - muralha;
  - tempestade;
  - abismo;
  - colosso;
  - labirinto;
  - eclipse;
- a forma representa o obstáculo, sem copiar monstros;
- barra de vida integrada à composição;
- dano recente e missões relevantes;
- uma ação principal.

Prova de Ascensão:

- apresentação como um limiar;
- critérios objetivos;
- progresso visível;
- recompensa permanente;
- não parecer checklist administrativo.

## 8.5 Build e talentos — Arquitetura do personagem

Sensação:

- escolha;
- identidade;
- especialização.

Cada build deve possuir uma geometria própria:

- **Erudito:** órbitas, círculos, linhas de conhecimento;
- **Vanguarda:** diagonais, impulso e formas direcionais;
- **Estrategista:** grade tática, conexões e equilíbrio.

Não depender apenas de mudar a cor.

Talentos:

- árvore navegável vertical;
- poucos nós relevantes;
- conexão clara;
- estados bloqueado, disponível e adquirido;
- descrição curta;
- efeito concreto;
- confirmação antes do gasto.

## 8.6 Recuperação — Acampamento

Sensação:

- segurança;
- retorno;
- ausência de culpa.

Composição:

- tela mais calma;
- contraste reduzido;
- Âmbar suave no lugar de vermelho;
- explicar que progresso permanente foi preservado;
- três caminhos claros:
  - Retomada leve;
  - Voltar ao plano;
  - Reorganizar Jornada.

Não mostrar uma parede de missões vencidas antes da escolha.

## 8.7 Legado — Crônica

Sensação:

- permanência;
- história;
- orgulho;
- evidência da evolução.

Composição:

- linha vertical cronológica;
- marcos gravados;
- títulos, Bosses, Provas e Jornadas;
- agrupamento por ciclo;
- variação de escala para eventos importantes;
- sem grade genérica de badges;
- sem excesso de troféus coloridos.

---

# 9. Onboarding

O onboarding precisa ser curto, imersivo e honesto.

Não criar um questionário de dez minutos.

Fluxo sugerido:

1. **Chamado**
   - “O que você quer elevar?”
   - selecionar uma intenção principal.

2. **Área**
   - Corpo;
   - Mente;
   - Ofício;
   - Ordem;
   - Conexão.

3. **Ritmo**
   - disponibilidade;
   - frequência;
   - preferência por orientação ou criação manual.

4. **Primeira rota**
   - escolher modelo de Jornada ou criar manualmente.

5. **Primeiros passos**
   - até três missões;
   - todas editáveis antes de ativar.

6. **Despertar**
   - conclusão da primeira missão;
   - mostrar XP, atributo, Jornada e progressão.

Usar o Eixo de Ascensão como indicador de etapas.

Persistir cada etapa.

Não pedir avaliação da loja.

Não apresentar paywall antes do usuário experimentar o loop principal.

---

# 10. Microinterações e movimento

A imersão deve vir da resposta do sistema, não de animações longas.

## Tempos sugeridos

```text
toque/utilidade       100–160 ms
estado de componente  160–220 ms
transição de tela     220–320 ms
recompensa comum      até 500 ms
grande conquista      até 1200 ms, ignorável
```

## Transições

- entrada vertical sutil;
- fade por máscara;
- linha de progresso desenhada;
- elemento compartilhado quando fizer sentido;
- evitar zoom excessivo;
- evitar typewriter em todos os textos;
- evitar partículas em toda conclusão.

## Conclusão de missão

Sequência:

1. estado local confirma o toque;
2. marcador da missão se fecha;
3. Eixo de Ascensão avança;
4. recompensa aparece como recibo compacto;
5. atualização de Jornada/Boss aparece somente se relevante;
6. estado pendente de sincronização continua visível sem bloquear.

## Haptics

- leve para seleção;
- médio para conclusão;
- forte apenas para nível, Boss ou Prova.

Respeitar redução de movimento e preferências do sistema.

---

# 11. Linguagem e microcopy

Tom:

- direto;
- adulto;
- encorajador;
- preciso;
- sem culpa;
- sem exageros heroicos em toda frase.

Evitar:

- “Você falhou novamente”.
- “Seu personagem está decepcionado”.
- “Você perdeu tudo”.
- “Torne-se invencível”.
- “O Sistema ordena”.
- uso excessivo de colchetes, caixa alta e termos pseudoépicos.

Preferir:

- “Seu plano não acompanhou esta semana.”
- “Seu progresso permanente foi preservado.”
- “Ajuste a rota antes de continuar.”
- “Próximo marco: concluir o capítulo.”
- “Momentum em recuperação.”
- “Missão concluída. Intelecto +12.”

O conteúdo deve parecer escrito por uma equipe de produto, não por um gerador de slogans.

---

# 12. Como evitar aparência gerada por IA

Aplicar explicitamente estas regras:

1. Não usar ilustrações fantasy geradas.
2. Não usar avatares 3D genéricos.
3. Não usar gradiente roxo-azul em todos os elementos.
4. Não repetir o mesmo layout de cartão em todas as telas.
5. Não usar textos genéricos como “Unlock your potential”.
6. Não preencher espaços com blobs, estrelas ou partículas aleatórias.
7. Não usar ícones de estilos diferentes.
8. Não criar dezenas de badges sem significado.
9. Não exagerar em simetria perfeita.
10. Não adicionar decoração sem relação com estado ou progresso.
11. Usar poucos motivos visuais, repetidos de forma intencional.
12. Criar composições específicas para cada área.
13. Preferir vetor, `CustomPainter`, formas e tipografia.
14. Manter detalhes imperfeitos e editoriais:
    - alinhamento alternado no mapa;
    - variação de escala;
    - espaços negativos;
    - hierarquia visual humana.
15. Toda tela deve possuir uma pergunta principal e uma ação principal.

---

# 13. Design system a implementar

Reestruturar `lib/core/theme` de forma clara, sem quebrar tudo de uma vez.

Estrutura sugerida:

```text
lib/core/theme/
├── app_theme.dart
├── app_palette.dart
├── app_typography.dart
├── app_spacing.dart
├── app_radius.dart
├── app_motion.dart
├── app_shapes.dart
└── app_theme_extensions.dart
```

Criar componentes reutilizáveis:

```text
lib/core/widgets/ascend/
├── ascend_scaffold.dart
├── ascent_background.dart
├── ascent_axis.dart
├── ascent_glyph.dart
├── ascend_panel.dart
├── ascend_section_header.dart
├── ascend_primary_action.dart
├── ascend_status_badge.dart
├── ascend_sync_indicator.dart
├── ascend_empty_state.dart
├── ascend_error_state.dart
├── ascend_reward_receipt.dart
├── ascend_level_core.dart
├── ascend_attribute_seal.dart
├── ascend_momentum_indicator.dart
├── ascend_mission_strip.dart
├── ascend_journey_path.dart
├── ascend_milestone_node.dart
├── ascend_boss_frame.dart
└── ascend_trial_frame.dart
```

Não é obrigatório usar exatamente esses nomes se houver melhor compatibilidade com o projeto. Preserve e refatore componentes atuais quando fizer sentido, especialmente os widgets de sistema existentes.

Evitar adicionar bibliotecas pesadas. Priorizar Flutter nativo e `CustomPainter`. Só adicionar dependência quando houver justificativa técnica clara.

---

# 14. Navegação

A navegação principal deve representar:

1. Base;
2. Missões;
3. Jornada;
4. Ascensão.

Regras:

- barra inferior compacta;
- fundo opaco ou mineral, não vidro;
- item selecionado indicado pelo Eixo de Ascensão ou glifo;
- ícone e texto;
- sem cinco ou seis abas;
- respeitar safe area;
- não esconder estado de sincronização importante;
- perfil acessível pelo cabeçalho.

Em telas mais largas:

- usar `NavigationRail` ou layout adaptativo;
- não apenas esticar o mobile.

---

# 15. Responsividade

Projetar e testar pelo menos:

```text
320 x 568
360 x 800
390 x 844
430 x 932
tablet vertical
tablet horizontal
```

Requisitos:

- sem overflow horizontal;
- sem textos cortados;
- alvos de toque adequados;
- componentes hero adaptáveis;
- mapa de Jornada legível;
- navegação funcional;
- escala de fonte do sistema até pelo menos 1.3 sem quebrar fluxos principais;
- teclado não deve cobrir ações importantes;
- bottom sheets devem respeitar teclado e safe area.

---

# 16. Acessibilidade

Implementar:

- `Semantics` em controles customizados;
- descrição de barras e medidores;
- foco previsível;
- contraste adequado;
- feedback que não dependa apenas de cor;
- redução de movimento;
- textos escaláveis;
- botões com área de toque adequada;
- alternativas textuais para glifos;
- estados de sincronização anunciáveis.

O visual imersivo não pode prejudicar uso real.

---

# 17. Estados obrigatórios

Cada tela principal precisa ter design e implementação para:

- carregando;
- vazio;
- conteúdo;
- erro recuperável;
- offline;
- sincronização pendente;
- sincronização falhou;
- ação concluída;
- permissão negada;
- dados parciais.

Não exibir apenas spinner central.

Loading:

- usar skeleton coerente com a composição;
- manter estrutura da tela;
- evitar flash branco.

Erro:

- explicar o que aconteceu;
- permitir tentar novamente;
- preservar ações locais quando possível;
- não usar linguagem temática obscura para erros técnicos.

---

# 18. Sequência de implementação

## Fase 0 — Inventário e documento

Criar ou atualizar:

`docs/design/ascend-visual-system.md`

O documento deve registrar:

- conceito;
- paleta;
- tipografia;
- tokens;
- componentes;
- navegação;
- movimento;
- estados;
- acessibilidade;
- telas;
- decisões de compatibilidade;
- itens ainda não implementados.

## Fase 1 — Fundação visual

Implementar:

- novos tokens;
- tema;
- tipografia;
- fundo;
- formas;
- Eixo de Ascensão;
- glifo;
- scaffold;
- navegação principal;
- estados base.

Manter aliases temporários para componentes antigos quando necessário.

## Fase 2 — Vertical slice

Redesenhar completamente, com dados reais:

1. Base;
2. Missões;
3. conclusão de missão;
4. recibo de recompensa;
5. estado offline/sincronização.

Essa fase deve provar a identidade antes de espalhá-la.

## Fase 3 — Jornada

Implementar:

- mapa vertical;
- capítulos;
- marcos;
- progresso;
- estado vazio;
- estado concluído;
- adaptação para Jornada inexistente.

## Fase 4 — Ascensão

Implementar:

- Boss semanal;
- Prova;
- Patamar;
- visão inicial do Legado.

## Fase 5 — Onboarding e recuperação

Implementar:

- onboarding visual;
- primeira rota;
- primeira missão;
- retorno após ausência;
- reorganização.

## Fase 6 — Polimento

- animações;
- haptics;
- acessibilidade;
- responsividade;
- performance;
- testes;
- remoção de componentes antigos;
- documentação final.

Não faça todas as fases de uma vez se isso tornar a mudança insegura. Entregue pelo menos Fase 0, Fase 1 e o vertical slice da Fase 2 de forma completa e consistente antes de avançar.

---

# 19. Testes

Adicionar ou atualizar testes para:

- tema e tokens;
- navegação;
- responsividade básica;
- Base com dados, vazia e offline;
- lista de Missões;
- conclusão;
- recompensa;
- sincronização pendente;
- Journey path quando implementado;
- redução de movimento quando aplicável;
- semântica de componentes customizados.

Preferir testes de widget para componentes e fluxos críticos.

Golden tests podem ser adicionados quando o ambiente do projeto suportar de forma estável. Não criar uma infraestrutura frágil apenas para afirmar que existem goldens.

---

# 20. Critérios de aceite

A renovação visual será aceita quando:

1. O aplicativo possuir identidade reconhecível sem depender de referências externas.
2. Base, Missões, Jornada e Ascensão tiverem composições diferentes, mas coerentes.
3. A interface não for apenas uma sequência de cartões.
4. O Eixo de Ascensão estiver integrado a progresso real.
5. A paleta não for dominada por gradiente roxo-azul.
6. Não houver arte gerada por IA.
7. Não houver cópia visual de anime.
8. A Base apresentar estado, direção e próxima ação sem parecer dashboard.
9. Missões forem rápidas de entender e concluir.
10. Jornada funcionar como mapa vertical.
11. Boss possuir presença visual sem depender de ilustração externa.
12. Estados offline e de sincronização estiverem claros.
13. Não houver overflow nos tamanhos definidos.
14. Acessibilidade básica estiver implementada.
15. `flutter analyze` passar.
16. `flutter test` passar.
17. Regras de negócio e integrações existentes continuarem funcionando.
18. Não houver retorno de funcionalidades competitivas.
19. Textos estiverem em português brasileiro e sem linguagem genérica.
20. A implementação estiver documentada.

---

# 21. Resultado esperado

O Ascend deve parecer um produto desenhado intencionalmente para representar evolução pessoal.

A experiência deve transmitir:

- direção, sem rigidez;
- imersão, sem teatralidade excessiva;
- progressão, sem manipulação;
- profundidade, sem confusão;
- personalidade, sem copiar;
- beleza, sem prejudicar a função.

A assinatura final deve ser:

> Uma cartografia viva da evolução do usuário.

Comece pela análise do estado atual, registre o plano em `docs/design/ascend-visual-system.md` e implemente a fundação visual e o primeiro vertical slice com Base e Missões.