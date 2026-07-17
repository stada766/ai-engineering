---
description: Run git add / commit / push without a Co-Authored-By trailer or AI-attribution footer. Stages changes, drafts a commit message that focuses on the why, and pushes by default (pass --no-push to stop at the commit).
argument-hint: [optional commit message override] [--no-push]
---

# /commit — Clean git commit + push

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

### 6. Push (default)

**Push by default.** A commit that only exists locally is work the user has to remember to finish, and this command exists to finish it.

- If upstream is set: `git push`
- If upstream is unset: `git push -u origin <current-branch>`
- If there is no remote at all: skip silently — a local-only repo is a legitimate state, not an error
- **Never** `--force` to main / master without an explicit user instruction
- Never `--no-verify`

**Stop after step 5 (do not push) when any of these hold:**

- `$ARGUMENTS` contains `--no-push`, or the user said not to push
- The push would be the repo's **first** push to a remote whose name the user has not seen this session — confirm the destination once, then push
- `git status` shows the branch is **behind** the upstream — pushing would fail or force a merge the user did not ask for. Report and let them decide between pull/rebase

Pushing publishes work to a remote others may read. That is fine for the everyday case this command serves, but it is not reversible by deleting a file — so the exceptions above are not optional politeness, they are the cases where "just push it" is the wrong default.

### 7. Report

End with a 1–2 sentence summary: SHA, file count, line delta, and push state (pushed to `<remote>/<branch>`, or why it was skipped).

## Anti-patterns

- Adding `Co-Authored-By` or AI-attribution lines (this is the whole point of this command)
- Using `git commit -m "line1\nline2"` — newlines break; use HEREDOC
- `git commit --amend` after a hook failure — creates ghost commits
- `git add .` blindly — sweeps secrets
- Force-pushing to a protected branch
- Adding the body before checking the repo's existing style (e.g., this repo uses lowercase imperative subjects)
- Leaving the commit local and telling the user to "run `git push` when ready" — that is the old behaviour; push is now the default
- Pushing a branch that is behind upstream instead of surfacing it — that turns a 5-second heads-up into a merge the user has to unpick
