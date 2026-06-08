# Firestore Weekly Boss Setup

## Objetivo

Configurar os documentos do boss semanal no Firestore e manter o resgate de
recompensa sob autoridade do backend Java no Cloud Run.

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
- endpoint Java `POST /api/v1/weekly-boss:claim`

As regras atuais permitem:

- leitura publica dos documentos de `weekly_bosses`
- leitura publica do ranking inicial em `completions`
- escrita autoritativa pelo backend Java com Firebase Admin SDK

As regras atuais bloqueiam:

- alteracao arbitraria do boss semanal pelo app
- edicao ou exclusao de conclusoes
- update de contadores pelo cliente

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

## Backend Java

O app chama `POST /api/v1/weekly-boss:claim` para registrar o clear remoto.
Nao existe fallback TypeScript ou transacao cliente para resgate de recompensa.
Se o backend Java nao estiver configurado, o fluxo deve falhar de forma
explicita durante validacao/desenvolvimento.

### O que o backend valida

- usuario autenticado
- `bossId` existente
- `isActive == true`
- janela ativa (`startsAt <= agora < endsAt`)
- rank enviado bate com rank do boss (quando enviado)
- idempotencia por usuario (nao cria clear duplicado)
- sessao ativa do dispositivo quando a regra exigir

### O que o backend grava

- `weekly_bosses/{bossId}/completions/{uid}`
- incrementa `completedCount`
- `users/{uid}/weekly_boss_claims/{bossId}`
- atualiza `users/{uid}/profile/current`

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
- registra clear remoto pelo backend Java
- mostra um ranking inicial com os primeiros clears sincronizados
- o boss global agora deve ser controlado pelo Firestore. Sem boss remoto ativo, a UI mostra que nao ha evento no momento.

## Proxima fase recomendada

Depois desta base, a proxima etapa e:

- exibir ranking real
- validar elegibilidade no backend usando fonte remota (ex: perfil em Firestore)
- adicionar Cloud Scheduler para rotacao automatica de boss semanal

## Progresso competitivo remoto

O app tambem passou a usar colecoes remotas para o sistema competitivo de rank:

- `users/{uid}/progression/current`
- `users/{uid}/progression_history/{weekKey}`
- `users/{uid}/promotion_exam/current`

Esses documentos agora carregam metadata de sync:

- `syncSchemaVersion`
- `syncSource`

Isso ajuda a manter compatibilidade de leitura enquanto o backend Java mantem a
autoridade das mutacoes sensiveis.
