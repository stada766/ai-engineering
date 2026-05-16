---
name: standard-naming
version: 0.1.0
last_updated: 2026-05-16
status: draft
---

# Naming Standard (Language-Agnostic)

## 原則

- **意図 > 短さ.** `n` より `pendingMessageCount`
- **役割を名前に込める.** `data` ではなく `subscriberRoster`
- **副作用のある関数は動詞で.** `fetchUser` / `applyMigration`
- **純粋関数は意味で.** `latencyP95(samples)` ではなく `p95Of(samples)` のように関係を示す

## 避けるべきパターン

- `Manager` / `Helper` / `Util` / `Common` — 責務が消える
- `data` / `info` / `value` — 何の情報か不明
- `_temp` / `_old` / `_new` — リファクタの残骸

## ディレクトリ命名

- 単数形か複数形を **プロジェクト全体で統一**（混在は迷う）
- domain 名 > 技術名（`billing/` > `services/`）

## 言語別の揺らぎは許容

- 言語のイディオム（Python の snake_case、TS の camelCase 等）はそれに従う
- 横断する命名規約はこの文書、言語固有は `stacks/<lang>/conventions.md`
