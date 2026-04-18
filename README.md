# Ascend

Ascend e um app mobile em Flutter que transforma tarefas diarias em progresso de RPG. O usuario conclui quests, ganha XP, sobe de nivel e distribui pontos entre forca, inteligencia, vitalidade e agilidade.

## Stack

- Flutter
- Riverpod com `StateNotifierProvider`
- Isar para persistencia local
- Firebase Auth com Google Sign-In
- Google Fonts e UI customizada em tema escuro

## Estrutura

```text
lib/
├── core/
│   ├── database/
│   ├── navigation/
│   └── theme/
├── features/
│   ├── auth/
│   ├── profile/
│   └── quests/
└── main.dart
```

## Como rodar

```powershell
flutter pub get
flutter run
```

Para escolher um dispositivo:

```powershell
flutter devices
flutter run -d android
flutter run -d windows
flutter run -d chrome
```

## Comandos uteis

```powershell
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
```

## Regras de negocio principais

- Quests concluidas concedem XP e aumento em um atributo ligado a recompensa.
- Ao subir de nivel, o jogador recebe 5 pontos para distribuir manualmente.
- O XP maximo cresce 20% a cada level up.
- As quests sao resetadas diariamente com base em `lastResetDate`.

## Pontos de atencao

- O Android atual usa `com.example.ascend` porque o `google-services.json` esta configurado para esse package.
- Se modelos do Isar forem alterados, rode o `build_runner` antes de executar o app.
