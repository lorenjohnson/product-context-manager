# Product Context Manager

## Overview

This product is a shared interface between human makers and LLM coding agents that maintains and persists the evolving context and intentions of a product across sessions. It exists to counter context rot and loss of direction caused by limited context windows and generative drift. It turns product direction into an operable contract, so sessions can start from clear grounding, apply consistent rules, and keep documentation synchronized with real work. Software here is treated as a designed relation between authors, users, and real-world conditions, so intent is continuously tested in use and steered toward more humane possibilities.

Its deeper purpose is to increase the odds that LLM-assisted development produces coherent, valuable outcomes aligned with the makers' principles rather than momentum or noise. It does this with lightweight durable rules plus workflow-guided context loading, not with heavy always-loaded process. The system is meant to protect continuity of intention, reduce accidental sprawl, and hold a middle line between abstract market logic and unstructured instinct so work remains practical to steward and meaningfully beneficial to human life and relationship.

## Product Development Principles

The aim is not framework mechanics for their own sake, and not pure improvisational authorship either. The center is authored interpretation with disciplined constraint.

We intentionally hold a middle line between two common failures: reducing people to generic market abstractions, and building from personal instinct without a method for scope, exclusion, revision, or care.

Products shaped by this system should remain interpretable over time, humane in use, and practical to steward.

## Practical Orientation

When choices are ambiguous, prefer coherence over feature count, fewer stronger moves over many weak additions, and explicit refusal/removal over accidental sprawl.

Play and exploration are welcome, but they are held to consequence: work should stay connected to real use, real constraints, and long-term stewardship.

## Boundaries

- This is not a full PM platform.
- This is not a permanent archive of every historical decision.
- Template reconciliation is a maintenance task, not an eval.
- This is not meant to load every documentation file into every session by default.

## What Lives Here

- `principles.md`: concise principles loaded by LLM sessions.
- `rules.md`: canonical durable documentation and implementation rules.
- `tasks/README.md`: shared tools index and task usage entrypoint.
- `workflow.md`: canonical project workflow, runtime routing, and conditional context-loading behavior.
- `project-template.md`: required section template for new project docs.
- `docs/`: this repository's own product docs (self-applied pattern).
- `template/`: canonical files copied into adopting projects.
- `tasks/`: reusable maintenance tasks (including template reconciliation).

## Default Session Shape

The intended default session baseline is deliberately small:

- shared `principles.md`
- shared `rules.md`
- project-local `docs/rules.md`
- shared `workflow.md`
- project-local `docs/product.md`

Additional docs such as `queue.md`, selected project docs, and task docs should be loaded only when the workflow actually calls for them.

## Adoption Intent

Projects that adopt this system copy the template payload, keep shared practice centralized here, and keep project docs focused on local product definition and active work. `AGENTS.md` should stay small and normative, while `workflow.md` handles when extra project context gets pulled in.

## Adopt In A Project

1. Clone this repository as a sibling of the project you want to initialize.

```bash
cd /path/to/parent-directory
git clone https://github.com/lorenjohnson/product-context-manager.git
cd product-context-manager
```

2. From the target project's root, ask your coding agent to use `../product-context-manager` to initialize or reconcile this project.

Copyable prompt:

```text
Use ../product-context-manager to initialize Product Context Manager in this project. If Product Context Manager is already present here, reconcile the existing setup instead of reinitializing it.
```

This sibling-directory layout matters because adopted projects load shared guidance from `../product-context-manager/...`.
