---
name: standard-error-handling
version: 0.1.0
last_updated: 2026-05-16
status: draft
---

# Error Handling Standard

## 原則

- **境界で検証, 内部で信頼.** ユーザ入力・外部 API は境界で検証し、内部関数は事前条件を信頼する。
- **失敗モードは型で表現.** 例外で投げるべきか結果型で返すべきかは、**呼び出し側がハンドルするか** で決める。
- **再試行可能性を分類.** transient / permanent / unknown を区別。**unknown を transient 扱いするのは事故の元.**

## やらないこと

- すべての関数で try/catch を被せる（防衛的プログラミング過剰）
- 例外を握りつぶす（必ず log / propagate / 明示的に無視と書く）
- "起きえない" を引数として黙って通す（assert か型で潰す）

## ロギング

- 例外と一緒に **コンテキスト** を出す（入力の要約・処理段階）
- スタックトレースは保持する（再 throw 時に消さない）
