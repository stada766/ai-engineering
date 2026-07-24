# ai-engineering

**AI Native Engineering Playbook** — Claude Code をはじめとする AI コーディングエージェントと協働するための、**再利用可能な思想・規約・Skills・Commands** を束ねたリポジトリ。

複数プロジェクト間で「同じ ADR テンプレ」「同じレビュー方針」「同じコミットルール」を共有しつつ、各プロジェクト固有の文化は壊さない仕組みになっています。

---

## なにが嬉しいか

- **新規プロジェクトを 5 分で立ち上げられる** — `curl ... | bash` ワンライナーで playbook 組み込み、`/bootstrap` 一発で ADR と CLAUDE.md を生成
- **「このプロジェクトに必要な道具」を AI が選ぶ** — `/sync-recommended` がプロジェクトの ADR と CLAUDE.md を読んで Skills / Commands を推薦
- **プロジェクトで書いた Skill / Command を共有資産に昇格できる** — `/promote` で双方向同期
- **AI プロンプト資産にライフサイクル管理** — `version` / `status` / `superseded_by` を frontmatter で扱える
- **ベンダ非依存知識と AI ツール固有実装が物理分離** — `claude/` 配下は Claude Code 固有、トップレベルはツール非依存。将来 Cursor / Gemini 等に拡張可能

---

## 全体像

```
 ai-engineering リポジトリ                          各プロジェクト
 (source of truth)                                  (runtime)

 claude/                                            project/
   skills/                ─── submodule ───→          .ai/         (固定参照)
   commands/              ─── sync ─────────→          .claude/     (実体コピー)
   always-include.txt                                    skills/
                                                         commands/
                          ←─── promote ───────         project-skills/
```

- **`.ai/`** はこのリポジトリの submodule（**読み取り専用**）
- **`.claude/`** は実体ファイル。Claude Code がここを読む
- **下り (sync)**: `.ai/` → `.claude/` — 必要なものだけコピー
- **上り (promote)**: `.claude/{project-skills, commands}` → `.ai/claude/` — 共有資産化

---

## 5 分で始める（新規プロジェクト）

### Step 1. GitHub で空 repo を作る → clone

```bash
git clone <your-new-empty-repo-url>
cd <project-dir>
```

### Step 2. ワンライナーで playbook 接続

```bash
curl -fsSL https://raw.githubusercontent.com/stada766/ai-engineering/main/install.sh | bash
```

これだけで：
1. `.ai/` として ai-engineering を submodule add
2. `.claude/{skills, commands, project-skills}` を作成
3. `claude/always-include.txt` に列挙された **最小キット** を sync
   - commands: `/bootstrap` `/sync-recommended` `/commit` `/adr` `/claude-md` `/promote`
   - skills: `adr-writer` `claude-md-writer`

### Step 3. Claude Code を起動

```bash
claude
```

### Step 4. Vision から ADR と CLAUDE.md を生成

Claude のプロンプトで：

```
/bootstrap <一行で何を作るか>
```

例：

```
/bootstrap broadcast pacing を持つラジオ風 AI が音楽と会話を生成する web app
```

`/bootstrap` は **7 phase** を踏みます：

| Phase | 内容 |
|---|---|
| 1. Vision intake | 6 つの構造化質問（誰のため / 制約 / 既決 / 未決 / 非ゴール）— **答えられないものは「未定」で OK**。捏造はしない |
| 2. Decomposition | 基盤判断を 3〜8 個に分解（言語 / アーキ / 永続化 / AI ランタイム / デプロイ等） |
| 3. Stack selection | `stacks/` から最適一致を提案 |
| 4. ADR generation | `docs/decisions/0001..NNNN-*.md` を **全て `Status: Proposed` で生成** |
| 5. CLAUDE.md generation | Project context / Active skills / Don'ts / Active ADRs |
| 6. Validation | adr-writer の Quality Checklist を自動適用 |
| 7. Review | ファイル一覧 + 未回答質問を提示 → **承認するまで書き込まない** |

### Step 5. Claude に Skill / Command を選んでもらう

ADR と CLAUDE.md ができたら：

