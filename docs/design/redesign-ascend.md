# Prompt completo para o Codex — Correção profunda do design do Ascend

Você está trabalhando no repositório:

`https://github.com/mateusblm/ascend`

O Ascend é um aplicativo Flutter de evolução pessoal com:

- missões;
- XP;
- níveis;
- atributos;
- Jornadas;
- builds;
- talentos;
- chefe semanal;
- Provas de Ascensão;
- Patamares;
- Legado;
- funcionamento offline;
- sincronização;
- backend autoritativo.

A parte competitiva já foi removida e **não deve ser reintroduzida**.

A nova direção do produto é:

> Transformar objetivos reais em Jornadas e ações reais em evolução de personagem, com uma experiência imersiva, clara, confiável e visualmente original.

O redesign atual não atingiu o padrão esperado. A direção conceitual “Cartografia da Ascensão” continua válida, mas a implementação visual precisa ser refeita de forma profunda.

As capturas atuais demonstram os seguintes problemas:

- contraste excessivamente baixo;
- títulos e textos parecendo desabilitados;
- excesso de linhas topográficas competindo com o conteúdo;
- cartões com faixas diagonais decorativas;
- composição baseada quase exclusivamente em cartões;
- Base com aparência de dashboard administrativo;
- Jornada sem aparência real de rota;
- Missões com excesso de espaço vazio;
- barra inferior alta, pesada e visualmente isolada;
- formulários genéricos em dialogs;
- componentes inconsistentes;
- mistura de português e inglês;
- uso decorativo de cores sem significado;
- pouca presença de identidade;
- ausência de um sistema visual realmente autoral.

Não quero uma correção superficial.

Não faça apenas:

- troca de cores;
- aumento de contraste;
- redução de opacidade;
- ajuste de bordas;
- alteração de padding;
- substituição de um card por outro card;
- aplicação de mais gradientes;
- adição de mais linhas topográficas.

O objetivo é refazer a fundação visual e a composição das telas principais.

---

# 1. Objetivo desta tarefa

Refazer o design do Ascend e entregar um vertical slice consistente das seguintes áreas:

1. Base;
2. Missões;
3. Jornadas;
4. criação de Jornada;
5. edição de Jornada;
6. gerenciamento de capítulos;
7. navegação inferior;
8. estados vazios;
9. estados offline;
10. estados de sincronização.

Não implemente novas funcionalidades de produto nesta etapa.

Não avance para Ascensão, Legado, monetização ou sistemas adicionais antes de validar visualmente Base, Missões e Jornadas.

Preserve:

- Flutter;
- Riverpod;
- Isar;
- Firebase Auth;
- Firestore;
- backend Java/Spring Boot;
- regras de domínio;
- contratos de API;
- analytics;
- Crashlytics;
- sincronização;
- funcionamento offline;
- testes existentes;
- navegação funcional;
- dados reais.

Não altere regras de negócio apenas para facilitar o layout.

---

# 2. Leitura obrigatória antes de modificar

Antes de alterar qualquer código:

1. Leia integralmente:
   - `AGENTS.md`;
   - `docs/ai/source-of-truth.md`;
   - documentação ativa em `docs/product`;
   - documentação ativa em `docs/design`, se existir;
   - `README.md`;
   - `pubspec.yaml`;
   - estrutura de `lib/core`;
   - estrutura de `lib/features`;
   - tema atual;
   - navegação atual;
   - widgets reutilizáveis;
   - providers;
   - modelos;
   - testes existentes.

2. Verifique o estado real da branch.

3. Não presuma que documentação antiga esteja correta quando conflitar com:
   - o código atual;
   - esta decisão de produto;
   - a retirada da competição.

4. Faça um inventário curto antes da implementação:
   - telas existentes;
   - componentes existentes;
   - cores e tipografia atuais;
   - widgets reaproveitáveis;
   - widgets que devem ser removidos;
   - nomes ligados à competição;
   - textos em inglês;
   - riscos de regressão;
   - inconsistências entre telas;
   - dependências visuais atuais.

5. Registre o inventário em:

`docs/design/ascend-redesign-audit.md`

---

# 3. Problemas do design atual que devem ser corrigidos

## 3.1 Contraste

