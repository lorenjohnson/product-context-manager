# Rules

Project-local additions or overrides belong in each project's `docs/rules.md`.
RFC-2119 keywords (`MUST`, `SHOULD`, `MAY`, `MUST NOT`) are normative in this document.

## Documentation Rules

- Docs routing and lifecycle policy MUST live in rules documents and MUST NOT be embedded in project specs.
- Project docs SHOULD use one `.md` file by default.
- Multi-file project write-ups MUST use `active/<project>/index.md` as the entrypoint.
- Project entry docs SHOULD include YAML front matter with `doc-status`.
- Supporting project docs such as `plan.md` or reference notes MAY omit front matter.
- Allowed `doc-status` values are `draft`, `ready`, `in-progress`, `done`, and `wont-do`.
- `doc-status` tracks document or project-definition state and MUST NOT be treated as the same axis as queue placement in `active/`, `backlog/`, or `archive/`.
- If the user explicitly directs implementation to begin or resume from a project doc with `doc-status: draft`, the agent MAY move the doc to `in-progress` without pausing.
- If implementation intent is ambiguous while a project doc is still `draft`, the agent SHOULD pause and ask whether to refine further or move it to `ready` or `in-progress`.
- The agent SHOULD help make the boundary visible between informal exploration and committed project work.
- When implementation begins from rough, untracked, or still-draft project thinking, the agent SHOULD call that out clearly and keep project context aligned without creating unnecessary stop points.
- Active and backlog project write-ups SHOULD follow `project-template.md` as the default shape.
- File and folder names MUST use kebab-case.
- Archived project filenames MUST use exact format `YYYYMMDD-project-name.md`.
- When archiving a project, `queue.md` MUST be updated so active and backlog references stay accurate.

## Implementation Rules

- You MUST ask before adding migration or legacy-compatibility code.
- You SHOULD prefer starting new isolated project tracks from a clean, up-to-date `main` when that materially improves clarity, but you MAY adapt to the user's current working state.
- Dedicated project branches SHOULD use format `project/<project-slug>`.
- You SHOULD keep `project-slug` stable across branch naming and project docs.
- You MUST start implementation with the smallest meaningful slice that can validate direction.
- You SHOULD prefer removal, rollback, or simplification over layering additional complexity.
- You SHOULD keep project docs synchronized with implemented behavior at meaningful checkpoints and before handoff or finalization, and you MUST confirm with the user before doc updates that change scope, rules, or intent.
- You SHOULD prefer simple, explicit implementations with legible boundaries and predictable data flow.
- Regressions in reliability, responsiveness, or data safety MUST be treated as product bugs.
