# Ascend Roadmap

## Product Goal

Turn Ascend from a simple gamified habit tracker into a retention-focused progression product with a clear path to monetization.

## Phase 1: Foundation

Goal:
- stabilize the codebase and define product direction

Deliverables:
- clear product vision
- AI development guardrails
- updated engineering instructions
- architecture cleanup around app state and persistence
- basic tests for player progression and quest logic

Success criteria:
- contributors and AI agents can safely work in the repo
- core progression rules are protected by tests

## Phase 2: Retention

Goal:
- make users want to come back every day

Deliverables:
- daily streaks
- weekly completion score
- historical XP and attribute charts
- reset-safe progress summaries
- better onboarding with objective selection

Success criteria:
- app has stronger daily and weekly loops
- user can understand progress over time

## Phase 3: Progression Depth

Goal:
- make the game layer feel meaningful

Deliverables:
- titles and achievement improvements
- classes or builds
- talent or specialization system
- weekly bosses or milestone challenges
- reward economy for unlocks and cosmetics

Success criteria:
- character progression feels deeper than simple XP gain
- users can develop identity and attachment

## Phase 4: Guided Growth

Goal:
- make the app actively useful, not just reactive

Deliverables:
- journey templates such as study, fitness, focus, or health
- AI-assisted quest suggestions
- weekly planning and review flow
- adaptive difficulty for quests

Success criteria:
- user can start with a goal and receive structure
- app helps maintain momentum, not just record actions

## Phase 5: Monetization and Distribution

Goal:
- prepare the app for real product validation

Deliverables:
- premium feature boundary
- app branding and polished onboarding
- analytics events for retention funnel
- release checklist and store preparation

Success criteria:
- product has a credible premium offer
- app is ready for early user validation

## Current Strategic Shift: Production Readiness

The next major goal is not more feature breadth. It is turning the current build into something that behaves like a real product in the hands of real users.

This means the main execution focus should now be:
- release identity instead of prototype defaults
- operational reliability instead of feature expansion
- market trust surfaces instead of internal-only polish
- backend-owned progression architecture instead of frontend-owned reward rules

## Final Progression Architecture

Goal:
- make account progression secure, consistent across devices, and cheap to read

Deliverables:
- canonical progression facts persisted by the backend
- backend-authored `profile/current` aggregate
- backend-authored command paths for:
  - personal quest completion
  - personal quest revocation
  - attribute allocation
  - weekly boss claim
- client snapshots downgraded to migration/repair tooling instead of normal truth
- local Isar persistence treated as cache/offline support, not final account authority

Success criteria:
- reward-bearing business rules no longer depend on Flutter controllers as final authority
- level/xp/stat/streak state converges across devices through backend-authored aggregates
- recomputation of the whole profile is not the normal production write path

## Production Readiness Program

### Block 1: Release Identity and Environment Separation

Goal:
- remove prototype signals and make release artifacts safe to ship

Deliverables:
- definitive Android package/application id instead of example identity
- explicit Firebase environment strategy (`staging` and `prod`) or a consciously documented single-project release policy
- release signing and versioning discipline
- real app branding package:
  - app name
  - launcher icon
  - splash treatment
  - store-safe metadata
- release build path documented and repeatable

Success criteria:
- no production build ships with placeholder identity
- Firebase target and release artifact are unambiguous before deployment
- the app looks and installs like a product, not a dev shell

### Block 2: Operational Hardening

Goal:
- trust critical flows under real-world usage, not only under local validation

Deliverables:
- real-device smoke-test matrix covering:
  - login
  - onboarding
  - personal quest completion
  - competitive quest start and verification
  - rank/integrity refresh
  - account access and logout
  - session restoration after app restart
- stronger automated protection for production-critical UI and backend flows
- release-candidate validation discipline using:
  - `docs/product/release-checklist.md`
  - `docs/product/firebase-operations-dashboard.md`
  - `docs/product/first-week-funnel.md`
- Remote Config / feature-flag / kill-switch direction for risky competitive or live-service behavior
- operational alerting expectations for auth, funnel drop, callable failure, and crash spikes

Success criteria:
- critical user journeys are validated both automatically and on a real device
- release regressions are easier to detect before users report them
- live operations can react without emergency code edits where possible

### Block 3: Market Trust and Store Readiness

Goal:
- close the trust gaps that matter when strangers install the app

Deliverables:
- dedicated account surface for session and identity controls
- privacy policy and terms links
- support/contact path inside the product
- account/data deletion policy and implementation plan
- store-readiness package:
  - screenshots
  - description
  - onboarding copy review
  - closed-test distribution plan

Success criteria:
- the app has the minimum trust surface expected from a market-facing product
- users can understand who they are signed in as, how to leave, and how to get help
- the product is credible enough for staged external testing

## Current Build Priority

The current implementation priority should be:

1. competitive rank loop stabilization
2. tests for rank, exam, demotion, and weekly boss logic
3. home/rank/stats polish around progression identity
4. leaderboard and season depth
5. guided growth and AI planner integration

Current production priority above the roadmap queue:

1. release identity and Firebase environment separation
2. real-device smoke testing and release hardening
3. market trust surfaces:
   - account
   - privacy/support
   - store readiness
4. only then resume broader progression and guided-growth expansion

## Current Competitive Track

The current active product track is the competitive RPG layer:

- rank maintenance and demotion
- promotion exam flow
- weekly rank history
- seasonal rank summary
- prestige and reputation signals
- rank arena event read-model
- sync metadata for remote competitive state

Near-term follow-up deliverables:

