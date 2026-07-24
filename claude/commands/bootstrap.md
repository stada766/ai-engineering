---
description: Bootstrap a greenfield project — interview the user, decompose 3-8 foundational decisions, generate ADRs and CLAUDE.md (all Proposed) for human review before commit.
argument-hint: [optional one-line vision]
---

# /bootstrap — Greenfield project bootstrap

Initial vision (optional, may be empty): $ARGUMENTS

## Hard gate — STOP if this fails

This command is for **empty projects only**. Before doing anything else, check:

- `docs/decisions/` does not exist or is empty
- `CLAUDE.md` does not exist
- `ARCHITECTURE.md` does not exist

If either exists, **stop immediately** and tell the user to use `/adr` or `/claude-md` instead. Do not overwrite.

## Procedure

### Phase 1 — Vision intake (structured interview)

Ask the user the following. **Do not fabricate answers**. For each, the user may answer "未定 / let me decide later" — record that explicitly.

1. **What are you building?** (one sentence)
2. **Who is the user / what problem does it solve?**
3. **Hard constraints**: deadline / budget / scale / team size / existing assets
4. **Already-decided**: language / hosting / libraries / "must-have X"
5. **Open questions**: things you want help deciding (these become ADR candidates)
6. **Non-goals**: what this is NOT

Combine `$ARGUMENTS` if provided as the seed for question 1.

### Phase 2 — Decision decomposition

From the vision, extract **3–8 foundational decisions**. Typical candidates:

- Language / runtime
- Architecture style (monolith / event-driven / microservices)
- Persistence (DB type, schema strategy)
- **AI runtime boundary** (required if AI is core)
- Hosting / deployment
- Realtime / communication (WebSocket / polling / serverless)
- Auth strategy (only if non-trivial)
- Observability approach (only if scale demands it)

**Do NOT** create ADRs for:
- "Use Git" or other trivial choices
- Defaults that come with the chosen stack (e.g., `tsconfig strict`)
- Specific library picks unless architecturally significant

If you would exceed 8, split into "lock now" vs "defer".

### Phase 3 — Stack selection

Propose the closest fit from `.ai/stacks/` (`node-typescript`, `flutter`, `python-ai`) or a hybrid (e.g., TS + Python AI). Confirm with the user it does not conflict with Phase 1's "already-decided" answers.

### Phase 4 — ADR generation

For each decision, follow the **adr-writer skill conventions** (`.ai/claude/skills/engineering/adr-writer/SKILL.md` when sync'd, otherwise the procedure below):

- Sequential numbering `0001..NNNN`, kebab-case title
- File path: `docs/decisions/NNNN-<title>.md`
- `Status: Proposed` (never Accepted at bootstrap time)
- Use the template at `.ai/templates/adr/0000-template.md`
- Options Considered must have **at least 2** entries (including "don't do it" if valid)
- Apply the adr-writer Quality Checklist to each

### Phase 5 — CLAUDE.md generation

Follow `claude-md-writer` conventions. Start from `.ai/claude/templates/claude-md/<stack>.md`. Required sections in order:

1. Project context (3–5 sentences from Phase 1)
2. Active skills (the skills the user plans to sync — ask which, default to `engineering/adr-writer`, `engineering/tdd-enforcer`, plus stack-relevant ones)
3. Project-specific skills (likely empty at bootstrap — note `.claude/project-skills/` exists for later)
4. Stack reference (pull from `.ai/stacks/<lang>/ai-instructions.md`)
5. Don'ts (derived from Phase 1's non-goals and constraints)
6. Active ADRs (list every ADR from Phase 4 with its status)

### Phase 5.5 — Architecture Doc scaffold

Create `ARCHITECTURE.md` at project root — the **living source of truth for the current design** (distinct from ADRs, which record *why*). See `standards/documentation-model.md`.

- Start from `.ai/templates/architecture/overview-template.md`.
- Fill §1–§4 from Phase 1–3 (purpose / non-goals / constraints / runtime topology / main components).
- Build §5 Key Decisions from the Phase 4 ADRs (area → choice → `ADR-NNNN`). At bootstrap the ADRs are `Proposed`; still list them, and note in §7 that they await Acceptance.
- Leave genuine unknowns as `<未定>` in §7 Open Questions. **Do not fabricate.**
- `status: draft`, `last_updated` = today.

### Phase 6 — Validation

Self-check before showing the user:

- [ ] All ADRs are `Status: Proposed`
- [ ] Every ADR passes the adr-writer Quality Checklist
- [ ] ADR count is between 3 and 8
- [ ] CLAUDE.md section order is canonical
- [ ] ARCHITECTURE.md exists; §5 lists every ADR; unknowns are `<未定>`, not fabricated
- [ ] Open vision questions are listed separately for follow-up
- [ ] No existing file is being overwritten

If any check fails, fix before proceeding.

### Phase 7 — Output & human review

Present this summary (do not auto-commit):

```
Planned files:

docs/decisions/
  0001-<title>.md   Status: Proposed   <one-line summary>
  0002-<title>.md   Status: Proposed   <one-line summary>
  ...

ARCHITECTURE.md    <one-line summary — current design map>
CLAUDE.md          <one-line summary>

Open questions (未回答 vision 項目):
  - ...
  - ...
```

Ask the user to:
1. Approve as-is, or
2. Request edits to specific ADRs / CLAUDE.md (regenerate those only), or
3. Cancel and discard

After approval, write the files. Commit only if the user explicitly says so (then use the `/commit` command).

## Anti-patterns

- Fabricating constraints when the user says "未定" — leave it open
- Generating 12+ ADRs by including trivial choices — keep to 3-8
- Marking ADRs as `Accepted` — always start as `Proposed`
- Auto-committing the generated files — always require human approval
- Overwriting an existing `CLAUDE.md` or ADRs — bail out per the hard gate
- Pasting the interview transcript verbatim into ADR Context — extract the structural facts only
