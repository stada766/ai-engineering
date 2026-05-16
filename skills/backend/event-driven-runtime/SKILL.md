---
name: event-driven-runtime
version: 0.1.0
last_updated: 2026-05-16
scope: backend
responsibility: "Guide the design of event-driven runtimes — event shapes, ordering guarantees, idempotency, replay."
status: draft
compatible_with:
  - claude-code
depends_on:
  - engineering/runtime-boundary-check
superseded_by: null
tests: null
---

# Event-Driven Runtime

## What this skill does

イベント駆動なランタイム（pub/sub、event sourcing、message bus）を設計するときの判断軸を提供する。

## When to invoke

- 新しいイベントトピック / メッセージバスの導入
- 既存の同期処理を非同期化する設計
- イベント順序・冪等性・リプレイ性が問題になっている場面

## When NOT to invoke

- リクエスト/レスポンス型の単純な API 設計
- バックグラウンドジョブ 1 種類だけの追加（cron で足りる規模）

## Procedure

1. **Event shape** を定義: name / version / payload schema / metadata（causation_id, correlation_id, occurred_at）
2. **Ordering guarantee** を選ぶ: total / per-partition / per-aggregate / none
3. **Delivery** を選ぶ: at-most-once / at-least-once / exactly-once（の幻想を疑う）
4. **Idempotency** をどう担保するか: dedup key / outbox / consumer state
5. **Replay** 戦略: from beginning / from offset / snapshot+delta
6. **失敗時** の DLQ / poison message 扱い

## Output format

```
## Event catalog
- <event name> v<n>
  payload: {...}
  ordering: per-aggregate
  delivery: at-least-once + idempotent consumer

## Failure handling
- DLQ: <topic>
- Retry: exponential backoff, max <n>
```

## Anti-patterns

- exactly-once delivery を素朴に信じる
- payload に内部状態を全部詰めて巨大化する
- causation/correlation を省略してトレース不能にする