O design atual utiliza baixa opacidade em excesso.

Isso faz com que:

- títulos pareçam desabilitados;
- labels fiquem ilegíveis;
- itens não selecionados desapareçam;
- informações importantes percam prioridade;
- a interface pareça permanentemente inativa.

Corrigir:

- contraste;
- hierarquia;
- cores de texto;
- estados selecionados;
- estados desabilitados;
- labels;
- navegação;
- conteúdo dos cartões;
- bordas.

Não usar opacidade como principal mecanismo de hierarquia.

Usar:

- tamanho;
- peso;
- cor;
- espaço;
- posição;
- composição.

## 3.2 Decoração sem função

Remover:

- faixas diagonais multicoloridas;
- gradientes aleatórios;
- fundos com várias cores escuras;
- linhas topográficas atravessando áreas de leitura;
- brilhos que não representam estado;
- bordas coloridas em todos os componentes;
- elementos decorativos sem relação com progresso.

Toda decoração deve ter significado.

## 3.3 Excesso de cartões

A interface atual parece uma coleção de cards.

Evitar:

```text
Título
Card
Card
Card
FAB
Bottom navigation
```

Nem toda informação precisa estar dentro de um cartão.

Usar:

- linhas;
- faixas;
- mapas;
- divisores;
- painéis estruturais;
- agrupamentos editoriais;
- hierarquia tipográfica;
- espaço negativo;
- composições assimétricas.

## 3.4 Base como dashboard

A Base atual parece uma tela de indicadores.

Ela deve parecer:

- núcleo do personagem;
- observatório pessoal;
- centro de orientação;
- ponto de partida.

Ela não deve parecer:

- painel administrativo;
- tela bancária;
- dashboard de KPI;
- coleção de métricas.

## 3.5 Jornada sem rota

A Jornada é um dos principais diferenciais do produto.

Ela não pode ser apenas:

- título;
- porcentagem;
- capítulo;
- botão;
- card.

Ela deve possuir uma representação visual real de percurso.

## 3.6 Missões vazias demais

Estados vazios não podem deixar 70% da tela sem função.

Devem:

- explicar a situação;
- orientar o próximo passo;
- oferecer ação clara;
- manter identidade visual;
- mostrar utilidade;
- evitar poluição.

## 3.7 Navegação pesada

A barra inferior atual deve ser substituída.

Ela está:

- alta;
- pesada;
- visualmente isolada;
- com ícones pequenos dentro de caixas;
- ocupando espaço demais;
- misturando português e inglês.

## 3.8 Formulários genéricos

Criar e editar Jornada são ações centrais.

Não devem ocorrer em dialogs pequenos com campos comprimidos.

Usar:

- tela cheia;
- fluxo em etapas;
- bottom sheet alto;
- campos legíveis;
- validação clara;
- ação fixa;
- contexto.

---

# 4. Conceito visual central

## Cartografia da Ascensão

A identidade do Ascend deve representar evolução pessoal como uma subida registrada por um instrumento de navegação.

Metáforas:

- missões são passos;
- Jornadas são rotas;
- capítulos são trechos;
- marcos são pontos de altitude;
- atributos são capacidades;
- Momentum é o ritmo da subida;
- chefe semanal é um obstáculo;
- Provas de Ascensão são passagens;
- Patamares são níveis de domínio;
- Legado é o registro da trajetória.

A interface deve parecer:

> Um instrumento vivo de orientação e progressão pessoal.

Combinar:

- precisão tecnológica;
- materialidade mineral;
- mapas;
- linhas de trajetória;
- marcas de altitude;
- sinais;
- selos;
- composições editoriais;
- espaços escuros;
- luz controlada;
- assimetria intencional.

Não usar:

- estética medieval genérica;
- visual de terminal hacker;
- fantasia genérica;
- interface de anime;
- cópia de Solo Leveling;
- skin gamer aplicada sobre dashboard;
- ilustração gerada por IA;
- avatars 3D genéricos;
- excesso de neon;
- glassmorphism;
- gradiente roxo-azul universal.

---

# 5. Assinatura visual

## Eixo de Ascensão

Criar uma assinatura visual baseada em uma linha vertical ascendente.

Nome interno:

`Eixo de Ascensão`

Usos:

