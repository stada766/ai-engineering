#!/usr/bin/env bash
# promote-to-source.sh — promote (add) or update (modify) a Skill or Command
# from a project's .claude/ runtime up to the shared ai-engineering source.
#
# Run from project root (where .ai/ submodule lives).
#
# Usage:
#   ./.ai/claude/scripts/promote-to-source.sh --skill <name> [--scope <s>]
#   ./.ai/claude/scripts/promote-to-source.sh --command <name>
#   ./.ai/claude/scripts/promote-to-source.sh --list-promotable
#
# Modes (auto-detected):
#   ADD     — artifact lives only in .claude/project-skills/ or .claude/commands/ (no .ai source)
#             For skills: --scope is REQUIRED (engineering | backend | ai | frontend).
#   MODIFY  — artifact exists in both runtime and .ai/claude/ source, and they differ.
#             Runtime is treated as the new authoritative content.
#             For skills: --scope optional (existing scope is auto-detected).
#
# Notes:
#   - Refuses if runtime and source are identical (nothing to promote).
#   - Does NOT commit. The .ai submodule is a separate repo; prints next-steps instead.
#   - For modifications, suggests a version bump but does not enforce one.

set -euo pipefail

skill_name=""
target_scope=""
command_name=""
force=0
mode_request=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skill)            skill_name="$2"; mode_request="skill"; shift 2 ;;
    --command)          command_name="$2"; mode_request="command"; shift 2 ;;
    --scope)            target_scope="$2"; shift 2 ;;
    --list-promotable)  mode_request="list"; shift ;;
    --force)            force=1; shift ;;
    -h|--help)          sed -n '2,21p' "$0"; exit 0 ;;
    *)                  echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

PROJECT_ROOT="$(pwd)"
AI_DIR="$PROJECT_ROOT/.ai"
CLAUDE_SRC_DIR="$AI_DIR/claude"
RUNTIME_SKILL_DIR="$PROJECT_ROOT/.claude/skills"
RUNTIME_PROJECT_SKILLS="$PROJECT_ROOT/.claude/project-skills"
RUNTIME_COMMANDS="$PROJECT_ROOT/.claude/commands"

if [[ ! -d "$CLAUDE_SRC_DIR" ]]; then
  echo "Error: $CLAUDE_SRC_DIR not found. Run from project root with .ai submodule installed." >&2
  exit 1
fi

# --- helpers ---

