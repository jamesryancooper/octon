---
title: Autonomous Control Points
description: Policy-governed reversible autonomy. Agents execute by default; control points are enforced by reversibility, evidence, budgets, and multi-agent quorum—not manual approvals.
pillar: Trust, Direction
status: Active
---

# Autonomous Control Points

> Agents run autonomously by default. Control points are **machine-enforced** gates that preserve trust through **reversibility and proof**, not per-step human authorization.

## What This Means

Autonomous Control Points (ACPs) are Octon’s primary mechanism for governing consequential side effects.

Under reversible autonomy:

- Agents may execute long runs without requiring humans to guide or authorize.
- Material changes are governed by **policy gates**: reversibility requirements,
  evidence requirements, budgets, kill-switches, and (for high-risk ops) a
  **multi-agent quorum**.
- Humans review by exception and post-run receipts; runs do not halt waiting for
  default runtime approvals.

The standard loop becomes:

**Intent → Boundaries → Plan/Diff/Test → Stage → ACP Gate (policy+quorum) → Promote → Attest → Report**

## SSOT: Governance Gates

ACPs are Octon's single normative specification for **promotion** and **finalize** gating into durable state.

This includes the canonical semantics for:

- stage/promote/finalize decision outcomes (`contraction` is a glossary alias of `finalize`)
- evidence, quorum, and rollback requirements
- budget and circuit-breaker enforcement
- receipt requirements and disclosure completeness levels

Boundary split:

- For authority boundaries, see [Arbitration and Precedence](./arbitration-and-precedence.md) (SSOT): ACP governs promote/finalize authority and Deny by Default governs capability-attempt authority.

`No Silent Apply` is satisfied by ACP receipts, evidence references, and rollback
handles. This does not require standing human authorizations.

## Canonical References

- Promotion and finalize semantics (including `contraction` alias): this document.
- Capability attempt authorization: [Deny by Default](./deny-by-default.md).
- Replay and provenance semantics: [Determinism and Provenance](./determinism-and-provenance.md).
- Promotion input minimums and receipt requirements: RA/ACP Promotion Inputs Matrix (canonical).
- Shared terminology: [RA/ACP Glossary](../controls/ra-acp-glossary.md).
- Waiver/exception taxonomy: [Waivers and Exceptions](../exceptions/waivers-and-exceptions.md).
- Conflict precedence: [Arbitration and Precedence](./arbitration-and-precedence.md).

## Why It Matters

### Trust: Autonomous, Reversible, Provable

ACPs preserve trust without relying on constant supervision:

- **Reversible-by-default:** changes ship with a rollback handle.
- **Provable:** evidence bundles show what was changed and why it is safe.
- **Bounded:** budgets and scopes limit blast radius.
- **Auditable:** every promotion emits a receipt.

### Direction: Human Oversight without Friction

Humans keep strategic control with low operational friction:

- Agents proceed autonomously inside defined boundaries.
- Humans are approached only when:
  - the agent quorum cannot resolve a disagreement,
  - a risk threshold is crossed, or
  - after completion (digest/receipt) for optional review.

## ACP Levels

Each action class maps to an ACP level. Higher levels require stronger interlocks.

| ACP | Name | Typical Scope | Required Interlocks |
|---|---|---|---|
| ACP-0 | Observe | Read-only, analysis | Deny-by-default capability allowlists |
| ACP-1 | Reversible Local | Workspace edits, refactors, tests, branch commits | Reversible primitives + evidence (diff/tests) + budgets + receipt |
| ACP-2 | Stateful Reversible | Migrations, feature flags, small infra diffs, deploy canaries | ACP-1 + rollback proof + canary/rollout rules + **2-agent quorum** |
| ACP-3 | Destructive-Adjacent | Soft deletes, deprovision-with-retention, high blast-radius changes | ACP-2 + recovery window + **3-agent quorum** + stricter budgets + circuit breakers |
| ACP-4 | Irreversible | Hard deletes/destroys, no recovery path | **Blocked by default** (break-glass only) |

**Important:** ACP-3 is the highest level intended for routine autonomous operation.
ACP-4 exists to make irreversibility explicit and difficult.

## Risk Tier Mapping Authority

Risk tier to ACP mapping is policy-canonical and must not be re-declared here:
`.octon/capabilities/governance/policy/deny-by-default.v2.yml#acp.risk_tier_mapping`

Operational references:
- RA/ACP Promotion Inputs Matrix (`risk-tier-mapping-canonical` section)
- [Observability as a Contract](./observability-as-a-contract.md)

## The ACP Gate

An ACP gate is a policy evaluation that answers:

> “May this staged change be promoted to durable state *now*, given the actor profile,
> risk tier, evidence, budgets, kill-switches, and quorum attestations?”

Outcomes:

- **ALLOW (promote):** promote change and emit receipt
- **STAGE_ONLY:** keep change staged; emit receipt; notify humans if configured
- **DENY:** block action; emit denial with reason codes
- **ESCALATE:** request human intervention (rare; only when policy requires)

Evidence and receipt enforcement triggers are keyed on canonical predicate
`material_side_effect` (see [RA/ACP Glossary](../controls/ra-acp-glossary.md)).

