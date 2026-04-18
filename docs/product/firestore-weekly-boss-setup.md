# Firestore Weekly Boss Setup

## Objetivo

Adicionar uma camada remota para o boss semanal por rank sem substituir o sistema local do app.

## Dependencia

O projeto agora usa `cloud_firestore`.

Rode:

```powershell
flutter pub get
```

## Colecao inicial

Crie a colecao:

`weekly_bosses`

Cada documento pode representar um boss semanal ativo para um rank.

Exemplo de documento:

```json
{
  "rank": "E",
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
- `startsAt <= agora`
- `endsAt > agora`
- `limit(1)`

Isso significa que:

- para cada rank, deve existir no maximo um boss ativo por vez
- `startsAt` e `endsAt` precisam estar preenchidos corretamente

## O que o app ja faz

- calcula o progresso localmente pelos dias ativos da semana
- usa Firestore para ler o boss remoto do rank
- mostra `completedCount` e `participantCount` quando existir boss remoto
- continua funcionando com fallback local se nao houver boss remoto

## Proxima fase recomendada

Depois desta base, a proxima etapa e:

- registrar conclusao em uma subcolecao
- usar timestamp do servidor
- exibir ranking real
- adicionar regras de seguranca e, depois, Cloud Functions
