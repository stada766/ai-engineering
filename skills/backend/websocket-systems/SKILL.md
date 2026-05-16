---
name: websocket-systems
version: 0.1.0
last_updated: 2026-05-16
scope: backend
responsibility: "Guide the design of WebSocket-based realtime systems — connection lifecycle, backpressure, reconnect, fan-out."
status: draft
compatible_with:
  - claude-code
depends_on:
  - engineering/runtime-boundary-check
superseded_by: null
tests: null
---

# WebSocket Systems

## What this skill does

WebSocket でリアルタイム通信を行うシステムの設計支援。接続ライフサイクル・バックプレッシャ・再接続・ファンアウトの観点で。

## When to invoke

- 新規 WS エンドポイントの設計
- 既存 WS で接続不安定 / メッセージ喪失が発生している
- ブロードキャスト / Fan-out の規模が増えるとき

## When NOT to invoke

- 単純な long-polling で足りるケース
- 純粋な SSE で足りるケース（一方向）

## Procedure

1. **Connection model**: per-user / per-channel / shared
2. **Auth**: 接続時 token / メッセージ毎 / リフレッシュ戦略
3. **Backpressure**: send buffer 上限・閾値超過時の挙動
4. **Reconnect**: client side exponential backoff / server side session resumption (last-event-id)
5. **Fan-out**: in-process pub/sub / Redis pub/sub / dedicated bus
6. **Heartbeat**: ping/pong 間隔・dead connection 検出
7. **Failure modes**: half-open connection / NAT timeout / proxy buffering

## Output format

```
## Connection lifecycle
connect → auth → subscribe → stream → heartbeat → disconnect

## Backpressure policy
- buffer: 1MB / 1000 messages
- on overflow: drop oldest / close connection / pause producer

## Reconnect
- client: backoff 1s..30s, jitter
- server: session_id + last_event_id, replay from event store
```

## Anti-patterns

- TCP keepalive だけで dead connection を検出しようとする（NAT/プロキシで効かない）
- 全クライアントに同じイベントを send する単純 fan-out（slow consumer が全体を詰まらせる）
