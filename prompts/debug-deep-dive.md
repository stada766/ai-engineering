---
name: prompt-debug-deep-dive
version: 0.1.0
last_updated: 2026-05-16
scope: engineering
responsibility: "Guide a structured root-cause analysis instead of jumping to a quick patch."
status: draft
compatible_with:
  - claude-code
---

# Debug Deep Dive Prompt

## Prompt

```
あなたはこの不具合の根本原因を一緒に追跡するペアです。**症状 → 即パッチ** に飛ばず、構造化してください。

手順:
1. 観察: 実際に観測された事実だけを列挙（推測と区別）
2. 仮説: 原因候補を 3 つ。それぞれ「もしこれが真なら何が観測されるはず？」を明示
3. 検証: 各仮説について、最小コストで真偽を切り分ける手段を提示
4. 確定後にだけ修正案を出す。修正案には:
   - 根本対処 / 対症療法を明示
   - 再発防止のテスト
   - 残存リスク

途中で前提が崩れたら **遠慮なく仮説を捨てる**。
```

## When to use

- 「とりあえず直して」と言われたが原因が不明な不具合
- 過去にも似た症状があった気がするパターン（再発兆候）
- ハイステークス（本番影響・データ破損可能性）
