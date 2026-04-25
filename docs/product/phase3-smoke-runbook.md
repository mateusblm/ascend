# Phase 3 Smoke Runbook

## Purpose

Define the real-device validation path for a release candidate before external testing.

This runbook does not replace:
- `docs/product/phase1-smoke-log.md`
- `docs/product/ui-smoke-checklist.md`
- `docs/product/release-candidate-log.md`

Use it to execute and record the missing real-device evidence.

## Current Target Candidate

Candidate: `RC-internal-2026-04-25`

Primary artifact:
- `build/app/outputs/flutter-apk/app-production-release.apk`

Secondary identity checks:
- staging debug: `build/app/outputs/flutter-apk/app-staging-debug.apk`
- production debug: `build/app/outputs/flutter-apk/app-production-debug.apk`

Current execution status:
- automated validation: `passed`
- real-device smoke: `pending`
- visual/scroll-density pass: `pending`
- Android/iOS device available in the current Codex environment: `no`
  - `rtk flutter devices` currently reports only `Linux (desktop)` under WSL

## Required Device Matrix

Minimum before external beta:

| Platform | Build | Required result |
| --- | --- | --- |
| Android | production release APK | install, login, core smoke, logout, session restore |
| Android | staging debug APK | install alongside production identity and login sanity check |

Optional before broader beta:

| Platform | Build | Required result |
| --- | --- | --- |
| iOS | production signed build | install, login, core smoke |
| Android | low/small screen device | first-session and Quests readability |
| Android | large screen device | Home, Quests, Rank, Plano density |

## Core Smoke Path

Run on a real authenticated mobile build.

Record result in `docs/product/phase1-smoke-log.md`.

1. Install the candidate build.
2. Launch app.
3. Login with Google.
4. Complete onboarding, or verify restored first-run state for an existing account.
5. Confirm the app lands in `Quests` after starter-kit confirmation for a new account.
6. Create one personal quest.
7. Complete one personal quest.
8. Start one competitive quest.
9. Complete one competitive quest if timer/reflection requirements allow it.
10. Open `Home`.
11. Open `Quests`.
12. Open `Arena`.
13. Open `Plano`.
14. Open `Conta`.
15. Verify connected account, privacy, support, deletion direction, and logout entry.
16. Logout.
17. Restart app.
18. Verify signed-out state or session restore behavior matches the account state.

## Visual And Density Pass

Record result in `docs/product/ui-smoke-checklist.md`.

Check:
- `Home`: return motivation, XP, streak, and detail entries do not crowd each other.
- `Quests`: return-loop block, first-week panel, Arena/Base sections, and FAB remain readable.
- `Arena`: current rank, weekly pressure, boss, and promotion gates remain distinct.
- `Plano`: weekly read owns score/grade/delta and plan detail remains reachable.
- `Conta`: support/privacy/deletion/logout surfaces remain visible and trust-focused.

## Operational Signal Check

After the device smoke, verify Firebase:

Analytics events expected:
- `auth_login_succeeded`
- `onboarding_completed`
- `starter_kit_applied`
- `quest_created`
- `quest_completed`
- `competitive_quest_started`
- `competitive_quest_blocked` only when a blocked path is intentionally exercised
- `weekly_boss_claimed`, `promotion_exam_started`, or `promotion_confirmed` only if that path is exercised

Crashlytics checks:
- no new fatal issue for the candidate version
- no unexpected non-fatal spike in:
  - `competitive_remote:*`
  - `weekly_boss_remote:*`
  - `competitive_quest_authority:*`
  - `riverpod:*`

## Pass Record Template

Append to `docs/product/phase1-smoke-log.md`:

```text
### Smoke pass - YYYY-MM-DD

- Environment:
- Build:
- Artifact:
- Device:
- Tester:
- Result:
- Steps passed:
- Failures observed:
- Crash/non-fatal follow-up:
- Analytics follow-up:
- Next action:
```

Append to `docs/product/ui-smoke-checklist.md`:

```text
### UI smoke pass - YYYY-MM-DD

- Environment:
- Build:
- Artifact:
- Device:
- Tester:
- Screens checked:
- Visual regressions found:
- Ownership regressions found:
- Follow-up:
```

