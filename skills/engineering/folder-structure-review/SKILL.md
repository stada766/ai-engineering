---
name: folder-structure-review
description: Review a project's folder structure and flag layering, naming, or responsibility violations. Use when reviewing new layouts or after large refactors.
version: 0.1.0
last_updated: 2026-05-16
scope: engineering
responsibility: "Review a project's folder structure and flag layering / naming / responsibility violations."
status: draft
compatible_with:
  - claude-code
depends_on: []
superseded_by: null
tests: null
---

# Folder Structure Review

## What this skill does

プロジェクトのフォルダ構成を読み、層構造・命名・責務違反を指摘する。

## When to invoke

- 新規プロジェクトの初期構成レビュー
- 大規模リファクタ前後の構造点検
- 「このディレクトリ構成で良いか」と問われたとき

## When NOT to invoke

- 単一ファイルの配置相談（小さすぎる）
- 既存構成への小規模な追加（影響範囲が限定的）

## Procedure

1. ルートから 2〜3 階層分の `tree` を取得
2. 各ディレクトリを「何を責務とするか一文」で問う
3. 以下の違反を抽出：
   - **層の混在**: ドメイン / インフラ / UI が同階層
   - **命名揺れ**: `utils` / `helpers` / `common` の併存
   - **目的不明**: 1〜2 ファイルしかないディレクトリ
   - **責務肥大**: 何でも入っている `core/`, `lib/`
4. 修正案を **段階的に** 提示（一気に書き換えない）

## Output format

```
## Current structure
<簡易ツリー>

## Violations
- [LAYER]   <path> — <why>
- [NAMING]  <path> — <suggestion>
- [PURPOSE] <path> — <why unclear>

## Migration plan (incremental)
1. ...
2. ...
```

## Anti-patterns

- 「理想構造」を一気に提示して既存を全否定する
- 命名規約を一つに固定しすぎる（言語・スタックに応じた揺らぎは許容）
