---
name: tdd-enforcer
description: Drive code changes through red-green-refactor, refusing to write production code without a failing test first. Use when implementing new logic, fixing bugs, or refactoring.
version: 0.1.0
last_updated: 2026-05-16
scope: engineering
responsibility: "Drive code changes through the red-green-refactor cycle, refusing to write production code without a failing test first."
status: draft
compatible_with:
  - claude-code
depends_on: []
superseded_by: null
tests: null
---

# TDD Enforcer

## What this skill does

実装タスクに対して、**赤 → 緑 → リファクタ** の順を強制する。プロダクションコードを書く前に、必ず失敗するテストを先に書く。

## When to invoke

- 新機能・新ロジックの実装依頼
- バグ修正（再現テストから入る）
- リファクタリング（既存テストで保護できているか確認するため）

## When NOT to invoke

- 純粋なドキュメント変更・README 編集
- 設定ファイル・スキーマ更新のみ
- プロトタイピング段階でユーザが明示的に「テストなしで」と指定

## Procedure

1. **赤**: 期待する振る舞いを表現するテストを書く。実行して失敗することを確認
2. **緑**: 最小限の実装でテストを通す
3. **リファクタ**: テストを保ったまま、命名・構造・重複を整える
4. ステップを跨ぐときに、必ず「今は赤/緑/リファクタのどこか」を宣言する

## Output format

```
[RED] Write test: <path/to/test>
[GREEN] Implement: <path/to/code>
[REFACTOR] Clean up: <what changed and why>
```

## Anti-patterns

- 実装を書いてからテストを書く（順序が逆）
- 1 ステップで複数の振る舞いを一気にテスト化する（小さく刻む）
- リファクタフェーズでテストが落ちる（リファクタは振る舞い不変が前提）
