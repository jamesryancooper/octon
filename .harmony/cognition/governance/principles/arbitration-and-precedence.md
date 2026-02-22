---
title: Arbitration and Precedence
description: Single normative conflict-resolution contract for RA/ACP governance.
pillar: Trust, Direction
status: Active
---

# Arbitration and Precedence

> Resolve principle conflicts with deterministic, policy-bound tie-break rules.

## Normative Rules (SSOT)

1. Determine decision class first: capability-attempt, durable promotion/finalize, or supporting governance semantics.
2. Capability-attempt authority is deny-by-default policy output only.
3. Durable promotion/finalize authority is ACP gate output only.
4. `apply` for durable state is interpreted as `promote` unless explicitly stage-only/read-only.
5. Owner attestation is quorum input only; it is never standalone promotion authority.
6. Term collisions are resolved by [RA/ACP Glossary](../controls/ra-acp-glossary.md) definitions.
7. Evidence-minima collisions are resolved by [RA/ACP Promotion Inputs Matrix](../controls/ra-acp-promotion-inputs-matrix.md).
8. Non-normative guidance/examples cannot weaken fail-closed controls in policy.
9. If principles disagree and no explicit mapping exists, fail closed with reason-coded `STAGE_ONLY` or `DENY`.
10. Human intervention is exception-driven only (quorum unresolved, risk threshold crossed, or policy-triggered escalation).

## Application Order

1. Classify the decision.
2. Apply the single authority source for that class.
3. If unresolved, fail closed and emit a reason-coded receipt.

## Related Documentation

- [Autonomous Control Points](./autonomous-control-points.md)
- [Deny by Default](./deny-by-default.md)
- [Guardrails](./guardrails.md)
- [No Silent Apply](./no-silent-apply.md)
- [Waivers and Exceptions](../exceptions/waivers-and-exceptions.md)
