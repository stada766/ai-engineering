---
name: pattern-event-driven
version: 0.1.0
last_updated: 2026-05-16
status: draft
---

# Pattern: Event-Driven Architecture

## When to choose

- 複数の関心が同じ事実を異なる目的で消費する
- 書き込みと読み込みのスケール特性が異なる
- 監査ログ・リプレイ・タイムトラベルが要件

## When NOT to choose

- 単純な同期 CRUD で足りる規模
- 強い読み取り一貫性が必要（イベント駆動は eventually consistent）

## 構造

```
Producer → Event Bus → Consumer(s) → Read Model(s)
                     ↘ Audit Log / Snapshot
```

## 重要な意思決定軸

- Event sourcing にするか、単なる pub/sub か
- イベントの **アグリゲート境界** をどう切るか
- バージョニング戦略（schema evolution）

詳細手順は [[event-driven-runtime]] を参照。
