#!/usr/bin/env bash
# install.sh — bootstrap a new project to use ai-engineering
#
# Usage (from your project root, AFTER `git clone` of YOUR project):
#   curl -fsSL https://raw.githubusercontent.com/stada766/ai-engineering/main/install.sh | bash
#
# What it does:
#   1. Adds ai-engineering as a git submodule at .ai
#   2. Creates .claude/{skills,commands,project-skills}
#   3. Syncs everything in claude/always-include.txt (the configurable
#      default toolkit). Edit that file in ai-engineering to change defaults.
#
# After install:
#   - Start `claude` (Claude Code) in this directory
#   - In Claude: /bootstrap <one-line vision>  -> generates ADRs + CLAUDE.md
#   - In Claude: /sync-recommended             -> Claude picks more Skills/Commands

set -euo pipefail

REPO_URL="${AI_ENGINEERING_REPO:-https://github.com/stada766/ai-engineering.git}"

if [[ ! -d .git ]]; then
  echo "Error: not a git repository." >&2
  echo "       Run from your project root after \`git init\` or \`git clone\`." >&2
  exit 1
fi

echo "1/3  Adding ai-engineering as submodule (.ai)..."
if [[ -d .ai ]]; then
  echo "     .ai already exists. Skipping submodule add."
  echo "     (Run 'cd .ai && git pull origin main' later to update the playbook.)"
else
  git submodule add "$REPO_URL" .ai
fi

echo "2/3  Ensuring .claude/{skills,commands,project-skills} exist..."
mkdir -p .claude/skills .claude/commands .claude/project-skills

echo "3/3  Syncing always-include toolkit..."
./.ai/claude/scripts/sync-to-project.sh --always

cat <<'EOS'

Done.

Next steps:
  1. Start Claude Code in this directory:
       claude
  2. In Claude, generate ADRs + CLAUDE.md from your vision:
       /bootstrap <one-line description of what you're building>
  3. After /bootstrap completes, let Claude pick more tooling:
       /sync-recommended
  4. Iterate:
       /adr <decision>       — new ADR
       /claude-md            — refresh CLAUDE.md
       /commit               — commit without Co-Authored-By
       /promote skill <name> — push a local Skill back to ai-engineering

EOS
