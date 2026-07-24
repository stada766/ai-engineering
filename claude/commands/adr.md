---
description: Write a new Architecture Decision Record for a single decision, following the adr-writer skill conventions (Options Considered, Quality Checklist, Status Proposed).
argument-hint: <short title or one-line decision>
---

# /adr — Write a single ADR

Decision input: $ARGUMENTS

## Procedure

Invoke the `adr-writer` skill (`.claude/skills/adr-writer/SKILL.md` when sync'd, source at `.ai/claude/skills/engineering/adr-writer/SKILL.md`). If the skill is not sync'd into this project, follow the inline procedure below.

### Inline summary (when adr-writer is not sync'd)

1. Extract from `$ARGUMENTS` and the conversation:
   - **Context**: why this decision is needed now
   - **Decision**: one-sentence "We will ..."
   - **Options Considered**: at least 2 alternatives, each with Strengths / Weaknesses / Operational impact
   - **Consequences**: Positive / Negative / Neutral
2. Look at `docs/decisions/` for the next number `NNNN`. **Do not renumber existing files.**
3. Check for conflict with existing ADRs:
   - If this decision **overturns** a prior one, write this as a new ADR and update the prior ADR's `Status:` to `Superseded by NNNN`. Do not rewrite the prior content.
4. Use `.ai/templates/adr/0000-template.md` as the structural template
5. File path: `docs/decisions/NNNN-<kebab-title>.md`
6. `Status: Proposed` (human elevates to `Accepted` on merge)
7. Apply the Quality Checklist (see adr-writer skill)
8. **Reflect into the living doc**: when this ADR becomes `Accepted`, its conclusion must be reflected into `ARCHITECTURE.md` (§5 Key Decisions + the relevant section). Run `/architecture` to reconcile — the ADR carries the *why*, `ARCHITECTURE.md` carries the *current design*. See `standards/documentation-model.md`.

### When to refuse / redirect

- User wants to record **multiple** unrelated decisions → write multiple ADRs, one per file
- User wants to amend an old decision in place → refuse; explain superseding instead
- The "decision" is an implementation detail or a default that ships with the stack → suggest skipping the ADR

## Anti-patterns

- Empty Options Considered
- Decision sentence contains "and" linking two unrelated changes — split into two ADRs
- Renaming or renumbering existing ADRs
- Marking as `Accepted` without explicit user instruction
- Pasting chat transcript as Context — extract the structural facts only
