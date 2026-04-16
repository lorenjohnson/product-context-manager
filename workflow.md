# Workflow

Runtime routing for project-oriented work.
Use this file for session behavior, not durable policy or tool reference.

## Routing Decision (Run First)

1. If the request does not require project lifecycle changes, project-memory lookup, or code changes, handle it directly without project/branch actions and without loading queue or project docs.
2. If routing, prioritization, or continuity depends on project state, consult `queue.md`.
3. If requested work is already covered by an active project doc, use Resume Project.
4. Otherwise use New Project.
5. After meaningful project-related code changes or before handoff, run After Code Changes.
6. When implementation appears complete, run Finalize Project.

## Context Loading

- Treat `AGENTS.md` load order as the default context baseline.
- Load `docs/queue.md` only when routing project work, checking project status or prioritization, or locating an existing project doc.
- Load linked project docs only after a relevant queue entry or project doc has been selected.
- Load `project-template.md` only during New Project when creating a new project doc.
- Load `tasks/README.md` only when invoking a Product Context Manager task.

## Events

### New Project

Trigger: user asks for work that is not already covered by an active project doc.
This includes new features, bug fixes, and modifications of existing behavior.

Required actions:

1. Load `project-template.md`, then create the project doc and fill all required sections before implementation.
2. Initialize the project entry doc with `doc-status: draft`.
3. When implementation begins, apply the draft-start rule from `rules.md`.
4. Apply any relevant implementation rules from `rules.md`.
5. Begin with the smallest meaningful implementation slice.

### Resume Project

Trigger: user asks to resume work on a project with prior implementation history.

Required actions:

1. Identify the target project doc and project slug for the resumed work.
2. If multiple active projects could match, pause and ask the user to select one.
3. Load the selected project doc and any directly relevant linked project docs.
4. Reconcile project doc with current codebase reality.
5. When implementation resumes, apply the draft-start rule from `rules.md`.
6. Apply any relevant implementation rules from `rules.md`.
7. Continue with the next smallest meaningful implementation slice.

### Finalize Project

Trigger: a project's implementation work is considered complete.

Required checks:

1. Validate completion checklist: implemented behavior matches intent, testing is adequate for scope, no obvious regressions or unresolved high-risk issues remain, and outcome still aligns with product principles.
2. If any checklist item fails, report what remains and continue the project.
3. If all checklist items pass, ask the user for branch disposition (`merge now`, `defer merge`, or `close without merge`).
4. Apply the chosen branch disposition.
5. If archiving is selected, apply archive and queue updates according to `rules.md`.

### After Code Changes

Trigger: after meaningful code changes during implementation or before handoff/finalization.

Required actions:

1. Apply the canonical project-doc synchronization rule from `rules.md`.
2. Keep `doc-status` synchronized when project state has clearly changed.
3. Continue implementation after any needed project doc updates are complete.
