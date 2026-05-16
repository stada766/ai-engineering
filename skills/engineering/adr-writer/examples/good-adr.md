# 0007. Use Submodule + Copy for Skill Distribution

- Status: Accepted
- Date: 2026-05-16
- Deciders: @stada766
- Related: 0001-skill-hierarchy.md

## Context

複数プロジェクトで `ai-engineering` リポジトリの Skill / プロンプトを共有したい。symlink・submodule・コピー・npm パッケージ化が候補にあがった。各プロジェクトは Mac / WSL / CI 上で動く想定で、編集権限の境界も明確にしたい。

## Decision

We will use **Git submodule for source-of-truth and a copy script for runtime distribution**. `.ai/` を submodule、`.claude/` を runtime コピー先とする。

## Alternatives Considered

- **Submodule + symlink**: バージョン固定は強いが、Windows/WSL/Docker/CI で symlink が壊れやすく、編集 authority が曖昧化する。
- **npm package**: Node 中心ならアリだが、Skill は markdown / prompt / template 中心で package manager と相性が悪い。
- **コピーのみ（submodule なし）**: 最初は楽だが、静かな分岐が起きやすく drift 検出が事後対応になる。

## Consequences

### Positive
- バージョン固定が submodule で担保される
- runtime は実体ファイルなので AI ツール（Claude Code 等）が自然に読める
- pruning しやすい（必要な Skill だけコピー）
- CI で drift 検査を回せる

### Negative
- 2 ステップ運用になる（submodule 更新 → resync）
- runtime コピーを直接編集する誘惑が残る → ドキュメントとレビューで防ぐ

### Neutral
- submodule に不慣れな貢献者向けに README に手順を書く必要がある
