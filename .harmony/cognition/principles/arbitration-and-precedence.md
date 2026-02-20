---
title: Arbitration and Precedence
description: Single normative conflict-resolution contract for RA/ACP governance.
pillar: Trust, Direction
status: Active
---

# Arbitration and Precedence

> Resolve principle conflicts with deterministic, policy-bound tie-break rules.

## Normative Rules (SSOT)

1. Capability-attempt authority is deny-by-default policy output only.
2. Durable promotion/contraction/finalize authority is ACP gate output only.
3. `apply` for durable state is interpreted as `promote` unless explicitly stage-only/read-only.
4. Owner attestation is quorum input only; it is never standalone promotion authority.
5. Waiver/exception behavior must use the canonical taxonomy in [Waivers and Exceptions](./_meta/waivers-and-exceptions.md); unmapped overrides fail closed.
6. Governance-trigger evidence/receipt enforcement is keyed off canonical predicate `material_side_effect` (aliases must normalize to this predicate).
7. If principles disagree and no explicit mapping exists, fail closed with reason-coded `STAGE_ONLY` or `DENY`.
8. Non-normative guidance cannot weaken fail-closed controls in policy.
9. Normative arbitration text must remain in this document only; other principles may include informational summaries and links.
10. Broken/missing canonical references in principles must fail governance lint before merge.

## Application Order

1. Determine whether the question is capability-attempt, durable promotion/contraction/finalize, or supporting governance semantics.
2. Apply the corresponding authority rule above.
3. If unresolved, apply fail-closed behavior and emit reason-coded receipts.

## Related Documentation

- [Autonomous Control Points](./autonomous-control-points.md)
- [Deny by Default](./deny-by-default.md)
- [Guardrails](./guardrails.md)
- [No Silent Apply](./no-silent-apply.md)
- [Waivers and Exceptions](./_meta/waivers-and-exceptions.md)
