#!/usr/bin/env bash
# Detect drift between .ai/skills (source) and .claude/skills (runtime copy).
#
# Run from project root. Exit non-zero if drift found.
#
# Compares SKILL.md `version` and full content. project-skills/ is ignored.

set -euo pipefail

PROJECT_ROOT="$(pwd)"
AI_DIR="$PROJECT_ROOT/.ai"
RUNTIME_DIR="$PROJECT_ROOT/.claude/skills"

if [[ ! -d "$RUNTIME_DIR" ]]; then
  echo "No .claude/skills/ — nothing to check."
  exit 0
fi

drift=0

for runtime_skill in "$RUNTIME_DIR"/*/; do
  [[ -d "$runtime_skill" ]] || continue
  name="$(basename "$runtime_skill")"

  # Find source location
  src=""
  for scope_dir in "$AI_DIR"/skills/*/; do
    if [[ -d "${scope_dir}${name}" ]]; then
      src="${scope_dir}${name}"
      break
    fi
  done

  if [[ -z "$src" ]]; then
    echo "[ORPHAN] .claude/skills/$name has no source in .ai/"
    drift=1
    continue
  fi

  # Compare version
  src_v=$(grep -E '^version:' "$src/SKILL.md" 2>/dev/null | head -1 | awk '{print $2}')
  dst_v=$(grep -E '^version:' "$runtime_skill/SKILL.md" 2>/dev/null | head -1 | awk '{print $2}')
  if [[ "$src_v" != "$dst_v" ]]; then
    echo "[VERSION] $name: source=$src_v runtime=$dst_v"
    drift=1
  fi

  # Compare full content
  if ! diff -rq "$src" "$runtime_skill" >/dev/null 2>&1; then
    echo "[DIFF]    $name: file contents differ between source and runtime"
    drift=1
  fi
done

if (( drift == 0 )); then
  echo "No drift detected."
fi
exit $drift
