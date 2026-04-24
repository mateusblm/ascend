# Requirements Baseline

## Purpose

Turn Ascend's current product direction into an execution baseline that future work can be measured against.

Use this document when deciding:
- what belongs in scope now
- what must be protected before adding breadth
- which behaviors are product requirements versus implementation details

This document is upstream from:
- `docs/product/project-plan.md`
- `docs/product/roadmap.md`
- `docs/ai/quality-gates.md`

## External Market Signals

These are not product templates to copy. They are current market signals that justify the baseline.

### Signal 1: retention loops work when goals, streaks, and progress are visible

Todoist's official Karma docs emphasize:
- daily goals
- daily and weekly streaks
- points
- level progression
- visual trend graphs

Implication for Ascend:
- the app needs visible short-loop progress
- the user should always understand the next meaningful gain
- streaks and progression must stay easy to read and hard to fake

References:
- https://www.todoist.com/karma
- https://www.todoist.com/help/articles/introduction-to-karma-OgWkWy

### Signal 2: habit products retain better when guidance is gentle but structured

Finch's official product help emphasizes:
- guided onboarding
- themed goal grouping
- rewarding small steps
- streak handling with pause/repair concepts
- a companion identity that grows with the user

Implication for Ascend:
- onboarding should narrow the first useful action
- focus areas should organize behavior, not just decorate it
- identity and emotional attachment should amplify habit loops without becoming noise

References:
- https://help.finchcare.com/hc/en-us/articles/37935669335309-Our-Approach-to-Self-Care
- https://help.finchcare.com/hc/en-us/articles/37780731973133-Self-Care-Areas
- https://help.finchcare.com/hc/en-us/articles/37780736136205-Understanding-Streaks

### Signal 3: competitive loops need anti-abuse posture, not only motivational copy

Duolingo publicly leans on XP, streaks, leagues, and anti-cheating expectations around social competition.

Implication for Ascend:
- personal progress and competitive proof must be separated
- rank-facing rewards cannot trust client-only completion state
- suspicious or low-friction activity should not silently decide competitive outcomes

References:
- https://blog.duolingo.com/duolingo-leagues-leaderboards/
- https://blog.duolingo.com/friend-streak/

### Signal 4: production mobile apps need explicit security and server authority

OWASP MASVS defines the mobile security baseline areas, and Firebase's official docs explicitly position Security Rules as an independent enforcement layer outside the client.

Implication for Ascend:
- auth, storage, network, and authorization need first-class requirements
- reward-bearing and trust-bearing actions must be server-authoritative
- client bugs must not be enough to mint rewards or override account truth

References:
- https://mas.owasp.org/MASVS/
- https://firebase.google.com/docs/rules

### Signal 5: maintainable Flutter apps keep business logic out of widgets and protect critical flows with the test pyramid

Flutter's official architecture and testing docs emphasize:
- views should not contain business logic
- repositories are the source of truth for model data
- use-cases should encapsulate complex cross-repository rules when needed
- strong apps lean on many unit and widget tests, plus targeted integration coverage

Implication for Ascend:
- feature screens should render state, not own reward logic
- repositories and backend-authoritative commands should define the production path
- tests should cluster around progression, sync, auth, and critical UI states

References:
- https://docs.flutter.dev/app-architecture/guide
- https://docs.flutter.dev/testing/overview
- https://docs.flutter.dev/app-architecture/case-study/testing

## Release Baseline Scope

The current release baseline is not "all planned features."

It is:
- a secure account-backed progression app
- with reliable personal and competitive quest loops
- with clear onboarding and next-step guidance
- with market-trust surfaces expected from an externally testable product

It is not yet:
- a wide social platform
- a creator marketplace
- a broad AI product
- a cosmetics-heavy live-service economy

## Functional Requirements

Priority keys:
- `P0`: required before market-facing release confidence
- `P1`: strongly recommended in the current phase window
- `P2`: valuable, but not gating the current baseline

### FR-01 Account and session authority

Priority: `P0`

Requirements:
- users must authenticate through a supported account flow
- one account should have an explicit active-session policy
- the user must be able to see which account is connected
- logout must return the app to a valid signed-out state
- account-backed progress must restore on a second device

### FR-02 Onboarding and first useful action

Priority: `P0`

Requirements:
- onboarding must capture a primary focus or equivalent first-direction signal
- onboarding must create a short starter path instead of dropping the user into an empty shell
- the first useful action after onboarding must be obvious from the UI
- onboarding must not require the user to understand rank rules before they can start

### FR-03 Personal quest loop

Priority: `P0`

