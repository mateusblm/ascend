---
type: decision
status: active
source_note: [[competitive-quest-integrity]]
created_at: 2026-04-19T22:05:00-03:00
tags:
  - decision
  - integrity
  - competitive
confidence: high
---
# Silent Integrity Layer

## Decision

- add a silent trust score for the competitive loop before applying hard penalties
- surface it as a warning/reading layer in Home and Rank
- persist it remotely so season and leaderboard rules can consume it later

## Impact

- gives Ascend an anti-abuse foundation without punishing honest users too early
- lets the team calibrate suspicious-pattern rules with real usage first
- keeps future restrictions additive instead of reactive

## Related Notes

- [[competitive-quest-integrity]]
- [[task-2026-04-19-competitive-quest-hardening]]
