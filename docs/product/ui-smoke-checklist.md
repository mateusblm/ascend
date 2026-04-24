# UI Smoke Checklist

## Purpose

Provide a lightweight visual and ownership smoke path for the main UI surfaces after changes to top-level screens.

This checklist is complementary to:
- `docs/product/phase1-smoke-log.md`
- `docs/product/release-checklist.md`

Last updated: `2026-04-24`

## Current Status

- Automated desk pass: `completed`
- Real-device visual pass: `pending`

Automated desk pass evidence:
- `flutter analyze`
- widget coverage for `Home`, `Arena`, and this pass for `Quests` and `Plano`

### Automated desk pass - 2026-04-23

- Result: `passed`
- Validation:
  - `flutter analyze lib/features/profile/presentation/home_screen.dart lib/features/quests/presentation/quests_screen.dart lib/features/profile/presentation/rank_screen.dart lib/features/profile/presentation/stats_screen.dart lib/features/profile/presentation/account_screen.dart test/features/quests/presentation/quest_card_test.dart test/features/profile/presentation/stats_screen_test.dart`
  - `flutter test test/features/profile/presentation/home_screen_test.dart test/features/profile/presentation/rank_screen_test.dart test/features/profile/presentation/stats_screen_test.dart test/features/quests/presentation/quest_card_test.dart`
- Remaining gap:
  - visual rhythm, scroll feel, and density still require a real-device pass

### Automated desk pass - 2026-04-24

- Result: `passed`
- Validation:
  - `rtk flutter analyze`
  - `rtk flutter test`
- Coverage added since the previous pass:
  - onboarding -> `Quests` -> first personal quest journey
  - `Home` return-motivation surface
  - `Quests` return-loop surface
- Remaining gap:
  - visual rhythm, scroll feel, density, and small/large-screen manual judgment still require a real-device pass

## Manual Path

### `Base`

Check:
- hero shows identity, XP, and compact momentum only once
- build preview is visible without repeating analytics from `Plano`
- secondary arena reads stay inside detail entries

### `Quests`

Check:
- hero shows actionable counts
- weekly-priority block interprets the queue instead of repeating hero totals
- return-loop block explains today's first action, tomorrow's return, and weekly/rank pressure
- `Arena`, `Base`, and `Concluidas` sections are visually distinct
- quest cards remain readable and do not render as flat black blocks

### `Arena`

Check:
- current rank has one dominant owner in the hero
- weekly pressure, boss, and next gate are readable before opening detail
- `Agora`, `Temporada`, and `Legado` do not repeat the same rank summary

### `Plano`

Check:
- header stays lightweight
- `Leitura da semana` owns `Score`, `Grau`, and delta
- `Proximo passo` is visible without scrolling far
- detail entries feel distinct: overview, build, and week detail

### `Conta`

Check:
- identity, provider, support, privacy, deletion, and logout are visible
- no gameplay dashboards leak into the screen
- support and deletion copy still matches the active release assumptions

## Record Template

When a manual pass is run, append:

### UI smoke pass - YYYY-MM-DD

- Environment:
- Build:
- Device:
- Tester:
- Screens checked:
- Visual regressions found:
- Ownership regressions found:
- Follow-up:
