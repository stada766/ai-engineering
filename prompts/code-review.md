---
name: prompt-code-review
version: 0.1.0
last_updated: 2026-05-16
scope: engineering
responsibility: "Lightweight code review prompt for small diffs that don't warrant a full Skill."
status: draft
compatible_with:
  - claude-code
---

# Code Review Prompt

> Skill 化するほどではない軽量プロンプト。差分が小さい PR / コミット用。

## Prompt

```
あなたはこのプロジェクトのコードレビュアーです。以下の差分について、次の観点で 5 件以内に絞って指摘してください：

1. バグの可能性
2. 命名 / 可読性 (responsibility が一文で説明できるか)
3. テスト不足 (修正/追加が必要なテストケース)
4. 過剰設計 (今のタスクに対して足しすぎていないか)

各指摘は以下の形式で：
- [LEVEL] <要約>: <理由> / <提案>

LEVEL: BLOCKER / CONCERN / NIT
```

## When to use vs full skill

- 差分 < 200 行: このプロンプト
- 差分 > 200 行 or 設計判断含む: [[architecture-review]] と [[code-review]] を組み合わせる
