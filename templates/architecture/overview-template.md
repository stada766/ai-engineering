---
name: architecture-overview
version: 0.1.0
last_updated: YYYY-MM-DD
status: draft   # draft | stable
---

# <Project> Architecture

> **これは「現在の設計の唯一の正典」です。** 設計を変える PR では、この文書を同じ PR で更新してください。
> 各決定の **なぜ** は ADR にあります（下表からリンク）。ここに rationale を重複させないこと。
> 運用ルールは `standards/documentation-model.md` を参照。

## 1. Purpose & Scope

- **何を作るか**: <一文>
- **誰のためか / 何を解決するか**: <一文>
- **Non-goals**: <このプロジェクトが *やらない* こと。スコープの境界>

## 2. Constraints

- **技術的前提**: <言語 / ランタイム / ホスティング / 既存資産など動かせないもの>
- **その他の制約**: <期限 / 予算 / スケール / チーム / コンプライアンス>

## 3. System Overview

現在のランタイム構成と主要コンポーネントの関係。

```
<context / component 図。テキストで可。
 例:
 Client ──► API server ──► DB
                │
                └──► AI Adapter ──► Provider SDK   (別ランタイム)
>
```

- **ランタイム分割**: <同期/非同期・CPU/IO・stateful/stateless・AI 呼び出しの境界。なければ「単一ランタイム」と明記>

## 4. Building Blocks

| コンポーネント | 責務（一文） | 主要な依存 |
|---|---|---|
| <name> | <責務> | <depends on> |
| <name> | <責務> | <depends on> |

## 5. Key Decisions（→ ADR）

現在の設計を形作っている主要決定。詳細と代替案は ADR 本体を参照。

| 領域 | 現在の選択 | 根拠 (ADR) |
|---|---|---|
| <アーキテクチャ様式> | <選択> | ADR-0001 |
| <永続化> | <選択> | ADR-0002 |
| <AI runtime 境界> | <選択> | ADR-000X |

> Superseded された ADR はここに載せない（現在の正解のみ）。履歴は `docs/decisions/` を辿る。

## 6. Cross-cutting Concerns

- **AI runtime 境界**: <timeout / retry / cost guard / schema をどこが所有するか。該当なければ省略>
- **エラー処理**: <方針。詳細は standards/error-handling.md>
- **観測**: <境界ごとのメトリクス / trace / correlation ID>
- **セキュリティ**: <認証 / 秘密情報 / 信頼境界>
- **テスト**: <unit/integration/E2E の比重。詳細は standards/testing-philosophy.md>

## 7. Risks & Open Questions

- **リスク**: <既知の弱点 / 負債>
- **未解決**: <まだ決めていないこと。ADR 候補。決まったら §5 へ移す>

---

### Maintenance

- **更新タイミング**: 設計を変える PR と同一 PR。ADR を Accepted にしたらその結論を §5 に反映。
- **更新しないもの**: 決定理由（→ ADR）・実装手順（→ Design Doc / issue）・履歴（→ git）。
- **陳腐化チェック**: `frontmatter.last_updated` が古く実装とズレていたら要更新。
