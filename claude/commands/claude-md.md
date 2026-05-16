---
description: Create or update this project's CLAUDE.md by composing stack template, active skills, project philosophy, and Don'ts. Updates only changed sections by default.
argument-hint: [optional: section name to refresh, or "all"]
---

# /claude-md — Create or update CLAUDE.md

Target section / scope: $ARGUMENTS (defaults to "auto-detect what changed")

## Procedure

Invoke the `claude-md-writer` skill (`.claude/skills/claude-md-writer/SKILL.md` when sync'd, source at `.ai/claude/skills/engineering/claude-md-writer/SKILL.md`). If the skill is not sync'd, follow the inline summary below.

### Inline summary (when claude-md-writer is not sync'd)

1. If `CLAUDE.md` does not exist:
   - Detect stack from project files (`package.json` → node-typescript, `pubspec.yaml` → flutter, `pyproject.toml` → python-ai)
   - Start from `.ai/claude/templates/claude-md/<stack>.md`
   - Ask the user for `Project context` (3–5 sentences) before writing
2. If `CLAUDE.md` exists:
   - Read all sections
   - Update **only the sections that have changed** (active skills list, ADRs, Don'ts, etc.)
   - Do not rewrite untouched sections
3. Required section order (do not change):
   1. Project context
   2. Active skills (list from `.claude/skills/`, name + leading clause of description)
   3. Project-specific skills (list from `.claude/project-skills/`)
   4. Stack
   5. Don'ts (project-specific)
   6. Active ADRs (list from `docs/decisions/` with status)
4. Keep total length to roughly A4 1–2 pages. Push longer content into `docs/` and link.

### When to refuse / redirect

- User wants to record a past decision → use `/adr` instead
- User wants to write a README for humans → CLAUDE.md is for the AI; suggest a separate README
- User wants a tutorial / how-to → put it under `docs/` and link from CLAUDE.md

## Anti-patterns

- Rewriting unchanged sections (creates noisy diffs and erases human edits)
- Listing active skills that are not actually in `.claude/skills/` (must sync first)
- Including implementation details, API examples, or marketing language
- Adding sections out of canonical order — AI relies on stable positions
- Deleting content via comments (`<!-- removed: ... -->`); explain in the commit message instead
