# Stack: Flutter — AI Instructions

このファイルはプロジェクトの AI 向け指示書（Claude Code なら `CLAUDE.md`、他ツールなら `AGENTS.md` 等）の起点としてコピー / 改変する。ベンダ非依存の素材として用意されている。

## Language conventions

- Dart 3 系。Null safety 必須
- 公式 lint パッケージ `flutter_lints` を継承し、プロジェクト独自 rule を追記
- `dart format` を CI で強制

## State management

- 機能規模に応じて Riverpod / Bloc / ChangeNotifier を選ぶ
- グローバル State は最小化。**画面ローカル State を優先**
- 永続化は Hive / Drift / SharedPreferences のいずれか一つに統一

## Folder structure

```
lib/
  app/         entry, router
  features/    画面・機能単位（縦割り）
  core/        cross-cutting (theme, network, ai-adapter)
  shared/      共通 widget / utils
```

## AI integration

- AI 呼び出しは `core/ai/` の adapter に閉じ込める ([[ai-runtime-boundary]])
- UI スレッドをブロックしない。`compute` / isolate を活用

## Don'ts

- `setState` の乱用（rebuild 範囲が読めなくなる）
- `BuildContext` を非同期処理に持ち越す（mounted チェックなしの利用）
