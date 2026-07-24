---
name: architecture-overview
version: 0.1.0
last_updated: 2026-07-23
status: draft
---

# ai-engineering Architecture

> **これは「現在の設計の唯一の正典」です。** 設計を変える PR では、この文書を同じ PR で更新してください。
> 各決定の **なぜ** は ADR にあります（§5 からリンク）。ここに rationale を重複させないこと。
> 運用ルールは [[standard-documentation-model]] (`standards/documentation-model.md`) を参照。

## 1. Purpose & Scope

- **何を作るか**: AI コーディングエージェント（Claude Code 等）と協働するための、再利用可能な思想・規約・Skills・Commands を束ねた playbook リポジトリ。
- **誰のためか / 何を解決するか**: 複数プロジェクトを横断して同じ ADR テンプレ・レビュー方針・コミットルールを共有し、静かな分岐・責務の暗黙化・資産の負債化を防ぐ。詳細は [[philosophy]] (`docs/philosophy.md`)。
- **Non-goals**: アプリケーションコードは持たない（組織的記憶＝ドキュメント/プロンプト資産のみ）。特定 1 プロジェクト固有の文化を Core に混ぜない。

## 2. Constraints

- **技術的前提**: 各プロジェクトは macOS / WSL / Docker / CI で動作する想定。配布は Git submodule ＋ copy script（npm 等のパッケージレジストリに依存しない）。
- **ベンダ非依存の原則**: トップレベルはツール非依存、ツール固有実装は `claude/` 配下に隔離（将来 Cursor / Gemini 等を追加可能に）。

## 3. System Overview

source-of-truth リポジトリと、それを参照する各プロジェクト runtime の 2 層構成。

```
 ai-engineering (source of truth)          各プロジェクト (runtime)
   claude/skills/     ── submodule ──►        .ai/      (固定参照・read-only)
   claude/commands/   ── sync ───────►        .claude/  (実体コピー)
   always-include.txt                            skills/ commands/
                      ◄── promote ───         project-skills/ (上り昇格)
   standards/ templates/ stacks/ architecture/ docs/
```

- **ランタイム分割**: `.ai/`（source 参照, read-only）と `.claude/`（runtime 実体）を **物理分離**。symlink ではなくコピーで境界を視覚化（→ ADR-0002）。編集は原則 read-only、例外は "edit-then-promote"。

## 4. Building Blocks

| コンポーネント | 責務（一文） | 主要な依存 |
|---|---|---|
| `claude/skills/` | AI が発見する単一責務レンズ（engineering/backend/ai/frontend の 4 スコープ） | scope 階層 (ADR-0001) |
| `claude/commands/` | ユーザがトリガーする儀式（`/bootstrap` `/adr` `/architecture` `/commit` 他） | skills |
| `claude/scripts/` | `sync-to-project.sh`（下り）/ `promote-to-source.sh`（上り） | submodule 構成 |
| `claude/always-include.txt` | 常時同期する既定ツールキットの宣言（repo-level policy） | sync/install |
| `standards/` | ベンダ非依存の規約（testing / error-handling / naming / documentation-model） | — |
| `templates/` | ADR / Architecture Doc / Design Doc / PR / CLAUDE.md の雛形 | — |
| `stacks/` | 言語スタック別 AI 指示（node-typescript / flutter / python-ai） | — |
| `architecture/patterns/` | 生きたパターン集（runtime-separation / ai-runtime-boundary 他） | — |
| `docs/decisions/` | ADR（不変の意思決定ログ） | — |

## 5. Key Decisions（→ ADR）

現在の設計を形作っている主要決定。詳細と代替案は ADR 本体を参照。

| 領域 | 現在の選択 | 根拠 (ADR) |
|---|---|---|
| Skill 階層 | 4 水平スコープ（engineering/backend/ai/frontend）＋ project overlay | ADR-0001 |
| 配布戦略 | submodule = source（`.ai/`）、copy script = runtime（`.claude/`） | ADR-0002 |
| ツール名前空間 | Claude 固有実装は `claude/` 配下、トップレベルはベンダ非依存 | ADR-0003 |
| ドキュメント運用 | ADR（Why・不変）/ ARCHITECTURE.md（現在）/ Design Doc（提案）の 3 層 | [[standard-documentation-model]] |

> Superseded された ADR はここに載せない（現在の正解のみ）。履歴は `docs/decisions/` を辿る。

## 6. Cross-cutting Concerns

- **AI runtime 境界**: playbook 自体はコードを持たないため N/A。ただし各プロジェクト向けの指針として [[pattern-ai-runtime-boundary]] / [[pattern-runtime-separation]] を提供。
- **ライフサイクル管理**: すべての資産は frontmatter に `version` / `status` / `superseded_by` を持ち、陳腐化を追跡できる。
- **同期の一貫性**: 下り（sync）は必要なものだけコピー、上り（promote）は ADD/MODIFY を自動判定・no-op 拒否・lint。upstream は auto-commit しない。
- **テスト**: `tests/` に skill 単位のテスト（例 `tests/adr-writer/`）。方針は [[standard-testing-philosophy]]。

## 7. Risks & Open Questions

- **リスク**: submodule ＋ copy の二重管理で、`.ai/` と `.claude/` がドリフトし得る（"edit-then-promote" 規律で緩和）。
- **未解決**: Claude 以外の runtime（Cursor / Gemini 等）への `claude/` 相当の展開方法は未着手。追加時は ADR を起こす。
- **未解決**: Design Doc 層（`docs/design/`）の実運用はこれから。最初の大型機能で試す。

---

### Maintenance

- **更新タイミング**: 設計を変える PR と同一 PR。ADR を Accepted にしたらその結論を §5 に反映（`/architecture` で reconcile）。
- **更新しないもの**: 決定理由（→ ADR）・実装手順（→ Design Doc / issue）・履歴（→ git）。
- **陳腐化チェック**: `frontmatter.last_updated` が古く実装とズレていたら要更新。
