---
name: standard-testing-philosophy
version: 0.1.0
last_updated: 2026-05-16
status: draft
---

# Testing Philosophy

## 階層

- **Unit**: 純粋関数・小さなクラス。速い。網羅的に。
- **Integration**: 境界を跨ぐもの（DB・外部 API・WS）。**現実に近い構成** で。
- **E2E**: ユーザ視点の golden path。少数に絞る。

## モックの方針

- **境界より内側はモックしない.** 内部のクラス・関数同士のモックはテストの嘘になりがち。
- **境界はモック OK だが、契約テスト（contract test）でモックと実物の乖離を検出する.**

## 重要

過去にモック前提のテストが通っていたのに本番マイグレーションが壊れたインシデントがあった。**DB / 外部システムを伴うテストは実 DB / コンテナ化サービスで.**

## TDD

新規ロジックは原則 TDD（[[tdd-enforcer]]）。ただしプロトタイピングはこの限りではない。
