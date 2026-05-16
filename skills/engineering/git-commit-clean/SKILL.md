---
name: git-commit-clean
description: Run git add / commit / push on the user's behalf without a Co-Authored-By trailer or AI-attribution footer. Use whenever the user asks to commit or push.
version: 0.1.0
last_updated: 2026-05-16
scope: engineering
responsibility: "Run git add / commit / push on the user's behalf without appending a Co-Authored-By trailer or AI-attribution footer."
status: stable
compatible_with:
  - claude-code
depends_on: []
superseded_by: null
tests: null
---

# Git Commit (Clean)

## What this skill does

ユーザの代わりに `git add` → `commit` → `push` を実行する。**通常の手順は守るが、Co-Authored-By トレーラーや "🤖 Generated with Claude Code" 系のフッターは付けない**。

## When to invoke

- ユーザが「commit して」「push して」「add commit push」のような指示を出したとき
- このリポジトリで commit を作るすべての場面（既定の挙動として）

## When NOT to invoke

- ユーザがその場で **明示的に** Co-Authored-By を入れてほしいと指示したとき（その回だけ通常の add-attribution 挙動に戻す。Skill を編集しない）
- 単なる `git status` / `git diff` のような読み取り操作（commit を作らない）

## Procedure

1. **状況把握** — 以下を **並列** に実行：
   - `git status`（`-uall` は使わない）
   - `git diff`（staged / unstaged 双方）
   - `git log --oneline -10` でスタイル参照
2. **コミットメッセージ起草**
   - 変更の性質を分類（feat / fix / refactor / chore / docs / test など）
   - **なぜ** その変更が必要かを 1〜2 文で
   - 既存リポジトリの慣習（プレフィックス・主語の有無）に合わせる
   - **秘密情報を含むファイル**（.env, credentials.json 等）を含めない。含めたい場合はユーザに警告
3. **ステージング & コミット** — 並列に：
   - 必要なファイルを `git add`（`-A` / `.` はユーザ指示が明示にあるときのみ。それ以外はファイル名指定を優先）
   - `git commit -m "$(cat <<'EOF' ... EOF)"` の **HEREDOC 形式** で実行。フォーマット崩れを避ける
4. **コミットメッセージから除外する行**
   - `Co-Authored-By: Claude ... <noreply@anthropic.com>`
   - `🤖 Generated with [Claude Code](...)` 系フッター
   - その他の AI 帰属トレーラー
5. **検証** — `git status` で working tree clean を確認
6. **push**
   - ユーザが明示的に push を指示したときのみ
   - upstream 未設定なら `-u origin <branch>`
   - 既存 upstream への通常 push なら `git push`
   - `--force` / `--force-with-lease` はユーザ明示指示なしで使わない

## Output format

ターン終了時に **2 文以内** で：

- どの SHA に何ファイル / 何行を確定したか
- push したならリモートとブランチ、未 push ならその旨

例:

```
初版コミット完了。400a571 で 48 ファイル / 2,074 行を確定し、origin/main に push 済み。
```

## Anti-patterns

- HEREDOC を使わず `-m "..."` で複数行を渡す（改行が崩れる）
- pre-commit hook 失敗時に `--amend` で前回コミットを上書き（hook 失敗時はコミット自体が起きていないので、修正後は **新規コミット** を作る）
- `--no-verify` でフックを迂回（ユーザ明示指示があるときのみ）
- 確認なしに `git push --force` を main / master に対して実行
- `git add .` を盲目的に使い、`.env` や credential を巻き込む

## Notes

- このリポジトリ (`ai-engineering`) では `.DS_Store` 等は `.gitignore` 済み
- PR 説明 ([[templates/pr-description.md]]) でも同様に AI 帰属フッターは付けない
