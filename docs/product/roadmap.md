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

## Current Build Priority

The current implementation priority should be:

1. competitive rank loop stabilization
2. tests for rank, exam, demotion, and weekly boss logic
3. home/rank/stats polish around progression identity
4. leaderboard and season depth
5. guided growth and AI planner integration

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

Recommended next production steps:

- deploy the new Functions and Firestore rules for competitive quest authority
- run a real-device smoke test for:
  - start competitive session
  - early completion rejection
  - valid completion after minimum time
  - authoritative grant creation
  - rank/integrity refresh after completion
- add automated coverage for the new authority path:
  - callable validation
  - duplicate grant prevention
  - UI reaction after successful grant
- decide whether personal XP should remain local indefinitely or move to a softer server-audited model later
