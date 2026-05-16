---
name: prompt-design
version: 0.1.0
last_updated: 2026-05-16
scope: ai
responsibility: "Design a single-purpose prompt with explicit role, input shape, output contract, and failure handling."
status: draft
compatible_with:
  - claude-code
  - cursor
  - gemini
depends_on: []
superseded_by: null
tests: null
---

# Prompt Design

## What this skill does

新しいプロンプト（or Skill 本文）を設計する。役割・入力・出力契約・失敗時挙動を **明示** することを強制する。

## When to invoke

- 新しい AI 機能・エージェントの実装着手前
- 既存プロンプトの責務が曖昧になってきたタイミング
- Skill 化を検討する初期段階

## When NOT to invoke

- すでに動いているプロンプトの 1 行修正
- ad-hoc な one-shot 質問

## Procedure

1. **Role**: AI に何者として振る舞わせるか（一文）
2. **Input shape**: 何を渡すか（型・例）
3. **Output contract**: 何を返すか（構造・例）
4. **Constraints**: やってはいけないこと
5. **Failure mode**: 入力が不正・不足のとき何を返すか
6. **Test cases**: 最低 3 つの入力例と期待出力

## Output format

```
## Role
You are <role>, doing <one thing>.

## Input
<schema or example>

## Output
<schema or example>

## Constraints
- ...

## On failure
If <condition>, return <fallback>.

## Test cases
1. input → expected output
2. ...
```

## Anti-patterns

- Role が複数（"You are a reviewer AND an implementer AND..."）→ 分割
- Output 契約が自然言語のみで構造が不明 → 構造を例示する
- Failure mode 未定義 → 不正入力で AI が暴走する余地が残る
