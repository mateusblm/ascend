# Plano de migracao para PostgreSQL

## Objetivo

Transformar o PostgreSQL no banco autoritativo do Ascend, mantendo o Firebase apenas para autenticacao enquanto for util. O Firestore deve deixar de guardar regras de jogo, progresso, quests, sessoes e resgates.

## Estado atual

- O backend Java Spring Boot ja possui dependencias de JDBC, PostgreSQL e Flyway.
- O `compose.yaml` sobe `ascend-postgres` junto com `ascend-backend`.
- A migration `V1__criar_nucleo_jogo.sql` cria o nucleo relacional do jogo.
- Os repositorios de negocio ainda usam Firestore em parte do fluxo.

## Fases

### 1. Fundacao do banco

- Criar schema inicial via Flyway.
- Subir PostgreSQL local no Docker.
- Validar boot do backend aplicando migrations.

### 2. Usuarios e sessoes

- Persistir usuario autenticado na tabela `usuarios`.
- Trocar sessao ativa para `sessoes_ativas`.
- Manter mensagens de erro em portugues e regras importantes documentadas em Javadoc.

### 3. Perfil e progressao

- Migrar perfil, XP, nivel, atributos, streak e metadados para `perfis_jogador`.
- Garantir que o backend continue sendo a fonte autoritativa de recompensas.
- Cobrir subida de nivel, alocacao de atributos e sincronizacao de perfil com testes.

### 4. Quests pessoais

- Migrar inventario de quests para `quests`.
- Migrar conclusoes para `conclusoes_quest`.
- Garantir idempotencia: concluir a mesma quest novamente nao deve duplicar XP.
- Corrigir o fluxo em que uma quest concluida permanece em "A fazer".

### 5. Eventos de recompensa

- Registrar recompensas em `eventos_xp`.
- Usar eventos para auditoria e recomputacao futura de progresso.
- Evitar snapshots inconsistentes entre quest, perfil e historico.

### 6. Boss pessoal semanal

- Migrar resgates para `resgates_boss_pessoal_semanal`.
- Garantir um unico resgate por usuario e semana.
- Manter o boss como desafio pessoal, sem depender de competitivo.

### 7. Remocao do Firestore de jogo

- Remover repositorios Firestore substituidos.
- Remover configuracoes e permissoes que existiam apenas para dados de jogo.
- Atualizar docs e comandos de desenvolvimento.

## Regra de corte

Como o app ainda nao foi lancado, podemos resetar dados e evitar scripts complexos de migracao historica. O foco e deixar o modelo correto para a primeira versao publica.