- onboarding;
- timeline de Missões;
- rota de Jornada;
- árvore de talentos;
- progressão de Patamar;
- Legado;
- estados de carregamento;
- transições;
- navegação selecionada.

Características:

- espessura consistente;
- pequenos nós;
- marcas de altitude;
- quebras pontuais;
- avanço visual;
- ligação entre etapas;
- uso funcional.

Não usar como linha decorativa atravessando toda a tela.

## Glifo de Ascensão

Criar um glifo geométrico original.

Características:

- simples;
- vetorial;
- reproduzível em Flutter;
- baseado em:
  - linha vertical;
  - corte diagonal;
  - três estágios;
- usável como:
  - marca;
  - ícone;
  - watermark;
  - indicador de progresso;
  - símbolo de Patamar.

Não usar arte gerada por IA.

Não copiar símbolos conhecidos.

Implementar com:

- `CustomPainter`;
- SVG manual;
- `Path`;
- formas simples.

---

# 6. Grid e espaçamento

Usar sistema de 4 px.

```text
4   detalhe mínimo
8   espaço interno pequeno
12  agrupamento compacto
16  espaço padrão
20  margem horizontal mobile
24  separação de seção
32  separação estrutural
48  espaço hero
64  distância entre blocos principais
```

Regras:

- margem horizontal padrão: 20 px;
- largura útil consistente;
- evitar componentes quase tocando a borda;
- evitar espaçamentos aleatórios;
- não usar grandes áreas vazias sem intenção;
- respeitar safe areas;
- teclado não pode cobrir ações;
- manter ritmo vertical previsível.

---

# 7. Paleta de cores

## Estruturais

```text
Abismo          #07090D
Basalto         #0D1218
Ardósia         #151D26
Cinza mineral   #232D38
Osso            #E8E4DA
Névoa           #A9B2BC
Texto reduzido  #707B86
```

## Superfícies

```text
background      #07090D
surface         #10161D
surfaceRaised   #171F28
surfaceStrong   #202A35
```

## Bordas

```text
borderSubtle    rgba(232, 228, 218, 0.08)
borderNormal    rgba(232, 228, 218, 0.12)
borderStrong    rgba(232, 228, 218, 0.18)
```

## Funcionais

```text
Ascensão        #63D6C5
Recompensa      #D9A85F
Boss            #E36F6A
Vitalidade      #6DBA83
Intelecto       #8878E6
Informação      #6CA8D8
Alerta          #E2B35C
```

## Textos

```text
textPrimary     #F0EDE6
textSecondary   #ADB5BE
textMuted       #747E88
textDisabled    #4D5660
```

## Regras de cor

- Ascensão é a cor principal da marca.
- Âmbar representa recompensa, nível e marco.
- Vermelho/coral representa Boss e erro real.
- Intelecto é cor de atributo, não tema do app.
- Missões não devem virar amarelas.
- Jornada não deve virar azul.
- Cada tela deve ter:
  - uma cor dominante;
  - no máximo uma cor secundária forte.
- Não usar todas as cores funcionais juntas.
- Não usar gradientes em todos os elementos.
- Gradientes devem ser raros e funcionais.
- Não usar glow em todos os componentes.
- Cada tela deve ter no máximo um foco luminoso dominante.
- Garantir contraste WCAG AA em conteúdo essencial.

---

# 8. Tipografia

Sugestão:

- **Sora** para títulos e números;
- **Manrope** para corpo e interface;
- **IBM Plex Mono** apenas para telemetria curta.

Se o projeto já tiver fontes adequadas, avaliar reaproveitamento.

Não adicionar várias famílias sem necessidade.

## Tokens

```text
displayHero  32/36 semibold
displayLevel 28/32 semibold
heading1     26/32 semibold
heading2     21/26 semibold
heading3     17/22 semibold
bodyLarge    16/24 regular
body         14/21 regular
bodySmall    12/18 regular
label        11/16 medium
telemetry    12/16 medium mono
button       14/18 semibold
```

## Regras

- evitar caixa alta em títulos longos;
- caixa alta apenas em labels curtas;
- evitar letter spacing exagerado;
- mono apenas como acento;
- não usar opacidade para criar hierarquia;
- respeitar escala de fonte;
- manter legibilidade em 1.3x;
- português consistente;
- não usar “Quests”.

