# Tasks

This directory defines reusable maintenance tasks for Product Context Manager.
Operational API names/contracts are canonical in `../workflow.md`.

## Task Names

- `setup`
- `projects-cleanup`
- `next-best-thing`
- `check-alignment`


## Use

- `setup.md`: initialize Product Context Manager in a project or reconcile an existing setup.
  - default mode is apply (updates files)
  - `--check` for dry verification only
- `projects-cleanup.md`: classify active/backlog project docs into keep/refine/remove candidates.
  - output is direct to terminal/chat
  - no report file is written
- `next-best-thing.md`: rank all projects and return top recommendation + alternates.
  - output is direct to terminal/chat
  - no report file is written
- `check-alignment.md`: compare product intent against features and write alignment eval output.
  - output includes executive summary in chat/terminal
  - writes `<PROJECT_ROOT>/docs/evals/product-alignment.md`
