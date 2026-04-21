# Decision: Competitive Quest Authority

## Date

2026-04-21

## Decision

Competitive quest progression should no longer trust only local timer state and local verification flags.

The competitive path now moves toward:

- backend session start
- backend completion validation
- backend reward grant records

This keeps the casual personal loop lightweight while making rank-facing effort more trustworthy.

## Why

The app can no longer look production-serious if the most important competitive proof still depends only on local state.

We need:

- real timer pressure for competitive quests
- duplicate reward protection
- server-readable completion history
- a cleaner bridge from quest verification to rank authority

## Consequences

- the app starts competitive sessions through a callable
- the app completes competitive quests through a callable
- the backend stores:
  - `competitive_quest_sessions`
  - `competitive_quest_grants`
- competitive sync can now prefer server grants over client-only competitive date history
