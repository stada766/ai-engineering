---
name: ambient-ux-review
description: Review UI designs against ambient UX principles — low-attention, glanceable, non-intrusive presence. Use for notifications, persistent widgets, always-on products, or background AI feedback surfaces.
version: 0.1.0
last_updated: 2026-05-16
scope: frontend
responsibility: "Review UI designs against ambient UX principles — low-attention, glanceable, non-intrusive presence."
status: draft
compatible_with:
  - claude-code
depends_on: []
superseded_by: null
tests: null
---

# Ambient UX Review

## What this skill does

UI / UX 設計を「アンビエント UX」観点でレビューする。**注意を奪わずに情報を伝える** デザインができているか。

## When to invoke

- 通知・通知バナー・常駐型ウィジェットの設計レビュー
- ラジオ的・常時稼働型プロダクトの UI
- バックグラウンドで動く AI のフィードバック表現

## When NOT to invoke

- フォーカスを必ず奪うべき critical alert（誤って ambient 化させない）
- 一度きりのモーダル / ウィザード

## Procedure

1. **Attention budget** を見積もる: ユーザは何秒/時間で何回これを見るか
2. **Glanceability**: 一瞥で意味が伝わるか（数字 / アイコン / 色のみで成立しているか）
3. **Non-intrusive**: タスクを中断しないか・しても回復が早いか
4. **Persistent presence vs ephemeral**: 残し続ける根拠があるか
5. **Failure on noise**: 情報密度を上げすぎていないか（ambient ≠ static dashboard）

## Output format

```
## Attention model
- expected frequency: <N times/hour>
- expected dwell: <seconds>

## Findings
- [GLANCE]   <element> は一瞥で読めない（要素過多）
- [INTRUDE]  <transition> がフォーカスを奪う
- [NOISE]    <region> の情報密度が高すぎ
```

## Anti-patterns

- ambient = 小さくする、と勘違いする（小ささではなく注意設計の問題）
- 通知音・モーションで気を引きすぎる
- ダッシュボード的密度を ambient と呼ぶ
