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

As regras atuais permitem:

- leitura publica dos documentos de `weekly_bosses`
- leitura publica do ranking inicial em `completions`
- criacao de uma conclusao apenas pelo proprio usuario autenticado
- incremento de `completedCount` somente quando a mesma transacao cria a conclusao do usuario

As regras atuais bloqueiam:

- alteracao arbitraria do boss semanal pelo app
- edicao ou exclusao de conclusoes
- duplicidade de clear para o mesmo usuario no mesmo boss

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

- `rank == rank do jogador`
- `isActive == true`
- `limit(1)`

Isso significa que:

- para cada rank, deve existir no maximo um boss ativo por vez
- `isActive` deve estar `true` no boss atual
- `startsAt` e `endsAt` podem continuar existindo como metadado do evento

## O que o app ja faz

- calcula o progresso localmente pelos dias ativos da semana
- usa Firestore para ler o boss remoto do rank
- mostra `completedCount` e `participantCount` quando existir boss remoto
- registra o clear remoto em `weekly_bosses/{bossId}/completions/{uid}` quando o boss e resgatado
- incrementa `completedCount` no documento do boss
- mostra um ranking inicial com os primeiros clears sincronizados
- o boss global agora deve ser controlado pelo Firestore. Sem boss remoto ativo, a UI mostra que nao ha evento no momento.

## Proxima fase recomendada

Depois desta base, a proxima etapa e:

- usar timestamp do servidor
- exibir ranking real
- adicionar validacao mais forte e, depois, Cloud Functions
