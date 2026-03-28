# Agent Directives

## Normative Status

- This file defines normative routing and system directives for LLM sessions in this repository.
- `README.md` is human-facing context and MUST NOT be treated as routing policy.
- You SHOULD read `README.md` for context and intent.

## Required Load Order

1. `principles.md`
2. `rules.md`
3. `docs/rules.md`
4. `tasks/README.md`
5. `workflow.md`
6. `personality.md`
7. `docs/product.md`
8. `docs/features.md`
9. `docs/queue.md` and linked project docs as needed

## Rules

- You MUST keep routing/system directives in `AGENTS.md`.
- You MUST keep `README.md` human-centric and non-normative.
- You MUST treat `template/docs/` as the canonical copied docs payload for adopted projects.
- You SHOULD load `project-template.md` only when the New Project event in `workflow.md` requires creating a new project doc.
- You SHOULD prefer consolidation over additive growth.
- You MUST avoid duplicating identical contract text across multiple files when a pointer is sufficient.
- You MAY use `evals/` only when the task explicitly requires eval workflows.
- You SHOULD use `tasks/setup.md` for template setup and reconciliation work.
