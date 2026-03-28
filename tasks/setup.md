# Setup Task

Task name: `setup`

Use this task to initialize Product Context Manager in a project or reconcile an already initialized project.

## Payload

Copy the full contents of `template/**` into `<PROJECT_ROOT>/**`, preserving relative paths.
In plain form: mirror `template/*` into project root.

## Managed Classes

- strict replace:
  - `<PROJECT_ROOT>/AGENTS.md`
  - `<PROJECT_ROOT>/docs/README.md`
  - any template-managed docs file not explicitly scaffold-only
- scaffold/shape check:
  - `<PROJECT_ROOT>/docs/queue.md`
  - `<PROJECT_ROOT>/docs/product.md`
  - `<PROJECT_ROOT>/docs/rules.md`
  - enforce `##` headings from template only
- never-touch project-owned docs content:
  - `<PROJECT_ROOT>/docs/archive/done.md`

## Initialize (New Project)

1. Apply the full template payload copy (`template/**` -> `<PROJECT_ROOT>/**`).
2. Confirm required docs structure exists after copy.

## Reconcile (Already Initialized Project)

Use this path when template payload already exists and you want to bring project docs back into contract.
This preserves scaffold-managed project docs while enforcing template shape rules.
When an existing setup fingerprint is detected, setup asks whether to proceed in reconcile mode.

## Input

- Project root path: `<INSERT_PATH_TO_PROJECT_ROOT>`

Constraints:

- `<INSERT_PATH_TO_PROJECT_ROOT>/` must exist.
- `product-context-manager/template/docs/` must exist.

## Run

From the `product-context-manager` repository root:

```bash
bash tasks/scripts/run-setup.sh <INSERT_PATH_TO_PROJECT_ROOT>
```

Options:

- `--check`: detect divergences only (no file changes)
- `--yes`: skip reconcile confirmation when fingerprint is detected

## Output

- Default output is a direct summary in terminal/chat.
