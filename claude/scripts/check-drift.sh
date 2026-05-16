#!/usr/bin/env bash
# Detect drift between .ai/claude (source) and .claude (runtime copy) — both skills and commands.
#
# Run from project root. Exit non-zero if drift found.
#
# Compares:
#   - .ai/claude/skills/<scope>/<name>  vs .claude/skills/<name>     (full content + SKILL.md version)
#   - .ai/claude/commands/<name>.md     vs .claude/commands/<name>.md (full content)
#
# project-skills/ and user-authored commands (no .ai source) are skipped with a note.

set -euo pipefail

PROJECT_ROOT="$(pwd)"
AI_DIR="$PROJECT_ROOT/.ai"
CLAUDE_SRC_DIR="$AI_DIR/claude"
RUNTIME_SKILL_DIR="$PROJECT_ROOT/.claude/skills"
RUNTIME_CMD_DIR="$PROJECT_ROOT/.claude/commands"

drift=0

if [[ -d "$RUNTIME_SKILL_DIR" ]]; then
  for runtime_skill in "$RUNTIME_SKILL_DIR"/*/; do
    [[ -d "$runtime_skill" ]] || continue
    name="$(basename "$runtime_skill")"

    src=""
    for scope_dir in "$CLAUDE_SRC_DIR"/skills/*/; do
      if [[ -d "${scope_dir}${name}" ]]; then
        src="${scope_dir}${name}"
        break
      fi
    done

    if [[ -z "$src" ]]; then
      echo "[SKILL-ORPHAN] .claude/skills/$name has no source in .ai/claude/"
      drift=1
      continue
    fi

    src_v=$(grep -E '^version:' "$src/SKILL.md" 2>/dev/null | head -1 | awk '{print $2}')
    dst_v=$(grep -E '^version:' "$runtime_skill/SKILL.md" 2>/dev/null | head -1 | awk '{print $2}')
    if [[ "$src_v" != "$dst_v" ]]; then
      echo "[SKILL-VERSION] $name: source=$src_v runtime=$dst_v"
      drift=1
    fi

    if ! diff -rq "$src" "$runtime_skill" >/dev/null 2>&1; then
      echo "[SKILL-DIFF]    $name: file contents differ between source and runtime"
      drift=1
    fi
  done
fi

if [[ -d "$RUNTIME_CMD_DIR" ]]; then
  for runtime_cmd in "$RUNTIME_CMD_DIR"/*.md; do
    [[ -f "$runtime_cmd" ]] || continue
    name="$(basename "$runtime_cmd" .md)"
    src="$CLAUDE_SRC_DIR/commands/${name}.md"

    if [[ ! -f "$src" ]]; then
      echo "[CMD-LOCAL]   .claude/commands/$name.md has no source in .ai/claude/ (user-authored)"
      continue
    fi

    if ! diff -q "$src" "$runtime_cmd" >/dev/null 2>&1; then
      echo "[CMD-DIFF]    $name: file contents differ between source and runtime"
      drift=1
    fi
  done
fi

if (( drift == 0 )); then
  echo "No drift detected."
fi
exit $drift
