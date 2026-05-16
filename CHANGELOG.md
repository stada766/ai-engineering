# Changelog

All notable changes to this repository will be documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `skills/engineering/git-commit-clean/` — Skill for running `git add` / `commit` / `push` without a Co-Authored-By trailer or AI-attribution footer.
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
