# Competitive Verification V1

## Purpose

Define the next product implementation track for competitive quests: make Arena progress depend on evidence, not trust-only completion.

This is the main product direction after the internal release-candidate work was paused for deeper gameplay value. The app can stay pre-device and pre-public-launch while this architecture is built and tested.

Status: `partially_implemented`

Implemented on `2026-04-25`:
- Dart evidence domain and pure evaluator
- richer official competitive quest catalog for running, focus, reading, workout, and study
- deterministic mock evidence for pre-device development and tests
- backend evidence evaluator inside competitive verification authority
- backend evidence audit records in `competitive_quest_evidence`
- Firestore read-only client rules for evidence audit records
- domain, backend, and rules tests for valid evidence, missing evidence, impossible pace, and read/write boundaries

Still future:
- real Health Connect adapter
- real Strava adapter
- real AI reading quiz generation
- full UI for manual/provider evidence details
- duplicate source-activity checks against historical provider ids

## Product Problem

Competitive quests are the highest-trust part of Ascend. If a player can claim rank-bearing running, reading, study, or workout quests with no meaningful proof, the Arena loses value.

Current competitive verification is useful as a backend authority baseline, but too narrow:
- timer
- timer with reflection

That is not enough for the long-term product promise.

## Design Principles

- Backend decides rank-bearing outcomes.
- Flutter collects evidence and renders state; it does not grant competitive authority.
- Start with fake/testable providers before real device/API integrations.
- Prefer structured evidence over ornamental copy.
- Avoid blocking implementation on real devices while the domain contract is still immature.
- Treat fraud prevention as risk reduction, not perfect proof.
- Make each quest template declare what evidence it needs.

## Trust Tiers

| Tier | Evidence | Competitive Use |
| --- | --- | --- |
| 0 | self report only | personal progress only; not rank-bearing |
| 1 | in-app timer or reflection | low-stakes competitive progress |
| 2 | structured evidence payload | normal competitive progress |
| 3 | provider-backed evidence, such as Health Connect or Strava | higher-confidence competitive progress |
| 4 | multi-source evidence plus reputation | future high-stakes seasons and exams |

## Evidence Types

Initial domain should support these types even if only fake/local providers exist at first:

- `timedFocus`: start/end/duration, interruption count, optional reflection.
- `runningDistance`: distance, duration, source activity id, optional route hash.
- `readingComprehension`: book metadata, claimed pages or minutes, generated quiz answers, score.
- `workoutSession`: duration, movement category, optional provider session id.
- `studySession`: duration, topic, review answers or recall prompt.

## Evidence Providers

V1 implementation should include:
- `manual`: low-trust fallback for non-rank or low-rank quests.
- `appTimer`: current in-app timer path, formalized as evidence.
- `mockEvidence`: deterministic provider for tests and development.

Later adapters:
- `healthConnect`: Android exercise sessions, route data only when permission and user consent allow it.
- `strava`: OAuth activity import and webhook-based refresh.
- `aiReadingQuiz`: generated comprehension check from user-declared book/topic.

Do not start V1 by integrating Health Connect, Strava, or AI. Build the contract, evaluator, catalog, and tests first.

## Domain Model Sketch

Suggested names can change, but the concepts should remain.

```text
CompetitiveQuestTemplate
- id
- title
- category
- rankWeight
- verificationRequirement
- reward

VerificationRequirement
- evidenceType
- minimumTrustTier
- minimumDurationMinutes
- minimumDistanceMeters
- minimumQuizScore
- allowedProviders
- riskRules

QuestEvidence
- questId
- sessionId
- provider
- type
- startedAt
- completedAt
- durationMinutes
- distanceMeters
- sourceActivityId
- routeHash
- bookMetadata
- quizAnswers
- quizScore
- reflection
- createdAt

VerificationDecision
- status: accepted | rejected | needsReview | insufficientEvidence
- confidenceScore
- riskFlags
- acceptedReward
- backendAuditId
```