```
/sync-recommended
```

これは：

1. `CLAUDE.md` と `docs/decisions/*.md` を読む
2. `.ai/claude/skills/` と `.ai/claude/commands/` を一覧し、各 `description:` を読む
3. プロジェクトの内容と突合し **Add / Optional / Skip** に分類
4. always-include policy のものは「非交渉 Add」として明示
5. ユーザに承認・編集を求める
6. 承認後 sync 実行 + CLAUDE.md の Active skills 節を更新

ハードコードのキーワードテーブルは使わず、純粋に Claude の意味解釈で判断します。

### Step 6. コミット

```
/commit
```

Co-Authored-By トレーラーや AI 帰属フッターを付けずに commit & push（push はユーザが明示したときだけ）。

これで初期セットアップ完了です。

---

## 日々の運用

| やりたいこと | コマンド |
|---|---|
| 新しい設計判断を残す | `/adr <短いタイトル>` |
| 現在の設計の正典を作る / 追従させる | `/architecture` |
| CLAUDE.md の Active skills や Don'ts を更新 | `/claude-md` |
| Skill / Command を追加で sync | `./.ai/claude/scripts/sync-to-project.sh --skill <scope>/<name> --command <name>` |
| 利用可能な Skill / Command を一覧 | `./.ai/claude/scripts/sync-to-project.sh --list` / `--list-commands` |
| 不要な Skill / Command を消す | `rm -rf .claude/skills/<name>` / `rm .claude/commands/<name>.md` |
| 上流の playbook が更新された | `cd .ai && git pull origin main && cd ..` → `./.ai/claude/scripts/sync-to-project.sh --resync-all` |
| 整合性検査（runtime と source の乖離） | `./.ai/claude/scripts/check-drift.sh` |
| コミット & push（AI 帰属無し） | `/commit` |

---

## ドキュメントモデル（ADR / Architecture Doc / Design Doc）

設計文書を 3 層に役割分担する。**「実装が増えると現在の設計の正解が分からない」問題の答えは `ARCHITECTURE.md`**（常に最新に保つ正典）であって、ADR でも Design Doc でもない。

| 層 | 場所 | 時制 | 答えるもの |
|---|---|---|---|
| **ADR** | `docs/decisions/` | 過去の一点（不変） | **なぜ**その判断をしたか |
| **Architecture Doc** | `ARCHITECTURE.md` | **常に現在** | **今の**正しい設計 |
| **Design Doc** | `docs/design/`（任意） | 実装前の一点 | これから**何を作るか** |

運用のキモ:

- **設計を変える PR では `ARCHITECTURE.md` を同じ PR で更新する。** コードと正典を同時に動かしてズレを防ぐ。
- **ADR が Accepted になったら結論を `ARCHITECTURE.md` §5 に反映**（`/architecture` で reconcile）。ADR は Why、Architecture Doc は現在の姿。rationale を二重に書かない。
- Design Doc は大型機能の実装前レビュー用（任意）。実装後は結論を `ARCHITECTURE.md` に溶かして archive。

詳細ルールは `standards/documentation-model.md`、雛形は `templates/architecture/` と `templates/design/`。

---

## プロジェクト固有の Skill / Command を作る

### Project Overlay (Skill)

`.claude/project-skills/<name>/SKILL.md` に手書き。**プロジェクト固有の哲学・固有名詞**（"Producer AI", "broadcast pacing", "ambient UX" 等）を込めて良い場所です。

雛形は `claude/templates/project-skill-examples/adr-writer-with-runtime-rules/` を参照。

### Project-Local Command

`.claude/commands/<name>.md` に手書き。frontmatter は `description:` だけあれば動作します。例：

```markdown
---
description: Cut a release — verify all ADRs Accepted, finalize CHANGELOG, bump VERSION, tag.
argument-hint: <patch | minor | major>
---

# /release — Cut a release

Bump type: $ARGUMENTS

## Procedure
1. ...
```

`.ai/` に対応 source が無い command は `check-drift.sh` で `[CMD-LOCAL]` として識別され、drift とは扱われません。

