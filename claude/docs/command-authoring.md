# Command Authoring Guide

Slash Command (`/name`) を作るときの作法。Skill との違いは [`README.md`](../README.md#skill-と-command-の違い) と [`skill-authoring.md`](skill-authoring.md) を参照。

## いつ Command にするか

| ある | Command 向き |
|---|---|
| ユーザが「これをやって」と **明示的に走らせる** | はい |
| 1 回の発動で **複数ファイル生成 / 外部副作用** がある（git push, file write） | はい |
| `$ARGUMENTS` でユーザ入力を受け取りたい | はい |
| AI が会話の流れで自動判断してほしい | **いいえ → Skill にする** |

迷ったら：Skill にして使いながら判断する（後から Command 化できる）。

## ファイル配置

```
ai-engineering/
└── claude/
    └── commands/
        └── <name>.md    ← フラット。サブディレクトリは作らない（slash command が /name で発見される）
```

各プロジェクトでの配置：

```
project/
└── .claude/
    └── commands/
        └── <name>.md    ← sync-to-project.sh --command <name> でコピー
```

## ファイル形式（Claude Code 公式）

```markdown
---
description: <スラッシュコマンドピッカーに出る短い説明>
argument-hint: [optional, ユーザに見せる引数ヒント]
---

# /<name> — <短い title>

User input: $ARGUMENTS    # ユーザが /name の後に書いた文字列に展開される

## Procedure

<手順を箇条書きで>

## Anti-patterns

<ハマりポイント>
```

frontmatter は **最小**で済む。Skill のような `version` / `responsibility` / `compatible_with` は不要（lint 対象外）。

## Skill との両建てパターン

`/adr` `/claude-md` のように、Skill が手順の本体を持ち、Command が薄いエントリになるパターン：

- Command の本文に「`adr-writer` skill (`.claude/skills/adr-writer/SKILL.md` when sync'd) を呼び出す」と書く
- Skill が sync されていない場合のフォールバック手順を簡潔に併記しておく（Command 単体でも最低限動く）
- Skill 側が source of truth。手順を変えるときは Skill を直し、Command は触らない

## Command を書くときの規約

- **`description:` は 1 行・ピッカー表示用**。冗長にしない
- **`$ARGUMENTS` の扱いを明示**する（empty でも動くか、必須かを書く）
- **Hard gate を冒頭に**置く（例: `/bootstrap` は empty project でのみ動く）
- **副作用は明示**する（ファイル生成 / git 操作 / 外部 API 呼び出し）
- **長くなりすぎない**（目安 200 行以下。超えるなら Skill 化を検討）

## Anti-patterns

- Command と Skill で同じ手順を二重に持つ（変更コストが倍）→ Skill を source of truth に
- `description:` がコマンド名と同じ（情報量ゼロ）
- `$ARGUMENTS` を使うのに hint が無い
- Hard gate なしで破壊的操作（既存ファイル上書き等）を行う
