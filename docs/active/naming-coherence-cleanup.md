---
doc-status: draft
---

# Naming Coherence Cleanup

## 1) Project Statement

- What is being proposed?
Normalize in-file naming from legacy `product-practice` phrasing to Product Context Manager phrasing where intended.
- Why now?
Naming drift reduces clarity and introduces avoidable confusion.
- If this project modifies existing behavior: what is current behavior and what is the intended delta?
Current behavior is mixed naming across docs/template/tasks/evals/scripts. Intended delta is coherent naming with explicit exceptions for repo slug/path transitions.

## 2) Product Fit And Value

- Which product principles does this project support?
Coherence over accumulation; make future edits easier.
- How does this align with current product definition?
It improves legibility of the system contract.
- What user or product value is expected if this ships?
Less ambiguity during adoption, reconciliation, and maintenance.
- How important is it relative to current queue priorities?
Medium-high; mostly copy/contract hygiene.
- What is the expected impact if this succeeds?
Lower cognitive load and cleaner docs operations.

## 3) Scope And Non-Goals

- In scope for this project:
Update names in normative docs, template assets, task/eval docs, and user-facing script/help text.
- Explicit non-goals for this project:
Do not rename repository directory within this thread unless explicitly requested.
- Estimated scope size (small/medium/large):
Small.
- Capacity budget (time and attention) for this project:
Low.

## 4) First Slice Plan

- Smallest meaningful first slice:
Produce a deterministic list of string replacements and apply to canonical files first.
- Known uncertainties requiring user clarification:
Which legacy terms should remain for compatibility.
- Immediate acceptance check for the first slice:
Core docs no longer contain accidental legacy naming drift.
