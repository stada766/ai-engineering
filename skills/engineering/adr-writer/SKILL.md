---
name: adr-writer
version: 0.1.0
last_updated: 2026-05-16
scope: engineering
responsibility: "Write a single Architecture Decision Record following Michael Nygard's template."
status: draft
compatible_with:
  - claude-code
  - cursor
depends_on: []
superseded_by: null
tests: tests/adr-writer/
---

# ADR Writer

## What this skill does

ユーザが下した一つの設計判断を、Michael Nygard 形式の ADR (Architecture Decision Record) 一本に書き起こす。背景・選択肢・決定・結果を構造化して残す。

## When to invoke

- ユーザが「ADR を書いて」「この決定を記録したい」と明示したとき
- 設計に関する議論が一段落し、結論が出たとき
- 既存 ADR を更新ではなく **新規の判断** として記録する場合

## When NOT to invoke

- 設計議論がまだ収束していない段階（議論を ADR に押し込まない）
- 既存 ADR の小さな修正（その場合は元 ADR を直接編集）
- 単なる実装メモやコメント（ADR は **判断** を記録するもの）
- 複数の独立した判断が混ざっている場合 → **複数の ADR に分割**

## Procedure

1. ユーザの説明から以下を抽出する：
   - **Context**: なぜこの判断が必要になったか
   - **Decision**: 何を選んだか（一文で言えるか確認）
   - **Alternatives**: 検討した他の選択肢（最低 2 つ）
   - **Consequences**: 採用したことで得られるもの・失うもの
2. `templates/adr/0000-template.md` をコピーし、連番 (`NNNN-title.md`) で配置
3. 各セクションを埋める。**Status は `Proposed` で開始**（マージ時に `Accepted` へ）
4. 関連する既存 ADR があれば `Related:` で相互リンク
5. 「これ一文で言えるか？」のセルフチェック。言えなければ判断が複合しているサインなので分割を提案する

## Output format

```
# NNNN. <短いタイトル>

- Status: Proposed
- Date: YYYY-MM-DD
- Deciders: <名前 / @handle>
- Related: NNNN-other-adr.md

## Context

<2〜5 文。背景と制約。>

## Decision

<一文で。"We will ..."。>

## Alternatives Considered

- **Option A**: <概要> — Pros: ... / Cons: ...
- **Option B**: <概要> — Pros: ... / Cons: ...

## Consequences

### Positive
- ...

### Negative
- ...

### Neutral
- ...
```

## Anti-patterns

- **判断複合**: 1 ADR に 3 つの決定が混ざる → 分割する
- **議論ログ化**: ADR を Slack ログのコピペにする → 結論と理由だけ残す
- **代替案ゼロ**: Alternatives が空 → 必ず最低 2 つ明示する（「やらない」も選択肢）
- **将来予測の混入**: Consequences に「将来こうなるかも」を書き散らかす → 現時点で確度の高い帰結だけ

## References

- [Michael Nygard original article](references/michael-nygard-template.md)
- `examples/good-adr.md` / `examples/bad-adr.md`