---

# 9. Formas e materiais

Criar três famílias de contêiner.

## 9.1 Painel estrutural

Uso:

- dados agrupados;
- núcleo do personagem;
- resumo semanal;
- formulário;
- detalhes de Jornada.

Características:

- fundo Basalto ou Ardósia;
- borda fina;
- raio entre 14 e 18 px;
- sem sombra pesada;
- canto recortado opcional;
- sem gradiente multicolorido.

## 9.2 Faixa de missão

Uso:

- listas;
- timelines;
- próximas ações.

Características:

- formato horizontal;
- sem card pesado;
- divisor;
- marcador lateral;
- estado claro;
- recompensa resumida;
- ação acessível.

## 9.3 Painel de marco

Uso:

- Jornada;
- Boss;
- Prova;
- recompensa;
- Patamar.

Características:

- composição assimétrica;
- título forte;
- número ou estado dominante;
- detalhe visual exclusivo;
- largura total quando necessário;
- baixa repetição.

## Assinatura de forma

Criar uma pequena marca diagonal ou canto recortado de 8 px.

Usar com moderação.

Evitar:

- glassmorphism;
- blur pesado;
- sombra difusa;
- cartões dentro de cartões;
- bordas coloridas em tudo;
- arredondamento excessivo;
- blobs;
- listras diagonais.

---

# 10. Fundo topográfico

Criar um componente:

`AscentBackground`

Variações:

```text
base
missions
journey
ascension
recovery
legacy
```

Características:

- fundo Abismo;
- vinheta leve;
- topografia entre 2% e 5% de opacidade;
- no máximo dois agrupamentos por tela;
- não atravessar conteúdo importante;
- não desenhar linha central vertical permanente;
- foco luminoso localizado;
- ruído procedural sutil somente se performático;
- sem raster gigante;
- sem imagem gerada por IA.

A topografia deve ser percebida depois do conteúdo.

---

# 11. Navegação inferior

Refazer completamente.

## Estrutura

Itens:

1. Base;
2. Missões;
3. Jornadas;
4. Ascensão, quando disponível.

## Especificação

- altura entre 64 e 72 px;
- fundo sólido;
- borda superior sutil;
- largura total;
- sem aparência de card flutuante;
- ícones simples;
- sem quadrados internos;
- ícone e label;
- estado selecionado:
  - cor Ascensão;
  - pequeno indicador;
  - peso maior;
- estado não selecionado legível;
- safe area correta;
- sem mistura de idiomas;
- sem FAB sobreposto.

Quando houver ação contextual:

- botão no conteúdo;
- ação no cabeçalho;
- botão compacto;
- botão fixo acima da navegação, quando necessário.

Em telas maiores:

- adaptar para `NavigationRail`;
- não apenas esticar a barra mobile.

---

# 12. Tela Base

A Base deve responder:

1. Quem estou me tornando?
2. Como estou hoje?
3. Qual é o próximo passo?

## 12.1 Cabeçalho

- glifo pequeno;
- nome Ascend;
- subtítulo contextual;
- acesso ao perfil;
- sem título gigante “Base”.

## 12.2 Núcleo do personagem

Criar uma composição hero única contendo:

- Patamar;
- nome ou identidade;
- build;
- nível;
- XP;
- Momentum;
- próximo desbloqueio.

Não fragmentar em vários cards.

A composição deve ser:

- marcante;
- legível;
- autoral;
- compacta;
- responsiva.

Pode usar:

- glifo central;
- anel parcial;
- linha de ascensão;
- nível destacado;
- selo de Patamar;
- barra de XP integrada.

Não usar avatar 3D genérico.

## 12.3 Próximo passo

Após o núcleo:

```text
PRÓXIMO PASSO

Nome da missão recomendada
Contexto curto
Jornada associada
Recompensa resumida

[Continuar]
```

Quando não houver missão:

```text
Sua rota está aberta.

Crie o próximo passo para continuar evoluindo.

[Criar missão]
```

## 12.4 Atributos

Não mostrar seis linhas soltas.

Alternativas permitidas:

- composição 2x3;
- selos compactos;
- barras curtas;
- radar simples;
- arco segmentado.

