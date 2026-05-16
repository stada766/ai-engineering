# 0001. Skill Hierarchy: engineering / backend / ai / frontend + project overlay

- Status: Accepted
- Date: 2026-05-16
- Deciders: @stada766

## Context

Skill を平らに並べると、横断的（言語非依存）なものと、スタック固有・ドメイン固有のものが混在し、再利用判断が難しくなる。一方で過度に細かい階層は迷子を生む。

## Decision

We will organize Skills into **4 horizontal scopes (engineering / backend / ai / frontend) + 1 vertical (project overlay)**.

- Core (このリポジトリ): `skills/{engineering,backend,ai,frontend}/`
- Overlay (各プロジェクト): `project/.claude/project-skills/`

## Alternatives Considered

- **2 階層 (engineering / domain)**: シンプルだが backend と ai と frontend が混ざり、`ai/prompt-design` のようなクロスカット系の置き場が曖昧。
- **言語単位 (language-typescript, language-python ...)**: 言語依存より責務依存で切る方が再利用性が高い。`compatible_with:` で表現すれば十分。

## Consequences

### Positive
- Skill の置き場が一義に決まる
- Project Overlay が物理的に分離されることで、固有思想を Core に混ぜる事故を防げる

### Negative
- 「これは engineering か ai か」で迷うケースはある（ADR を起こして決める）

### Neutral
- 将来必要なら 5 番目以降のスコープ（例: `infra/`, `data/`) を追加する余地がある
