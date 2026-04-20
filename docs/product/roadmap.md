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
