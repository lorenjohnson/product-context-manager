# Project Template

Use this template when creating a new project document.
The New Project event in `workflow.md` requires the sections below to be filled before implementation starts.

Default shape is a single project file.
If the plan becomes long or implementation-heavy, use a multi-file write-up:
- `active/<project>/index.md` for Overview (+ Scope/Rules when useful)
- `active/<project>/plan.md` for detailed implementation planning

## 1) Overview

- What is being proposed?
- Why now?
- If this project modifies existing behavior: what is current behavior and what is the intended delta?

`Goal` and `Description` are accepted aliases for `Overview`.
Use only one heading from this alias set per document (`Overview|Goal|Description`).

## 2) Scope (Optional, alias: Rules)

Use only one heading from this alias set per document (`Scope|Rules`).

When this section is present, use RFC-2119 bullets:
- `MUST`: in-scope requirements
- `SHOULD`: preferred constraints
- `MAY`: optional allowances
- `MUST NOT`: out-of-scope guardrails

## 3) Plan

- Smallest meaningful next slice:
- Immediate acceptance check:
- Optional milestones/checkpoints only if they improve clarity:

## Optional Sections

### Open Questions

Use when unresolved questions materially affect safe progress.
