# claude/ — Claude Code 固有の実装層

このサブツリーは **Claude Code 固有のフォーマット・配布の仕組み** を集約する。AI ツール非依存の素材（ADR テンプレ / standards / architecture / stacks）はトップレベルに置く。

将来 `cursor/`, `gemini/`, `codex/` などのサブツリーを兄弟として追加できる構造になっている。

## 中身

| ディレクトリ | 内容 |
|---|---|
| `skills/` | Claude Code Skill（`SKILL.md` 形式、frontmatter 必須）。階層: `engineering / backend / ai / frontend` |
| `commands/` | Slash Command (`/name`)。`description:` + `argument-hint:` の最小 frontmatter |
| `templates/skill/` | 新規 Skill の雛形 (`SKILL.md.template`) |
| `templates/claude-md/` | プロジェクト用 `CLAUDE.md` のスタック別雛形 |
| `templates/project-skill-examples/` | Project Overlay のサンプル (`.claude/project-skills/` 用) |
| `scripts/` | `sync-to-project.sh` / `check-drift.sh` / `lint-skills.sh` |
| `docs/` | `sync-guide.md` / `skill-authoring.md` / `command-authoring.md` |

## ベンダ非依存な素材へのリンク

`claude/` 配下の SKILL / Command / template は、トップレベルの素材を **参照** している：

- ADR テンプレ: `../templates/adr/0000-template.md`
- スタックガイド: `../stacks/<lang>/ai-instructions.md`
- 標準: `../standards/<name>.md`
- パターン: `../architecture/patterns/<name>.md`

この設計により、`claude/` を `cursor/` や `gemini/` にコピー＋微修正することで多 AI ツール対応が可能。

## 配布

このサブツリーから各プロジェクトの `.claude/` への配布は `scripts/sync-to-project.sh`。詳細は [`docs/sync-guide.md`](docs/sync-guide.md)。
