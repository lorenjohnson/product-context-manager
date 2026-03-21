# Product Practice

Shared product and design philosophy, principles, and development method used across projects.

## Purpose

This repository is the canonical home for cross-project product practice.

Use it to:
- define and refine enduring product/design principles
- maintain a practical product development method
- capture implementation heuristics that should be shared across projects

It is intentionally compact. The aim is not to create a heavy PM system, but a maintainable set of documents that can guide product definition, design judgment, and LLM-assisted iteration.

## Canonical Docs

- `docs/README.md`
- `docs/01-product-philosophy.md`
- `docs/02-product-development-method.md`
- `docs/03-chat-synthesis.md`
- `docs/04-implementation-principles.md`
- `templates/project-adoption-checklist.md`
- `templates/docs-readme-template.md`

## Reading Order

1. `docs/01-product-philosophy.md`
2. `docs/02-product-development-method.md`
3. `docs/03-chat-synthesis.md`
4. `docs/04-implementation-principles.md`

## Cross-Project Workflow

- If guidance applies to multiple projects, keep it here.
- If guidance is project-specific, keep it in that project repo and link back to this repo.
- Use `templates/project-adoption-checklist.md` inside each product repo during alignment passes.
- Prefer small, iterative edits and keep assumptions explicit.

## Current Project

This repository is now the root context for consolidating product-practice material from multiple software projects into one canonical system.

Primary objective:
- synthesize and condense overlapping product philosophy, principles, and method docs from project repos into this repository
- leave project repos with only project-specific deltas plus references back here

## Source Repositories

Priority first:
- `/Users/lorenjohnson/dev/Hypnograph`

Additional repositories with `docs/` directories to review:
- `/Users/lorenjohnson/dev/Divine`
- `/Users/lorenjohnson/dev/HypnoPackages`

## Consolidation Plan

1. Audit each source repo for product-practice-like documents.
2. Extract reusable principles and method language into `docs/` in this repo.
3. Deduplicate and tighten wording so this repo becomes canonical.
4. In each source repo, remove redundant shared-practice text.
5. Replace removed sections with short references to this repo.
6. Keep only project-specific product decisions in source repos.

## Definition Of Done

- `product-practice` contains the stable, canonical shared product-practice system.
- source repos keep only local deltas and implementation-specific context.
- each source repo has explicit references to canonical docs in this repo.

## Next Thread Handoff

Use this repository as the active working directory for continuation.

Suggested starting sequence:
1. run a full docs audit for `/Users/lorenjohnson/dev/Hypnograph`
2. identify overlap against `docs/01` through `docs/04` in this repo
3. propose minimal delete/keep/reference edits for Hypnograph

## New Project Setup Rule

For every new or existing project that adopts this system:

1. ensure a root `docs/` directory exists
2. copy `templates/docs-readme-template.md` from this repo to `<project>/docs/README.md`
3. customize only the project name and any intentionally project-specific folders

This keeps docs routing predictable for both humans and LLM-assisted sessions.
