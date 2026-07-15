# Tasks

This directory defines reusable maintenance tasks for Product Context Manager.

## Task Names

- `setup`

## Use

- `setup.md`: initialize Product Context Manager in a project or reconcile an existing setup.
  - default mode is apply (updates files)
  - `--check` for dry verification only
  - `--yes` for authorized non-interactive reconciliation of a marked installation
  - `--adopt` for explicit adoption when unmarked managed files conflict
  - `/bin/bash tasks/scripts/test-setup.sh` runs setup safety regressions
