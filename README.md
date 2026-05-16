# ai-engineering

**AI Native Engineering Playbook** — 再利用可能な AI 向け Skills / プロンプト / 設計テンプレートを束ねるリポジトリ。

## コア思想

- **`.ai/` is source, `.claude/` is runtime.** このリポジトリは source-of-truth。各プロジェクトの `.claude/` にはここから **コピー** で配布する。
- **1 skill = 1 responsibility.** すべての `SKILL.md` は単一責務、frontmatter の `responsibility:` フィールドで明文化、本文 300 行以下。
- **Core (共有) と Overlay (固有) は物理分離.** プロジェクト固有思想は `project/.claude/project-skills/` に隔離する。Core に混ぜない。
- **必要な skill だけコピー.** 全部入り同期は AI コンテキストを肥大化させる。Pruning は機能。
- **ライフサイクル管理.** AI プロンプト資産も技術的負債化する。`status` と `superseded_by` で寿命を管理する。

詳しくは [`docs/philosophy.md`](docs/philosophy.md)。

## ディレクトリ

```
skills/        Skills（階層: engineering / backend / ai / frontend）
prompts/       軽量な再利用プロンプト（Skill 化するほどでないもの）
templates/     SKILL / ADR / CLAUDE.md などの雛形
standards/     言語横断のコーディング哲学
architecture/  アーキテクチャパターン
stacks/        スタック別ガイド (node-typescript / flutter / python-ai)
docs/          思想・運用ドキュメント
  decisions/   このリポジトリ自体の ADR
scripts/       sync / drift / lint
tests/         Skill の prompt contract test
```

## 使い方

各プロジェクトでは：

```bash
# 1. このリポジトリを submodule で追加（source）
git submodule add https://github.com/stada766/ai-engineering.git .ai

# 2. 必要な Skill だけ runtime にコピー
./.ai/scripts/sync-to-project.sh \
  --skill engineering/adr-writer \
  --skill engineering/tdd-enforcer

# 3. プロジェクト固有 Skill は .claude/project-skills/ に書く
```

詳しくは [`docs/sync-guide.md`](docs/sync-guide.md)。

## Skill を書く

[`docs/skill-authoring.md`](docs/skill-authoring.md) と [`templates/skill/SKILL.md.template`](templates/skill/SKILL.md.template) を参照。
