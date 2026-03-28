---
doc-status: draft
---

# Small-Fix Fast Path

## 1) Project Statement

- What is being proposed?
Define a minimal workflow path for small bug fixes so the system can track work without requiring full project-doc overhead when unnecessary.
- Why now?
This is a recurring operator expectation and currently underdefined.
- If this project modifies existing behavior: what is current behavior and what is the intended delta?
Current behavior routes most work through New Project with full spec sections. Intended delta is an explicit lightweight path with clear boundaries.

## 2) Product Fit And Value

- Which product principles does this project support?
Stewardship before expansion; coherence over accumulation; practical usefulness.
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
Define trigger criteria, minimum tracking artifact, and branch/doc behavior for small fixes.
- Explicit non-goals for this project:
Do not redesign the full workflow or eval system.
- Estimated scope size (small/medium/large):
Small.
- Capacity budget (time and attention) for this project:
Low-to-medium.

## 4) First Slice Plan

- Smallest meaningful first slice:
Add explicit small-fix event/rules plus one example flow in docs.
- Known uncertainties requiring user clarification:
How small-fix artifacts should be represented in `queue.md` and archive.
- Immediate acceptance check for the first slice:
A session can request a tiny bug fix and follow a documented path without full project scaffolding.
