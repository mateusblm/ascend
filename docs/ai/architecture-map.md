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
- Android release identity now prefers explicit flavors instead of one placeholder package:
  - `production` -> `com.ascend.mobile`
  - `staging` -> `com.ascend.mobile.staging`
- The app currently uses feature-local controllers with domain and presentation separation.
- Isar is injected through `isarProvider` instead of relying on a global in `main.dart`.

## Critical Systems

### Auth
- initialization happens in `main.dart`
- user state is exposed through `authProvider`
- login and onboarding are now part of the product-critical first-session flow, not just access screens
- account/session controls should now prefer a dedicated account surface instead of being scattered across unrelated tabs
- account access now also has an active-session boundary:
  - one account should keep only one active device session at a time
  - active session registration and refresh now happen through backend callables
  - session conflicts should sign the local device out and return the user to login with a clear error message
- auth state now carries enough user identity for account-facing UI:
  - `uid`
  - `displayName`
  - `photoUrl`
  - `email`
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
- final authority for reward-bearing progression should not live in Flutter:
  - the frontend may start commands and render optimistic UI
  - the backend must own canonical facts, aggregates, and sensitive progression rules
- player profile is no longer device-only:
  - canonical account progress now lives in Firestore at `users/{uid}/profile/current`
  - Isar now acts as a per-user local cache instead of the only source of truth
  - first login after this change migrates an existing local player profile when meaningful progress already exists
  - a fresh device with no meaningful local progress should not create an empty remote profile automatically
- player profile writes are no longer direct client Firestore writes:
  - normal progression now uses backend commands instead of client snapshots:
    - `completePersonalQuest`
    - `revokePersonalQuestCompletion`
    - `verifyCompetitiveQuestCompletion`
    - `allocateAttributePoint`
    - `claimWeeklyBoss`
    - `updateProfileSettings`
  - these commands update `users/{uid}/profile/current` as the account aggregate and return the backend-authored result
  - `syncPlayerProfileFromSource` remains only as migration/repair tooling for old local progress or audited recovery
- the repo should treat command -> fact -> aggregate update as the normal production path:
  - full profile recomputation is no longer the intended steady-state write path
  - if a change tries to reintroduce reward-bearing snapshot writes from Flutter, that change is architecturally wrong
- local player profile now also includes lightweight identity settings:
  - player name is editable through the player controller
  - primary focus can be changed from a dedicated account-management flow
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
- UI surface ownership should now follow the product map in:
  - `docs/product/ux-positioning.md`
  - `docs/product/ui-information-architecture.md`
  - `docs/product/ui-redesign-phases.md`
  - `docs/product/ui-surface-audit.md`
  - intended labels:
    - `BASE`: snapshot, momentum, build identity
    - `QUESTS`: execution
    - `ARENA`: competitive systems
    - `PLANO`: cadence, review, planning, build management
    - `CONTA`: identity and trust controls
- the product direction is intentionally not "to-do list first":
  - quests are input
  - player state and progression are the center of the experience
  - major UI decisions should reinforce build, momentum, rivalry, and payoff
- repeated metrics across screens should be treated carefully:
  - reuse is allowed only when the meaning changes by surface
  - simple duplication of the same block in different tabs is a product smell
- visual hierarchy changes on top-level screens should also pass:
  - `docs/product/ui-smoke-checklist.md`
  - the relevant widget coverage for the touched surface when available
- UI surfaces should prefer progressive disclosure:
  - short strong summary on the top-level tab
  - detail on tap through rows, sheets, or child screens
  - avoid endless same-weight panel stacks as the default solution
- the `Base` screen now follows that rule more explicitly:
  - one identity/progression hero
  - one compact momentum block
  - one build preview
  - secondary reads such as streak, payoff, pulse, rivalry, and weekly event move into detail-sheet entries
- the `Plano` screen now also follows a clearer surface split:
  - one short planning header
  - one weekly-read block
  - one next-step block
  - broader diagnostics and build management move into quieter detail entries
- the `Arena` screen now also follows the redesign split more directly:
  - one dominant competitive summary hero
  - one short directory into `Agora`, `Temporada`, and `Legado`
  - risk, weekly objective, and next gate should be readable before entering a detail view
- the shared visual foundation now has an explicit implementation boundary:
  - `lib/core/theme/app_colors.dart`
  - `lib/core/theme/app_theme.dart`
  - feature screens should prefer these tokens over ad-hoc repeated color/style systems
- cross-screen chrome should now follow the same calmer system:
  - bottom navigation uses sentence-case labels and lighter active emphasis
  - `DetailShellScreen` should match the same neutral surface and border treatment as the top-level tabs
