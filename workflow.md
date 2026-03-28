# Workflow

Event-based execution protocol for LLM-assisted product work.
Events are trigger-based and are not a sequential stage pipeline.
Project doc sync is a continuous loop.

## Terminology

- Use `project` as the default unit of work.
- A project may be a new feature, bug fix, or modification of existing behavior.
- Feature/bugfix/modification are project types, not separate workflow events.

## Operational API Surface

This section is the canonical operation surface for this system, independent of transport.
Direct shell usage and any future MCP adapter MUST preserve these names and contracts.

### `initialize`

Purpose: adopt or reconcile one project with the template contract.

Task doc:

- `tasks/setup.md`

Input:

- `project_root` (required)
- `mode`: `apply` (default) or `check`
- `assume_yes`: `true|false` (default `false`, maps to `--yes`)

Current implementation:

- `tasks/scripts/run-setup.sh <project_root> [--check] [--yes]`

### `audit_projects`

Purpose: classify active/backlog project docs for keep/refine/remove decisions.

Input:

- `project_root` (required)
- `profile`: `focus-cut` (default) or `default`

Current implementation:

- `tasks/scripts/run-projects-cleanup.sh <project_root> [--profile <profile>]`

### `next_best_thing`

Purpose: recommend what to work on next across active/backlog docs.

Input:

- `project_root` (required)
- `profile`: `focus-cut` (default) or `default`

Current implementation:

- `tasks/scripts/run-next-best-thing.sh <project_root> [--profile <profile>]`

### `check_alignment`

Purpose: compare product intent against feature reality and write alignment report.

Input:

- `project_root` (required)
- `print_report`: `true|false` (default `false`)

Current implementation:

- `tasks/scripts/run-check-alignment.sh <project_root> [--print-report]`

## Routing Decision (Run First)

1. If the request does not require project lifecycle changes or code changes, handle it directly without project/branch actions.
2. If requested work is already covered by an active project doc, use Resume In-Progress Project.
3. If requested work is not covered by an active project doc, use New Project.
4. After any project-related code changes, run After Code Changes.
5. When implementation appears complete, run Finalize Project.

## Events

### New Project

Trigger: user asks for work that is not already covered by an active project doc.
This includes new features, bug fixes, and modifications of existing behavior.

Required actions:

1. Create/switch branch `project/<project-slug>` using canonical branch rules in `rules.md`.
2. Create the project doc from `project-template.md` and fill all required sections before implementation.
3. Ask the user only for clarifications that materially block safe progress.
4. Begin with the smallest meaningful implementation slice.

### Resume In-Progress Project

Trigger: user asks to resume work on a project with prior implementation history.

Required actions:

1. Identify the target project doc and project slug for the resumed work.
2. If multiple active projects could match, pause and ask the user to select one.
3. Ensure branch `project/<project-slug>` exists and switch to it.
4. If the branch does not exist, pause and ask whether to create it from current `main` or treat this as New Project.
5. Reconcile project doc with current codebase reality.
6. Continue with the next smallest meaningful implementation slice.

### Finalize Project

Trigger: a project's implementation work is considered complete.

Required checks:

1. Validate completion checklist: implemented behavior matches intent, testing is adequate for scope, no obvious regressions or unresolved high-risk issues remain, and outcome still aligns with product principles.
2. If any checklist item fails, report what remains and continue the project.
3. If all checklist items pass, ask the user for branch disposition (`merge now`, `defer merge`, or `close without merge`).
4. Apply the chosen branch disposition.
5. If archiving is selected, apply archive and queue updates according to shared product-context-manager `rules.md`.

### After Code Changes

Trigger: after any code changes during implementation.

Required actions:

1. Apply the canonical project-doc synchronization rule from `rules.md`.
2. Continue implementation after required project doc updates are complete.