Cada atributo deve mostrar:

- nome;
- valor;
- progresso;
- cor funcional;
- sem card individual pesado.

## 12.5 Semana

Mostrar:

- desafio semanal;
- progresso;
- próximo marco;
- ação contextual.

Não parecer KPI.

## 12.6 Estado vazio da Base

Mostrar:

- identidade;
- explicação;
- próximo passo;
- CTA claro;
- sem grande espaço preto sem função.

---

# 13. Tela Missões

A tela deve parecer um quadro de execução.

## 13.1 Cabeçalho

```text
MISSÕES
Terça-feira, 14 de julho
3 de 5 concluídas
```

Não mostrar um grande número sem contexto.

## 13.2 Abas

- Hoje;
- Próximas;
- Histórico;
- Arquivadas.

Regras:

- label selecionada clara;
- não selecionadas legíveis;
- indicador fino;
- altura compacta;
- sem excesso de caixa alta.

## 13.3 Timeline

Usar o Eixo de Ascensão.

Exemplo:

```text
● 08:00
│ Nome da missão
│ Jornada · +20 XP
│ [Concluir]
│
○ 14:00
  Próxima missão
```

Cada item deve mostrar apenas:

- horário ou contexto;
- nome;
- Jornada, quando existir;
- recompensa resumida;
- estado;
- sincronização, se necessário;
- ação principal.

Não mostrar:

- todas as configurações;
- descrição longa;
- vários chips;
- card pesado.

## 13.4 Ações

- concluir;
- reagendar;
- pausar;
- editar;
- arquivar.

Usar:

- gesto lateral;
- menu contextual;
- bottom sheet;
- ação direta.

Não colocar cinco ícones em cada item.

## 13.5 Estado vazio

Na primeira metade da tela:

```text
Nenhuma missão para hoje

Sua rota está livre. Você pode criar um passo rápido
ou planejar algo para outro dia.

[Criar missão]
[Ver próximas]
```

Adicionar pequena representação funcional do Eixo.

Sem ilustração genérica.

## 13.6 Estado offline

Exibir:

- banner compacto;
- ações locais disponíveis;
- status pendente;
- não bloquear conclusão;
- reconciliação posterior.

---

# 14. Tela Jornadas

Esta deve ser a tela mais diferencial.

## 14.1 Jornada ativa

No topo:

- nome;
- objetivo;
- motivação curta;
- progresso;
- capítulo atual;
- próximo marco;
- ações secundárias.

Não usar card com listras.

## 14.2 Mapa vertical

Implementar rota real.

Exemplo:

```text
● Início
│
◆ Capítulo 1
│  Primeiro avanço
│  1 de 3 marcos
│
◇ Marco atual
│  Revisar proposta
│
○ Capítulo 2
│  Bloqueado
│
○ Destino
```

Implementar com:

- `CustomPainter`;
- widgets vetoriais;
- linha vertical;
- nós;
- marcos;
- labels alternadas;
- estado atual destacado.

Estados:

- concluído;
- atual;
- futuro;
- pausado;
- bloqueado.

## 14.3 Composição

- capítulos podem alternar levemente entre esquerda e direita;
- evitar simetria perfeita;
- usar espaço negativo;
- trecho concluído com Ascensão;
- trecho atual com Âmbar ou Ascensão;
- futuro com baixo contraste;
- não usar cores demais;
- permitir scroll vertical natural.

## 14.4 Múltiplas Jornadas

Priorizar uma Jornada ativa.

Outras Jornadas em seção compacta:

```text
OUTRAS JORNADAS
```

Mostrar:

- nome;
- estado;
- progresso;
- ação para abrir.

Não mostrar todos os detalhes.

## 14.5 Pausada

Mostrar estado claramente.

Não reduzir opacidade do card inteiro.

## 14.6 Legado

Não usar card dourado misturado às Jornadas.

Usar acesso secundário:

```text
Consultar Jornadas concluídas →
```

## 14.7 Sem Jornada

Mostrar:

```text
Nenhuma Jornada ativa

Escolha um objetivo e transforme-o em uma rota com
capítulos, marcos e missões.

[Iniciar Jornada]
[Explorar modelos]
```

---

# 15. Criação de Jornada

Não usar dialog central.