## Backend Contract

The current backend path should evolve from "verify a competitive quest" into:

1. `startCompetitiveQuestSession`
   - creates an authoritative session
   - records template id, user id, start time, expected requirement

2. `submitCompetitiveQuestEvidence`
   - accepts raw evidence
   - checks template requirement
   - evaluates risk flags
   - writes an auditable evidence record

3. `verifyCompetitiveQuestCompletion`
   - may stay as compatibility wrapper
   - must delegate to the same evaluator
   - returns backend-authored decision and reward result

The backend owns:
- duplicate completion blocking
- source activity id reuse checks
- impossible pace/duration checks
- reward grant
- competitive activity grant record
- profile aggregate update
- rank/season/boss read-model update

The client owns:
- starting a session
- showing quest requirements
- collecting or simulating evidence
- submitting evidence
- rendering accepted/rejected/needs-review state

## Fraud Rules For V1

Implement as pure evaluator rules first, then wire into callables.

Running:
- reject missing distance or duration
- reject distance below template minimum
- reject impossible pace
- reject duplicated `sourceActivityId`
- flag unusually high pace even if not automatically rejected

Timer/focus:
- reject completion before minimum duration
- reject session completed before it was started
- flag too many interruptions if tracked

Reading:
- reject missing book/topic metadata
- reject missing quiz answers when quiz is required
- reject quiz score below threshold
- flag repeated identical answers or suspiciously short completion time

All:
- reject unknown template id
- reject evidence provider not allowed by template
- reject stale evidence outside the session window
- reject client-supplied reward totals

## Quest Catalog V1

Add richer official templates before adding many UI features:

| Template | Evidence | Notes |
| --- | --- | --- |
| `run_2k_controlled` | running distance | starter competitive running quest |
| `run_5k_ranked` | running distance | higher confidence, later rank use |
| `focus_25_deep_work` | timed focus | current timer path, clearer template |
| `read_20_comprehension` | reading quiz | starts AI quiz path later |
| `bodyweight_20_session` | workout session | timer first, provider later |
| `study_30_recall` | study session | recall answers or quiz later |

Each template should declare:
- allowed evidence providers
- trust tier
- minimum duration/distance/score
- reward/rank effect
- whether it can affect weekly boss, season score, promotion, or only XP

## UI Behavior

Competitive quest cards should show:
- evidence requirement
- current session state
- primary action:
  - start
  - submit evidence
  - complete timer
  - retry
- backend decision state:
  - accepted
  - rejected
  - needs review
  - insufficient evidence

Avoid UI that implies a claim was accepted before the backend decision returns.

## Test Plan

Domain tests:
- valid running evidence accepted
- missing distance rejected
- impossible pace rejected
- duplicate source activity rejected
- too-short timer rejected
- stale evidence rejected
- invalid provider rejected
- reading quiz below threshold rejected

Backend tests:
- callable rejects client reward mutation
- callable writes evidence audit record
- callable grants reward once
- callable updates competitive grant/read-model only after accepted decision

Flutter tests:
- competitive quest exposes correct primary action by state
- submitting evidence renders backend decision
- accepted quest triggers immediate competitive sync
- rejected quest does not grant local rank-facing progress

## Implementation Order

1. Add pure domain model/evaluator for evidence and decisions.
2. Expand official competitive quest templates with verification requirements.
3. Add deterministic fake evidence provider for tests and local development.
4. Wire backend callable tests around evaluator decisions.
5. Update Flutter repository/controller to submit evidence and render decisions.
6. Add UI keys for primary competitive actions and decision surfaces.
7. Only then evaluate Health Connect, Strava, and AI reading quiz adapters.

## Out Of Scope For V1

- real Health Connect integration
- real Strava OAuth
- real AI-generated reading quiz
- full location tracking
- public anti-cheat claims
- manual human review queue
- external launch dependency
