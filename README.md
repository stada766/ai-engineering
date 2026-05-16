# ai-engineering

**AI Native Engineering Playbook** — AI と協働するための再利用可能な思想・規約・スキルを束ねるリポジトリ。

特定の AI ツールに依存しない **エンジニアリング知識** をトップレベルに、Claude Code / Cursor などツール固有の実装は **各ツール名のサブツリー** に格納する。

## コア思想

- **`.ai/` is source, `.claude/` is runtime.** このリポジトリは source-of-truth。各プロジェクトの `.claude/` （や将来の他ツール runtime）にはここから **コピー** で配布する。
- **1 skill = 1 responsibility.** すべての `SKILL.md` は単一責務、frontmatter の `responsibility:` フィールドで明文化、本文 300 行以下。
- **Core (共有) と Overlay (固有) は物理分離.** プロジェクト固有思想は `project/.claude/project-skills/` に隔離する。Core に混ぜない。
- **必要な skill だけコピー.** 全部入り同期は AI コンテキストを肥大化させる。Pruning は機能。
- **ライフサイクル管理.** AI プロンプト資産も技術的負債化する。`status` と `superseded_by` で寿命を管理する。
- **ベンダ非依存と固有実装の分離.** ADR / 標準 / アーキテクチャパターン / スタックガイドは AI ツール非依存。Skill / Command / `.claude/` 配布の仕組みは `claude/` 配下。将来 `cursor/` `gemini/` などを兄弟として追加できる。

詳しくは [`docs/philosophy.md`](docs/philosophy.md)。

## ディレクトリ

```
claude/                              Claude Code 固有の実装
  skills/                              AI 自動発動の lens / mode (階層: engineering / backend / ai / frontend)
  commands/                            ユーザ明示起動の Slash Command (/bootstrap, /commit, /adr, /claude-md)
  templates/
    skill/                             SKILL.md 雛形
    claude-md/                         プロジェクト用 CLAUDE.md の雛形 (スタック別)
    project-skill-examples/            Project Overlay のサンプル
  scripts/                             sync / drift / lint
  docs/                                Claude Code 固有のドキュメント (sync-guide / skill-authoring / command-authoring)

# ↓ ここから下は AI ツール非依存
prompts/                             軽量な再利用プロンプト
standards/                           言語横断のコーディング哲学
architecture/patterns/               アーキテクチャパターン
stacks/                              スタック別ガイド (node-typescript / flutter / python-ai)
templates/
  adr/                                 ADR テンプレート (Nygard)
  pr-description.md                    PR 説明
docs/
  decisions/                           このリポジトリ自体の ADR
  philosophy.md                        思想
```

### Skill と Command の違い

- **Skill** — AI が `description:` を読んで自動発動する **lens / mode**。実装中の TDD、レビュー時の architecture-review など。
- **Command** — ユーザが `/name` で明示起動する **ritual / action**。プロジェクト初期化 `/bootstrap`、コミット `/commit` など。
- **両建て** — `/adr` `/claude-md` は Skill（手順の本体）と Command（薄いエントリ）両方を持つ。

## Quick Start (新規プロジェクト)

```bash
# 1. GitHub で空 repo 作成 → git clone → cd
git clone <your-new-empty-repo-url> && cd <project>

# 2. install.sh をワンライナーで実行（submodule + 最小キット sync）
curl -fsSL https://raw.githubusercontent.com/stada766/ai-engineering/main/install.sh | bash

# 3. Claude Code を起動
claude

# 4. (Claude 内) vision から ADR + CLAUDE.md を生成
/bootstrap <一行で何を作るか>

# 5. (Claude 内) 生成物を読んで Claude が必要な Skill / Command を推薦・sync
/sync-recommended

# 6. 以降の運用
#   /adr <decision>          新しい設計判断
#   /claude-md               CLAUDE.md 更新
#   /commit                  Co-Authored-By 無しでコミット
#   /promote skill <name>    project-skill を ai-engineering に昇格
```

## 既存プロジェクトに追加するとき

```bash
git submodule add https://github.com/stada766/ai-engineering.git .ai
mkdir -p .claude/{skills,commands,project-skills}
./.ai/claude/scripts/sync-to-project.sh \
  --skill engineering/adr-writer \
  --skill engineering/tdd-enforcer \
  --command bootstrap \
  --command commit \
  --command adr
```

詳しくは [`claude/docs/sync-guide.md`](claude/docs/sync-guide.md)。

## Skill / Command を書く

- Skill: [`claude/docs/skill-authoring.md`](claude/docs/skill-authoring.md) と [`claude/templates/skill/SKILL.md.template`](claude/templates/skill/SKILL.md.template)
- Command: [`claude/docs/command-authoring.md`](claude/docs/command-authoring.md)