- stronger boss leaderboard and rank arena feel
- backend-authoritative competitive rules
- seasonal reset and season rewards
- widget/integration coverage for competitive UI flows
- seasonal reward track surfaced in Rank UI with reset pressure and unlock pacing
- seasonal leaderboard surfaced in Rank UI with podium, bracket score, and clear-rate pressure
- concrete seasonal reward package surfaced in Rank UI with badge/title/payoff instead of generic preview text
- seasonal reward state mirrored to Firestore for future authoritative rewards, archives, and season history
- seasonal reward claim state surfaced in Rank UI with real resgate flow and remote archive
- seasonal claim upgraded toward an authoritative backend path with permanent title, badge, and visual legacy records
- active seasonal legacy surfaced in Home and Rank so claimed seasons become visible identity, not just stored data
- rank progression now moving toward a hybrid model:
  - level gates upward eligibility
  - weekly maintenance prevents or causes demotion
  - peak rank enables accelerated reconquest instead of treating returning players like full beginners
- rank UI reorganized around three user-facing layers instead of one long technical panel:
  - Agora
  - Temporada
  - Legado
- stats UI repositioned as support for numbers and planning, not as the main place to explain rank rules
- competitive quest architecture split:
  - personal quests stay flexible and low-friction
  - official competitive templates now act as the trustworthy path into rank, boss, and season systems
- lightweight verification track introduced for competitive quests:
  - timer
  - timer plus short reflection
- competitive activity now has its own history so future anti-fraud systems can evolve without breaking the casual quest loop
- competitive progression rule clarified:
  - personal quests may still increase `Level`
  - promotion, boss progress, and seasonal competitive standing only advance from validated competitive activity
  - personal quests now belong to a lighter XP lane than official competitive templates

Next hardening steps for quest integrity:

- expand automated coverage for the new quest verification flow
- add trust-scoring and suspicious-pattern detection before heavier proof systems
- keep health/location/photo verification as later layers, not v1 defaults

Current anti-abuse layer now includes:

- official competitive templates
- lightweight competitive verification
- level/rank trust split
- lighter XP lane for personal quests
- silent competitive trust score with suspicious-pattern tracking

Current onboarding/product polish direction:

- onboarding now needs to explain the first week through action, not theory
- the first session should show:
  - chosen focus
  - starter kit preview
  - what affects level
  - what affects rank
- the first week should feel guided before the app asks the user to understand deeper systems
- after onboarding, Home and Quests should keep that guidance alive through:
  - a compact first-week loop
  - a visible next-payoff summary
  - one obvious next action

Current backend-authoritative follow-up:

- promotion exam start should prefer a callable backend path
- promotion confirmation should prefer a callable backend path
- critical competitive collections should behave as backend-written read models
- client fallback should shrink in the competitive layer instead of remaining the default
- weekly boss remote claim should stay backend-only
- seasonal bracket leaderboard should move toward backend-fed standings instead of only local boss podium reads
- competitive snapshot sync should be computed from raw source payloads on the backend
- competitive integrity sync should be computed from raw source payloads on the backend

Current competitive trust direction:

- trust score now starts to matter softly:
  - prestige can be downgraded by weak integrity
  - seasonal standing can be flagged as under review
- hard restrictions should come later, after calibration against real player behavior

Queued after the current backend-hardening phase:

- surface global bracket rivalry more aggressively in Home and Rank
- calibrate when trust score only signals versus when it actually limits standing or rewards
- add a more ceremonial season closeout and reward reveal
- deepen the daily return loop now that first-week guidance is in place

Recent follow-through:

- Home and Rank now expose a compact rivalry layer from the global bracket leaderboard
- the product is starting to talk in terms of chase and pressure, not only placement and score
- first-production telemetry now exists for the main funnel:
  - auth entry
  - onboarding completion
  - starter kit application
  - quest creation, start, and completion
  - weekly boss claim
  - promotion start and confirmation
  - season reward claim
- crash reporting is now part of the production baseline:
  - Flutter framework errors
  - async zone errors
  - Riverpod provider failures
  - signed-in user context attached through auth state
- the first-week funnel is now explicitly documented in:
  - `docs/product/first-week-funnel.md`
- Firebase operational reading now has its own guide in:
  - `docs/product/firebase-operations-dashboard.md`
- release discipline now has its own guide in:
  - `docs/product/release-checklist.md`
- competitive quest authority now has a more serious production boundary:
  - session start is registered in backend
  - completion creates an authoritative competitive grant in backend
  - sync paths can prefer server grant history over client-reported competitive dates
- quest UX and sync follow-through were also tightened:
  - the quest timer helper in Quests now refreshes live while a competitive session is running
  - completed competitive quests no longer appear duplicated in both the active competitive section and the completed section
  - competitive quest completion now triggers immediate competitive sync instead of waiting only for navigation debounce
- the latest competitive authority rollout has now been operationalized:
  - `functions` and `firestore.rules` were deployed to the active Firebase project
  - backend authority coverage now includes session start, early rejection, valid completion grant, and duplicate-grant protection
- account surface is now moving toward market-readiness instead of hiding session controls inside a stats-only action:
  - a dedicated account screen now exists for identity and session management
  - name editing, focus change, connected-account visibility, and logout now live behind that dedicated surface

Recommended next production steps:

- finish release identity work:
  - replace prototype package identity
  - define staging/prod Firebase policy
  - lock release versioning/signing flow
- run a real-device smoke test for:
  - account entry
  - name update
  - focus change
  - logout and session restore
  - start competitive session
  - early completion rejection
  - valid completion after minimum time
  - authoritative grant creation
  - rank/integrity refresh after completion
- add release-hardening coverage for:
  - account screen flows
  - login/logout/session restore
  - verified competitive quest happy path in UI
- define production trust surfaces:
  - privacy policy
  - support/contact path
  - account/data deletion policy
- decide whether personal XP should remain local indefinitely or move to a softer server-audited model later
