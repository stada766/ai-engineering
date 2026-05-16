#!/usr/bin/env bash
# Sync selected skills from .ai (submodule) to .claude/skills (runtime).
#
# Run from project root (where .ai/ submodule lives).
#
# Usage:
#   ./.ai/scripts/sync-to-project.sh --skill engineering/adr-writer
#   ./.ai/scripts/sync-to-project.sh --skill engineering/adr-writer --skill ai/prompt-review
#   ./.ai/scripts/sync-to-project.sh --resync-all     # re-copy every skill already in .claude/skills
#   ./.ai/scripts/sync-to-project.sh --list           # list available skills in .ai/
#
# Notes:
#   - Source is .ai/skills/<scope>/<name>
#   - Destination is .claude/skills/<name>   (flat, scope stripped at runtime)
#   - project-skills/ is never touched.

set -euo pipefail

PROJECT_ROOT="$(pwd)"
AI_DIR="$PROJECT_ROOT/.ai"
RUNTIME_DIR="$PROJECT_ROOT/.claude/skills"

if [[ ! -d "$AI_DIR/skills" ]]; then
  echo "Error: $AI_DIR/skills not found. Run from project root with .ai submodule installed." >&2
  exit 1
fi

mkdir -p "$RUNTIME_DIR"

copy_skill() {
  local scoped_name="$1"     # e.g. engineering/adr-writer
  local src="$AI_DIR/skills/$scoped_name"
  local name="${scoped_name##*/}"
  local dst="$RUNTIME_DIR/$name"

  if [[ ! -d "$src" ]]; then
    echo "[SKIP] $scoped_name not found in .ai/skills/"
    return
  fi

  rm -rf "$dst"
  cp -R "$src" "$dst"
  echo "[ OK ] $scoped_name -> .claude/skills/$name"
}

list_skills() {
  find "$AI_DIR/skills" -mindepth 2 -maxdepth 2 -type d \
    | sed "s|$AI_DIR/skills/||" \
    | sort
}

resync_all() {
  if [[ ! -d "$RUNTIME_DIR" ]]; then
    echo "No .claude/skills/ to resync."
    return
  fi
  for dst in "$RUNTIME_DIR"/*/; do
    [[ -d "$dst" ]] || continue
    local name
    name="$(basename "$dst")"
    # Find the scope this skill lives under in .ai/
    local found=""
    for scope_dir in "$AI_DIR"/skills/*/; do
      if [[ -d "${scope_dir}${name}" ]]; then
        found="$(basename "$scope_dir")/$name"
        break
      fi
    done
    if [[ -n "$found" ]]; then
      copy_skill "$found"
    else
      echo "[WARN] $name in runtime but not in .ai/ (orphan — review manually)"
    fi
  done
}

skills=()
mode="copy"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skill) skills+=("$2"); shift 2 ;;
    --resync-all) mode="resync"; shift ;;
    --list) mode="list"; shift ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

case "$mode" in
  list) list_skills ;;
  resync) resync_all ;;
  copy)
    if [[ ${#skills[@]} -eq 0 ]]; then
      echo "No --skill specified. Use --list to see available skills." >&2
      exit 1
    fi
    for s in "${skills[@]}"; do copy_skill "$s"; done
    ;;
esac