Usar:

- tela cheia;
- wizard;
- bottom sheet alto;
- fluxo em etapas.

## Etapas

1. Identidade;
2. objetivo;
3. motivação;
4. primeiro capítulo;
5. revisão.

## 15.1 Etapa 1 — Identidade

Campos:

- nome da Jornada;
- prazo opcional;
- categoria opcional.

## 15.2 Etapa 2 — Objetivo

Campo:

- “O que você quer alcançar?”

Usar textarea confortável.

## 15.3 Etapa 3 — Motivação

Campo opcional:

- “Por que isso importa?”

## 15.4 Etapa 4 — Primeiro capítulo

Campos:

- nome do capítulo;
- descrição;
- primeiro marco opcional.

## 15.5 Etapa 5 — Revisão

Mostrar:

- nome;
- objetivo;
- capítulo;
- prazo;
- primeira ação.

CTA:

`Iniciar Jornada`

## Regras

- indicador de progresso pelo Eixo;
- botão principal fixo;
- voltar sem perder dados;
- persistir etapa;
- validação clara;
- labels acima dos campos;
- campos de 52 a 56 px;
- textarea somente quando necessário;
- teclado não cobre ação;
- cancelar com confirmação quando houver dados.

---

# 16. Edição de Jornada

Não usar dialog pequeno.

Usar:

- tela dedicada;
- sheet alto;
- mesma linguagem da criação.

Permitir:

- editar nome;
- objetivo;
- motivação;
- prazo;
- estado;
- capítulos;
- marcos.

Separar:

- dados gerais;
- estrutura;
- estado.

Não colocar tudo em três campos comprimidos.

---

# 17. Gerenciamento de capítulos

Criar tela ou sheet alto.

Mostrar:

- rota dos capítulos;
- ordem;
- progresso;
- estado;
- marcos;
- ações.

Ações:

- adicionar;
- editar;
- reordenar;
- concluir;
- pausar;
- remover, quando permitido.

Não usar apenas:

- título;
- uma linha;
- botão “novo capítulo”.

Reordenação:

- drag and drop, se compatível;
- ou ações explícitas.

Preservar histórico.

---

# 18. Formulários

Criar componentes consistentes.

## Campos

- label acima;
- texto legível;
- estado focado;
- estado preenchido;
- estado erro;
- estado desabilitado;
- helper text;
- contador quando necessário.

## Botões

### Primário

- Ascensão;
- contraste alto;
- altura 52 a 56 px;
- label clara;
- loading sem mudar largura.

### Secundário

- fundo transparente;
- borda;
- texto legível.

### Destrutivo

- coral;
- confirmação.

## Bottom sheets

- raio superior consistente;
- handle discreto;
- altura adequada;
- safe area;
- teclado;
- ação fixa.

## Dialogs

Reservar para:

- confirmação;
- exclusão;
- decisão curta.

Não usar para fluxos complexos.

---

# 19. Microinterações e movimento

A imersão deve vir da resposta do sistema.

## Tempos

```text
toque/utilidade       100–160 ms
estado de componente  160–220 ms
transição de tela     220–320 ms
recompensa comum      até 500 ms
grande conquista      até 1200 ms
```

## Conclusão de missão

1. feedback local imediato;
2. marcador se fecha;
3. Eixo avança;
4. recibo compacto;
5. Jornada/Boss atualiza, se relevante;
6. sincronização fica visível;
7. não bloquear navegação.

## Transições

- fade curto;
- deslocamento vertical;
- máscara;
- shared element quando útil;
- linha sendo desenhada;
- sem zoom excessivo;
- sem typewriter em tudo;
- sem partículas em toda conclusão.

## Haptics

- leve para seleção;
- médio para conclusão;
- forte somente para nível, Boss ou Prova.

Respeitar:

- redução de movimento;
- preferências do sistema;
- acessibilidade.

---

# 20. Microcopy

Tom:

- direto;
- adulto;
- preciso;
- encorajador;
- sem culpa;
- sem excesso de teatralidade;
- sem linguagem genérica.

Evitar:

- “Você falhou novamente”.
- “Você perdeu tudo”.
- “Seu personagem está decepcionado”.
- “Torne-se invencível”.
- “Desbloqueie seu potencial”.
- “O Sistema ordena”.
- “Quests”.
- caixa alta excessiva.
- colchetes temáticos em todo texto.

