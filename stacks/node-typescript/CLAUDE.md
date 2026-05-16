# Stack: Node + TypeScript (CLAUDE.md template)

このファイルをプロジェクトの `CLAUDE.md` の起点としてコピー / 改変する。

## Language conventions

- TypeScript strict mode 必須 (`strict: true`)
- `any` 禁止（必要なら `unknown` + narrow）
- ESM 前提。CJS 互換が必要ならビルド時に分離
- Node の minimum: LTS の現行版

## Tooling

- パッケージマネージャ: pnpm
- Linter: ESLint + `@typescript-eslint`
- Formatter: Prettier
- Test: Vitest（フロント・バックエンド共通）
- Build: tsup / esbuild

## Folder structure（例）

```
src/
  app/            entry points (CLI / server / worker)
  domain/         core logic, no I/O
  infra/          adapters (DB, http, AI)
  shared/         cross-cutting types & utils
```

## Patterns

- Result 型（neverthrow 等）を境界で使い、内部は throw を許容
- Zod でスキーマ検証 + 型推論を一元化
- AI 呼び出しは `infra/ai/` に閉じ込め、Adapter パターンで上位に提供 ([[ai-runtime-boundary]])

## Don'ts

- グローバルシングルトン（テスト不能になる）
- default export（リファクタが効きにくい）
- 型を `as` で誤魔化す
