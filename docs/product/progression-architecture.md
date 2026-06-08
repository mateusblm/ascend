# Progression Architecture

## Purpose

Define the final production architecture for account progression, quests, rewards, and competitive proof.

This document exists to prevent a recurring mistake:
- putting security-sensitive business rules in the Flutter client
- treating client snapshots as canonical truth
- recomputing the whole account from scratch during normal app flow

## Core Principles

1. Business rules that affect rewards, rank, progression, entitlement, anti-abuse, or account trust must live in the backend.
2. The frontend may render state, collect input, and show optimistic UI, but it must not be the final authority for progression outcomes.
3. The system should persist both:
   - canonical facts
   - backend-authored aggregates/read-models
4. Full recomputation should be reserved for:
   - migrations
   - repair jobs
   - audits
   - admin recovery tools

## The Correct Data Split

### 1. Canonical Facts

These represent things that actually happened and should be append-only or close to append-only.

Examples:
- personal quest completion
- personal quest completion revocation
- competitive quest session start
- competitive quest grant verification
- weekly boss claim
- attribute point allocation
- promotion exam start/confirm
- season reward claim

These should be stored as backend-authored records.

### 2. Aggregates

These are fast, authoritative account summaries that the app can read directly without recomputing everything.

Primary aggregate:
- `users/{uid}/profile/current`

This should contain values such as:
- `level`
- `xp`
- `maxXp`
- `statPoints`
- `attributes`
- `currentStreak`
- `bestStreak`
- `lastQuestCompletionDate`
- `lastCompetitiveQuestCompletionDate`
- onboarding/profile settings that belong to account state

The backend should update this aggregate transactionally when canonical facts are accepted.

### 3. Read-Models

These are specialized projections optimized for one domain or UI surface.

Examples already aligned with this pattern:
- `users/{uid}/progression/current`
- `users/{uid}/integrity/current`
- `users/{uid}/season_rewards/current`
- `users/{uid}/season_profile/current`

Read-models are not raw input. They are backend-authored outputs.

### 4. Local Cache

Isar should exist for:
- cache
- offline continuity
- UI speed
- temporary drafts

Isar should not be the canonical source of truth for account progression.

## Frontend Responsibility

The Flutter app should:
- display aggregates and read-models
- start commands
- collect proof or user intent
- keep lightweight optimistic state when needed
- cache remote state locally

The Flutter app should not:
- decide final XP or level outcomes for the account
- decide final competitive grants
- decide anti-abuse outcomes
- treat a local player snapshot as the real account truth

## Backend Responsibility

The backend should:
- validate commands
- write canonical facts
- update aggregates
- update read-models
- reject invalid or conflicting commands
- keep sensitive business rules out of the client

## Recommended Production Collections

Suggested target structure:

- `users/{uid}/profile/current`
- `users/{uid}/profile_settings/current`
- `users/{uid}/quest_inventory/{questId}`
- `users/{uid}/quest_completions/{completionId}`
- `users/{uid}/competitive_quest_sessions/{attemptId}`
- `users/{uid}/competitive_quest_grants/{grantId}`
- `users/{uid}/weekly_boss_claims/{claimId}`
- `users/{uid}/attribute_allocations/{allocationId}`
- `users/{uid}/progression_ledger/{entryId}`
- `users/{uid}/progression/current`
- `users/{uid}/integrity/current`

Notes:
- `quest_inventory` is current state for rendering and management
- `quest_completions` is factual history
- `progression_ledger` is the safest long-term base for account reward accounting

## Recommended Command Surface

Normal progression should move through backend commands such as:
- `POST /api/v1/quests/personal:complete`
- `POST /api/v1/quests/personal:revoke`
- `POST /api/v1/quests/competitive:session:start`
- `POST /api/v1/quests/competitive:verify`
- `POST /api/v1/profile/attributes:allocate`
- `POST /api/v1/weekly-boss:claim`
- `POST /api/v1/profile/settings:update`

Each command should:
1. validate intent and prerequisites
2. write the canonical fact
3. update affected aggregates/read-models
4. return the backend-authored result

## Current Implementation Status

The app is now backend-authoritative for active progression flows:
- `profile/current` is the official account aggregate for:
  - `level`
  - `xp`
  - `maxXp`
  - `statPoints`
  - `attributes`
  - streak and activity history
- personal quest completion writes the fact and updates `profile/current` + `quests/{questId}`
- personal quest revocation reverts the personal completion fact and repairs the affected aggregate fields
- competitive quest verification writes the competitive grant fact and updates:
  - `profile/current`
  - `quests/{questId}`
  - `quest_completions/{attemptId}`
- attribute allocation and weekly boss claim also update `profile/current` on the backend
- `syncPlayerProfileFromSource` and `syncQuestInventoryFromSource` now exist primarily for:
  - migration
  - repair
  - audited cache recovery

The Flutter app should treat the Java backend response as the source of truth
and only cache that result locally.

## Anti-Patterns To Avoid

Do not:
- trust `level/xp/streak/history` sent by the client as final truth
- recompute the whole profile from raw quest inventory on every normal sync forever
- keep reward-critical rules only in Flutter controllers
- let the client mutate reward-bearing collections directly
- model long-term account progression as a UI cache problem

## Post-Migration Direction

The migration direction is now complete for the active product behavior. Future
work should:

1. keep `profile/current` as the official backend-authored aggregate
2. keep personal quest completion in the command + fact + aggregate update flow
3. keep attribute allocation in the command + fact + aggregate update flow
4. keep weekly boss and competitive paths backend-authored
5. keep source sync endpoints as repair tooling instead of normal reward paths
6. avoid reintroducing Firebase Functions or TypeScript fallback paths

## Security Rule

If a rule exists to protect value, trust, rank, rewards, or abuse resistance, that rule belongs in the backend, not in the frontend.