Preferir:

- “Seu plano não acompanhou esta semana.”
- “Seu progresso permanente foi preservado.”
- “Ajuste a rota antes de continuar.”
- “Próximo marco: concluir o capítulo.”
- “Momentum em recuperação.”
- “Missão concluída. Intelecto +12.”
- “Nenhuma missão para hoje.”
- “Sua rota está livre.”

Todos os textos visíveis devem estar em português brasileiro.

---

# 21. Como evitar aparência gerada por IA

Aplicar estas regras:

1. Não usar ilustrações fantasy geradas.
2. Não usar avatares 3D genéricos.
3. Não usar gradiente roxo-azul universal.
4. Não repetir o mesmo card em todas as telas.
5. Não usar textos como “unlock your potential”.
6. Não preencher espaços com blobs.
7. Não usar partículas aleatórias.
8. Não misturar estilos de ícones.
9. Não criar badges sem significado.
10. Não usar simetria perfeita em tudo.
11. Não decorar sem relação com estado.
12. Usar poucos motivos visuais.
13. Repetir motivos de forma intencional.
14. Criar composição específica por tela.
15. Preferir vetor, tipografia e `CustomPainter`.
16. Usar espaço negativo.
17. Variar escala e alinhamento.
18. Toda tela deve ter:
    - uma pergunta principal;
    - uma ação principal.
19. Toda cor deve ter função.
20. Toda animação deve ter função.

---

# 22. Design system

Reestruturar `lib/core/theme`.

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

Criar ou revisar componentes:

```text
lib/core/widgets/ascend/
├── ascend_scaffold.dart
├── ascent_background.dart
├── ascent_axis.dart
├── ascent_glyph.dart
├── ascend_bottom_navigation.dart
├── ascend_header.dart
├── ascend_panel.dart
├── ascend_hero_panel.dart
├── ascend_section_header.dart
├── ascend_primary_button.dart
├── ascend_secondary_button.dart
├── ascend_status_badge.dart
├── ascend_sync_indicator.dart
├── ascend_offline_banner.dart
├── ascend_empty_state.dart
├── ascend_error_state.dart
├── ascend_reward_receipt.dart
├── ascend_level_core.dart
├── ascend_attribute_indicator.dart
├── ascend_momentum_indicator.dart
├── ascend_mission_row.dart
├── ascend_journey_route.dart
├── ascend_journey_node.dart
├── ascend_milestone_node.dart
├── ascend_form_field.dart
├── ascend_bottom_sheet.dart
└── ascend_loading_skeleton.dart
```

Não é obrigatório seguir exatamente os nomes.

Reaproveitar componentes atuais quando fizer sentido.

Não criar componentes duplicados.

Não adicionar dependência pesada sem justificativa.

Priorizar Flutter nativo.

---

# 23. Estados obrigatórios

Cada tela precisa possuir:

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

## Loading

- skeleton;
- estrutura da tela preservada;
- sem spinner central isolado;
- sem flash branco.

## Erro

- explicar;
- permitir tentar novamente;
- preservar ação local;
- não usar linguagem temática obscura;
- não culpar o usuário.

## Offline

- indicar estado;
- manter ações possíveis;
- mostrar pendências;
- reconciliar depois.

---

# 24. Responsividade

Validar:

```text
320 x 568
360 x 800
390 x 844
430 x 932
tablet vertical
tablet horizontal
```

Requisitos:

- sem overflow;
- sem texto cortado;
- mapa legível;
- navegação funcional;
- hero adaptável;
- teclado não cobre ação;
- sheets respeitam safe area;
- fonte até 1.3x;
- áreas de toque adequadas;
- layouts maiores não apenas esticados.

---

# 25. Acessibilidade

Implementar:

- `Semantics`;
- descrições de medidores;
- foco previsível;
- contraste WCAG AA;
- área de toque mínima;
- suporte a fonte;
- redução de movimento;
- feedback não dependente de cor;
- labels persistentes;
- estado de sincronização anunciável;
- alternativa textual para glifos.

---

# 26. Processo obrigatório

## Fase 0 — Auditoria

