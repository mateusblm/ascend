# Phase 1 Smoke Log

## Purpose

Record the real-device validation required to close `Phase 1 - Core authority and trust`.

Do not mark Phase 1 as completed until this log has a real pass record.

Related documents:
- `docs/product/execution-tracker.md`
- `docs/product/phase-backlog.md`
- `docs/product/release-checklist.md`

## Current Status

Status: `pending`
Last updated: `2026-04-25`

Blocking note:
- this log exists, but no real-device pass has been recorded yet
- current Codex environment reports only `Linux (desktop)` from `rtk flutter devices`; Android/iOS mobile smoke must be run outside this environment or after attaching a device/emulator

Current target candidate:
- `RC-internal-2026-04-25`
- artifact: `build/app/outputs/flutter-apk/app-production-release.apk`

## Required Smoke Path

Run on a real authenticated build that matches the intended environment.

| Step | Result | Notes |
| --- | --- | --- |
| Login | `pending` | |
| Onboarding or restored first-run state | `pending` | |
| Create one personal quest | `pending` | |
| Complete one personal quest | `pending` | |
| Start one competitive quest | `pending` | |
| Complete one competitive quest | `pending` | |
| Open Home | `pending` | |
| Open Rank | `pending` | |
| Open Quests | `pending` | |
| Open Stats | `pending` | |
| Open Conta and verify connected account | `pending` | |
| Open Conta and verify privacy/support visibility | `pending` | |
| Logout | `pending` | |
| Restart app and verify session restore behavior | `pending` | |

## Pass Record Template

When a real pass is executed, add an entry like this:

### Smoke pass - YYYY-MM-DD

- Environment:
- Build:
- Device:
- Tester:
- Result:
- Failures observed:
- Crash/non-fatal follow-up:
- Next action:
