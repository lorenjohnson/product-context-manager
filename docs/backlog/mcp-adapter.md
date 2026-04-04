---
doc-status: draft
---

# MCP Adapter

## 1) Project Statement

- What is being proposed?
Implement a practical MCP adapter that exposes the existing operational surface as tools/resources/prompts.
- Why now?
This enables standardized integration once file-contract behavior is stable.
- If this project modifies existing behavior: what is current behavior and what is the intended delta?
Current behavior uses direct file and shell contract execution. Intended delta adds an MCP transport without changing core contracts.

## 2) Product Fit And Value

- Which product principles does this project support?
Coherence over accumulation; preserve explicit state and boundaries.
- How does this align with current product definition?
It fits the goal of predictable, portable context-management operations.
- What user or product value is expected if this ships?
Standardized integration path with compatible clients and clearer deployment.
- How important is it relative to current queue priorities?
Medium-low until core contract settles further.
- What is the expected impact if this succeeds?
Cleaner adapter layer and less bespoke wiring across environments.

## 3) Scope And Non-Goals

- In scope for this project:
Expose current operation names/contracts without semantic drift.
- Explicit non-goals for this project:
Do not redesign workflow/rules content during adapter implementation.
- Estimated scope size (small/medium/large):
Large.
- Capacity budget (time and attention) for this project:
Medium-high.

## 4) First Slice Plan

- Smallest meaningful first slice:
Implement a thin wrapper for setup/reconciliation without changing the underlying docs contract.
- Known uncertainties requiring user clarification:
Preferred packaging/deployment model and authentication assumptions.
- Immediate acceptance check for the first slice:
One end-to-end MCP invocation produces output equivalent to direct shell execution.
