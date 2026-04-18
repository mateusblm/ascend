# Ascend Architecture Map

## Current Architecture

Ascend is a Flutter application organized by feature area.

Current high-level structure:

```text
lib/
|-- core/
|   |-- database/
|   |-- navigation/
|   `-- theme/
|-- features/
|   |-- auth/
|   |-- profile/
|   `-- quests/
`-- main.dart
```

## Active Technical Decisions

- Riverpod is the state management solution.
- Isar is the local persistence layer.
- Firebase Auth provides authentication.
- The app currently uses feature-local controllers with domain and presentation separation.
- Isar is injected through `isarProvider` instead of relying on a global in `main.dart`.

## Critical Systems

### Auth
- initialization happens in `main.dart`
- user state is exposed through `authProvider`

### Player Progression
- player state is exposed through `playerProvider`
- leveling, XP, stat points, and attribute growth are product-critical rules
- competitive rank state is mirrored remotely through Firestore progression snapshots
- promotion exams and rank history are part of the progression system, not just UI
- the rank screen now reads from dedicated domain summaries:
  - `rank_progression.dart`
  - `promotion_exam.dart`
  - `rank_prestige.dart`
  - `rank_season.dart`
  - `rank_arena.dart`
- remote competitive writes now carry sync metadata:
  - `syncSchemaVersion`
  - `syncSource`

### Quests
- quest state is exposed through `questProvider`
- quest completion drives XP and attribute rewards
- daily reset behavior depends on the player's `lastResetDate`

## Architectural Direction

The preferred direction for upcoming work is:

1. keep feature-first organization
2. remove implicit coupling between features where reasonable
3. move toward repository boundaries for auth, player, and quests
4. protect domain rules with tests before deep refactors
5. keep UI-specific behavior out of domain models

## Near-Term Refactor Targets

- introduce repositories for player and quest persistence
- separate business rules from persistence details
- reduce synchronous database work in UI-driven flows
- add tests for progression and reset logic
- move competitive progression toward a more authoritative remote boundary over time
- keep rank, exam, season, and prestige rules in domain helpers instead of scattering them in widgets
- keep remote competitive writes constrained to one repository sync path (`syncCompetitiveState`)

## Constraints

- do not break Firebase setup by changing Android identifiers casually
- do not edit Isar generated files manually
- do not perform broad directory reshuffles without updating documentation and imports
