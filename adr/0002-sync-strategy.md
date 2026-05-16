# 0002. Sync Strategy: Submodule as source, Copy as runtime

- Status: Accepted
- Date: 2026-05-16
- Deciders: @stada766
- Related: 0001-skill-hierarchy.md

## Context

複数プロジェクトで `ai-engineering` の Skill / プロンプトを共有する手段が必要。symlink・submodule・コピー・npm パッケージ化が候補。各プロジェクトは macOS / WSL / Docker / CI で動作する想定。

## Decision

We will use **Git submodule for source-of-truth (`.ai/`) and a copy script for runtime distribution (`.claude/`)**.

- `project/.ai/` ← submodule（read-only な source）
- `project/.claude/skills/` ← `scripts/sync-to-project.sh` でコピー
- `project/.claude/project-skills/` ← project-local（手書き）

## Alternatives Considered

- **Submodule + symlink**: バージョン固定は強いが、Windows / WSL / Docker bind mount / Remote container / CI で symlink が壊れやすい。`.claude/` を直接編集してしまう誘惑が残り、編集 authority が曖昧化する。
- **npm package (`@stada766/claude-skills`)**: Node 中心ならアリだが、Skill は markdown / template / prompt 中心で package manager との相性が悪い。Skill のセマンティクスと npm の install/lockfile セマンティクスがズレる。
- **Copy only (no submodule)**: 静かな drift が起きやすく、検出が事後的になる。submodule は drift 検出の土台になる。

## Consequences

### Positive
- バージョン固定が submodule で担保される
- runtime は実体ファイルなので Claude Code が自然に読める
- 必要な Skill だけコピー（pruning）でき、AI コンテキスト肥大を防げる
- `check-drift.sh` で CI 検査できる

### Negative
- 2 ステップ運用（submodule 更新 → resync）。`scripts/sync-to-project.sh --resync-all` でカバー
- runtime コピーを誤って直接編集する誘惑 → README とコメントで明示し、CI でも検出する

### Neutral
- 貢献者向けに sync-guide.md が必要（既に整備済み）
