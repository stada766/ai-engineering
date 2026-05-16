---
name: pattern-runtime-separation
version: 0.1.0
last_updated: 2026-05-16
status: draft
---

# Pattern: Runtime Separation

## Why

異なる **失敗モード・スケール特性・レイテンシ要件** を持つ処理を同じランタイムに同居させない。

## 切り分け軸

- **同期 / 非同期**
- **CPU bound / IO bound**
- **stateful / stateless**
- **AI 呼び出し（高レイテンシ・高コスト・確率的）**

## 典型分離

- API server vs background worker
- realtime channel server vs business logic
- **AI runtime** vs CRUD runtime（コスト・タイムアウト・リトライ特性が違う）

## ガード

- ランタイム間は **メッセージング** か **明示的 API** で結ぶ
- 共有 DB の writer は一つに絞る（多重 writer は競合の温床）
- 観測は **境界ごとに別メトリクス**

詳細点検は [[runtime-boundary-check]] を参照。
