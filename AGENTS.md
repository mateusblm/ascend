# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Ascend is a Flutter mobile app that gamifies daily tasks using an RPG progression system. Users complete quests to earn XP and level up their character, with attribute points distributed across strength, intelligence, vitality, and agility.

## Build & Development Commands

```powershell
# Install dependencies
flutter pub get

# Generate Isar database schemas (required after modifying @Collection or @embedded models)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run on specific device
flutter run -d windows
flutter run -d chrome

# Analyze/lint code
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart
```

## Tech Stack

- **State Management**: Riverpod with `StateNotifierProvider` pattern
- **Local Database**: Isar (NoSQL) with code generation
- **Authentication**: Firebase Auth with Google Sign-In
- **UI**: Material Design with custom dark theme, Google Fonts (Orbitron)

## Architecture

### Directory Structure
```
lib/
├── main.dart              # App entry point, Firebase/Isar initialization
├── core/                  # Shared utilities
│   ├── navigation/        # Navigation state (Riverpod provider)
│   └── theme/             # AppColors and theming
└── features/              # Feature modules
    ├── auth/              # Authentication (Firebase/Google)
    ├── profile/           # Player stats, leveling, attributes
    └── quests/            # Daily quests/tasks system
```

### Feature Module Pattern
Each feature follows domain/presentation separation:
- `domain/` - Models, state classes (e.g., `player_model.dart`, `auth_state.dart`)
- `presentation/` - Screens, controllers (Riverpod notifiers), widgets

### State Management Pattern
Controllers use Riverpod's `StateNotifierProvider`:
```dart
final playerProvider = StateNotifierProvider<PlayerNotifier, Player>((ref) => ...);
```

### Isar Database
- Global `isar` instance declared in `main.dart`
- Models use `@Collection()` annotation with `part '*.g.dart'` for codegen
- Embedded objects use `@embedded` annotation
- **After modifying Isar models, always regenerate with `dart run build_runner build`**

### Key Providers
- `authProvider` - Authentication state (AuthController)
- `playerProvider` - Player stats and leveling (PlayerNotifier)
- `questProvider` - Quest list and completion (QuestNotifier)
- `navigationProvider` - Bottom navigation tab index

## Domain Concepts

- **Player**: Has level, XP, stat points, and 4 attributes (STR/INT/VIT/AGI)
- **Quest**: Daily task with XP reward and associated attribute bonus
- **Daily Reset**: Quests reset to incomplete at midnight (checked on app init)
- **Level Up**: Triggers at XP threshold, grants 5 stat points, increases maxXP by 20%