詳しい書き方は [`claude/docs/command-authoring.md`](claude/docs/command-authoring.md)。

---

## ローカル Skill / Command を共有資産に昇格 (`/promote`)

プロジェクトで書いた Skill / Command が「他プロジェクトでも使えそう」と思えたら：

### 新規追加 (ADD)

```
/promote skill <name> --scope <engineering|backend|ai|frontend>
/promote command <name>
```

### 修正 (MODIFY)

既に sync 済みの Skill / Command を `.claude/` で直接編集して動作確認 → `/promote` で source に戻す。auto-detect なので同じコマンドで OK：

```
/promote skill adr-writer
```

`/promote` の挙動：
- 該当ファイルを `.ai/claude/` にコピー
- skill の場合は frontmatter `scope:` を自動補正
- lint 実行
- `.ai/` への commit & push 手順をユーザに提示（submodule は別 repo なので自動 commit はしない）
- push 後 `--resync-all` で runtime と source の整合性を回復

詳しくは [`claude/docs/sync-guide.md`](claude/docs/sync-guide.md)。

---

## always-include policy を変える

`claude/always-include.txt` が **デフォルトキットの policy** ファイル。`install.sh` と `/sync-recommended` の両方が参照します。

```text
# Commands: minimum operational toolkit
cmd:bootstrap
cmd:sync-recommended
cmd:commit
cmd:adr
cmd:claude-md
cmd:promote

# Skills: back the commands above
skill:engineering/adr-writer
skill:engineering/claude-md-writer
```

このファイルを編集 → `ai-engineering` 側で commit & push すれば、以降の新規プロジェクトすべてに反映されます。

これは **repo レベル設定** で、プロジェクトレベルの override は意図的に持たせていません。「揃えること自体が価値」だからです。プロジェクトでどうしても外したい場合は `rm` で消せますが、次の `--resync-all` で戻る点に注意。

---

## Skill と Command の違い

| 観点 | Skill | Command |
|---|---|---|
| 起動 | AI が `description:` を読んで **自動発動** | ユーザが `/name` で **明示起動** |
| 性質 | **lens / mode**（適用される視点） | **ritual / action**（明示的に走らせる手順） |
| 引数 | 自然文から推定 | `$ARGUMENTS` で渡せる |
| 配置 | `.claude/skills/<name>/SKILL.md` | `.claude/commands/<name>.md` |
| 例 | `tdd-enforcer`, `architecture-review` | `/bootstrap`, `/commit`, `/promote` |

**両建てパターン**: `/adr` `/claude-md` は Skill（手順の本体）と Command（薄いエントリ）両方を持ちます。詳細は [`claude/docs/command-authoring.md`](claude/docs/command-authoring.md)。

---

## リポジトリ構成

```
ai-engineering/
├── install.sh                    ← ワンライナー setup
├── README.md                     ← この文書
├── ARCHITECTURE.md               ← 現在の設計の正典 (living doc)
├── CHANGELOG.md
├── VERSION
│
├── claude/                       Claude Code 固有 (ベンダ依存)
│   ├── README.md                 この階層の説明
│   ├── always-include.txt        ← デフォルトキットの policy
│   ├── skills/                   AI 自動発動の lens / mode
│   │   ├── engineering/          adr-writer, claude-md-writer, tdd-enforcer, ...
│   │   ├── backend/              event-driven-runtime, websocket-systems
│   │   ├── ai/                   prompt-design, prompt-review, multi-agent-review
│   │   └── frontend/             ambient-ux-review
│   ├── commands/                 ユーザ明示起動の Slash Command
│   │                             bootstrap, sync-recommended, commit, adr,
│   │                             architecture, claude-md, promote
│   ├── templates/
│   │   ├── skill/                SKILL.md 雛形
│   │   ├── claude-md/            プロジェクト用 CLAUDE.md スタック別雛形
│   │   └── project-skill-examples/  Project Overlay サンプル
│   ├── scripts/                  sync-to-project / check-drift / lint-skills / promote-to-source
│   └── docs/                     sync-guide, skill-authoring, command-authoring
│
│ ↓ ここから下は AI ツール非依存
├── prompts/                      軽量な再利用プロンプト
├── standards/                    言語横断のコーディング哲学（命名 / エラー処理 / テスト / コメント / documentation-model）
├── architecture/patterns/        アーキテクチャパターン（event-driven / runtime-separation / AI runtime boundary）
├── stacks/                       スタック別 AI Instructions
│   ├── node-typescript/ai-instructions.md
│   ├── flutter/ai-instructions.md
│   └── python-ai/ai-instructions.md
├── templates/
│   ├── adr/                      ADR テンプレ (Nygard)
│   ├── architecture/            Architecture Doc テンプレ (living doc)
│   ├── design/                  Design Doc テンプレ (実装前提案)
│   └── pr-description.md
└── docs/
    ├── decisions/                このリポジトリ自体の ADR
    ├── design/                   Design Doc 置き場（任意・大型機能用）
    └── philosophy.md             思想
```

