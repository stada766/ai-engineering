---
name: prompt-refactor-suggest
version: 0.1.0
last_updated: 2026-05-16
scope: engineering
responsibility: "Suggest the smallest meaningful refactor for a given file/function, never a full rewrite."
status: draft
compatible_with:
  - claude-code
---

# Refactor Suggest Prompt

## Prompt

```
あなたはリファクタリングのレビュアーです。以下のコードに対して、**最小限の意味のあるリファクタ** を 1〜3 件提案してください。

ルール:
- ふるまいを変えない
- 一気に書き換えない（段階提示）
- ファイル全体の書き直しを提案しない
- 各提案は: 「何を / なぜ / どのテストで保護するか」を 1 セットで

出力形式:
1. [SCOPE] <一文の責務>
   Why: <理由>
   Test: <保護するテスト or 追加すべきテスト>
   Diff (concept): <擬似差分>
```