Requirements:
- the user must be able to create, view, complete, and revoke personal quests
- personal quests must grant bounded XP and attribute rewards
- personal quests must affect level and streak systems
- personal quests must not directly grant rank-facing competitive credit

### FR-04 Competitive quest loop

Priority: `P0`

Requirements:
- competitive quests must come from official templates or similarly controlled sources
- competitive quests must support server-backed start and completion verification
- verification must enforce mode-specific requirements such as timer and reflection where applicable
- verified competitive completions must refresh rank/integrity-facing reads
- duplicate active competitive templates should be prevented

### FR-05 Progression and player identity

Priority: `P0`

Requirements:
- the user must have visible level, XP, streak, focus, and build identity
- level-up thresholds, rollover, stat points, and stat allocation must be deterministic
- the user must understand the next useful gain from the top-level product surfaces
- titles, achievements, or equivalent identity signals should remain downstream from real effort

### FR-06 Competitive rank and weekly pressure

Priority: `P0`

Requirements:
- rank survival must reflect weekly maintenance rules
- promotion or reconquest must require formal proof, not passive accumulation
- boss requirements must be explicit by rank bracket
- Arena must show current risk, next gate, and current objective before opening deeper detail

### FR-07 Seasonal and historical reads

Priority: `P1`

Requirements:
- the user should be able to understand current seasonal standing
- season rewards, legacy, and historical peak identity should remain readable
- history should inform payoff and rivalry without replacing the core quest loop

### FR-08 Planning and guidance

Priority: `P1`

Requirements:
- the app should help the user decide what to do next this week
- planning surfaces should summarize cadence, not duplicate all progression metrics
- suggested quests or weekly guidance must stay aligned with the user's selected focus

### FR-09 Trust and support surfaces

Priority: `P0`

Requirements:
- the app must expose privacy policy, terms, support, and account-management paths
- the user must be able to understand how to leave the product and how to get help
- account/data deletion policy must be documented even if implementation is staged

### FR-10 Release operations

Priority: `P0`

Requirements:
- staging and production identity must be unambiguous
- release build steps must be repeatable
- critical smoke flows must be defined before a market-facing release candidate
- risky competitive/live-service behavior should have a remote shutoff strategy

## Non-Functional Requirements

### NFR-01 Security and authorization

Priority: `P0`

Requirements:
- use OWASP MASVS as the mobile security baseline
- keep auth, authorization, secure storage, and network protection explicit
- clients must not become the final authority for reward-bearing state
- Firebase Security Rules must default to least privilege and be tested before deploy

### NFR-02 Data consistency and authority

Priority: `P0`

Requirements:
- backend-authored aggregates must be the normal production source of truth for progression
- local Isar data must behave as cache and offline support, not canonical truth
- sync must be scoped per user account
- second-device restore must converge without duplicating stale local state

### NFR-03 Reliability and recoverability

Priority: `P0`

Requirements:
- recoverable remote failures must surface clearly in UX
- critical commands must fail safely without double-granting rewards
- startup, session restore, and remote refresh must avoid invalid partial states

### NFR-04 Testability

Priority: `P0`

Requirements:
- critical business rules must be covered by automated tests
- UI-critical flows should prefer widget tests where possible
- cross-screen persistence-sensitive flows should have targeted integration or manual smoke coverage
- tests should validate behavior, not implementation trivia

### NFR-05 Performance

Priority: `P1`

Requirements:
- screens with live timers or frequent updates should avoid excessive rebuild churn
- list rendering should remain responsive on low-end devices
- heavy sync or recomputation should not occur in frame-critical UI paths

### NFR-06 Accessibility and copy quality

Priority: `P1`

Requirements:
- copy must use production-quality Portuguese where the surface is user-facing
- labels should favor sentence case unless a badge or system token genuinely needs otherwise
- visual emphasis must not be the only carrier of meaning for risk or reward

### NFR-07 Observability

Priority: `P0`

Requirements:
- auth, onboarding, quest, promotion, and weekly boss flows must emit centralized analytics
- critical failures must be visible through centralized crash/non-fatal reporting
- live-service regressions must be diagnosable without reading client logs on a user device

## Explicit Non-Goals For The Current Baseline

The following are out of scope until the release baseline is stable:
- multiplayer guilds or direct PvP
- user-generated quest marketplaces
- broad theming or cosmetic inventory systems
- wide AI copilots across every screen
- deep social feeds or chat systems

## Acceptance Standard

No feature should be called "done" unless:
- it maps to one or more requirements in this document
- its risk tier is known
- its validation path is explicit
- its docs, tests, and source-of-truth boundaries remain aligned
