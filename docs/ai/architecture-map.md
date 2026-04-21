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
- login and onboarding are now part of the product-critical first-session flow, not just access screens
- product analytics now has a central boundary through:
  - `core/analytics/analytics_service.dart`
  - feature code logs product events through that wrapper instead of calling Firebase Analytics directly
  - `main.dart` now wires the analytics navigation observer so screen-view telemetry can stay centralized
- crash reporting now also has a central boundary through:
  - `core/crash/crash_reporting_service.dart`
  - `main.dart` wires Flutter fatal errors, async zone failures, and Riverpod provider failures into the same reporting path
  - auth now attaches and clears the signed-in user id for crash correlation

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
- the competitive sync repository now prefers backend authority from source payloads:
  - `syncCompetitiveStateFromSource` computes snapshot, exam resolution, and season reward on the server
  - `syncCompetitiveIntegrityFromSource` computes trust score and suspicious-pattern read models on the server
  - the client still keeps a local fallback only for temporary UI continuity when the callable fails
- the seasonal reward claim path now has its own authoritative boundary:
  - `claimSeasonReward` callable performs claim transaction
  - it updates current reward, reward history, permanent season legacy, and active season profile in one server-side flow
  - the Flutter repository now treats backend response as the real write path
- promotion authority is now also moving further into backend callables:
  - `startPromotionExam`
  - `confirmPromotion`
  - promotion flow now treats the callable path as authoritative instead of writing those records directly from the client
- critical competitive state is now less trustful of client-computed read models:
  - snapshot, exam pass/fail resolution, and season reward state now come from backend source evaluation
  - integrity/trust score now comes from backend source evaluation
  - the client primarily sends raw activity and quest evidence, not final competitive decisions
- Firestore rules now treat the competitive collections as backend-written read models:
  - progression
  - promotion exam
  - season reward
  - season legacy/profile
  - integrity
  - weekly boss completions
- weekly boss claim no longer falls back to direct client writes once the callable path is available
- competitive integrity now has its own silent read-model:
  - `competitive_integrity.dart`
  - `watchCurrentIntegrity()`
  - `watchIntegrityHistory()`
  - `syncCompetitiveIntegrity(...)`
- integrity is intentionally informational in v1:
  - it tracks trust score and suspicious patterns
  - it still does not hard-block progression outright
  - it now softly affects prestige and seasonal standing before any hard restriction is applied

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
  - `competitive_quest_authority_repository.dart`
  - `quest_controller.dart`
  - `add_quest_modal.dart`
  - `quest_card.dart`
- starter kit generation is now shared through `starterQuestsForFocus(...)` so onboarding, focus changes, and quest seeding stay aligned
- the first-week loop now has its own domain read-model through:
  - `first_week_journey.dart`
  - Home uses it for a compact onboarding-after-onboarding card
  - Quests uses it to keep the starter week actionable instead of theoretical
- visible payoff messaging now has its own domain read-model through:
  - `progress_payoff.dart`
  - Home uses it to explain next level, next rank, and season reward in one compact block
- seasonal bracket leaderboard now has a backend-fed path through:
  - `getSeasonBracketLeaderboard`
  - `seasonBracketLeaderboardProvider`
  - Rank season UI can prefer bracket standings over only the current boss podium
- bracket rivalry now has its own UI-facing read-model through:
  - `rank_rivalry.dart`
  - Home uses it as a compact tension card
  - Rank season uses it to frame the leaderboard as a chase, not only a score table
- weekly boss and rank arena now prefer competitive activity history and only fall back to general activity when the player has no competitive data yet
- first-production telemetry now covers the main funnel:
  - auth start/cancel/success/failure
  - onboarding completion
  - focus changes
  - starter kit application
  - quest creation, start, and completion
  - suggested-week injection
  - weekly boss claim
  - promotion exam start and confirmation
  - season reward claim
- competitive quest friction now also exposes operational signals through:
  - `competitive_quest_blocked`
  - duplicate template pressure
  - timer/validation/reflection friction
- competitive quest authority now has a backend validation path:
  - `startCompetitiveQuestSession`
  - `verifyCompetitiveQuestCompletion`
  - backend stores session state and authoritative reward grants
  - competitive state/integrity sync can prefer `competitive_quest_grants` over client-only competitive history
- product telemetry should now be read together with:
  - `docs/product/first-week-funnel.md`
  - `docs/product/firebase-operations-dashboard.md`
  - `docs/product/release-checklist.md`
  - Crashlytics fatal and non-fatal errors for first-session and competitive flows

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
