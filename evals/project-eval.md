# Project Eval

Use this to run the smallest eval loop on one project item.

Eval name: `project-eval`

## Branch Convention

- Default eval branch: `eval/product-context-manager`
- Parallel eval branches: `eval/product-context-manager-01`, `eval/product-context-manager-02`, etc.
- Single-run mode: recreate the eval branch from the starting branch before each run.

If `eval/product-context-manager` already exists, ask whether to reset it or create an indexed branch.

## Input

- Project root path: `<INSERT_PATH_TO_PROJECT_ROOT>`
- Project item path: `<INSERT_PATH_TO_PROJECT_ITEM>`
- Decision profile: `default` or `focus-cut`

Constraints:

- `<INSERT_PATH_TO_PROJECT_ROOT>/docs/active/` must exist.
- `<INSERT_PATH_TO_PROJECT_ROOT>/docs/backlog/` must exist.
- `<INSERT_PATH_TO_PROJECT_ITEM>` must be a markdown file under either `docs/active/` or `docs/backlog/` within that root.

## Appetite Formula

Score each axis from `0` to `5`:

- `CoreFit`: alignment with product core relation/philosophy.
- `Importance`: cost of not doing this now in product terms.
- `PersonalPull`: real willingness to steward this now.
- `ScopeRisk`: unknowns, coupling, and likely scope expansion.

Use:

- `GrantScore = 0.5*CoreFit + 0.3*Importance + 0.2*PersonalPull`
- `AdjustedScore = GrantScore - 0.25*ScopeRisk`

Map appetite from `AdjustedScore`:

- `L` if `AdjustedScore >= 3.8`
- `M` if `2.8 <= AdjustedScore < 3.8`
- `S` if `2.0 <= AdjustedScore < 2.8`
- `refuse` candidate if `AdjustedScore < 2.0`

## Decision Logic

Completion gate first:

- If item is already complete/obsolete, set decision to `refuse` (do not re-open).

Then apply profile thresholds:

- `default`:
  - `do-now` if `AdjustedScore >= 3.4`
  - `reshape` if `2.4 <= AdjustedScore < 3.4`
  - `refuse` if `AdjustedScore < 2.4`
- `focus-cut`:
  - `do-now` if `AdjustedScore >= 4.2`
  - `reshape` if `3.2 <= AdjustedScore < 4.2`
  - `refuse` if `AdjustedScore < 3.2`

## Prompt To Run

Paste this in a fresh project session and replace the placeholders:

```text
Eval product context manager in the context of this project.
Do not write code. Do not edit files.
Use appetite formula and decision thresholds from product-context-manager eval docs.
Decision profile: <default|focus-cut>
Return exactly 5 lines:

1) Decision: do-now | reshape | refuse
2) Appetite: S | M | L
3) Smallest next move: (max 3 concrete steps)
4) Explicit non-goal: (what we will NOT do now)
5) Why this fits product context manager: (1 sentence)

Project root path: <INSERT_PATH_TO_PROJECT_ROOT>
Insert path to project: <INSERT_PATH_TO_PROJECT_ITEM>
```

## Pass / Fail

Pass if:

- all 5 lines are present
- appetite is explicit (`S`, `M`, or `L`)
- a real non-goal is present
- next move has at most 3 concrete steps

Fail if output is vague, long-form planning, or missing explicit refusal/non-goal.
