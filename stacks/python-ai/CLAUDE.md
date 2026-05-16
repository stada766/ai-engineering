# Stack: Python + AI (CLAUDE.md template)

## Language conventions

- Python 3.12+
- 型ヒント必須 (`mypy --strict` or `pyright strict`)
- `ruff` で lint + format

## Tooling

- パッケージ管理: uv
- Test: pytest
- Schema: pydantic v2
- AI SDK: anthropic / openai / google-genai を adapter 経由でラップ

## Folder structure

```
src/
  app/        entry (CLI, FastAPI, worker)
  domain/     core logic
  infra/
    ai/       provider adapters
    db/
  shared/
tests/
```

## AI integration

- すべての AI 呼び出しは `infra/ai/<provider>_adapter.py` 経由 ([[ai-runtime-boundary]])
- pydantic スキーマで入出力を型化
- retry / timeout / cost guard は adapter に閉じ込める

## Don'ts

- `**kwargs` で全部受ける関数（型が消える）
- グローバル client（テスト不能 / 競合）
- AI レスポンスを **生の dict** のまま上位に流す（必ず pydantic で検証）
