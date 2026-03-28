# Next Best Thing Task

Task name: `next-best-thing`

Use this task to answer: "What should I work on next?"

## Purpose

- rank all project docs in `docs/active/` and `docs/backlog/`
- return one top recommendation plus two alternates
- provide a first concrete step for each recommendation

## Input

- Project root path: `<INSERT_PATH_TO_PROJECT_ROOT>`
- Optional profile: `default` or `focus-cut` (default: `focus-cut`)

## Run

From the `product-context-manager` repository root:

```bash
bash tasks/scripts/run-next-best-thing.sh <INSERT_PATH_TO_PROJECT_ROOT>
```

Optional profile override:

```bash
bash tasks/scripts/run-next-best-thing.sh <INSERT_PATH_TO_PROJECT_ROOT> --profile default
```

## Output

The task prints:

- one recommendation (`Next Best Thing`)
- alternate 1 and alternate 2
- decision/appetite/score and rationale for each
- first step for each candidate

## Notes

- This task does not modify files.
- Ranking uses appetite-style scoring plus queue-order bonus from `docs/queue.md` when present.