---

## コア思想

- **`.ai/` is source, `.claude/` is runtime.** source-of-truth と runtime を物理分離。同期は明示的なコピー
- **1 skill = 1 responsibility.** `SKILL.md` は frontmatter `responsibility:` で単一責務を宣言、本文 300 行以下を lint で強制
- **Core と Overlay の物理分離.** 共有資産は `.claude/skills/` `.claude/commands/`、プロジェクト固有は `.claude/project-skills/` と `.claude/commands/<手書き>.md`
- **必要なものだけ sync.** 全部入りは AI コンテキストを肥大化させる。Pruning は機能であってバグではない
- **ライフサイクル管理.** `status` / `version` / `superseded_by` で AI プロンプト資産も技術的負債化を防ぐ
- **ベンダ非依存と固有実装の分離.** `claude/` 配下は Claude Code 固有、トップレベルはツール非依存

詳しくは [`docs/philosophy.md`](docs/philosophy.md)。

---

## もっと詳しく

| 知りたいこと | ドキュメント |
|---|---|
| 思想と原則 | [`docs/philosophy.md`](docs/philosophy.md) |
| sync / promote の運用詳細 | [`claude/docs/sync-guide.md`](claude/docs/sync-guide.md) |
| 新しい Skill を書く | [`claude/docs/skill-authoring.md`](claude/docs/skill-authoring.md) |
| 新しい Command を書く | [`claude/docs/command-authoring.md`](claude/docs/command-authoring.md) |
| `claude/` 配下の概要 | [`claude/README.md`](claude/README.md) |
| このリポジトリ自体の意思決定 | [`docs/decisions/`](docs/decisions/) |

---

## トラブルシューティング

### `install.sh` で "not a git repository" エラー
プロジェクトが git 管理下になっていません。`git init` または `git clone` してから再実行してください。

### `.claude/skills/<name>/` を直接編集してしまった
そのままだと次の resync で上書きされます。**上流に戻す意図があれば** `/promote skill <name>` で `.ai/` に push し、`--resync-all` で整合性回復。意図していなければ `--resync-all` で source 側を runtime に上書き戻す。

### submodule が detached HEAD で commit できない
`.ai/` 配下では `git checkout main && git pull --rebase` してから commit してください。`/promote` コマンドはこの手順を案内します。

### `/promote` で "Target exists" と言われた
既に `.ai/claude/` に同名の skill / command がある場合は MODIFY mode が走るはずです。「runtime と source が同一」なら no-op で抜けます。意図的に上書きしたい場合のみ `--force` を使ってください（履歴を失う可能性があるので原則は避ける）。

### `/bootstrap` を既存プロジェクトで走らせてしまった
hard gate により、`CLAUDE.md` や `docs/decisions/` が既存ならコマンド側で停止します。それでも誤って実行された場合、ファイルが書かれる前にユーザの承認待ちで止まる設計なので、Cancel を選んでください。

### 既存プロジェクト（`.ai/` も `.claude/` も無い）に手動で組み込みたい
`install.sh` をそのまま実行できます。submodule add だけ skip され、残りは普通に走ります。

---

## ライセンス

未設定（個人用）。
