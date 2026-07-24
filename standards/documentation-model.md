---
name: standard-documentation-model
version: 0.1.0
last_updated: 2026-07-23
status: draft
---

# Documentation Model — ADR / Architecture Doc / Design Doc

設計に関する文書を **3 層** に役割分担する。混同すると「どれが最新の正解か分からない」状態になるため、各層の **時制** と **不変性** を明確に分ける。

## 3 層モデル

| 層 | 場所 | 時制 | 陳腐化 | 答えるもの |
|---|---|---|---|---|
| **ADR** | `docs/decisions/NNNN-*.md` | 過去の一点 | しない（追記のみ・supersede） | **なぜ** T 時点で X を選んだか |
| **Architecture Doc** | `ARCHITECTURE.md`（ルート） | **常に現在** | させない（更新前提） | **今の**正しい設計はこれ |
| **Design Doc** | `docs/design/NNNN-*.md`（任意） | 実装**前**の一点 | する（提案なので） | これから**何をどう**作るか |

### 重要な直観

- **ADR も Design Doc も一点もの (point-in-time)** である。ADR は「決めた瞬間」を、Design Doc は「作る前の提案」を凍結する。どちらも時が経てば「現在の姿」とはズレる。それは仕様であって欠陥ではない。
- 「実装が増えても現在の設計の正解が1枚で分かる」を担うのは **Architecture Doc だけ**。Design Doc を足してもこの目的は満たせない。
- 逆に、Architecture Doc に **なぜ (rationale)** を厚く書くと、決定の履歴が失われて ADR と二重管理になる。**Why は ADR、What/How-now は Architecture Doc** に寄せ、Architecture Doc からは ADR を参照リンクするに留める。

## どの層に書くか（判断フロー）

1. **一つの設計判断を記録したい**（なぜ X を選んだか、tradeoff を残したい）
   → **ADR** を1本。既存判断を覆すなら新 ADR ＋ 旧 ADR を `Superseded by` に。
2. **現在の全体像・構成・責務分割を説明したい / 更新したい**
   → **Architecture Doc** を更新。
3. **大きめの機能追加を実装前にレビューしたい**（複数の決定・図・段取り・代替案をまとめて）
   → **Design Doc** を1本。小さい判断なら Design Doc を作らず ADR 単発で十分。

## 層をまたぐ運用フロー

```
Design Doc (提案)
   │  レビューで方向確定
   ├─► 個々の決定を ADR に切り出す（Why を凍結）
   │
実装
   │
   └─► 結論を Architecture Doc に反映（現在の正解を更新）
        Design Doc は archive（status: superseded）
```

- **ADR が Accepted になったら、その結論を必ず Architecture Doc に反映する。** これを怠ると Architecture Doc が「現在」でなくなる。反映は ADR を Accepted にする PR と同一 PR で行うのが理想。
- **設計を変える PR では Architecture Doc を同じ PR で更新する。** コードと正典を同時に動かすことでズレを構造的に防ぐ。
- Design Doc は必須ではない。判断が1〜2個なら ADR 直行でよい。

## Architecture Doc に書くこと / 書かないこと

**書く（常に現在の事実）:** 目的とスコープ・制約・システム全体像とランタイム構成・主要ビルディングブロックと責務・横断的関心事（AI runtime 境界 / エラー処理 / 観測 / セキュリティ）・現在のリスクと未解決事項・主要決定の **ADR への参照表**。

**書かない:** 決定の詳細な rationale（→ ADR）・実装手順やチケット（→ Design Doc / issue）・履歴（→ ADR / git）。

## Anti-patterns

- Architecture Doc に決定理由を長々と書き、ADR と二重管理になる。
- ADR を Accepted にしたのに Architecture Doc へ反映せず、正典が古いまま放置される。
- Design Doc を「現在の設計書」として使い続け、実装が進むと嘘の文書になる。
- 設計変更 PR で `ARCHITECTURE.md` を更新せず、コードだけ先行する。
- 小さな判断のたびに重い Design Doc を書き、レビューが形骸化する。

関連: [[standard-testing-philosophy]] / ADR 運用は `adr-writer` skill、正典更新は `/architecture` コマンド。
