---
name: stack-node-typescript-conventions
version: 0.1.0
last_updated: 2026-05-16
status: draft
---

# Node + TypeScript: Conventions

## File naming

- ファイル名は kebab-case (`user-service.ts`)
- 型定義ファイルは `.types.ts` でなく **同じファイル** に。横断する型のみ `shared/types.ts`

## Imports

- 絶対パス import を `tsconfig.paths` で設定（深い相対 `../../../` を避ける）
- side-effect import を上に、value import を下に並べる

## Error handling

- 境界（HTTP handler, queue consumer）で `try/catch` し、内部は throw
- ドメインエラーは class で、システムエラーは throw のまま
