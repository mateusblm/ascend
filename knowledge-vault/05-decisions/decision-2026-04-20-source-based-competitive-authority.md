# Decision: Competitive Authority Should Be Calculated From Source Data

Date: 2026-04-20

## Context

Ascend had already pushed the most sensitive competitive writes behind callables and read-only Firestore collections, but two critical pieces still depended on client-computed read models:

- competitive rank snapshot sync
- competitive integrity or trust sync

That meant the client was still deciding the final competitive state and only asking the backend to persist it.

## Decision

We now prefer source-based server evaluation for the competitive layer:

- the app sends raw competitive activity history to the backend
- the backend computes the current rank snapshot
- the backend resolves promotion exam pass or fail from the new snapshot
- the backend refreshes current season reward state from server-side history
- the app sends raw quest evidence to the backend
- the backend computes integrity, trust band, and suspicious-pattern state

The client keeps a local fallback only so the UI does not go blank when the network path fails.

## Why

This is the cleanest path to a serious competitive product:

- it reduces trust in client-generated final states
- it keeps Firestore collections honest as backend-written read models
- it preserves product responsiveness without reopening client-write loopholes

## Files

- `functions/src/index.ts`
- `lib/features/profile/data/rank_progression_repository.dart`
- `docs/ai/architecture-map.md`
- `docs/product/roadmap.md`
