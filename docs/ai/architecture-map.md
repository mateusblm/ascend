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
- competitive rank now uses a hybrid progression model:
  - level defines the highest rank the player is eligible to attempt
  - weekly maintenance defines whether the current rank is sustained or lost
  - promotion or reconquest still requires a formal exam
- promotion exams and rank history are part of the progression system, not just UI
- the rank screen now reads from dedicated domain summaries and is intentionally split into user-facing sections:
  - `Agora`: status atual, manutencao, proxima subida ou reconquista, exame e evento da semana
  - `Temporada`: trilha mensal, recompensa e placar sazonal
  - `Legado`: pico, titulo sazonal ativo, arquivo de temporadas e historico recente
- the stats screen is now positioned as a supporting analytics view instead of the primary place to explain rank rules
- the rank screen now reads from dedicated domain summaries:
  - `rank_progression.dart`
  - `promotion_exam.dart`
  - `rank_prestige.dart`
  - `rank_season.dart`
  - `rank_season_leaderboard.dart`
  - `season_reward_snapshot.dart`
  - `rank_arena.dart`
- seasonal rank summaries now expose:
  - reward tier and reward status
  - reward track progress and next unlock hint
  - season reset pressure (`resetLabel`)
  - a concrete reward payload:
    - reward name
    - badge label
    - seasonal title label
    - reward package description
- seasonal leaderboard read-model now combines:
  - current bracket
  - season score
  - arena podium
  - rank clear rate
- seasonal reward state is now mirrored remotely in:
  - `users/{uid}/season_rewards/current`
  - `users/{uid}/season_reward_history/{seasonKey}`
- claimed seasonal rewards now generate permanent legacy records in:
  - `users/{uid}/season_legacy/{seasonKey}`
  - `users/{uid}/season_profile/current`
- seasonal reward snapshots now carry claim lifecycle state:
  - `locked`
  - `readyToClaim`
  - `claimed`
- competitive rank snapshots now also track:
  - `peakRank`
  - `highestEligibleRank`
  - `targetRequiredLevel`
  - `targetLevelGateMet`
  - `advancementMode` (`ascension` or `reconquest`)
- seasonal legacy/profile summaries now expose:
  - permanent title label
  - permanent badge label
  - cosmetic frame label
  - cosmetic aura label
- remote competitive writes now carry sync metadata:
  - `syncSchemaVersion`
  - `syncSource`
- the competitive sync repository now applies one guarded remote write path:
  - local batch commit happens first
  - the authoritative callable is best-effort, timeout-bounded, and skipped for debug payloads
- the seasonal reward claim path now has its own authoritative boundary:
  - `claimSeasonReward` callable performs claim transaction
  - it updates current reward, reward history, permanent season legacy, and active season profile in one server-side flow
  - the Flutter repository only falls back to client writes when the callable is unavailable
- competitive integrity now has its own silent read-model:
  - `competitive_integrity.dart`
  - `watchCurrentIntegrity()`
  - `watchIntegrityHistory()`
  - `syncCompetitiveIntegrity(...)`
- integrity is intentionally informational in v1:
  - it tracks trust score and suspicious patterns
  - it does not hard-block progression yet
  - it currently surfaces warnings in Home/Rank before any punitive rule is applied

### Quests
- quest state is exposed through `questProvider`
- quest completion drives XP and attribute rewards
- daily reset behavior depends on the player's `lastResetDate`
- quest progression now has two explicit tracks:
  - `personal` quests keep low-friction habit tracking and still reward XP
  - `competitive` quests use official templates and lightweight verification before they influence rank-facing systems
- competitive quest verification is intentionally narrow in v1:
  - `timer`
  - `timerWithReflection`
- level and rank now have intentionally different trust boundaries:
  - `Level` may continue to grow from both personal and competitive quests
  - competitive rank systems only read validated competitive activity
- only verified competitive quests should advance competitive systems such as:
  - weekly boss progress
  - rank maintenance pressure
  - seasonal competitive standing
  - promotion and reconquest eligibility
- competitive activity is tracked separately in the player model through:
  - `competitiveActivityHistory`
  - `lastCompetitiveQuestCompletionDate`
- current quest-domain primitives for this architecture are:
  - `quest_model.dart`
  - `competitive_quest_template.dart`
  - `quest_controller.dart`
  - `add_quest_modal.dart`
  - `quest_card.dart`
- weekly boss and rank arena now prefer competitive activity history and only fall back to general activity when the player has no competitive data yet

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
- keep the anti-fraud quest model low-friction:
  - official competitive templates first
  - in-app verification first
  - heavier proofs such as health/location/photo only after the base loop proves useful

## Constraints

- do not break Firebase setup by changing Android identifiers casually
- do not edit Isar generated files manually
- do not perform broad directory reshuffles without updating documentation and imports
