#!/usr/bin/env bash
# Lint SKILL.md files under claude/skills: enforce frontmatter completeness and size limit.
#
# Usage:
#   ./claude/scripts/lint-skills.sh                                  # lint all skills
#   ./claude/scripts/lint-skills.sh claude/skills/engineering/adr-writer
#
# Checks:
#   - SKILL.md exists
#   - frontmatter has: name, description, version, last_updated, scope, responsibility, status, compatible_with
#   - responsibility is a single non-empty line
#   - body (after frontmatter) is <= 300 lines

set -euo pipefail

CLAUDE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAX_BODY_LINES=300
REQUIRED_FIELDS=(name description version last_updated scope responsibility status compatible_with)

fail=0

lint_skill() {
  local skill_dir="$1"
  local skill_md="$skill_dir/SKILL.md"
  local rel
  rel="$(realpath --relative-to="$CLAUDE_ROOT/.." "$skill_dir" 2>/dev/null || echo "$skill_dir")"

  if [[ ! -f "$skill_md" ]]; then
    echo "[FAIL] $rel: SKILL.md not found"
    fail=1
    return
  fi

  local fm
  fm=$(awk '/^---$/{c++; next} c==1{print} c==2{exit}' "$skill_md")

  for f in "${REQUIRED_FIELDS[@]}"; do
    if ! echo "$fm" | grep -qE "^${f}:"; then
      echo "[FAIL] $rel: missing frontmatter field '${f}'"
      fail=1
    fi
  done

  local resp
  resp=$(grep -E '^responsibility:' "$skill_md" | head -1 | sed -E 's/^responsibility: *//; s/^"//; s/"$//')
  if [[ -z "${resp// }" ]]; then
    echo "[FAIL] $rel: responsibility is empty"
    fail=1
  fi

  local body_lines
  body_lines=$(awk 'BEGIN{c=0} /^---$/{c++; next} c>=2 {print}' "$skill_md" | wc -l | tr -d ' ')
  if (( body_lines > MAX_BODY_LINES )); then
    echo "[FAIL] $rel: body is ${body_lines} lines (max ${MAX_BODY_LINES}). Split this skill."
    fail=1
  fi

  if (( fail == 0 )); then
    echo "[ OK ] $rel (${body_lines} lines)"
  fi
}

if [[ $# -gt 0 ]]; then
  for arg in "$@"; do
    lint_skill "$arg"
  done
else
  while IFS= read -r -d '' dir; do
    lint_skill "$dir"
  done < <(find "$CLAUDE_ROOT/skills" -mindepth 2 -maxdepth 2 -type d -print0)
fi

exit $fail
