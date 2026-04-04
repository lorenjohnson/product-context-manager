# Workflow

Runtime routing for project-oriented work.
Use this file for session behavior, not durable policy or tool reference.

## Routing Decision (Run First)

1. If the request does not require project lifecycle changes or code changes, handle it directly without project/branch actions.
2. If requested work is already covered by an active project doc, use Resume Project.
3. Otherwise use New Project.
4. After any project-related code changes, run After Code Changes.
5. When implementation appears complete, run Finalize Project.

## Events

### New Project

Trigger: user asks for work that is not already covered by an active project doc.
This includes new features, bug fixes, and modifications of existing behavior.

Required actions:

1. Create the project doc from `project-template.md` and fill all required sections before implementation.
2. Initialize the project entry doc with `doc-status: draft`.
3. If implementation is about to begin while the project entry doc is still `draft`, pause and ask whether to refine further or move it to `ready` or `in-progress`.
4. When implementation actually begins, apply canonical branch rules from `rules.md`.
5. Begin with the smallest meaningful implementation slice.

### Resume Project

Trigger: user asks to resume work on a project with prior implementation history.

Required actions:

1. Identify the target project doc and project slug for the resumed work.
2. If multiple active projects could match, pause and ask the user to select one.
3. Reconcile project doc with current codebase reality.
4. If implementation is about to resume while the project entry doc is still `draft`, pause and ask whether to refine further or move it to `ready` or `in-progress`.
5. When implementation actually resumes, apply canonical branch rules from `rules.md`.
6. Continue with the next smallest meaningful implementation slice.

### Finalize Project

Trigger: a project's implementation work is considered complete.

Required checks:

1. Validate completion checklist: implemented behavior matches intent, testing is adequate for scope, no obvious regressions or unresolved high-risk issues remain, and outcome still aligns with product principles.
2. If any checklist item fails, report what remains and continue the project.
3. If all checklist items pass, ask the user for branch disposition (`merge now`, `defer merge`, or `close without merge`).
4. Apply the chosen branch disposition.
5. If archiving is selected, apply archive and queue updates according to `rules.md`.

### After Code Changes

Trigger: after any code changes during implementation.

Required actions:

1. Apply the canonical project-doc synchronization rule from `rules.md`.
2. Keep `doc-status` synchronized when project state has clearly changed.
3. Continue implementation after required project doc updates are complete.
