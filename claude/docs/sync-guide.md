# Sync Guide

各プロジェクトへの配布手順。**Submodule = source, Copy = runtime** モデル。

## 初期セットアップ

```bash
cd /path/to/your-project

# 1. submodule として追加（source-of-truth）
git submodule add https://github.com/stada766/ai-engineering.git .ai

# 2. .claude/ ディレクトリ（runtime）
mkdir -p .claude/skills .claude/project-skills

# 3. 必要な Skill と Command だけコピー
./.ai/claude/scripts/sync-to-project.sh \
  --skill engineering/adr-writer \
  --skill engineering/tdd-enforcer \
  --skill ai/prompt-review \
  --command bootstrap \
  --command commit \
  --command adr \
  --command claude-md
```

利用可能なものを一覧したいときは `--list` / `--list-commands`。

## ディレクトリ規約

```
your-project/
├── .ai/                          # ← submodule (source / read-only)
│   ├── claude/
│   │   ├── skills/...
│   │   ├── commands/...
│   │   └── templates/...
│   ├── stacks/                   # ベンダ非依存のスタックガイド
│   ├── standards/
│   └── architecture/
└── .claude/                      # ← runtime (Claude Code が読む)
    ├── skills/                   # コピーされた Core Skill
    │   ├── adr-writer/
    │   └── tdd-enforcer/
    ├── commands/                 # コピーされた Slash Command (/bootstrap, /commit, ...)
    │   ├── bootstrap.md
    │   └── commit.md
    └── project-skills/           # プロジェクト固有 (手書き)
        └── infinite-radio-architecture/
```

## 編集権限ルール

- **`.ai/` を直接編集しない.** 編集したい場合は `ai-engineering` リポジトリ側を変更し PR → submodule update。
- **`.claude/skills/` も直接編集しない.** runtime コピーなので、変更は `.ai/` 側で行い再 sync する。
- **`.claude/commands/` も同様.** ただし `.ai/` に対応 source の無い command はプロジェクト固有とみなされ drift 検査で skip される（user-authored）。
- **`.claude/project-skills/` だけが project ローカルの編集対象.**

## 更新フロー

```bash
# source を最新化
cd .ai && git pull origin main && cd ..
git add .ai && git commit -m "chore: bump .ai submodule"

# runtime に再反映（同じスクリプトで上書き）
./.ai/claude/scripts/sync-to-project.sh --resync-all
```

## Drift 検出

コピー運用は **静かな分岐** が起きやすい。CI で検出する：

```bash
./.ai/claude/scripts/check-drift.sh
# .ai/claude/skills/engineering/adr-writer/SKILL.md の version != .claude/skills/adr-writer/SKILL.md の version
# のような不一致を報告
```

## なぜ symlink を使わないか

- Windows / WSL / Docker bind mount / Remote container / CI で fragile
- 編集 authority が曖昧になる（`.claude/` を直接編集してしまう）
- Project Overlay と Core の境界が視覚的にわかりにくい

実体コピーは「pruning しやすい」「snapshot 化できる」「CI 検査しやすい」というメリットが大きい。