find_scope_of_existing_skill() {
  local name="$1"
  for scope_dir in "$CLAUDE_SRC_DIR"/skills/*/; do
    if [[ -d "${scope_dir}${name}" ]]; then
      basename "$scope_dir"
      return 0
    fi
  done
  return 1
}

print_next_steps() {
  local relpath="$1"
  local subject="$2"
  cat <<EOS

Next: commit in the .ai submodule (separate repo):
  cd .ai
  git checkout main && git pull --rebase
  git add $relpath
  git commit -m "$subject"
  git push
  cd ..

After push, restore runtime symmetry:
  ./.ai/claude/scripts/sync-to-project.sh --resync-all
EOS
}

# --- list mode ---

list_promotable() {
  echo "ADD candidates"
  echo "  Skills in .claude/project-skills/:"
  if [[ -d "$RUNTIME_PROJECT_SKILLS" ]]; then
    local found=0
    for d in "$RUNTIME_PROJECT_SKILLS"/*/; do
      [[ -d "$d" ]] || continue
      echo "    $(basename "$d")"
      found=1
    done
    [[ $found -eq 0 ]] && echo "    (none)"
  else
    echo "    (none)"
  fi
  echo "  Commands in .claude/commands/ without source in .ai/claude/:"
  if [[ -d "$RUNTIME_COMMANDS" ]]; then
    local found=0
    for f in "$RUNTIME_COMMANDS"/*.md; do
      [[ -f "$f" ]] || continue
      local name; name="$(basename "$f" .md)"
      if [[ ! -f "$CLAUDE_SRC_DIR/commands/$name.md" ]]; then
        echo "    $name"
        found=1
      fi
    done
    [[ $found -eq 0 ]] && echo "    (none)"
  else
    echo "    (none)"
  fi

  echo
  echo "MODIFY candidates (runtime differs from .ai/claude/ source)"
  echo "  Skills:"
  if [[ -d "$RUNTIME_SKILL_DIR" ]]; then
    local found=0
    for d in "$RUNTIME_SKILL_DIR"/*/; do
      [[ -d "$d" ]] || continue
      local name; name="$(basename "$d")"
      local scope; scope="$(find_scope_of_existing_skill "$name" || true)"
      [[ -z "$scope" ]] && continue
      if ! diff -rq "$d" "$CLAUDE_SRC_DIR/skills/$scope/$name" >/dev/null 2>&1; then
        echo "    $name (scope: $scope)"
        found=1
      fi
    done
    [[ $found -eq 0 ]] && echo "    (none)"
  else
    echo "    (none)"
  fi
  echo "  Commands:"
  if [[ -d "$RUNTIME_COMMANDS" ]]; then
    local found=0
    for f in "$RUNTIME_COMMANDS"/*.md; do
      [[ -f "$f" ]] || continue
      local name; name="$(basename "$f" .md)"
      local src="$CLAUDE_SRC_DIR/commands/$name.md"
      [[ -f "$src" ]] || continue
      if ! diff -q "$f" "$src" >/dev/null 2>&1; then
        echo "    $name"
        found=1
      fi
    done
    [[ $found -eq 0 ]] && echo "    (none)"
  else
    echo "    (none)"
  fi
}

# --- skill promotion ---

promote_skill() {
  local name="$skill_name"
  local project_src="$RUNTIME_PROJECT_SKILLS/$name"
  local runtime_src="$RUNTIME_SKILL_DIR/$name"
  local action="" src="" dst="" effective_scope=""

  if [[ -d "$project_src" ]]; then
    action="add"
    src="$project_src"
    if [[ -z "$target_scope" ]]; then
      echo "Error: --scope is required when promoting from .claude/project-skills/ (engineering | backend | ai | frontend)." >&2
      exit 1
    fi
    if [[ ! "$target_scope" =~ ^(engineering|backend|ai|frontend)$ ]]; then
      echo "Error: invalid scope '$target_scope'." >&2
      exit 1
    fi
    effective_scope="$target_scope"
    dst="$CLAUDE_SRC_DIR/skills/$effective_scope/$name"
    if [[ -d "$dst" && $force -eq 0 ]]; then
      echo "Error: $dst already exists. Did you mean to modify? If so, work on the runtime copy at .claude/skills/$name/ instead." >&2
      exit 1
    fi
  elif [[ -d "$runtime_src" ]]; then
    action="modify"
    src="$runtime_src"
    local existing_scope
    existing_scope="$(find_scope_of_existing_skill "$name" || true)"
    if [[ -z "$existing_scope" ]]; then
      echo "Error: $runtime_src exists in runtime but has no source in .ai/claude/skills/. Did you mean to add it?" >&2
      echo "       Move it to .claude/project-skills/$name/ and re-run with --scope <s>." >&2
      exit 1
    fi
    effective_scope="${target_scope:-$existing_scope}"
    if [[ -n "$target_scope" && "$target_scope" != "$existing_scope" ]]; then
      echo "Note: skill is moving scope: $existing_scope -> $effective_scope"
    fi
    dst="$CLAUDE_SRC_DIR/skills/$effective_scope/$name"
    if diff -rq "$src" "$CLAUDE_SRC_DIR/skills/$existing_scope/$name" >/dev/null 2>&1; then
      echo "Nothing to do: runtime and source are identical for skill '$name'."
      exit 0
    fi
    if [[ "$effective_scope" != "$existing_scope" && -d "$dst" && $force -eq 0 ]]; then
      echo "Error: $dst already exists. Use --force to overwrite, or pick a different --scope." >&2
      exit 1
    fi
    # remove old location if scope is changing
    if [[ "$effective_scope" != "$existing_scope" ]]; then
      rm -rf "$CLAUDE_SRC_DIR/skills/$existing_scope/$name"
    fi
  else
    echo "Error: no skill named '$name' found in .claude/project-skills/ or .claude/skills/." >&2
    exit 1
  fi

  rm -rf "$dst"
  cp -R "$src" "$dst"

  # Normalize scope field in frontmatter
  if [[ -f "$dst/SKILL.md" ]]; then
    local tmp; tmp="$(mktemp)"
    awk -v s="$effective_scope" '
      /^scope: / && !done { print "scope: " s; done=1; next }
      { print }
    ' "$dst/SKILL.md" > "$tmp"
    mv "$tmp" "$dst/SKILL.md"
  fi

  echo "[ OK ] promoted skill ($action): $name -> .ai/claude/skills/$effective_scope/$name"
  if [[ "$action" == "modify" ]]; then
    echo "      Consider bumping the 'version:' field in the SKILL.md before committing."
  fi
  echo
  echo "Running lint on the promoted skill:"
  bash "$CLAUDE_SRC_DIR/scripts/lint-skills.sh" "$dst" || {
    echo
    echo "[WARN] Lint reported issues. Fix in the source before committing."
  }

  print_next_steps \
    "claude/skills/$effective_scope/$name" \
    "$( [[ "$action" == "add" ]] && echo "feat(skill): add $name" || echo "feat(skill): update $name" )"
}

# --- command promotion ---

promote_command() {
  local name="$command_name"
  local src="$RUNTIME_COMMANDS/${name}.md"
  local dst="$CLAUDE_SRC_DIR/commands/${name}.md"
  local action=""

  if [[ ! -f "$src" ]]; then
    echo "Error: $src not found." >&2
    exit 1
  fi

  if [[ -f "$dst" ]]; then
    if diff -q "$src" "$dst" >/dev/null 2>&1; then
      echo "Nothing to do: runtime and source are identical for command '$name'."
      exit 0
    fi
    action="modify"
  else
    action="add"
  fi

  cp "$src" "$dst"
  echo "[ OK ] promoted command ($action): $name -> .ai/claude/commands/${name}.md"

  print_next_steps \
    "claude/commands/${name}.md" \
    "$( [[ "$action" == "add" ]] && echo "feat(command): add /$name" || echo "feat(command): update /$name" )"
}

# --- dispatch ---

case "$mode_request" in
  list)    list_promotable ;;
  skill)
    [[ -n "$skill_name" ]] || { echo "Error: --skill requires a name." >&2; exit 1; }
    promote_skill
    ;;
  command)
    [[ -n "$command_name" ]] || { echo "Error: --command requires a name." >&2; exit 1; }
    promote_command
    ;;
  "")
    echo "Nothing to do. Pass --skill <name> [--scope <s>], --command <name>, or --list-promotable." >&2
    exit 1
    ;;
esac
