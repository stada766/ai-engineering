#!/usr/bin/env bash
# Sync selected skills and commands from .ai/claude (submodule) to .claude (runtime).
#
# Run from project root (where .ai/ submodule lives).
#
# Usage:
#   ./.ai/claude/scripts/sync-to-project.sh --skill engineering/adr-writer
#   ./.ai/claude/scripts/sync-to-project.sh --skill engineering/adr-writer --command bootstrap
#   ./.ai/claude/scripts/sync-to-project.sh --command commit --command adr --command claude-md
#   ./.ai/claude/scripts/sync-to-project.sh --resync-all          # re-copy everything already in .claude/
#   ./.ai/claude/scripts/sync-to-project.sh --list                # list available skills in .ai/claude/
#   ./.ai/claude/scripts/sync-to-project.sh --list-commands       # list available commands in .ai/claude/
#
# Notes:
#   - Skills source:   .ai/claude/skills/<scope>/<name>  -> .claude/skills/<name>
#   - Commands source: .ai/claude/commands/<name>.md     -> .claude/commands/<name>.md
#   - project-skills/ and any user-authored commands in .claude/commands/ are never touched.

set -euo pipefail

PROJECT_ROOT="$(pwd)"
AI_DIR="$PROJECT_ROOT/.ai"
CLAUDE_SRC_DIR="$AI_DIR/claude"
RUNTIME_SKILL_DIR="$PROJECT_ROOT/.claude/skills"
RUNTIME_CMD_DIR="$PROJECT_ROOT/.claude/commands"

if [[ ! -d "$CLAUDE_SRC_DIR/skills" && ! -d "$CLAUDE_SRC_DIR/commands" ]]; then
  echo "Error: $CLAUDE_SRC_DIR has no skills/ or commands/. Run from project root with .ai submodule installed." >&2
  exit 1
fi

mkdir -p "$RUNTIME_SKILL_DIR" "$RUNTIME_CMD_DIR"

copy_skill() {
  local scoped_name="$1"
  local src="$CLAUDE_SRC_DIR/skills/$scoped_name"
  local name="${scoped_name##*/}"
  local dst="$RUNTIME_SKILL_DIR/$name"

  if [[ ! -d "$src" ]]; then
    echo "[SKIP] skill $scoped_name not found in .ai/claude/skills/"
    return
  fi

  rm -rf "$dst"
  cp -R "$src" "$dst"
  echo "[ OK ] skill   $scoped_name -> .claude/skills/$name"
}

copy_command() {
  local name="$1"
  local src="$CLAUDE_SRC_DIR/commands/${name}.md"
  local dst="$RUNTIME_CMD_DIR/${name}.md"

  if [[ ! -f "$src" ]]; then
    echo "[SKIP] command $name not found in .ai/claude/commands/"
    return
  fi

  cp "$src" "$dst"
  echo "[ OK ] command $name -> .claude/commands/$name.md"
}

list_skills() {
  find "$CLAUDE_SRC_DIR/skills" -mindepth 2 -maxdepth 2 -type d \
    | sed "s|$CLAUDE_SRC_DIR/skills/||" \
    | sort
}

list_commands() {
  find "$CLAUDE_SRC_DIR/commands" -mindepth 1 -maxdepth 1 -name '*.md' -type f \
    | sed "s|$CLAUDE_SRC_DIR/commands/||; s|\\.md\$||" \
    | sort
}

resync_all() {
  if [[ -d "$RUNTIME_SKILL_DIR" ]]; then
    for dst in "$RUNTIME_SKILL_DIR"/*/; do
      [[ -d "$dst" ]] || continue
      local name; name="$(basename "$dst")"
      local found=""
      for scope_dir in "$CLAUDE_SRC_DIR"/skills/*/; do
        if [[ -d "${scope_dir}${name}" ]]; then
          found="$(basename "$scope_dir")/$name"
          break
        fi
      done
      if [[ -n "$found" ]]; then
        copy_skill "$found"
      else
        echo "[WARN] skill $name in runtime but not in .ai/claude/ (orphan)"
      fi
    done
  fi

  if [[ -d "$RUNTIME_CMD_DIR" ]]; then
    for dst in "$RUNTIME_CMD_DIR"/*.md; do
      [[ -f "$dst" ]] || continue
      local name; name="$(basename "$dst" .md)"
      if [[ -f "$CLAUDE_SRC_DIR/commands/${name}.md" ]]; then
        copy_command "$name"
      else
        echo "[WARN] command $name in runtime but not in .ai/claude/ (orphan — likely user-authored, skipped)"
      fi
    done
  fi
}

skills=()
commands=()
mode="copy"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skill)         skills+=("$2"); shift 2 ;;
    --command)       commands+=("$2"); shift 2 ;;
    --resync-all)    mode="resync"; shift ;;
    --list)          mode="list-skills"; shift ;;
    --list-commands) mode="list-commands"; shift ;;
    -h|--help)       sed -n '2,18p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

case "$mode" in
  list-skills)   list_skills ;;
  list-commands) list_commands ;;
  resync)        resync_all ;;
  copy)
    if [[ ${#skills[@]} -eq 0 && ${#commands[@]} -eq 0 ]]; then
      echo "Nothing to do. Pass --skill <scope/name> or --command <name>, or use --list / --list-commands." >&2
      exit 1
    fi
    for s in "${skills[@]}";   do copy_skill "$s"; done
    for c in "${commands[@]}"; do copy_command "$c"; done
    ;;
esac
