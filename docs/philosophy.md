# Philosophy: AI Native Engineering Playbook

このリポジトリは、AI（Claude Code / Cursor / Gemini / Codex 等を想定）と協働するうえで再利用可能な **思想・規約・スキル** を一元管理するための場所である。コードベースではなく、**AI 向けの組織的記憶 (organizational memory)** を扱う。

ベンダ非依存な知識（ADR / 標準 / アーキテクチャパターン / スタックガイド）はトップレベルに、特定 AI ツール固有の実装（現状は `claude/` のみ）はツール名のサブツリーに分けて管理する。

## なぜ必要か

AI と協働するチームが直面する典型的な問題：

1. **静かな分岐.** プロジェクト A と B で「同じはずの ADR テンプレ」「同じはずのレビュー方針」が、気づくとずれている。
2. **責務の暗黙化.** 巨大な万能プロンプトを作ると、AI がコンテキストを失い、出力が劣化する。
3. **資産の負債化.** 一度作ったプロンプトを誰もメンテせず、古いプラクティスが残り続ける。
4. **プロジェクト固有思想の希薄化.** すべてを共通化すると、プロジェクト独自の文化（例: broadcast pacing, ambient UX, AI runtime separation）が薄まる。

このリポジトリはこれらに対し、**バージョン管理・責務分離・ライフサイクル管理** で応える。

## 4 つの原則

### 1. `.ai/` is source, `.claude/` is runtime

- このリポジトリ自体（`ai-engineering/`）は **source of truth**。
- 各プロジェクトの `.ai/` は submodule で固定された source の参照。
- 各プロジェクトの `.claude/` は **runtime**。`claude/scripts/sync-to-project.sh` でコピーされた実体ファイル。
- なぜ symlink ではないか: Windows / WSL / Docker bind mount / Remote container / CI で fragile。編集権限が曖昧になる。**境界を視覚的に明確にする**。

### 2. 1 skill = 1 responsibility

- すべての `SKILL.md` は **単一責務** を持つ。
- frontmatter の `responsibility:` フィールドに **一文** で書く。
- 本文は 300 行以下（`lint-skills.sh` で強制）。
- 大きくなりそうなら **skill を分割する** 兆候として扱う。

### 3. Core と Overlay の物理分離

| 層 | 場所 | 例 |
|---|---|---|
| **Core (普遍)** | `ai-engineering/claude/skills/engineering/` | adr-writer, tdd-enforcer |
| **Stack (技術固有)** | `ai-engineering/claude/skills/backend/` | event-driven-runtime |
| **Project Overlay (固有)** | `project/.claude/project-skills/` | producer-ai, broadcast-pacing |

Project Overlay を Core に持ち込まない。Core が薄まると価値が消える。

### 4. ライフサイクル管理

AI プロンプト資産も古くなる。frontmatter で寿命を扱う：

- `status: draft | stable | deprecated`
- `superseded_by:` で後継を指す
- `compatible_with:` で対応 AI ツール / スタックを宣言（claude-code, cursor, gemini, codex …）

## 将来方向

- **Prompt contract testing.** `tests/<skill>/` に input → expected-structure を置き、Skill の振る舞いを CI で検査する。
- **Skill composition graph.** `depends_on:` を辿って依存解決し、複合 Skill を組み立てる。
- **Compatibility matrix の自動レポート.** どの Skill がどの AI ツールで動作確認済みかを可視化。
