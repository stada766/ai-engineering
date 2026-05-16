---
name: multi-agent-review
description: Coordinate multiple specialized AI agents to review the same artifact and synthesize their findings. Use for high-stakes PRs or designs that need security / architecture / UX viewpoints simultaneously.
version: 0.1.0
last_updated: 2026-05-16
scope: ai
responsibility: "Coordinate multiple specialized AI agents to review the same artifact and synthesize their findings."
status: draft
compatible_with:
  - claude-code
depends_on:
  - ai/prompt-design
superseded_by: null
tests: null
---

# Multi-Agent Review

## What this skill does

同じ成果物（PR、設計、プロンプト）を **異なる視点を持つ複数のエージェント** にレビューさせ、結果を統合する。

## When to invoke

- 重要な PR や設計判断で、単一視点のレビューでは不安があるとき
- セキュリティ / アーキテクチャ / UX など複数領域に跨る変更

## When NOT to invoke

- 小規模変更（オーバーキル）
- 1 視点で十分判断できる単機能変更

## Procedure

1. レビュー観点を **3〜5 個** に分解（例: security / architecture / readability / test-coverage / performance）
2. それぞれに **独立した** agent を割り当て（コンテキスト汚染を避けるため別セッション）
3. 各 agent に同じ成果物を渡し、自分の観点だけで評価させる
4. 結果を統合し、**重複** と **矛盾** を抽出
5. 矛盾は人間に判断を仰ぐ / さらにエージェント間 debate にかける

## Output format

```
## Per-agent findings
### Security agent
- [HIGH] ...
- [LOW]  ...

### Architecture agent
- [HIGH] ...

## Synthesis
- Consensus: <agents が一致した点>
- Conflicts: <意見が割れた点> → 判断要請
- Coverage gaps: <どの観点でも触れられなかった懸念>
```

## Anti-patterns

- 全エージェントに同じ system prompt を渡す → 視点が同質化する
- 統合段階で多数決にする → 重大指摘が埋もれる
- agent 同士のコンテキストを共有させる → 互いを引きずって独立性が消える
