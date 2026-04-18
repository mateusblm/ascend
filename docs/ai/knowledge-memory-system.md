# Knowledge Memory System

## Purpose

Ascend uses a repository-local memory system to support AI-assisted development with better recall and lower token waste.

This system has three parts:
- a curated documentation layer in `docs/`
- an Obsidian-compatible vault in `knowledge-vault/`
- a lightweight pipeline in `tools/knowledge/` for ingesting chats and mapping the codebase

## Design Goals

- keep project memory persistent across sessions
- reduce repeated repo explanation in AI chats
- preserve decision history without treating old chat text as truth
- make code, docs, and discussions linkable through Markdown and simple graph data

## Trust Model

The system uses a strict confidence order:

1. current code
2. curated docs in `docs/`
3. normalized vault notes
4. raw imported chats

If code and memory disagree, trust the code.

## Components

### 1. Curated docs

Primary project rules stay in:
- `AGENTS.md`
- `docs/product/`
- `docs/ai/`

These files are the stable context layer for AI agents.

### 2. Obsidian vault

The vault stores:
- project notes
- codebase notes
- normalized chat notes
- entity notes
- decisions and tasks

Vault root:
- `knowledge-vault/`

### 3. Pipeline

Scripts in `tools/knowledge/` do two main jobs:
- build a codebase map from the repo
- import chats into the vault incrementally

## Data Flow

### Codebase Map

1. scan `lib/**/*.dart`
2. extract imports and top-level symbols
3. write code notes into the vault
4. generate entity catalog and graph edges

### Chat Import

1. read new or changed files from `memory-input/chats/`
2. store a raw copy in the vault
3. create a normalized note with metadata, tags, related files, and wikilinks
4. keep import state so future runs stay incremental

## Security And Privacy Rules

- raw chat imports are sensitive by default
- do not commit secrets, credentials, tokens, or personal data into the vault
- raw imports should stay ignored by Git unless intentionally sanitized
- normalized notes should be concise and curated before they are treated as long-term memory

## Operational Rule

Use the memory system for retrieval, not blind trust.

It exists to reduce rediscovery cost, not to replace reading the current code.
