---
description: Read this project's CLAUDE.md and docs/decisions/*.md, judge which Skills and Commands from ai-engineering would help here, and sync them. Use after /bootstrap, or whenever the project direction shifts.
argument-hint: [optional: "auto" to skip confirmation]
---

# /sync-recommended — Claude picks the right tooling for this project

Args: $ARGUMENTS

## Hard gate

Both must exist (otherwise tell the user to run `/bootstrap` first):

- `CLAUDE.md`
- at least one ADR in `docs/decisions/`

If either is missing, stop and explain.

## Procedure

### 1. Read what defines this project

Read these in full:

- `CLAUDE.md`
- every file under `docs/decisions/`

Extract for yourself: stack / language / runtime topology / architecture style / AI involvement / realtime needs / UI nature / scale targets / non-goals.

### 2. List what's available upstream

```bash
./.ai/claude/scripts/sync-to-project.sh --list
./.ai/claude/scripts/sync-to-project.sh --list-commands
```

For each item **not already synced**, read its `description:` field:

- Skills:   `.ai/claude/skills/<scope>/<name>/SKILL.md`
- Commands: `.ai/claude/commands/<name>.md`

Hold the descriptions in working memory — they are your decision input.

### 2.5 Apply the always-include policy

Read `.ai/claude/always-include.txt`. Every `skill:<scope>/<name>` and `cmd:<name>` listed there is **non-negotiable Add** with the reason "always-include policy". They appear in your Add list with that reason, and the user cannot move them to Skip via the normal confirmation flow. (If they truly need to deviate, instruct them to edit `claude/always-include.txt` in ai-engineering instead — those defaults are repo-level, not project-level.)

### 3. Judge each item

For every available Skill / Command, decide one of:

- **Add** — clearly relevant given the project's stated nature
- **Optional** — useful for some projects of this shape but not strictly needed
- **Skip** — irrelevant, contradictory, or duplicative

Use **semantic judgement against the project artifacts and the `description:` text**. Do not use a hardcoded keyword table.

Lean on signals like:

- Direct fit: ADR adopts event-driven architecture → `backend/event-driven-runtime` is a high-confidence Add
- Lifecycle: greenfield project → `engineering/tdd-enforcer` is a useful early-discipline Add
- Counter-evidence: project is a CLI with no UI → `frontend/ambient-ux-review` is Skip
- Composability: if you Add a Skill, also Add the Commands that back it (e.g., adding `claude-md-writer` implies `/claude-md` is already there or needed)

### 4. Present recommendations with reasoning

Output shape:

```
Recommendations based on CLAUDE.md, docs/decisions/, and always-include.txt:

Add (always-include policy — non-negotiable):
  - engineering/adr-writer         — always-include policy
  - engineering/claude-md-writer   — always-include policy
  - /bootstrap, /sync-recommended, /commit, /adr, /claude-md, /promote

Add (high-confidence, this project):
  - engineering/tdd-enforcer       — greenfield; early TDD discipline pays back
  - backend/event-driven-runtime   — ADR 0003 chose event-driven architecture
  - ai/prompt-design               — AI features are core (ADR 0005)
  ...

Optional (your call):
  - ai/multi-agent-review          — useful for high-stakes AI PRs; adds overhead
  ...

Skip:
  - frontend/ambient-ux-review     — no UI surface (CLAUDE.md: "backend-only API")
```

Every Add / Skip line must have a one-clause reason tied to the artifacts.

### 5. Confirm with the user

Unless `$ARGUMENTS` is literally `auto`, ask the user to:

- Approve the Add set as-is, or
- Move items between Add / Optional / Skip, or
- Add items the recommendation missed (the user knows things you don't)

If `$ARGUMENTS == "auto"`, proceed with the Add set directly (use sparingly — better is to confirm).

### 6. Sync

Compose the `sync-to-project.sh` invocation explicitly, print it, then run it:

```bash
./.ai/claude/scripts/sync-to-project.sh \
  --skill <scope/name> \
  --skill <scope/name> \
  --command <name>
```

### 7. Refresh CLAUDE.md Active skills section

After sync, invoke the `claude-md-writer` skill (or follow its rules) to update the **Active skills** section of `CLAUDE.md` to match what's actually under `.claude/skills/` and `.claude/commands/` now. Do not rewrite untouched sections.

### 8. Suggest commit

Tell the user this is a good checkpoint to commit. Suggest `/commit` with a subject like `chore: sync recommended skills and commands`.

## When to re-invoke later

- After accepting a new ADR that opens up architectural territory (e.g., introducing realtime → `/sync-recommended` may now recommend `websocket-systems`)
- After deprecating an active skill (it should drop from recommendations)
- When a new Skill / Command is added to ai-engineering upstream that might apply here

## Anti-patterns

- Hardcoding "keyword X → Skill Y" tables — brittle, drifts as the playbook grows
- Recommending everything (defeats pruning, bloats AI context)
- Skipping confirmation when `$ARGUMENTS != "auto"`
- Forgetting step 7 (Active skills out of sync with reality)
- Re-syncing already-synced items as new
- Recommending a Skill but not the Command that exposes it (or vice versa)
