---
name: standard-commenting-policy
version: 0.1.0
last_updated: 2026-05-16
status: draft
---

# Commenting Policy

## 原則: デフォルトはコメントを書かない

- 命名と構造で表現する
- 何をしているか (`what`) はコードで読めれば不要

## 書くべきとき

**WHY が非自明** な場合のみ：

- 隠れた制約（"DB の foo カラムが NULL を許容するため..."）
- 微妙な不変条件
- 特定バグへの workaround（issue 番号は書かない — 腐る）
- 読者が驚く挙動

## 書いてはいけない

- 「issue #123 の修正で追加」「X から呼ばれる」のような **コンテキスト依存**
- `// TODO` だけで日付・担当・期限がない
- コードのリピート（`i++; // i をインクリメント`）

## docstring

- 多段落の docstring は避ける
- 1〜2 行で意図 / 戻り値の意味 / 副作用を要約
