# Implementation Principles

These are cross-project implementation defaults.

## 1. Keep systems small and legible

- Prefer the simplest implementation that preserves clarity.
- Less code is usually better, unless reduction makes behavior obscure.
- Remove stale or duplicate code aggressively.

## 2. Optimize for stewardship, not novelty

- Favor patterns you can maintain over clever one-off abstractions.
- Treat every feature as an ongoing ownership commitment.
- If a feature no longer serves the product, simplify or remove it.

## 3. Preserve explicitness

- Prefer explicit state and predictable flows over hidden magic.
- Make key architectural boundaries obvious in code and docs.
- Use comments sparingly and only where intent is not self-evident.

## 4. Protect feedback loops

- Keep iteration cycles short and reversible.
- Design code so behavior can be observed quickly.
- Add instrumentation or diagnostics where uncertainty is high.

## 5. Reliability and performance are product quality

- Regressions in responsiveness, stability, or data safety are product bugs.
- Measure before optimizing, but treat critical path performance as first-class.

## 6. Human collaboration is a design target

- Write code that supports future edits by you and others.
- Keep naming and file structure straightforward.
- Prefer decisions that lower cognitive load for ongoing work.
