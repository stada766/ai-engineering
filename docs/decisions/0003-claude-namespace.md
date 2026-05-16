# 0003. Move Claude Code-Specific Artifacts Under `claude/`

- Status: Accepted
- Date: 2026-05-16
- Deciders: @stada766
- Related: 0001-skill-hierarchy.md, 0002-sync-strategy.md

## Context

リポジトリ名は `ai-engineering`（AI 全般を示唆）だが、内容は当初トップレベル直下に `skills/` `commands/` `templates/skill/` `scripts/sync-to-project.sh` 等の Claude Code 固有フォーマットを置いていた。`compatible_with: [claude-code, cursor, gemini, ...]` を SKILL の frontmatter で宣言した時点で、**ベンダ固有実装** と **ベンダ非依存知識** を物理分離すべきだった。

将来 Cursor / Gemini / Codex などの runtime に同等の skill / command を提供する見通しがあり、現状構造のままだと「どこに何のツール用ファイルがあるか」が破綻する。

## Options Considered

- **Option A — トップレベル直下に並列展開（現状）**:
  - Strengths: パスが短い
  - Weaknesses: 多ツール対応時に衝突。リポジトリ名と実態の乖離
  - Operational impact: 別ツール追加時に大規模リネームが必要
- **Option B — `claude/` 配下にツール固有を集約**:
  - Strengths: ツールごとのサブツリーが明示。将来 `cursor/` `gemini/` を兄弟追加できる。ベンダ非依存素材とベンダ固有実装の責務が物理分離
  - Weaknesses: パスが一段深くなる。sync スクリプトの参照先など多数の path 更新が必要
  - Operational impact: 一度の集中リファクタが必要、ただし以後は分離が自然に維持される
- **Option C — リポジトリ自体を `claude-engineering` にリネーム**:
  - Strengths: リポ名と実態が完全一致
  - Weaknesses: ツールごとに別リポジトリ運用となり、横断知識（ADR / standards / patterns）が重複・分岐する
  - Operational impact: 知識資産が増えるほど維持コストが線形に増える

## Decision

We will adopt **Option B**: Claude Code 固有実装を `claude/` 配下に集約し、ベンダ非依存知識（`prompts/` `standards/` `architecture/` `stacks/` `templates/adr/` `templates/pr-description.md` `docs/decisions/` `docs/philosophy.md`）をトップレベルに残す。

将来 Cursor / Gemini / Codex などを追加する際は `cursor/` `gemini/` `codex/` を兄弟として作る。

## Consequences

### Positive
- リポジトリ名 `ai-engineering` と実態が整合する
- ベンダ非依存知識（ADR テンプレ / standards / stacks）を別ツールから再利用できる
- 多 AI ツール対応の道筋が物理構造で示される
- `claude/` 単独で `cursor/` 等の雛形に転用できる

### Negative
- すべての path 参照（scripts / commands / docs / README）を一度更新する必要があった
- submodule 利用側のスクリプトパスが `.ai/scripts/...` → `.ai/claude/scripts/...` に変わる（既存利用者がいれば移行コスト）

### Neutral / Future implications
- `stacks/<lang>/CLAUDE.md` は filename 自体が Claude 由来だったため、本 ADR とあわせて `stacks/<lang>/ai-instructions.md` にリネーム。`claude/templates/claude-md/<lang>.md` から参照する形に変更
- `templates/adr/` `templates/pr-description.md` は vendor-neutral なのでトップレベルに維持
- 既存 ADR 0001 / 0002 は本 ADR で配置先のパス記述が部分的に古くなるが、ADR は historical record として書き換えない方針に従い、そのまま残す（本 ADR で上書き）
