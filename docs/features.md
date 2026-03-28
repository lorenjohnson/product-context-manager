# Features

List feature entries at a consistent level as user-visible capability clusters.
Start each feature with a concise high-level summary of behavior and value.
Add additional detail when useful, including notes on scope, UI surfaces, overlaps, caveats, or constraints.
Use optional `Health:` and `Health Note:` lines only when tracking clarity improves.

## Session Routing Contract
Defines deterministic session load order through `AGENTS.md`, separating human-facing context (`README.md`) from normative LLM routing and execution directives.

## Shared Core Files
Provides canonical `principles.md`, `rules.md`, `tasks/README.md`, `workflow.md`, and `personality.md` for cross-project use with project-local override points.

## Project Docs Template Payload
Supplies a reusable docs scaffold (`template/docs/`) with stable files (`README.md`, `product.md`, `features.md`, `queue.md`, `rules.md`) and directory layout (`active/`, `backlog/`, `archive/`, `reference/`, `user-testing/`).

## Project Lifecycle Workflow
Defines event-based handling for New Project, Resume In-Progress Project, Finalize Project, and After Code Changes, including branch and project-doc synchronization requirements.

## Project Template Intake
Provides a standard project-spec structure (`project-template.md`) requiring project statement, product fit/value, scope/non-goals, and first-slice plan before implementation starts.

## Maintenance Tasks
Includes runnable task flows for template reconciliation (`initialize`), project audit/cleanup (`audit_projects`), next priority recommendation (`next_best_thing`), and product/feature alignment checks (`check_alignment`).

## Evaluation Loops
Includes eval patterns for per-project and all-project triage plus product-alignment reporting to support focus cuts, refusal decisions, and queue reshaping.

## Self-Application Mode
Supports applying the same docs contract and workflow to this repository itself for continuous validation while the system evolves.
