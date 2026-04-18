# Firestore Weekly Boss Setup

## Objetivo

Adicionar uma camada remota para o boss semanal por rank sem substituir o sistema local do app.

## Dependencia

O projeto agora usa `cloud_firestore`.

Rode:

```powershell
flutter pub get
```

## Regras de seguranca

O repositorio agora possui:

- `firestore.rules`
- `firebase.json`
- `functions/` com callable `claimWeeklyBoss`

As regras atuais permitem:

- leitura publica dos documentos de `weekly_bosses`
- leitura publica do ranking inicial em `completions`
- escrita segura pelo app (transacao create completion + update completedCount)
- escrita pelo backend (Cloud Functions com Admin SDK), quando disponivel

As regras atuais bloqueiam:

- alteracao arbitraria do boss semanal pelo app
- edicao ou exclusao de conclusoes
- update de contadores fora da transacao valida

### Publicar regras

Opcao 1, pelo Firebase CLI:

```powershell
npm install -g firebase-tools
firebase login
firebase deploy --only firestore:rules --project ascend-b7c20
```

Opcao 2, pelo Firebase Console:

- abra `Firestore Database`
- va em `Rules`
- cole o conteudo de `firestore.rules`
- clique em `Publish`

## Backend (Cloud Functions)

O app agora chama a callable `claimWeeklyBoss` para registrar clear remoto.
Se a callable nao estiver deployada (ex: projeto sem Blaze), o app usa fallback automatico para transacao cliente com as rules atuais.

### Estrutura criada

- `functions/package.json`
- `functions/tsconfig.json`
- `functions/src/index.ts`

### Deploy da callable

No terminal, na raiz do projeto:

```powershell
cd functions
npm install
npm run build
cd ..
firebase deploy --only functions --project ascend-b7c20
```

> Observacao: Cloud Functions exige plano Blaze. Sem Blaze, mantenha apenas as rules publicadas e use o fallback cliente ja implementado no app.

### O que a callable valida

- usuario autenticado
- `bossId` existente
- `isActive == true`
- janela ativa (`startsAt <= agora < endsAt`)
- rank enviado bate com rank do boss (quando enviado)
- idempotencia por usuario (nao cria clear duplicado)

### O que a callable grava

- `weekly_bosses/{bossId}/completions/{uid}`
- incrementa `completedCount`
- incrementa `participantCount`

## Colecao inicial

Crie a colecao:

`weekly_bosses`

Cada documento pode representar um boss semanal ativo para um rank.

Exemplo de documento:

```json
{
  "rank": "E",
  "isActive": true,
  "title": "Primeira Ruptura",
  "description": "Fique ativo em 4 dias da semana para provar que voce merece subir de rank.",
  "targetActiveDays": 4,
  "rewardXp": 120,
  "rewardStatPoints": 2,
  "participantCount": 0,
  "completedCount": 0,
  "startsAt": "server timestamp",
  "endsAt": "server timestamp"
}
```

Sugestao de id:

`2026w16_rankE`

## Query usada pelo app

O app busca:

- leitura de `weekly_bosses` (limitado) e filtro local por rank normalizado (`trim + uppercase`)
- filtro local `isActive == true`
- filtro local de janela ativa por data (`startsAt <= agora < endsAt`)
- `limit(50)` com selecao do primeiro boss valido

Isso significa que:

- para cada rank, deve existir no maximo um boss ativo por vez
- `isActive` deve estar `true` no boss atual
- `startsAt` e `endsAt` devem estar corretos, pois fazem parte da validacao ativa

## O que o app ja faz

- calcula o progresso localmente pelos dias ativos da semana
- usa Firestore para ler o boss remoto do rank
- mostra `completedCount` e `participantCount` quando existir boss remoto
- registra clear remoto pela callable `claimWeeklyBoss`
- mostra um ranking inicial com os primeiros clears sincronizados
- o boss global agora deve ser controlado pelo Firestore. Sem boss remoto ativo, a UI mostra que nao ha evento no momento.

## Proxima fase recomendada

Depois desta base, a proxima etapa e:

- exibir ranking real
- validar elegibilidade no backend usando fonte remota (ex: perfil em Firestore)
- adicionar Cloud Scheduler para rotacao automatica de boss semanal
