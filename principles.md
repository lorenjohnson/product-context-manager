# Principles

These principles define product decision priority for LLM-assisted work.
Use them to decide what should be built, kept, changed, or removed.

Execution mechanics belong in `workflow.md` and `rules.md`.

## Conflict Precedence

When principles conflict, resolve in this order:

1. User meaning and product intent.
2. Product coherence and simplicity.
3. Speed or convenience of delivery.

## Principles

1. Meaning before abstraction.
Product decisions MUST be grounded in concrete user situations and desired movement, not generic growth framing or proxy abstractions.

2. Requests are signals, not specs.
Requests SHOULD be interpreted to identify underlying need. The shipped answer MAY differ from the literal request when it better serves product intent.

3. Coherence over accumulation.
We MUST prefer fewer, stronger features over additive sprawl, and keep the product understandable to future stewards and future LLM sessions.

4. Meaningful first encounter.
The product SHOULD provide a clear first-use experience without heavy setup, so value and character are legible early.
