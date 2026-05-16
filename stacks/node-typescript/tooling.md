---
name: stack-node-typescript-tooling
version: 0.1.0
last_updated: 2026-05-16
status: draft
---

# Node + TypeScript: Tooling

## scripts (package.json)

```jsonc
{
  "scripts": {
    "dev":      "tsx watch src/app/server.ts",
    "build":    "tsup src/app/server.ts --format esm --dts",
    "test":     "vitest run",
    "test:watch": "vitest",
    "lint":     "eslint . --max-warnings 0",
    "typecheck":"tsc --noEmit"
  }
}
```

## CI minimum

- `pnpm install --frozen-lockfile`
- `pnpm typecheck && pnpm lint && pnpm test`
- main 直接 push 禁止 / PR review 必須