Criar:

`docs/design/ascend-redesign-audit.md`

Registrar:

- componentes atuais;
- problemas;
- cores;
- tipografia;
- inconsistências;
- textos em inglês;
- componentes a remover;
- componentes a preservar;
- riscos.

## Fase 1 — Sistema visual

Criar:

`docs/design/ascend-visual-system.md`

Registrar:

- conceito;
- paleta;
- tipografia;
- espaçamento;
- formas;
- superfícies;
- navegação;
- Eixo;
- glifo;
- componentes;
- movimento;
- acessibilidade;
- estados;
- responsividade.

Implementar:

- tokens;
- tema;
- tipografia;
- fundo;
- formas;
- botões;
- campos;
- scaffold;
- navegação;
- estados.

## Fase 2 — Vertical slice

Implementar nesta ordem:

1. Base;
2. Missões;
3. conclusão de missão;
4. recompensa;
5. offline/sincronização;
6. Jornada;
7. criação de Jornada;
8. edição;
9. capítulos.

Não avançar antes de validar.

## Fase 3 — Capturas

Gerar capturas em 390x844:

- Base com dados;
- Base vazia;
- Missões com dados;
- Missões vazia;
- Jornada ativa;
- múltiplas Jornadas;
- Jornada vazia;
- criação;
- edição;
- capítulos;
- offline;
- sincronização pendente.

Comparar lado a lado.

## Fase 4 — Testes

Executar:

```bash
flutter analyze
flutter test
```

Adicionar testes para:

- tema;
- navegação;
- Base;
- Missões;
- Jornada;
- estados vazios;
- offline;
- sincronização;
- formulários;
- responsividade;
- semântica.

---

# 27. Critérios de aceite

A entrega não será aceita se:

- continuar parecendo uma pilha de cartões;
- faixas diagonais permanecerem;
- contraste continuar baixo;
- Jornada continuar apenas como card;
- Base continuar como dashboard;
- barra inferior continuar pesada;
- formulários continuarem em dialogs genéricos;
- houver português e inglês misturados;
- houver espaço vazio sem ação;
- topografia competir com conteúdo;
- cada tela usar estilo diferente;
- houver arte gerada por IA;
- houver cópia de anime;
- regras de negócio forem quebradas;
- competição for reintroduzida.

A entrega será aceita quando:

1. Houver identidade visual reconhecível.
2. Base, Missões e Jornada forem distintas e coerentes.
3. Jornada possuir rota visual real.
4. Base apresentar identidade, estado e próximo passo.
5. Missões forem rápidas de entender e executar.
6. Formulários parecerem parte do produto.
7. Navegação estiver compacta.
8. Fundo estiver subordinado ao conteúdo.
9. Contraste estiver correto.
10. Textos estiverem em português.
11. Offline estiver claro.
12. Sincronização estiver clara.
13. Não houver overflow.
14. Acessibilidade básica estiver implementada.
15. `flutter analyze` passar.
16. `flutter test` passar.
17. Dados reais continuarem funcionando.
18. Arquitetura existente for preservada.
19. Não houver novas dependências desnecessárias.
20. A implementação estiver documentada.

---

# 28. Entrega esperada

Ao final, apresentar:

1. resumo da auditoria;
2. decisões visuais;
3. componentes removidos;
4. componentes reaproveitados;
5. componentes criados;
6. arquivos alterados;
7. telas redesenhadas;
8. capturas geradas;
9. testes executados;
10. resultado de `flutter analyze`;
11. resultado de `flutter test`;
12. pendências reais;
13. riscos restantes.

Não afirmar que algo passou sem executar.

Não esconder pendências.

---

# 29. Resultado final desejado

O Ascend deve parecer um produto desenhado intencionalmente para representar evolução pessoal.

A experiência deve transmitir:

- direção, sem rigidez;
- imersão, sem teatralidade;
- progressão, sem manipulação;
- profundidade, sem confusão;
- personalidade, sem cópia;
- beleza, sem prejudicar função.

A assinatura final deve ser:

> Uma cartografia viva da evolução do usuário.

Comece pela auditoria do estado atual. Depois implemente a fundação visual e o vertical slice de Base, Missões e Jornadas. Não expanda o design atual para novas telas.
