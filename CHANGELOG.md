# Changelog

All notable changes to this repository will be documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `claude/always-include.txt` — editable default-toolkit policy file. Lists Skills and Commands that are always synced by `install.sh` and always classified as "Add" by `/sync-recommended`, regardless of project context. Repo-level configuration (not project-level).
- `claude/scripts/sync-to-project.sh --always` — new mode that reads `always-include.txt` and syncs everything listed.
- `install.sh` (top-level, curl-able) — one-liner project bootstrap. Adds ai-engineering as a submodule, creates `.claude/` runtime dirs, and runs `sync-to-project.sh --always`.
- `claude/commands/sync-recommended.md` — Claude-driven recommendation pass. Reads `CLAUDE.md` and `docs/decisions/*.md`, judges which Skills and Commands fit the project from their `description:` fields, and syncs the approved set. No hardcoded keyword tables — pure semantic judgement.
- `claude/scripts/promote-to-source.sh` and `claude/commands/promote.md` — bidirectional flow: a project can now push (add or modify) Skills/Commands back to ai-engineering. Auto-detects ADD vs MODIFY mode; refuses no-op promotions; runs lint; does not auto-commit upstream (separate repo).
- `claude/` — All Claude Code-specific artifacts now live under this namespace (see ADR 0003).
- `claude/commands/` — Slash Commands as a first-class category alongside Skills: `/bootstrap`, `/commit`, `/adr`, `/claude-md`. Commands are user-triggered rituals; Skills are AI-discovered lenses.
- `claude/skills/engineering/claude-md-writer/` — Skill for creating/updating a project's CLAUDE.md as a living instruction file. Backs the `/claude-md` command.
- `claude/README.md` — overview of the `claude/` sub-namespace and its relationship to vendor-neutral top-level content.
- `claude/docs/command-authoring.md` — guidance for when to write a Command vs Skill.
- `docs/decisions/0003-claude-namespace.md` — ADR documenting the namespace split.

### Changed
- Edit policy: `.claude/skills/` and `.claude/commands/` are still read-only by default, but the new exception is "edit-then-promote" — editing the runtime is OK if you immediately `/promote` the change back to `.ai/claude/`. After the upstream commit + resync, runtime and source are symmetric again.
- **Layout: Claude Code-specific artifacts moved under `claude/`**. Affected paths:
  - `skills/` → `claude/skills/`
  - `commands/` → `claude/commands/` (new in this release, never lived at the old path on main)
  - `templates/skill/` → `claude/templates/skill/`
  - `templates/claude-md/` → `claude/templates/claude-md/`
  - `templates/project-skill-examples/` → `claude/templates/project-skill-examples/`
  - `scripts/` → `claude/scripts/`
  - `docs/sync-guide.md`, `docs/skill-authoring.md` → `claude/docs/`
- `stacks/<lang>/CLAUDE.md` → `stacks/<lang>/ai-instructions.md` (filename is now vendor-neutral; content unchanged).
- All internal path references (commands, skills, docs, scripts) updated to the new layout. Submodule consumers must now invoke `./.ai/claude/scripts/sync-to-project.sh` instead of `./.ai/scripts/sync-to-project.sh`.
- `scripts/sync-to-project.sh` — added `--command <name>` and `--list-commands`; `--resync-all` now covers both skills and commands.
- `scripts/check-drift.sh` — now also diffs `.ai/claude/commands/` against `.claude/commands/`.
- Top-level `README.md` and `docs/philosophy.md` updated to describe the vendor-neutral / vendor-specific split.

### Removed
- `skills/engineering/project-bootstrap/` — replaced by `claude/commands/bootstrap.md` before reaching main.
- `skills/engineering/git-commit-clean/` — replaced by `claude/commands/commit.md`. Original SKILL.md history preserved in commit `c62dc94`.
- `description:` frontmatter field on every SKILL.md (matches Claude Code's official Skill discovery schema). Lint script now requires it.
- `Update & Superseding rules` and `Quality Checklist` sections to `adr-writer` (version 0.2.0).
- `templates/project-skill-examples/adr-writer-with-runtime-rules/` — Project Overlay template demonstrating how to layer project-specific AI runtime and consistency rules on top of the core `adr-writer`.

### Changed
- ADR storage path: `adr/` → `docs/decisions/`. Existing ADRs moved with `git mv` (history preserved).
- ADR template: `Alternatives Considered` → `Options Considered` with structured Strengths / Weaknesses / Operational impact bullets.
- ADR template: `Status` now includes `Superseded by NNNN` as an explicit state.
- `adr-writer/examples/good-adr.md` and `bad-adr.md` updated to the new Options Considered format.
- `docs/skill-authoring.md`: documents the distinction between `description:` (Claude Code runtime trigger) and `responsibility:` (internal lint contract).

## [0.1.0] - 2026-05-16

### Added
- Initial directory scaffolding for skills / prompts / templates / standards / architecture / stacks / adr / docs / scripts / tests.
- Core philosophy doc and sync guide.
- `SKILL.md.template` and canonical example (`adr-writer`).
- ADR 0001 (skill hierarchy) and ADR 0002 (sync strategy).
- `lint-skills.sh`, `sync-to-project.sh`, `check-drift.sh`.
