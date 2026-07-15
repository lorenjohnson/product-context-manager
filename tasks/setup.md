# Setup Task

Task name: `setup`

Use this task to initialize Product Context Manager in a project or reconcile an already initialized project.

## Payload

Copy the managed contents of `template/` into `<PROJECT_ROOT>/`, preserving relative paths and including the hidden installation marker.

The versioned `.product-context-manager` marker identifies installations created or explicitly adopted by this task.

## Managed Classes

- strict replace:
  - `<PROJECT_ROOT>/.product-context-manager`
  - `<PROJECT_ROOT>/AGENTS.md`
  - `<PROJECT_ROOT>/docs/README.md`
  - any template-managed docs file not explicitly scaffold-only
- scaffold/shape check:
  - `<PROJECT_ROOT>/docs/current.md`
  - `<PROJECT_ROOT>/docs/queue.md`
  - `<PROJECT_ROOT>/docs/product.md`
  - `<PROJECT_ROOT>/docs/rules.md`
  - enforce `##` headings from template only
- never-touch project-owned docs content:
  - `<PROJECT_ROOT>/docs/archive/done.md`

## Setup States

- Fresh: no marker and no managed-path conflicts. Initialize normally.
- Known: the supported marker exists. Reconcile only after interactive confirmation or with `--yes`.
- Unknown: no marker, but one or more managed paths exist. Stop without writing unless `--adopt` explicitly authorizes adoption.

Generic `AGENTS.md` or `docs/` presence MUST NOT be treated as a Product Context Manager installation marker.

## Initialize (Fresh Project)

1. Apply the managed template files other than the marker.
2. Write the installation marker.
3. Confirm required docs structure exists after copy.

## Reconcile (Already Initialized Project)

Use this path when the supported installation marker exists and you want to bring project docs back into contract.
This preserves scaffold-managed project docs while enforcing template shape rules.
Interactive setup asks whether to proceed. Non-interactive setup requires `--yes`.

## Adopt (Unknown Existing Project)

Use `--check` to review affected paths first. Use `--adopt` only after the user explicitly authorizes Product Context Manager to replace or modify conflicting managed paths.

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
- `--yes`: authorize non-interactive reconciliation when the supported marker exists
- `--adopt`: explicitly authorize setup when unmarked managed files already exist

`--yes` does not authorize adoption.

## Output

- Default output is a direct summary in terminal/chat.
- Apply mode reports a path before replacing or modifying it.
- `--check` lists managed paths that differ without changing them.

## Verify

Run the focused setup regression suite with the macOS system Bash:

```bash
/bin/bash tasks/scripts/test-setup.sh
```
