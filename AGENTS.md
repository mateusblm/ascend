# AGENTS.md

This file provides guidance for AI agents and human contributors working in this repository.

## Project Overview

Ascend is a Flutter mobile app that gamifies daily tasks using an RPG progression system. Users complete quests to earn XP and level up their character, with attribute points distributed across strength, intelligence, vitality, and agility.

Additional source-of-truth documents:
- `docs/product/vision.md`
- `docs/product/roadmap.md`
- `docs/product/progression-architecture.md`
- `docs/product/ux-positioning.md`
- `docs/product/ui-information-architecture.md`
- `docs/ai/development-charter.md`
- `docs/ai/source-of-truth.md`
- `docs/ai/architecture-map.md`
- `docs/ai/change-checklist.md`
- `docs/ai/testing-strategy.md`
- `docs/ai/token-efficiency.md`
- `docs/ai/knowledge-memory-system.md`
- `docs/ai/obsidian-vault-operations.md`
- `docs/ai/prompt-templates.md`
- `docs/ai/retrieval-workflow.md`

## Build And Development Commands

```powershell
# Install dependencies
flutter pub get

# Generate Isar database schemas after modifying @Collection or @embedded models
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run on a specific device
flutter run -d windows
flutter run -d chrome

# Analyze and lint
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart
```

## Tech Stack

- State management: Riverpod with `StateNotifierProvider`
- Local database: Isar
- Authentication: Firebase Auth with Google Sign-In
- UI: Material Design with custom dark theme and Google Fonts

## Architecture

### Directory Structure

```text
lib/
|-- main.dart              # App entry point, Firebase and Isar initialization
|-- core/                  # Shared utilities
|   |-- database/          # Database providers
|   |-- navigation/        # Navigation state
|   `-- theme/             # App colors and theming
`-- features/              # Feature modules
    |-- auth/              # Authentication
    |-- profile/           # Player stats, leveling, attributes
    `-- quests/            # Daily quests and completion flow
```

### Feature Module Pattern

Each feature follows domain and presentation separation:
- `domain/` for models and state classes
- `presentation/` for screens, controllers, and widgets

### State Management Pattern

Controllers use Riverpod providers. The main examples are:
- `authProvider`
- `playerProvider`
- `questProvider`
- `navigationProvider`

### Isar Database

- Models use `@Collection()` with `part '*.g.dart'` for code generation
- Embedded objects use `@embedded`
- Database access is provided through `isarProvider`
- After modifying Isar models, always regenerate with `dart run build_runner build --delete-conflicting-outputs`

## Domain Concepts

- Player: has level, XP, stat points, and 4 attributes
- Quest: daily task with XP reward and associated attribute bonus
- Daily reset: quests reset to incomplete based on `lastResetDate`
- Level up: grants 5 stat points and increases `maxXp` by 20%

## AI Working Rules

- Read the relevant feature files before editing.
- Prefer small, safe changes over broad refactors.
- Treat progression logic, persistence, and auth as sensitive areas.
- Keep reward-bearing and trust-bearing business rules out of the frontend whenever possible.
- Prefer backend-authored facts, aggregates, and read-models over client-owned progression snapshots.
- Do not let the app drift into generic to-do list UX when changing navigation or major screens.
- Prefer progressive disclosure and clear hierarchy over long, repetitive dashboard scrolls.
- Update the docs above when architecture or product behavior changes.
- Do not manually edit generated Isar files.
- Use the AI docs to avoid repeating repo-wide context in every session.
