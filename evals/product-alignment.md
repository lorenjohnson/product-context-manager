# Product Alignment Eval

Eval name: `product-alignment`

This eval checks whether stated product intent aligns with a human-authored features file.

## Flow

1. Ensure `docs/features.md` exists and is populated.
2. If missing or placeholder-only, stop and instruct operator to create/populate `docs/features.md` from template.
3. Compare intent source (`docs/product.md` or `docs/product/*.md`) against `docs/features.md`.
4. Write one stable report file (overwrite): `<PROJECT_ROOT>/docs/evals/product-alignment.md`.
5. Return executive summary in chat/terminal.

## Input

- Project root path: `<INSERT_PATH_TO_PROJECT_ROOT>`

## Run

From the `product-context-manager` repository root:

```bash
bash tasks/scripts/run-check-alignment.sh <INSERT_PATH_TO_PROJECT_ROOT>
```

Options:

```bash
bash tasks/scripts/run-check-alignment.sh <INSERT_PATH_TO_PROJECT_ROOT> --print-report
```

## Output

- features artifact: `<PROJECT_ROOT>/docs/features.md`
- eval report: `<PROJECT_ROOT>/docs/evals/product-alignment.md` (overwritten each run)
  - concise sections: summary, conflicts, needs clarification, notes

## Notes

- This eval is designed for iterative review against a human-authored features file.
- It is heuristic and supports human judgment; it does not replace it.
- It expects a simple features file (feature headings + prose), not per-feature metadata.