Docs-gate evidence is consumed by ACP runtime evaluation on promote. Missing
required documentation evidence returns fail-closed `STAGE_ONLY`/`DENY` with
reason code `ACP_DOCS_EVIDENCE_MISSING`, as mapped by policy per ACP level.

## Reversible-by-Default Execution

ACPs assume a two-phase model:

1. **Stage**  
   - Create a branch, overlay, preview environment, or tombstone layer.
   - Apply changes in a way that is safe to inspect and easy to discard.

2. **Promote**  
   - Only after passing ACP gates do changes become durable.
   - Promotion is atomic where possible (merge commit, deploy swap, migration promote).

3. **Rollback (always available)**  
   - Every promotion produces a rollback handle.
   - Rollback is tested at ACP-2+ and mandatory at ACP-3.

## Soft Destruction and Recovery Windows

Destructive intent must compile to reversible primitives:

- delete → tombstone + retain + restore command
- destroy → detach + archive + retain + restore path
- drop → shadow/rename + retain + finalize later

Every destructive-adjacent action must declare a **recovery window** (retention TTL)
during which restoration is guaranteed.

Finalization (hard delete) is a separate operation and is **ACP-4** by default.

## Multi-Agent Quorum for High-Risk Operations

For ACP-2 and ACP-3, promotion requires independent attestations:

- **Proposer:** creates plan + staged change + evidence bundle
- **Verifier:** independently validates plan, invariants, and evidence
- **Recovery Agent:** validates rollback works (in staging) and signs recovery plan
- **Observer (optional):** monitors execution and enforces circuit breakers

Quorum is policy-defined (e.g., 2-of-3 for ACP-2, 3-of-3 for ACP-3).

If quorum cannot be reached, the system falls back to **stage-only** and notifies humans.

## Ownership Attestation

For boundary exceptions or owner-scoped systems, policy may require an owner
attestation as a quorum input.

Owner signal precedence is defined in
[Ownership and Boundaries](./ownership-and-boundaries.md) and enforced by
policy.

Deterministic fallback behavior:
- owner attestation is never standalone promotion authority
- if required owner attestation is missing, ACP returns bounded `STAGE_ONLY`
  with reason code `ACP_OWNER_ATTESTATION_MISSING`
- ACP evaluator applies bounded retry and timeout windows from policy
- if retry/timeout is exhausted, policy may return `ESCALATE` with
  `ACP_OWNER_ATTESTATION_TIMEOUT`
- runs do not wait indefinitely for human authorization

See [Ownership and Boundaries](./ownership-and-boundaries.md) for boundary-owner
semantics.

## Budgets and Circuit Breakers

To prevent runaway autonomy, ACPs enforce:

- **Blast-radius budgets:** max files, max LOC, max rows, max API calls, max cost/time
- **Invariant checks:** tests, linters, static analysis, domain invariants
- **Circuit breakers:** if runtime signals degrade, auto-rollback and trip kill-switches

Budgets are attached to the run and enforced continuously, not just at promotion time.

## Telemetry Profile Mapping

ACP promotion telemetry profile requirements are canonical in
[RA/ACP Promotion Inputs Matrix](../controls/ra-acp-promotion-inputs-matrix.md#telemetry-profile-gate-canonical)
and enforced by policy (`acp.telemetry_gate`) at promote-time.

Profile deviations must use the canonical waiver taxonomy:
[Waivers and Exceptions](../exceptions/waivers-and-exceptions.md).

## Receipts and Continuous Oversight

Every ACP gate emits an append-only **Change Receipt**:

- intent and boundaries
- diff / staged artifacts
- evidence bundle references
- ACP level and policy decision
- quorum attestations
- rollback handle and recovery window

Humans “pop in” by reviewing receipts and digests, not by approving every step.

## ✅ Do

- Stage changes first; promote only after ACP gates pass.
- Prefer reversible primitives for all writes and deletions.
- Attach evidence and a rollback handle to every promoted change.
- Use quorum for high-risk or destructive-adjacent actions.
- Keep operations inside budgets; raise budgets only via time-boxed exceptions.

## ❌ Don’t

- Hard delete as part of a normal run.
- Bypass evidence requirements because “it looks safe”.
- Rely on humans as your primary safety mechanism.
- Ship changes without a receipt and rollback plan.
- Expand scope silently (more access, broader writes) without policy evaluation.

## Arbitration

See [Arbitration and Precedence](./arbitration-and-precedence.md) (SSOT) for conflict resolution.

## Historical Note (Non-Normative)

Earlier Octon drafts described human-gated runtime approvals. RA/ACP supersedes that model with machine-enforced policy gates and optional post-run review.

## Related Principles

- [Guardrails](./guardrails.md)
- [No Silent Apply](./no-silent-apply.md)
- [Reversibility](./reversibility.md)
- [Deny by Default](./deny-by-default.md)
- [Documentation is Code](./documentation-is-code.md)

## Related Documentation

- [Deny by Default](./deny-by-default.md)
- [Observability as a Contract](./observability-as-a-contract.md)
- [Ownership and Boundaries](./ownership-and-boundaries.md)
- [Arbitration and Precedence](./arbitration-and-precedence.md)
- [Trust Pillar](../pillars/trust.md)
- [Direction Pillar](../pillars/direction.md)
