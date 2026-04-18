# Ascend Cloud Functions

## Callable implementada

- `claimWeeklyBoss` (`southamerica-east1`)

## Payload esperado

```json
{
  "bossId": "2026w16_rankE",
  "displayName": "Mateus",
  "photoUrl": "https://...",
  "rankAtCompletion": "E"
}
```

## Respostas

- `{ "status": "claimed" }`
- `{ "status": "already_completed" }`

## Executar localmente

```powershell
cd functions
npm install
npm run build
```

## Deploy

```powershell
cd ..
firebase deploy --only functions --project ascend-b7c20
```
