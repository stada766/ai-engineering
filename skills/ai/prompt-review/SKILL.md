---
name: prompt-review
description: Review an existing prompt or SKILL.md for responsibility creep, contract clarity, and lifecycle hygiene. Use before modifying or versioning a prompt, or when AI output quality is degrading.
version: 0.1.0
last_updated: 2026-05-16
scope: ai
responsibility: "Review an existing prompt for responsibility creep, contract clarity, and lifecycle hygiene."
status: draft
compatible_with:
  - claude-code
  - cursor
depends_on:
  - ai/prompt-design
superseded_by: null
tests: null
---

# Prompt Review

## What this skill does

既存のプロンプトや SKILL.md をレビューする。責務 creep・契約曖昧化・ライフサイクル無視を検出する。

## When to invoke

- プロンプトを変更しようとしているとき
- AI 出力の品質が落ちてきたと感じたとき
- Skill のバージョンアップ前の点検

## When NOT to invoke

- 完全に新規のプロンプト設計（その場合は `prompt-design`）

## Procedure

1. `responsibility:` を読み、本文が **その一文に閉じているか** 確認
2. Role / Input / Output / Constraints / Failure / Tests の有無を確認
3. 本文の行数が 300 を超えていないか
4. `status` と `version` が更新されているか
5. `depends_on` の参照先が存在するか / `superseded_by` の整合性
6. 出力契約に **構造化された例** が含まれているか

## Output format

```
## Findings
- [CREEP]      責務が <X> と <Y> に分かれている → 分割提案
- [CONTRACT]   出力例が自然言語のみで構造不明
- [LIFECYCLE]  version 0.1.0 のまま 6 ヶ月、last_updated と乖離
- [DEAD-LINK]  depends_on: engineering/foo が存在しない

## Recommended actions
1. ...
```

## Anti-patterns

- 単なる「読みやすさ」のレビューに終始する → 責務と契約を最優先
- 全部 [WARN] で出す → 優先度（CREEP > CONTRACT > LIFECYCLE）を付ける
