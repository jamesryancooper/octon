# Decision Record Plan

Durable architectural decisions from implementation should be promoted to
`instance/cognition/decisions/**` only when they change repo-local durable
understanding or governance. Normal trigger/admission/renewal decisions belong in
`state/control/stewardship/**` with retained evidence.

Decision records to consider:

1. Adoption of Stewardship Program / Epoch hierarchy.
2. Decision to keep campaigns optional and deferred by default.
3. Decision that stewardship cannot execute material work directly.
4. Decision to treat idle as a successful governed state.
