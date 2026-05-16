---
name: pattern-ai-runtime-boundary
version: 0.1.0
last_updated: 2026-05-16
status: draft
---

# Pattern: AI Runtime Boundary

## なぜ AI を別ランタイムとして扱うか

LLM 呼び出しは通常の関数と性質が違う：

- **高レイテンシ**: 数百ms〜数十秒
- **高コスト**: 単価が高い・呼び出し回数で線形に増える
- **確率的**: 同じ入力で同じ出力が出ない
- **失敗モード豊富**: rate limit / context overflow / hallucination / 接続切れ

これらを **コード内のただの関数呼び出し** にすると：

- タイムアウト・リトライ・コスト上限がコード散乱
- 同期処理に紛れて UI ブロッキング
- 失敗時の縮退戦略が場当たり

## 境界の切り方

```
Application code  →  AI Adapter (boundary)  →  Provider SDK
                       - timeout
                       - retry (transient のみ)
                       - cost guard
                       - schema validation
                       - tracing
```

- Adapter は **入出力スキーマを所有** する
- リトライポリシー・タイムアウト・cost guard は adapter に閉じ込める
- 上位コードは Adapter の Result 型を扱うだけ

## AI Runtime のもう一段上の境界

複数の AI 呼び出しを束ねるエージェントは **さらに上の境界** で：

- session ID / correlation ID で観測可能に
- 中間状態は外部に永続化（chat の途中で死んでも復帰できるように）
- ユーザ向けにストリームを返すなら、producer/consumer は別ランタイム

詳細点検は [[runtime-boundary-check]] を参照。
