---
description: Run git add / commit / push without a Co-Authored-By trailer or AI-attribution footer. Stages changes, drafts a commit message that focuses on the why, and pushes if upstream is configured.
argument-hint: [optional commit message override]
---

# /commit — Clean git commit + optional push

Optional message override: $ARGUMENTS

## Procedure

### 1. Inspect

Run in parallel:

- `git status` (do NOT use `-uall` — it can OOM on large repos)
- `git diff` (staged and unstaged)
- `git log --oneline -10` to learn this repo's commit style

### 2. Draft

Classify the change: `feat` / `fix` / `refactor` / `chore` / `docs` / `test`.

Write a commit message that:

- Focuses on **why**, not what (the diff says what)
- Matches the repo's existing prefix / mood / subject convention
- Fits the first line in ~70 chars
- Optionally adds a body explaining context, trade-offs, follow-ups

If `$ARGUMENTS` is non-empty, treat it as either the full message or a hint to incorporate (use judgement).

**Excluded from the message** (do not add these):

- `Co-Authored-By: Claude ... <noreply@anthropic.com>`
- `🤖 Generated with [Claude Code](...)` or similar attribution footers
- Any other AI-authorship trailers

### 3. Stage

Prefer **named files** over `git add -A` or `git add .` to avoid sweeping in:

- `.env`, `credentials.*`, `*.pem`, `*.key` (warn the user if these are dirty)
- Large binaries the user did not mean to commit
- Editor / OS junk that should be in `.gitignore`

Use `git add -A` only if the user explicitly asked for "all changes" and the inspection showed nothing sensitive.

### 4. Commit (HEREDOC form)

```
git commit -m "$(cat <<'EOF'
<subject>

<body if any>
EOF
)"
```

The HEREDOC form preserves newlines and special characters.

### 5. Verify

Run `git status` — working tree should be clean.

If a pre-commit hook fails:

- The commit did **not** happen — do not `--amend`
- Fix the underlying issue
- Re-stage and create a **new** commit (not amend)

### 6. Push (only if requested)

Push only when the user explicitly said "push" or implied it (e.g., "上げて", "commit して push して"). Otherwise stop after step 5.

- If upstream is unset: `git push -u origin <current-branch>`
- If upstream is set: `git push`
- **Never** `--force` to main / master without an explicit user instruction
- Never `--no-verify`

### 7. Report

End with a 1–2 sentence summary: SHA, file count, line delta, and push state.

## Anti-patterns

- Adding `Co-Authored-By` or AI-attribution lines (this is the whole point of this command)
- Using `git commit -m "line1\nline2"` — newlines break; use HEREDOC
- `git commit --amend` after a hook failure — creates ghost commits
- `git add .` blindly — sweeps secrets
- Force-pushing to a protected branch
- Adding the body before checking the repo's existing style (e.g., this repo uses lowercase imperative subjects)
