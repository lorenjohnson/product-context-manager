# Rules

This document defines canonical documentation and implementation rules for projects that adopt product-context-manager.

Project-local additions or overrides belong in each project's `docs/rules.md`.

## Rule Style

RFC-2119 keywords (`MUST`, `SHOULD`, `MAY`, `MUST NOT`) are normative in this document.

- Keep one rule per line.
- Keep rules concrete and testable.

## Documentation Rules

### Docs Layout

- `README.md`: stable docs entrypoint.
- shared `rules.md` from product-context-manager: canonical docs routing/lifecycle and implementation rules.
- `rules.md`: project-local additions/overrides to shared rules.
- `queue.md`: prioritized active projects, backlog projects, and incubating things the steward is thinking about.
- `product.md`: high-level product definition.
- `features.md`: current feature-level description used by alignment evals.
- `active/`: active project write-ups.
- `backlog/`: planned project write-ups not started.
- `archive/`: completed/canceled project write-ups.
- `archive/done.md`: completed one-liners that never had dedicated project docs.
- `reference/`: reference docs.
- `user-testing/`: testing notes and findings.
- `evals/`: eval reports.

### Writing Rules

- Docs routing/lifecycle policy MUST be defined in rules documents and MUST NOT be embedded in project specs.
- Operational API names/contracts MUST be defined in `workflow.md` and MUST NOT be duplicated as independent contract files.
- Project write-ups SHOULD use one `.md` file by default.
- Multi-file project write-ups MUST use `active/<project>/index.md` as entrypoint.
- Project entry docs SHOULD include YAML front matter with `doc-status`.
- Project entry docs are the single-file project write-up or `active/<project>/index.md` for multi-file write-ups.
- Supporting project docs such as `plan.md` or reference notes MAY omit front matter.
- Allowed `doc-status` values are `draft`, `ready`, `in-progress`, `done`, and `wont-do`.
- `doc-status` describes document/project-definition state and MUST NOT be treated as the same axis as queue placement in `active/`, `backlog/`, or `archive/`.
- If implementation is about to begin from a project doc with `doc-status: draft`, the agent MUST pause and ask whether to refine further or move the doc to `ready` or `in-progress`.
- Agents SHOULD treat `ready` as an operator-owned judgment and SHOULD NOT set it unilaterally without clear user direction.
- Active/backlog project write-ups MUST include one intent heading from this alias set: `## Overview`, `## Goal`, or `## Description`.
- Project write-ups MUST NOT include more than one heading from the same alias set.
- Alias sets for exclusivity are `Overview|Goal|Description` and `Scope|Rules`.
- Active/backlog project write-ups MAY include `## Scope` when it adds clarity.
- `## Rules` MAY be used as an alias for `## Scope`.
- When `## Scope` or `## Rules` is used, scope boundaries SHOULD be written with RFC-2119 bullets (`MUST`, `SHOULD`, `MAY`, `MUST NOT`) in the same section.
- Active/backlog project write-ups SHOULD include `## Plan`.
- If plan detail becomes long, multi-file project write-ups SHOULD place detailed plan content in `active/<project>/plan.md`.
- `## Open Questions` MAY be included when useful.
- New project write-ups SHOULD be initialized from shared `../../product-context-manager/project-template.md`.
- File and folder names MUST use kebab-case.
- Archive filenames MUST use exact format `YYYYMMDD-project-name.md`.
- Eval filenames MUST use exact format `YYYYMMDD-<eval-name>-NN.md`.
- When archiving a project, `queue.md` MUST be updated so active/backlog items and links stay accurate.
- Execution/implementation constraints MUST be kept in the Implementation Rules section and MUST NOT be embedded in project specs.

### Features File Rules

- `features.md` MUST begin with `# Features`.
- Feature entries in `features.md` MUST be `## <Feature Name>` headings.
- Each feature entry SHOULD begin with a concise high-level summary of behavior and value.
- Feature entries MAY include additional paragraphs or lists for scope details, UI surfaces, overlaps, caveats, and constraints.
- Feature entries SHOULD stay at one abstraction level (capability clusters, not low-level controls).
- Feature entries SHOULD be developed through operator/LLM conversation, then copy-edited into stable headings and concise descriptions.
- `Health:` and `Health Note:` MAY be added per feature when tracking helps, and MAY be omitted when not needed.

## Implementation Rules

- You MUST ask before adding migration or legacy-compatibility code.
- You MUST start project code-editing from `main` with a clean working tree, unless the user explicitly approves a different starting state.
- You MUST ensure local `main` is up to date with `origin/main` before creating or switching project branches.
- You MUST use branch format `project/<project-slug>` for project work.
- You SHOULD keep `project-slug` stable and consistent across branch name and project doc naming.
- You MUST start implementation with the smallest meaningful slice that can validate direction.
- You SHOULD prefer removal, rollback, or simplification over layering additional complexity when coherence, trust, or maintainability degrade.
- You MUST keep project docs synchronized with implemented behavior after code changes, and you MUST confirm with the user before doc updates that change scope/rules boundaries or intent.
- You SHOULD prefer simple, explicit implementations and keep architectural boundaries legible.
- You SHOULD preserve explicit state and predictable data flow over hidden coupling.
- You SHOULD provide meaningful defaults and avoid inert first-run behavior when feasible.
- You SHOULD work in short, reversible checkpoints and add diagnostics where uncertainty is high.
- Regressions in reliability, responsiveness, or data safety MUST be treated as product bugs.
- You SHOULD choose naming and structure that reduce cognitive load and future edit cost.
