---
name: runtime-boundary-check
version: 0.1.0
last_updated: 2026-05-16
scope: engineering
responsibility: "Audit a design or codebase for clearly-defined runtime boundaries (process / thread / I/O / network / AI runtime)."
status: draft
compatible_with:
  - claude-code
depends_on: []
superseded_by: null
tests: null
---

# Runtime Boundary Check

## What this skill does

ランタイム境界 — プロセス・スレッド・I/O・ネットワーク・AI ランタイム — が設計上・コード上で明示されているかを点検する。境界が曖昧だと失敗モード・スケール特性が読めなくなる。

## When to invoke

- バックエンド・サービス層の設計レビュー
- 並行処理 / 非同期処理を含む実装の確認
- AI を組み込んだランタイム（プロデューサ AI、エージェント等）の設計時

## When NOT to invoke

- 純粋なフロントエンド UI 変更（境界が単純）
- 単一プロセス・同期のみの小規模スクリプト

## Procedure

1. システム内の境界を列挙：
   - プロセス境界（別バイナリ・別コンテナ）
   - スレッド境界（イベントループ / ワーカー）
   - I/O 境界（DB / ファイル / 外部 API）
   - ネットワーク境界（HTTP / WS / gRPC）
   - **AI ランタイム境界**（LLM 呼び出しの単位 — agent / tool / chain）
2. 各境界について：
   - 越える際のデータ表現は何か（型・スキーマ）
   - 失敗時の挙動は何か（再試行・縮退・伝播）
   - 観測可能性はあるか（ログ・メトリクス・トレース）
3. **曖昧 / 暗黙の境界** を発見したら明示化を提案

## Output format

```
## Boundaries identified
- [PROCESS] <name> — <data shape> / <failure mode>
- [AI-RUNTIME] <agent name> — <input>/<output>/<retry policy>
...

## Issues
- [IMPLICIT] <where>: 境界がコード上で明示されていない
- [LEAKY]    <where>: 失敗が上流に漏れている
```

## Anti-patterns

- AI 呼び出しを「ただの関数呼び出し」として扱い、リトライ・タイムアウト・コスト境界を曖昧にする
- スレッド境界をコメントで示すだけで、型システムや構造で表現しない
