---
description: Promote (add) a new Skill/Command from .claude/project-skills or .claude/commands up to the shared ai-engineering repo, OR push a modification of an already-sync'd Skill/Command back to source. Use when a project-local artifact should be shared, or when fixing/improving a sync'd artifact from inside a project.
argument-hint: skill <name> [--scope <engineering|backend|ai|frontend>] | command <name>
---

# /promote — Add or modify Skills/Commands in ai-engineering from this project

Args: $ARGUMENTS

## Two modes (auto-detected)

| Mode | Trigger | What it does |
|---|---|---|
| **ADD** | Source lives in `.claude/project-skills/<name>/` or `.claude/commands/<name>.md` with no upstream match | Copies new artifact into `.ai/claude/`. For skills, `--scope` is required. |
| **MODIFY** | Source lives in `.claude/skills/<name>/` or `.claude/commands/<name>.md` and differs from `.ai/claude/` source | Copies the modified runtime version over the source. For skills, scope is auto-detected. |

If runtime and source are identical, the script refuses with "nothing to do".

## When to use

- ADD: a project-local Skill/Command has matured and you want other projects to be able to sync it
- MODIFY: you discovered a bug or wanted improvement in a sync'd Skill/Command and edited it in `.claude/` to test — now you want to push the fix upstream
- (As a corollary: editing `.claude/skills/` or `.claude/commands/` runtime is OK **only when you intend to /promote the change**. Otherwise it's still considered a runtime edit violation and will be flagged by check-drift.)

## When NOT to use

- The artifact is still experimental — let it bake locally first
- The skill is intrinsically project-specific (e.g., references "Producer AI", "broadcast pacing", "ambient UX") — keep it as overlay
- You only need to bump a non-functional field (status / last_updated) — edit directly in `.ai/claude/` and resync

## Procedure

### 1. Parse args

From `$ARGUMENTS`, determine:
- Whether to promote a **skill** or **command**
- The name
- Optional scope (only used for ADD-skill, or to relocate a skill across scopes during MODIFY)

If args are ambiguous, run `./.ai/claude/scripts/promote-to-source.sh --list-promotable` and ask the user to pick.

### 2. Run the script

```bash
# Skill
./.ai/claude/scripts/promote-to-source.sh --skill <name> [--scope <scope>]

# Command
./.ai/claude/scripts/promote-to-source.sh --command <name>
```

The script:
- Auto-detects ADD vs MODIFY
- For ADD-skill: requires `--scope`
- For MODIFY-skill: auto-detects existing scope; allows scope change via explicit `--scope`
- Copies into the right `.ai/claude/...` location
- For skills: updates the `scope:` field in frontmatter and runs lint
- For MODIFY: suggests bumping `version:` (does not enforce)
- Prints next-steps for committing in the `.ai` submodule

### 3. Surface lint issues if any

If lint failed, show the user the path under `.ai/claude/` and ask whether to fix in this turn before proceeding to commit.

### 4. For MODIFY: nudge version bump

If the script reported MODIFY for a skill, ask the user whether to bump the `version:` field (semver patch / minor / major). If yes, edit `.ai/claude/skills/<scope>/<name>/SKILL.md` to bump and update `last_updated:` too.

### 5. Commit in the .ai submodule (explicit confirmation)

The `.ai/` submodule is a separate repo on a separate remote. After the copy, ask:

> "Commit and push to ai-engineering main now?"

If yes:

```bash
cd .ai
git checkout main && git pull --rebase
git add claude/<path-just-copied>
git commit -m "<subject>"
git push
cd ..
```

Use the subject the script suggested:
- ADD-skill:    `feat(skill): add <name>`
- MODIFY-skill: `feat(skill): update <name>`
- ADD-command:  `feat(command): add /<name>`
- MODIFY-command: `feat(command): update /<name>`

Optionally append ` (promoted from <current-project-name>)`.

**Do not** add `Co-Authored-By:` or AI-attribution footers.

If user says no, leave the file copied in `.ai/` (uncommitted) and print the manual commit instructions.

### 6. Restore runtime symmetry

After push, run:

```bash
./.ai/claude/scripts/sync-to-project.sh --resync-all
```

This re-pulls the now-updated `.ai/claude/` source over `.claude/` runtime, so `check-drift.sh` is clean again.

### 7. Suggest project-local cleanup (ADD only)

If the user just **added** a `project-skill`, ask:

> "Delete `.claude/project-skills/<name>/` now that it's available as a sync'd Core skill?"

If yes, `rm -rf .claude/project-skills/<name>` and remind to `git add` / commit in the project repo.

## Anti-patterns

- Auto-committing upstream without explicit confirmation
- Promoting before the artifact has been used in the project (no production-tested track record)
- ADD with `--force` overwriting an existing skill/command in `.ai/claude/` — that erases history; prefer renaming or using MODIFY semantics
- Promoting a project-specific overlay into Core — Core gets polluted; generalize first or keep as overlay
- MODIFY without considering version bump — silent semver drift
- Skipping the lint step
- Adding Co-Authored-By or AI-attribution to the upstream commit
- Editing `.claude/skills/` or `.claude/commands/` runtime without intent to /promote — that's just drift waiting to be overwritten by the next resync
