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
- **`.claude/skills/` `.claude/commands/` は基本 read-only.** runtime コピーなので、変更は `.ai/` 側で行い再 sync する。
- **`.claude/project-skills/` だけが project ローカル新規作成の場所.**
- **例外: 改修して上流に戻す場合は `.claude/` 直接編集も OK.** `.claude/skills/<name>/` や `.claude/commands/<name>.md` を直接編集してプロジェクト内で動作確認した後、`/promote` または `promote-to-source.sh --skill <name>` / `--command <name>` で `.ai/claude/` に戻す。コピー後 `--resync-all` でランタイムとソースが再び一致する。
- **`.ai/` に対応 source の無い `.claude/commands/<name>.md`** は user-authored 扱い。drift 検査では `[CMD-LOCAL]` として skip される。

## 更新フロー

```bash
# source を最新化
cd .ai && git pull origin main && cd ..
git add .ai && git commit -m "chore: bump .ai submodule"

# runtime に再反映（同じスクリプトで上書き）
./.ai/claude/scripts/sync-to-project.sh --resync-all
```

## プロジェクトから ai-engineering に追加・修正する (`/promote`)

ローカルで育てた skill / command を共有資産に戻すための upstream 方向の動線：

```bash
# 何が promote 候補か確認
./.ai/claude/scripts/promote-to-source.sh --list-promotable

# 新規追加 (project-skill から Core へ)
./.ai/claude/scripts/promote-to-source.sh --skill producer-ai --scope ai

# 修正 (.claude/skills/<name>/ で編集したものを source に戻す。scope は自動検出)
./.ai/claude/scripts/promote-to-source.sh --skill adr-writer

# Command の新規追加・修正 (どちらも同じ呼び出し。auto-detect)
./.ai/claude/scripts/promote-to-source.sh --command release
```

スクリプトは copy + lint のみ。`.ai/` 側の commit & push はユーザが別途行う（submodule は別 repo なので）。Claude Code から `/promote skill <name>` を呼ぶと、その流れまで会話で誘導してくれる。詳しくは `commands/promote.md`。

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
