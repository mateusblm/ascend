# AGENTS.md — Ascend

## Projeto

Ascend é um app Flutter de nivelamento da vida real com quests, XP, atributos, ranking competitivo, boss semanal e progressão inspirada em RPG/anime.

O projeto usa:
- Flutter
- Riverpod
- Isar
- Firebase Auth
- Cloud Firestore
- Java 21
- Spring Boot
- Maven
- Docker
- Google Cloud Run
- Cloud Run como backend Java autoritativo

## Regra central

O frontend Flutter nunca deve ser fonte final de verdade para:
- XP competitivo
- ranking
- promoções
- boss semanal
- recompensas sensíveis
- antiabuso

Essas regras devem ser validadas no backend autoritativo. O alvo principal é o backend Java em Spring Boot publicado no Cloud Run. Não criar novos fallbacks TypeScript.

## Agentes especializados

Antes de trabalhar, escolha o agente adequado:

### PO Agent
Use quando a tarefa envolver:
- definição de feature;
- priorização;
- regra de negócio;
- MVP;
- critérios de aceite;
- roadmap;
- experiência do usuário.

Leia:
`docs/agents/po-agent.md`

### Dev Agent
Use quando a tarefa envolver:
- implementação;
- arquitetura;
- Flutter;
- Java;
- Spring Boot;
- DDD;
- Riverpod;
- Isar;
- Firebase;
- Cloud Run;
- Cloud Functions removido do projeto local;
- refatoração;
- correção de bug.

Leia:
`docs/agents/dev-agent.md`

### QA Agent
Use quando a tarefa envolver:
- testes;
- bugs;
- regressão;
- ranking;
- XP;
- recompensa;
- abuso/trapaça;
- smoke test;
- critérios de release.

Leia:
`docs/agents/qa-agent.md`

### Game Design Agent
Use quando a tarefa envolver:
- quests;
- ranks;
- boss semanal;
- progressão;
- nomes;
- fantasia RPG/anime;
- retenção;
- diferenciação;
- monetização.

Leia:
`docs/agents/game-design-agent.md`

### Orchestrator Agent
Use quando a tarefa envolver uma feature completa do início ao fim, especialmente quando juntar produto, backend, frontend e regra de jogo. Para bugs pequenos, fatias simples de migração ou ajustes localizados, prefira usar apenas os agentes especializados necessários.

Leia:
`docs/agents/orchestrator-agent.md`

## Fluxo obrigatório

Para qualquer feature relevante:

1. Definir objetivo de produto.
2. Definir regras de negócio.
3. Definir fronteira frontend/backend.
4. Definir riscos de abuso.
5. Definir testes.
6. Implementar menor mudança segura.
7. Rodar validação.

## Comandos de validação

Antes de finalizar mudanças Flutter:

```bash
flutter analyze
flutter test
```

Antes de finalizar mudanças Java:

```bash
cd backend
mvn test
mvn package
```

Para testar o backend Java local com Docker:

```powershell
.\tools\backend\start-local-docker.ps1
```

Para testar o app Android apontando para o backend Java local:

```powershell
flutter run --dart-define=ASCEND_JAVA_BACKEND_URL=http://10.0.2.2:8080
```

Para testar o app Android apontando para Cloud Run:

```powershell
flutter run --flavor staging --dart-define=ASCEND_JAVA_BACKEND_URL=https://ascend-backend-staging-331143433117.southamerica-east1.run.app
```
