# Projects Cleanup Task

Task name: `projects-cleanup`

Use this task to quickly reduce project-doc clutter across one repository.

## Purpose

- classify every project in `docs/active/` and `docs/backlog/`
- recommend what to carry, what to refine, and what to remove
- keep output in chat/terminal (no report files)
- use minimal-shape checks (intent heading: `Overview` default with `Goal`/`Description` aliases; optional `Scope`/`Rules`; `Plan`) without forcing a rigid full template
- enforce alias exclusivity (only one heading from each alias set: `Overview|Goal|Description` and `Scope|Rules`)
- apply removal heuristics in this order:
  - implemented/completed signals (archive candidates)
  - staleness by `updated`/`created` dates
  - clear misalignment or irrelevance signals

## Input

- Project root path: `<INSERT_PATH_TO_PROJECT_ROOT>`
- Optional profile: `default` or `focus-cut` (default: `focus-cut`)

## Run

From the `product-context-manager` repository root:

```bash
bash tasks/scripts/run-projects-cleanup.sh <INSERT_PATH_TO_PROJECT_ROOT>
```

Optional profile override:

```bash
bash tasks/scripts/run-projects-cleanup.sh <INSERT_PATH_TO_PROJECT_ROOT> --profile default
```

## Output

The task prints:

- counts for refine / archive / remove candidates
- refine split counts: `refine_easy` and `refine_needs_attention`
- remove-gate hit counts (implemented/completed, staleness, relevance)
- plain in-chat action lists:
  - Refine Easy
  - Refine Needs Attention
  - Archive Candidates
  - Remove Candidates

## Notes

- This task does not modify files.
- This task does not write a report file.
- Use it before pruning docs or reprioritizing `docs/queue.md`.
