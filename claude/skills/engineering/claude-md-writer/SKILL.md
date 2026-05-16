---
name: claude-md-writer
description: Create or update a project's CLAUDE.md by composing the stack template, active skills, project-specific philosophy, and Don'ts into a single living instruction file. Use when bootstrapping a project's CLAUDE.md or when active skills / philosophy / stack rules change.
version: 0.1.0
last_updated: 2026-05-16
scope: engineering
responsibility: "Create or update a project's CLAUDE.md by composing stack template, active skills, and project philosophy into a single living instruction file."
status: stable
compatible_with:
  - claude-code
depends_on: []
superseded_by: null
tests: null
---

# CLAUDE.md Writer

## What this skill does

プロジェクトの `CLAUDE.md` を、**生きた指示書** として作成・更新する。スタック雛形・sync 済みアクティブ Skill・プロジェクト固有思想・禁則 (Don'ts) を 1 つに合成する。

CLAUDE.md と ADR の違い：

- **ADR**: 過去の判断、append-only、不変
- **CLAUDE.md**: 現在の指示、上書き OK、AI が毎セッションの先頭で読む

## When to invoke

- 新規プロジェクトで CLAUDE.md を初期化するとき（通常は `[[project-bootstrap]]` から呼ばれる）
- `.claude/skills/` に sync する skill 群が変わったとき（Active skills の節を更新）
- プロジェクト哲学・Don'ts に変更があったとき
- 新しい ADR が Accepted になり、それが普段の振る舞いに影響するとき

## When NOT to invoke

- ADR を書くべき場面（過去判断の記録 → `[[adr-writer]]`）
- 単発の typo 修正（直接編集で OK）
- プロジェクトの README を書きたいとき（読者が違う。CLAUDE.md は AI 向け）
- 実装チュートリアル・コードサンプル整備（それは `docs/` 配下）

## Procedure

1. **既存 CLAUDE.md の有無** を確認
   - 存在する: 各節を読み、変更箇所だけ更新する（全文書き直しはしない）
   - 存在しない: `claude/templates/claude-md/<stack>.md` を雛形として開始
2. **Stack の選択** — `stacks/<lang>/ai-instructions.md` から該当ガイドを取り込む（複数言語なら hybrid セクションを作る）
3. **Active skills** を列挙
   - `.claude/skills/` 配下の SKILL.md を読み、`name` と `description` の冒頭句を一覧化
   - skill が増減した場合のみ更新
4. **Project-specific skills** を列挙
   - `.claude/project-skills/` 配下も同様に
5. **Project context** を 3〜5 文で書く（または既存を更新）
6. **Don'ts** をプロジェクト固有制約として明記
7. **Active ADRs** の参照節を更新（`docs/decisions/` の最新を列挙、Status つき）

## Output format

```
# <Project Name>

## Project context
<3〜5 文。何を作っているか・誰のためか・主な制約>

## Active skills
- engineering/adr-writer — <description の冒頭句>
- engineering/tdd-enforcer — <...>
- ...

## Project-specific skills
- <name> — <一文>

## Stack
<stacks/<lang>/ai-instructions.md から関連箇所>

## Don'ts (project-specific)
- ...
- ...

## Active ADRs
- [0001 Language choice](docs/decisions/0001-...md) — Accepted
- [0002 ...] — Proposed
```

## Update rules

CLAUDE.md は ADR と違って **上書き OK**。ただし：

- **大きな哲学変更は ADR を先に書く** — その ADR を Active ADRs 節で参照する
- **削除した節は commit message に理由を残す**（コードに `<!-- removed -->` を残さない）
- **節順は固定**（Project context → Active skills → Project-specific skills → Stack → Don'ts → Active ADRs）。AI が場所を学習しやすくなる
- **長さは A4 1〜2 ページ相当** に抑える。それ以上は `docs/` に外出し

## Anti-patterns

- **チュートリアル化**: 「まずこのコマンドを実行...」のような手順を書く → `docs/` 配下に移す
- **Active skills の腐敗**: sync を消したのに CLAUDE.md に残し続ける → 同期する
- **実装詳細の混入**: 関数名や API レスポンス例を書く → コードと test に
- **マーケティング表現**: "革新的な..." "最先端の..." → AI には無意味
- **README との重複**: README は人間向け、CLAUDE.md は AI 向け。同じ内容を重ねない
