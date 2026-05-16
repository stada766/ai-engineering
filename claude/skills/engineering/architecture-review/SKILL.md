---
name: architecture-review
description: Review a proposed architecture against project constraints and surface mismatches before code is written. Use when evaluating new modules, services, or major refactors.
version: 0.1.0
last_updated: 2026-05-16
scope: engineering
responsibility: "Review a proposed architecture against project constraints and surface mismatches before code is written."
status: draft
compatible_with:
  - claude-code
depends_on:
  - engineering/runtime-boundary-check
superseded_by: null
tests: null
---

# Architecture Review

## What this skill does

提案されたアーキテクチャ（クラス図・モジュール構成・データフロー・ランタイム境界）を、プロジェクトの制約と照合してミスマッチを指摘する。**実装前** に行うレビュー。

## When to invoke

- 新しいモジュール・サービスの導入を検討中
- 大規模リファクタの設計レビュー
- 「この設計でいいか？」というユーザの問い

## When NOT to invoke

- 小さなバグ修正・パッチレベルの変更
- すでに実装が走り始めて引き返せない段階（その場合は事後 ADR を促す）

## Procedure

1. プロジェクトの **既存 ADR** と **CLAUDE.md** を読み、制約を抽出
2. 提案を以下の軸で評価：
   - ランタイム境界（プロセス・スレッド・I/O 境界）が明示されているか
   - 単一責務原則: 各モジュールが一文で説明できるか
   - データフロー: 同期 / 非同期 / イベント駆動の選択理由
   - 失敗モード: 各境界での失敗・縮退をどう扱うか
   - 進化容易性: 6 ヶ月後にこの設計を変えるコスト
3. **OK / Concern / Blocker** の 3 段階で項目化
4. Blocker があれば設計変更を、Concern なら ADR で根拠記録を提案

## Output format

```
## Summary
<3 文以内>

## Findings
- [BLOCKER] <issue> — why it blocks
- [CONCERN] <issue> — what could go wrong
- [OK]      <area>  — looks good

## Recommended actions
1. ...
```

## Anti-patterns

- 「綺麗だから OK」で評価を終える（制約と紐付けない）
- 全部 Concern にする（優先度が消える。Blocker と Concern を分ける）
- 代替案を出さずに否定する（建設的でない）
