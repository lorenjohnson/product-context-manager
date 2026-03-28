# All Projects Eval

Run `project-eval` in a loop for all project items in a provided repository.

Eval name: `all-projects-eval`

## Scope

Project root path:

- `<INSERT_PATH_TO_PROJECT_ROOT>`

Item set:

- all markdown files in `docs/active/`
- all markdown files in `docs/backlog/`
- decision profile: pass through to `project-eval` (`default` or `focus-cut`)

Constraints:

- `<INSERT_PATH_TO_PROJECT_ROOT>/docs/active/` must exist.
- `<INSERT_PATH_TO_PROJECT_ROOT>/docs/backlog/` must exist.

## Branch Convention

- Default: `eval/product-context-manager`
- Parallel: `eval/product-context-manager-01`, `eval/product-context-manager-02`, etc.

For a fresh single run, recreate the eval branch from the starting branch.

## Loop Procedure

1. Build the item list from `docs/active/**/*.md` and `docs/backlog/**/*.md`.
2. For each item path, run the exact prompt + logic from `project-eval.md`.
3. Capture the 5-line output exactly.
4. Produce one final markdown report in `<PROJECT_ROOT>/docs/evals/`.

## Report Location And Naming

Write to:

- `<PROJECT_ROOT>/docs/evals/YYYYMMDD-all-projects-eval-NN.md`

Where:

- `YYYYMMDD` uses the archive-style date format
- `NN` is a zero-padded run index for that date (`01`, `02`, `03`, ...)

## Report Format

Use this structure:

1. `# All Projects Eval Report`
2. `## Run Metadata` (date, branch, project root, item count, decision profile)
3. `## Summary` (count by decision: do-now / reshape / refuse; carry-forward total; refused total)
4. `## Carry Forward` table:
   - `item_path`
   - `decision`
   - `appetite`
   - `smallest_next_move`
   - `explicit_non_goal`
   - `fit_reason`
5. `## Refused` table:
   - `item_path`
   - `decision`
   - `appetite`
   - `explicit_non_goal`
   - `fit_reason`
6. `## Failures` (items that did not return the required 5 lines)
7. `## Notes` (short, optional)
