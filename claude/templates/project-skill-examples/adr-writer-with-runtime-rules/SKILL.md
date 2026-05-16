---
name: adr-writer-with-runtime-rules
description: TEMPLATE — Project Overlay sample that layers AI runtime and architecture consistency rules on top of the core adr-writer. Copy to your project's .claude/project-skills/ and customize.
version: 0.1.0
last_updated: 2026-05-16
scope: project
responsibility: "Add project-specific runtime philosophy and consistency rules on top of the core adr-writer."
status: draft
compatible_with:
  - claude-code
depends_on:
  - engineering/adr-writer
superseded_by: null
tests: null
---

# ADR Writer (with Runtime Rules) — Project Overlay Template

> **このファイルはテンプレートです.** ご自身のプロジェクトの `.claude/project-skills/<name>/SKILL.md` にコピーし、プロジェクト固有のランタイム哲学・命名（例: "Producer AI", "ambient UX", "broadcast pacing"）に置き換えてください。Core の Skill は別途 sync しておくこと。

## Purpose

Core の `[[adr-writer]]` は ADR の **書き方** を扱う。このオーバーレイは ADR の **整合性ルール** を扱う。プロジェクト固有のアーキテクチャ思想が薄れないようにする層。

## Extra: AI Runtime Rules

AI 関連 ADR を書くときの追加制約：

- orchestration と inference を分離する
- AI worker に world authority を埋め込まない
- orchestration authority は deterministic であること
- runtime state は observable であること

これらに違反する判断は ADR で **明示** され、必要なら supersede されるべき。

## Extra: Architecture Consistency Rules

新規 ADR は以下と整合すること：

- CLAUDE.md の哲学
- 既存 ADR
- event-driven principles
- domain-first organization
- orchestration authority rules

矛盾するなら supersede として書く（Core `[[adr-writer]]` の Update & Superseding rules 参照）。

## Extra: Documentation Synchronization

ADR を作成・更新したら：

- 関連するアーキテクチャドキュメントを更新
- feature registry を更新
- CLAUDE.md を必要に応じて更新

documentation drift を避ける。

## How to use this template

1. このファイルを `your-project/.claude/project-skills/adr-writer-with-runtime-rules/SKILL.md` にコピー
2. 「AI Runtime Rules」「Architecture Consistency Rules」の文言をプロジェクト固有の哲学・固有名詞に置換
3. Core の `adr-writer` を sync しておく: `.ai/claude/scripts/sync-to-project.sh --skill engineering/adr-writer`
4. status を `stable` に上げる
5. `depends_on:` の `engineering/adr-writer` は「同じプロジェクトに sync 済みであること」を示す signal

## Notes

- このスキルは Core を **置き換えない**。重ねるだけ
- Core の `adr-writer` 本体は別途 sync 済みであることが前提
