---
description: Create or update ARCHITECTURE.md — the project's single living source of truth for the CURRENT design. Reconciles Accepted ADRs into the doc; keeps Why in ADRs, What-now in the doc.
argument-hint: [optional focus, e.g. "reflect ADR-0005" or "refresh building blocks"]
---

# /architecture — Maintain the living Architecture Doc

Focus (optional): $ARGUMENTS

`ARCHITECTURE.md` (project root) is the **single source of truth for the current design**. This command creates it if missing, or reconciles it with reality (ADRs, code, CLAUDE.md) if it exists. See `standards/documentation-model.md` for the 3-layer model (ADR / Architecture Doc / Design Doc).

## Core rule

- **What-now → ARCHITECTURE.md.** **Why → ADR.** Do not duplicate decision rationale into the doc; link to the ADR instead.
- The doc describes the **current** design only. Superseded decisions do not appear (they live in `docs/decisions/`).

## Mode A — Create (ARCHITECTURE.md does not exist)

1. Read `CLAUDE.md` and every file under `docs/decisions/` (and skim key source dirs) to extract: purpose / non-goals / constraints / runtime topology / main components / cross-cutting concerns.
2. Start from the template `.ai/templates/architecture/overview-template.md`.
3. Fill each section from evidence only. **Do not fabricate** — mark unknowns as `<未定>` in §7 Open Questions.
4. Build the §5 Key Decisions table by listing every **Accepted** (not Superseded) ADR: area / current choice / `ADR-NNNN` link.
5. Set frontmatter `last_updated` to today, `status: draft`.
6. Write to `ARCHITECTURE.md` at project root. Show the user; do not auto-commit.

## Mode B — Reconcile (ARCHITECTURE.md exists)

1. Read the current `ARCHITECTURE.md`, all ADRs, and `CLAUDE.md`.
2. Detect drift:
   - **New Accepted ADRs** not yet reflected → add/update the relevant section and the §5 table.
   - **Newly Superseded / Deprecated ADRs** still listed as current → remove from §5 (they stay in `docs/decisions/`).
   - Building blocks / cross-cutting concerns that no longer match the code or CLAUDE.md.
3. If `$ARGUMENTS` names a focus (e.g. "reflect ADR-0005"), scope the update to that; otherwise do a full reconcile.
4. Edit **only** the sections that changed. Do not rewrite untouched prose. Preserve author wording where still accurate.
5. Bump frontmatter `last_updated` to today. Bump `version` minor if the change is structural.
6. Summarize the diff for the user (what drifted, what you changed). Do not auto-commit.

## When to invoke

- After a design-changing PR (update the current picture in the same PR).
- After an ADR moves to **Accepted** (reflect its conclusion here).
- After an ADR is **Superseded / Deprecated** (drop it from §5).
- When onboarding someone and the overview feels stale.

## When to refuse / redirect

- User wants to record **why** a decision was made → that is an ADR; use `/adr`.
- User wants to propose an **unimplemented** future design → that is a Design Doc (`.ai/templates/design/0000-template.md`), not this doc.
- User wants to edit a **Superseded** decision's rationale → refuse; ADRs are append-only (supersede instead).

## Anti-patterns

- Copying ADR rationale into ARCHITECTURE.md (double-maintenance) — link instead.
- Listing Superseded ADRs in §5 (the doc must show only the current design).
- Rewriting the whole file on a small reconcile — touch only drifted sections.
- Fabricating components or decisions not backed by ADRs / code — mark `<未定>` in Open Questions.
- Marking `status: stable` while §7 still has unresolved `<未定>` blockers.
- Auto-committing — always leave the write for human review.
