# 0007. Use Submodule + Copy for Skill Distribution

- Status: Accepted
- Date: 2026-05-16
- Deciders: @stada766
- Related: 0001-skill-hierarchy.md

## Context

複数プロジェクトで `ai-engineering` リポジトリの Skill / プロンプトを共有したい。symlink・submodule・コピー・npm パッケージ化が候補にあがった。各プロジェクトは Mac / WSL / CI 上で動く想定で、編集権限の境界も明確にしたい。

## Decision

We will use **Git submodule for source-of-truth and a copy script for runtime distribution**. `.ai/` を submodule、`.claude/` を runtime コピー先とする。

## Options Considered

- **Submodule + symlink**:
  - Strengths: バージョン固定が強い / source-of-truth が一意
  - Weaknesses: Windows / WSL / Docker bind mount / CI で symlink が壊れやすい
  - Operational impact: 編集 authority が曖昧化し `.claude/` を直接編集する事故が起きる
- **npm package (`@stada766/claude-skills`)**:
  - Strengths: Node エコシステムで配布が楽
  - Weaknesses: Skill 主体が markdown / prompt / template であり package manager との相性が悪い
  - Operational impact: lockfile / install セマンティクスが Skill の更新サイクルとズレる
- **コピーのみ（submodule なし）**:
  - Strengths: 初期コストゼロ
  - Weaknesses: 静かな drift が起きやすい
  - Operational impact: 検出が事後対応になり、検証コストが膨らむ

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
