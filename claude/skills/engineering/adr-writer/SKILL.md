---
name: adr-writer
description: Create or update Architecture Decision Records (ADR) for significant technical decisions. Use when architecture, runtime topology, folder structure, language strategy, infrastructure, orchestration, memory design, event systems, or deployment strategy changes.
version: 0.2.0
last_updated: 2026-05-16
scope: engineering
responsibility: "Create or update a single Architecture Decision Record, preserving historical traceability through superseding rather than rewriting."
status: stable
compatible_with:
  - claude-code
  - cursor
depends_on: []
superseded_by: null
tests: tests/adr-writer/
---

# ADR Writer

## What this skill does

ユーザが下した一つの設計判断を、Michael Nygard 形式の ADR (Architecture Decision Record) 一本に書き起こす、または既存 ADR を **書き換えではなく superseding** で更新する。背景・選択肢・決定・帰結を構造化し、**WHY と tradeoff** を長期保存する。

## When to invoke

- 新規 ADR が必要な意思決定: アーキテクチャ / ランタイム topology / フォルダ構造 / 言語戦略 / インフラ / オーケストレーション / メモリ設計 / イベントシステム / デプロイ戦略
- 既存判断を覆す decision が出たとき（**superseding ADR** を書く）
- 既存 ADR のステータス変更（Proposed → Accepted、Accepted → Deprecated）

## When NOT to invoke

- 設計議論がまだ収束していない段階（議論を ADR に押し込まない）
- 既存 ADR のタイポ修正・リンク修復など軽微な修正（直接編集）
- 単なる実装メモやコメント（ADR は **判断** を記録するもの）
- 複数の独立した判断が混ざっている場合 → **複数の ADR に分割**

## Procedure

1. ユーザの説明から以下を抽出：
   - **Context**: なぜこの判断が必要になったか・現状の圧力
   - **Decision**: 何を選んだか（一文で言えるか確認）
   - **Options Considered**: 検討した選択肢（最低 2 つ）
   - **Consequences**: 採用したことで得られるもの・失うもの
2. 既存 ADR を確認し、矛盾する判断がないか調査。矛盾があれば **supersede として書く** + 旧 ADR の Status を `Superseded by NNNN` に変更
3. `templates/adr/0000-template.md` をコピーし、連番 (`NNNN-kebab-title.md`) で `docs/decisions/` 配下に配置
4. Status は `Proposed` で開始（マージ時に `Accepted` へ）
5. 関連 ADR は `Related:` で相互リンク
6. 「これ一文で言えるか？」のセルフチェック。言えなければ判断が複合しているサインなので分割提案
7. Quality Checklist を全項目通過させる（下記）

## Output format

```
# NNNN. <短いタイトル>

- Status: Proposed                 <!-- Proposed | Accepted | Superseded by NNNN | Deprecated -->
- Date: YYYY-MM-DD
- Deciders: <名前 / @handle>
- Related: <NNNN-...md があれば>

## Context
<2〜5 文。背景・制約・現状の圧力。>

## Options Considered
- **Option A**: <概要>
  - Strengths: ...
  - Weaknesses: ...
  - Operational impact: ...
- **Option B**: <概要>
  - Strengths / Weaknesses / Operational impact

## Decision
<一文で。"We will ..."。reasoning と guiding philosophy を 1〜3 文補足。>

## Consequences
### Positive
- ...
### Negative
- ...
### Neutral / Future implications
- ...
```

## Update & Superseding rules

ADR は **歴史的記録**。過去の判断を上書きしない：

- **既存 ADR を書き換えない.** タイポ・リンク修正以外で本文を改変しない
- **判断が覆ったら supersede.** 新規 ADR を書き、旧 ADR の Status を `Superseded by NNNN` に変更（旧本文はそのまま残す）
- **連番を振り直さない.** 抜けが出ても OK
- **ステータス変更だけは例外**（Proposed → Accepted, Accepted → Deprecated 等）。本文には触らない

## Anti-patterns

- **判断複合**: 1 ADR に 3 つの決定が混ざる → 分割する
- **議論ログ化**: ADR を Slack ログのコピペにする → 結論と理由だけ残す
- **代替案ゼロ**: Options Considered が空 → 必ず最低 2 つ明示する（「やらない」も選択肢）
- **将来予測の混入**: Consequences に「将来こうなるかも」を書き散らかす → 現時点で確度の高い帰結だけ
- **書き換えによる歴史抹消**: 過去 ADR を編集して "なかったこと" にする → supersede で記録を残す

## Quality Checklist

確定前に全項目 YES になるか確認：

- [ ] 問題 (Context) が明確に書かれているか？
- [ ] 代替案 (Options Considered) が **最低 2 つ** 文書化されているか？
- [ ] トレードオフが explicit に書かれているか？（"全方面で最適" は嘘）
- [ ] アーキテクチャ的意図が一文で言えるか？
- [ ] 将来影響 (Consequences / Future implications) が説明されているか？
- [ ] 決定が歴史的にトレース可能か？（supersede 関係が示せるか）
- [ ] CLAUDE.md / 既存 ADR と矛盾していないか？（矛盾するなら supersede として書く）
- [ ] 新規参加者がこの ADR を読んで **なぜ** 現在の系がそうなっているか理解できるか？

通らない項目があれば revise してから merge / commit。

## References

- [Michael Nygard original article](references/michael-nygard-template.md)
- `examples/good-adr.md` / `examples/bad-adr.md`
- Project Overlay 例: `claude/templates/project-skill-examples/adr-writer-with-runtime-rules/`
