# Skill Authoring Guide

新しい Skill を書くときの作法。

## 1. 命名と配置

| ディレクトリ | スコープ | 例 |
|---|---|---|
| `skills/engineering/` | 言語・スタック非依存の普遍的スキル | `adr-writer`, `tdd-enforcer` |
| `skills/backend/` | サーバ・ランタイム系 | `event-driven-runtime` |
| `skills/ai/` | AI/LLM プロダクト設計系 | `prompt-design` |
| `skills/frontend/` | UI / UX 系 | `ambient-ux-review` |

ディレクトリ名 = `name` = kebab-case。

## 2. テンプレートをコピー

```bash
cp -r templates/skill skills/<scope>/<your-skill-name>
```

## 3. frontmatter を埋める

必須フィールド：

```yaml
---
name: your-skill-name           # ディレクトリ名と一致
description: "<Use when ...>"   # Claude Code が発動判断に使う公式フィールド
version: 0.1.0                  # semver
last_updated: 2026-05-16
scope: engineering              # engineering | backend | ai | frontend | project
responsibility: "<一文で>"      # 内部 lint 用の単一責務記述
status: draft                   # draft → stable → deprecated
compatible_with:
  - claude-code
depends_on: []
superseded_by: null
---
```

### `description:` と `responsibility:` の違い

- **`description:`** — Claude Code の公式 Skill フォーマットで読み取られるフィールド。**実行時に Claude がこの Skill を発動すべきか判断する** ために使う。トリガとなる条件を含む簡潔な一文。"Use when ..." 形式が有効。
- **`responsibility:`** — このリポジトリ独自の単一責務宣言。「1 skill = 1 responsibility」を lint で強制するための内部フィールド。書き換えれば外部から見える `description:` も連動更新するのが望ましい。

## 4. 「責務」を書ききる

`responsibility:` は **「この Skill が何を１つだけやるのか」** を一文で書く。

良い例:

> "Write a single ADR following Michael Nygard's template."

悪い例:

> "Help with architecture decisions and reviews and documentation."

→ 3 つに分割すべき。

## 5. 本文 300 行以下を死守

`lint-skills.sh` が落ちる。超えたら Skill を分割する。

## 6. examples/ を活用

`SKILL.md` 本文を肥大化させずに、具体例は `examples/` 配下に置く。

```
skills/engineering/adr-writer/
├── SKILL.md
├── examples/
│   ├── good-adr.md
│   └── bad-adr.md
└── references/
    └── michael-nygard-template.md
```

## 7. status の運用

- `draft`: 試験運用。本番プロジェクトでは使わないことを推奨。
- `stable`: 安定。複数プロジェクトで利用 OK。
- `deprecated`: 使用停止。`superseded_by:` で後継を必ず示す。

## 8. PR を出す前に

```bash
./scripts/lint-skills.sh skills/<scope>/<your-skill-name>
```
