# Evals

This directory defines fast, repeatable product-context-manager evaluation loops.

## Invocation Contract

Start evals by providing:

1. eval name
2. project root path
3. project item path (required only for `project-eval`)

Required project-root structure:

- For `project-eval` and `all-projects-eval`:
  - `<PROJECT_ROOT>/docs/active/`
  - `<PROJECT_ROOT>/docs/backlog/`
- For `product-alignment`:
  - `<PROJECT_ROOT>/docs/product.md` or `<PROJECT_ROOT>/docs/product/*.md`
  - `<PROJECT_ROOT>/docs/`

## Eval Names

- `project-eval`
- `all-projects-eval`
- `product-alignment`

## Use

- `project-eval.md` for one project item path (active or backlog).
- `all-projects-eval.md` for a loop across all items in `docs/active` and `docs/backlog` for a provided project root.
- `product-alignment.md` for intent-vs-implementation alignment.
  - requires a populated `<PROJECT_ROOT>/docs/features.md`
  - refuses to run if features file is missing or placeholder-only
  - writes one stable report: `<PROJECT_ROOT>/docs/evals/product-alignment.md`
- `reference/roadmap-triage.md` for eval-system triage procedure guidance (not a project template doc).

Write eval outputs to the evaluated project only: `<PROJECT_ROOT>/docs/evals/`.
