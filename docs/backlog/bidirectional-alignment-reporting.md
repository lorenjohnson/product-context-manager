---
doc-status: draft
---

# Bidirectional Alignment Reporting

## 1) Project Statement

- What is being proposed?
Refine alignment output so it clearly reports both directions: product-to-features and features-to-product.
- Why now?
Current alignment reports are useful but can still be ambiguous.
- If this project modifies existing behavior: what is current behavior and what is the intended delta?
Current behavior gives mixed alignment/conflict sections. Intended delta is explicit directional framing and clearer decision value.

## 2) Product Fit And Value

- Which product principles does this project support?
Coherence over accumulation; practical usefulness over process theater.
- How does this align with current product definition?
It strengthens one of the core evaluation loops in the system.
- What user or product value is expected if this ships?
Faster interpretation and clearer next actions after running alignment.
- How important is it relative to current queue priorities?
Medium.
- What is the expected impact if this succeeds?
Higher trust in alignment reports and easier queue shaping decisions.

## 3) Scope And Non-Goals

- In scope for this project:
Output structure, section naming, and directional conflict/fit criteria.
- Explicit non-goals for this project:
Do not introduce heavy per-feature metadata requirements.
- Estimated scope size (small/medium/large):
Medium.
- Capacity budget (time and attention) for this project:
Medium.

## 4) First Slice Plan

- Smallest meaningful first slice:
Adjust report format and language only, then validate against one real project run.
- Known uncertainties requiring user clarification:
Preferred report verbosity and persistence defaults.
- Immediate acceptance check for the first slice:
A single run yields an unambiguous directional summary and prioritized mismatches.
