# Product Context Manager

## Overview

This product is a shared interface between human makers and LLM coding agents that maintains and persists the evolving context and intentions of a product across sessions. It exists to counter context rot and loss of direction caused by limited context windows and generative drift. It turns product direction into an operable contract, so sessions can start from clear grounding, apply consistent rules, and keep documentation synchronized with real work. Software here is treated as a designed relation between authors, users, and real-world conditions, so intent is continuously tested in use and steered toward more humane possibilities.

Its deeper purpose is to increase the odds that LLM-assisted development produces coherent, valuable outcomes aligned with the makers' principles rather than momentum or noise. It does this with appetite, constraints, and selective refusal, not as rigid enforcement, but as support for the human stewards responsible for guiding the product. The system is meant to protect continuity of intention, reduce accidental sprawl, and hold a middle line between abstract market logic and unstructured instinct so work remains practical to steward and meaningfully beneficial to human life and relationship.

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
- Evals are secondary and focused on decision loops.
- Template reconciliation is a maintenance task, not an eval.

## What Lives Here

- `principles.md`: concise principles loaded by LLM sessions.
- `rules.md`: canonical documentation and implementation rules.
- `tasks/README.md`: shared tools index and task usage entrypoint.
- `workflow.md`: canonical product workflow and operational API surface.
- `personality.md`: canonical collaboration style and partner stance.
- `project-template.md`: required section template for new project docs.
- `docs/`: this repository's own product docs (self-applied pattern).
- `template/`: canonical files copied into adopting projects.
- `tasks/`: reusable maintenance tasks (including template reconciliation).
- `evals/`: evaluation workflows (subject to iteration).

## Adoption Intent

Projects that adopt this system copy the template payload, keep shared practice centralized here, and keep project docs focused on local product definition and active work.

## Adopt In A Project

1. Clone this repository as a sibling of the project you want to initialize.

```bash
cd /path/to/parent-directory
git clone https://github.com/lorenjohnson/product-context-manager.git
cd product-context-manager
```

2. Run setup against the target project root from this repository.

```bash
bash tasks/scripts/run-setup.sh ../your-project
```

3. Open the target project's `AGENTS.md` and `docs/` files, then start work from the project root with Product Context Manager in place.

This sibling-directory layout matters because adopted projects load shared guidance from `../product-context-manager/...`.