- account and identity management now have their own dedicated screen:
  - `account_screen.dart`
  - it is entered from `Stats`, but it is not a bottom-navigation destination
  - it currently owns:
    - account visibility
    - player-name editing
    - focus-change entry
    - logout
- first-session entry now follows the redesigned lighter surface pattern too:
  - `login_screen.dart` should keep the sign-in promise short and the primary Google action obvious
  - `awakening_onboarding_screen.dart` should center on one first useful action: choose a focus and start the first week
  - `focus_selection_sheet.dart` should stay aligned with the same calmer visual system so post-onboarding focus changes do not feel like an older flow
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
- `users/{uid}/profile/current` should evolve toward a backend-authored aggregate instead of remaining a client-shaped snapshot
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
- quest inventory is no longer device-only:
  - canonical quest continuity now lives in Firestore under `users/{uid}/quests/{questId}`
  - `users/{uid}/quests_meta/current` distinguishes an intentionally empty remote inventory from a not-yet-migrated account
  - Isar now acts as a per-user quest cache instead of the only source of truth
  - first login after this change migrates existing local quests when they exist
- quest inventory writes are no longer direct client Firestore writes:
  - normal personal/competitive completion no longer depends on direct quest inventory sync from the client
  - backend command responses now update the authoritative quest documents directly
  - `syncQuestInventoryFromSource` remains an audited migration/repair path for restoring quest cache state
  - the backend still validates competitive quests against official templates and blocks duplicate open competitive templates
- quest progression now has two explicit tracks:
  - `personal` quests keep low-friction habit tracking and still reward XP
  - `competitive` quests use official templates and lightweight verification before they influence rank-facing systems
- competitive quest verification is intentionally narrow in v1:
  - `timer`
  - `timerWithReflection`
- level and rank now have intentionally different trust boundaries:
  - `Level` is now updated by backend-owned progression commands from both personal and competitive quests
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
- the next competitive architecture target is `Competitive Verification V1`:
  - product source: `docs/product/competitive-verification-v1.md`
  - next-agent brief: `docs/ai/competitive-verification-next-agent.md`
  - evidence contracts, evaluator, richer official templates, and fake/test provider now exist before real Health Connect, Strava, GPS, or AI integrations
  - backend verification now evaluates submitted evidence and writes read-only audit records under `competitive_quest_evidence`
- quest presentation also has two important behavioral guarantees now:
  - `QuestsScreen` keeps a live timer helper through a lightweight time stream instead of frozen `DateTime.now()` text
  - `QuestNotifier._applyCompletion(...)` triggers immediate competitive sync after a verified competitive completion so Rank does not wait only for navigation-level debounce
- competitive quest UI should now avoid duplicate perception:
  - active competitive section only shows unfinished competitive quests
  - completed competitive quests remain in the completed section only
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

## Final Progression Direction

The target production architecture for progression is:

1. frontend issues commands instead of deciding final account outcomes
2. backend writes canonical facts for reward-bearing actions
3. backend updates `profile/current` as the official aggregate
4. backend maintains specialized read-models for competitive systems
5. Isar remains a cache/offline layer, not the final authority

Reference:
- `docs/product/progression-architecture.md`

## Production Readiness Direction

The current architecture priority is to move from "feature-complete prototype" toward "operationally shippable app".

That means upcoming changes should prefer:
- explicit release identity over placeholder defaults
- environment clarity over ad-hoc Firebase usage
- dedicated account/trust surfaces over hidden session actions
- centralized analytics/crash/reporting boundaries over feature-local SDK calls
- release-safe operational controls over permanent reliance on manual hotfixes

Current production-oriented architectural targets:

1. make release identity explicit:
   - package/application id
   - versioning
   - signing path
2. make runtime environment explicit:
   - staging/prod flavor strategy
   - Firebase target clarity
   - deployment discipline
3. keep product trust surfaces first-class:
   - account screen
   - support/privacy entry points
   - clear session visibility
4. keep live-service controls centralized:
   - analytics wrapper
   - crash wrapper
   - future Remote Config / kill-switch boundary
5. validate critical product flows on real devices before treating a release as stable

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
- next high-value hardening target:
  - add explicit automated and smoke coverage for account, auth, and competitive authority flows together
  - confirm backend grant records are the long-term source for competitive activity, not only a transitional overlay
  - define where release/environment configuration should live before broadening the distribution footprint

## Constraints

- do not break Firebase setup by changing Android identifiers casually
- if Android identifiers are changed for release readiness, update Firebase config in the same workstream
- if Android flavors are changed, keep Firebase Android app registrations aligned with each flavor package id
- do not edit Isar generated files manually
- do not perform broad directory reshuffles without updating documentation and imports
