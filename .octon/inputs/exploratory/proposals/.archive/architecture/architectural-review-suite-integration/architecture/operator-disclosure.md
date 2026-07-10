# Operator Disclosure

## What Changes For Operators After Promotion

- When you run an architectural review occasion, the run evidence now records
  **which method** the review used (Balanced by default) and the lens profile
  applied, via the existing v2 routing-decision/report artifact. Nothing about
  how you invoke a review changes.
- The product feature note and the governed mechanism entry now describe the
  method layer (method catalog, lens bank, v2 schemas) and give a
  **per-occasion method advisory**: Balanced is the default; companion methods
  are recommended on named escalation conditions (target does not exist yet →
  Greenfield; ≥2 viable designs → Tradeoff; failure behavior in doubt →
  Failure-Mode; long-lived fitness in doubt → Evolution/Fitness; authority
  placement in doubt → Boundary/Authority).

## What Does Not Change

- No new review command, workflow mode, lifecycle gate, or evidence root.
- The pre-integration support receipt is unchanged and remains the only
  lifecycle-gating review artifact; it never records a method.
- Method selection is **advisory** — it does not gate acceptance, promotion, or
  closeout. Choosing a non-default method never bypasses any existing gate.
- Readiness and surface-architecture audits behave exactly as before.

## Non-Authority Reminder

The recorded method id is **run evidence**, not authority: it does not
authorize a mutation, clear a gate, or widen a support claim. Generated
projections that show the method layer are derived-only and are never a source
of truth. Durable authority lives only in the promoted framework surfaces.

## Human Decisions Still Required

- Maintainer review and acceptance of this packet through the proposal
  lifecycle.
- Resolution of the lifecycle-advisory-placement open item (in-scope reference
  vs. a parent registry revision if a prompt-source edit proves necessary).
