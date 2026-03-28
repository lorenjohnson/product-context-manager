# Check Alignment Task

Task name: `check-alignment`

This task is the operational engine used by the `product-alignment` eval.

## Purpose

- require an existing, populated `docs/features.md`
- compare product intent docs (`docs/product.md` or `docs/product/*.md`) against `docs/features.md`
- produce a concise alignment result and write the eval report

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

- updates/uses: `<PROJECT_ROOT>/docs/features.md`
- writes eval report: `<PROJECT_ROOT>/docs/evals/product-alignment.md` (overwritten each run)
- prints executive summary in chat/terminal
- report is concise by default:
  - `Alignment Summary`
  - `Conflicts`
  - `Needs Clarification`
  - `Notes`

## Notes

- If `docs/features.md` is missing or still placeholder content, this task refuses to run and instructs the operator to populate it first.
- This flow is heuristic and intended to support human review.
- The alignment script reads feature headings and prose descriptions; it does not require per-feature metadata fields.
