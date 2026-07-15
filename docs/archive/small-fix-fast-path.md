---
doc-status: done
---

# Small-Fix Fast Path

## 1) Project Statement

- What is being proposed?
Define a minimal routing exception for small bug fixes so they can proceed without project-doc overhead when unnecessary.
- Why now?
This is a recurring operator expectation and currently underdefined.
- If this project modifies existing behavior: what is current behavior and what is the intended delta?
Current behavior routes most work through New Project with full spec sections. Intended delta is a single bounded exception for direct handling, not a separate workflow or tracking artifact.

## 2) Product Fit And Value

- Which product principles does this project support?
Coherence over accumulation; meaningful first encounter; practical usefulness.
- How does this align with current product definition?
It supports proportional friction and fast corrective loops.
- What user or product value is expected if this ships?
Less process drag for low-risk fixes while preserving continuity and traceability.
- How important is it relative to current queue priorities?
High; this is a core usability gap in day-to-day operation.
- What is the expected impact if this succeeds?
Higher adoption confidence and fewer skipped documentation updates.

## 3) Scope And Non-Goals

- In scope for this project:
Define narrow trigger criteria and escalation behavior for directly handled small fixes.
- Explicit non-goals for this project:
Do not redesign the full workflow or eval system.
- Estimated scope size (small/medium/large):
Small.
- Capacity budget (time and attention) for this project:
Low-to-medium.

## 4) First Slice Plan

- Smallest meaningful first slice:
Add one routing exception to `workflow.md` and clarify that expanding work returns to New Project.
- Known uncertainties requiring user clarification:
None. Directly handled fixes do not require a PCM tracking artifact.
- Immediate acceptance check for the first slice:
A session can handle a localized, low-risk fix directly while routing broader work through New Project.

## 5) Outcome

- Added a single direct-handling exception rather than a new workflow event.
- Limited the exception to clear, localized, low-risk fixes without product, scope, architecture, migration, or data-safety decisions.
- Added no queue, project-doc, or `current.md` requirement for directly handled fixes.

## 6) Closure

Archived after implementation and verification.
