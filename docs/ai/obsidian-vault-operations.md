# Obsidian Vault Operations

## Vault Location

The project vault lives at:

- `knowledge-vault/`

It is compatible with Obsidian because it uses plain Markdown, folder structure, and wikilinks.

## Folder Layout

```text
knowledge-vault/
|-- 00-inbox/
|-- 01-project/
|-- 02-codebase/
|   `-- files/
|-- 03-chats/
|   |-- raw/
|   `-- normalized/
|-- 04-entities/
|   `-- code/
|-- 05-decisions/
|-- 06-tasks/
|-- _system/
|   |-- indexes/
|   `-- state/
`-- _templates/
```

## How To Feed Chats

Drop exported chats into:

- `memory-input/chats/`

Supported inputs are plain text, Markdown, and JSON chat exports.

## Pipeline Commands

Run the full memory pipeline:

```powershell
powershell -ExecutionPolicy Bypass -File tools/knowledge/run-memory-pipeline.ps1
```

Run only the codebase map:

```powershell
powershell -ExecutionPolicy Bypass -File tools/knowledge/build-codebase-map.ps1
```

Run only chat import:

```powershell
powershell -ExecutionPolicy Bypass -File tools/knowledge/import-chats.ps1
```

## Scheduling

### Windows Task Scheduler

Create a scheduled task:

```powershell
powershell -ExecutionPolicy Bypass -File tools/knowledge/register-memory-task.ps1
```

### Cron

For WSL, Linux, or macOS cron:

```cron
0 * * * * cd /path/to/ascend && pwsh -ExecutionPolicy Bypass -File tools/knowledge/run-memory-pipeline.ps1
```

## Expected Usage Pattern

1. keep the codebase map refreshed
2. import new chats on a schedule
3. read normalized notes before raw notes
4. mark outdated decision notes as superseded when the project changes

## Hygiene Rules

- keep raw chats out of Git by default
- keep normalized notes short and link-rich
- prefer one useful note over many thin notes
- if a chat note changes product direction, move the durable part into `docs/` or a decision note
