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
2. Autonomous-by-default is execution posture only; it does not grant capability-attempt or promotion authority.
3. Capability-attempt authority is deny-by-default policy output only.
4. Durable promotion/finalize authority is ACP gate output only.
5. `apply` for durable state is interpreted as `promote` unless explicitly stage-only/read-only.
6. Owner attestation is quorum input only; it is never standalone promotion authority.
7. Term collisions are resolved by [RA/ACP Glossary](../controls/ra-acp-glossary.md) definitions.
8. Evidence-minima collisions are resolved by [RA/ACP Promotion Inputs Matrix](../controls/ra-acp-promotion-inputs-matrix.md).
9. Non-normative guidance/examples cannot weaken fail-closed controls in policy.
10. If principles disagree and no explicit mapping exists, fail closed with reason-coded `STAGE_ONLY` or `DENY`.
11. Human intervention is exception-driven only (quorum unresolved, risk threshold crossed, or policy-triggered escalation).

## Application Order

1. Classify the decision.
2. Apply the single authority source for that class.
3. If unresolved, fail closed and emit a reason-coded receipt.

## Governed Autonomy Lifecycle Arbitration

- Safe Start artifacts prepare Engagement, Project Profile, Work Package,
  Decision Request, Evidence Profile, Preflight Evidence Lane, Tool/MCP
  Connector Posture, and Run Contract Candidate surfaces; they do not authorize
  material execution.
- Safe Continuation and Continuous Stewardship may stage mission or stewardship
  decisions, but the run contract remains the atomic execution authority.
- Connector Admission Runtime can narrow connector and capability posture; it
  cannot widen support claims or convert tool availability into permission.
- Constitutional Self-Evolution may distill evidence into candidates,
  simulations, lab gates, proposals, amendments, promotions, recertifications,
  and ledger entries, but it cannot self-authorize durable governance change.
- Federated Trust may verify Portable Proof Bundles, Attestation Envelopes, and
  Local Acceptance Records as evidence. Imported proof and external
  attestations never override local authority or execution authorization.

## Related Documentation

- [Autonomous Control Points](./autonomous-control-points.md)
- [Deny by Default](./deny-by-default.md)
- [Guardrails](./guardrails.md)
- [No Silent Apply](./no-silent-apply.md)
- [Waivers and Exceptions](../exceptions/waivers-and-exceptions.md)
