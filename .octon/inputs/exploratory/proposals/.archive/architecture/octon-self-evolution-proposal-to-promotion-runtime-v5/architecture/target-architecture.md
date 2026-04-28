# Target Architecture

## Selected v5 implementation target

**Self-Evolution Proposal-to-Promotion Runtime v5**

The selected highest-leverage v5 step is the Self-Evolution Proposal-to-Promotion Runtime: an evidence-backed pipeline that turns retained evidence and friction into Evolution Candidates, compiles review-ready proposal packets, routes authority-changing changes through human/quorum Decision Requests or Constitutional Amendment Requests, promotes accepted outputs into durable authority surfaces, retains promotion receipts, and runs post-promotion recertification. This is narrower than full v5: it does not implement autonomous constitutional amendment, broad lab automation, or general self-modifying runtime.

## Why this is the highest-leverage v5 step

The live repository already has a mature non-canonical proposal-packet standard and a proposal-gated evidence-distillation contract, but it does not yet expose a complete runtime/control pipeline that governs the path from retained evidence to candidate improvement, proposal compilation, acceptance, promotion, recertification, and rollback. That gap is the practical safety boundary for self-evolution. Without it, Octon can write proposals and retain evidence, but cannot safely operationalize self-improvement without relying on ad hoc human interpretation.

## Target state

The target state is a governed self-evolution pipeline:

1. retained evidence or friction creates an **Evolution Candidate**;
2. the candidate receives source refs, risk class, authority-impact class, and disposition;
3. authority-impacting candidates require governance impact simulation and lab-gate proof appropriate to risk;
4. viable candidates compile into manifest-governed proposal packets;
5. authority-changing changes create Decision Requests or Constitutional Amendment Requests;
6. accepted proposals are promoted only to declared durable targets;
7. promotion emits retained receipts;
8. generated projections are regenerated only as derived outputs;
9. post-promotion recertification validates root placement, runtime authorization coverage, support posture, evidence completeness, generated/effective freshness, and documentation/runtime consistency;
10. the Evolution Ledger indexes candidate/proposal/promotion/recertification lineage without replacing canonical manifests, ADRs, evidence, or receipts.

## Scope limits

This packet does **not** implement the full v5 target. It defers autonomous constitutional amendment, broad AI-only governance, fully automated support-target widening, full lab orchestration, general self-modifying runtime, and broad v1-v4 backfills.

Non-negotiable boundaries:

- Evidence may suggest change; it does not authorize change.
- Models may propose change; they do not approve change.
- Labs may validate change; lab success is not approval.
- Simulations may score change; simulation success is not approval.
- Proposal packets are temporary non-canonical implementation and decision aids.
- Durable authority lands only in `framework/**` or `instance/**`.
- Mutable live control truth lands in `state/control/**`.
- Retained proof lands in `state/evidence/**`.
- Generated/read-model outputs remain derived only.
- Chat, hidden model memory, generated summaries, host labels/comments/checks, dashboards, and raw `inputs/**` never become authority.
- Constitutional, governance, support-target, runtime authorization, capability, connector, evidence, generated/effective, and release authority changes require human/quorum approval through canonical control surfaces.


## Canonical artifact placement

Proposed durable target families:

`framework/**`
- `framework/engine/runtime/spec/evolution-program-v1.schema.json`
- `framework/engine/runtime/spec/evolution-candidate-v1.schema.json`
- `framework/engine/runtime/spec/evolution-proposal-compiler-v1.md`
- `framework/engine/runtime/spec/governance-impact-simulation-v1.schema.json`
- `framework/engine/runtime/spec/constitutional-amendment-request-v1.schema.json`
- `framework/engine/runtime/spec/promotion-runtime-v1.md`
- `framework/engine/runtime/spec/recertification-runtime-v1.md`
- `framework/engine/runtime/spec/evolution-ledger-v1.schema.json`
- `framework/orchestration/practices/evolution-lifecycle-standards.md`

`instance/**`
- `instance/governance/evolution/programs/<program-id>/program.yml`
- `instance/governance/evolution/policies/evolution-policy.yml`
- `instance/governance/evolution/policies/promotion-policy.yml`
- `instance/governance/evolution/policies/recertification-policy.yml`
- `instance/governance/evolution/policies/constitutional-amendment-policy.yml`
- ADRs or durable decisions under `instance/cognition/decisions/**` where promotion changes durable architecture.

`state/control/**`
- `state/control/evolution/candidates/<candidate-id>.yml`
- `state/control/evolution/simulations/<simulation-id>.yml`
- `state/control/evolution/lab-gates/<gate-id>.yml`
- `state/control/evolution/amendment-requests/<request-id>.yml`
- `state/control/evolution/promotions/<promotion-id>.yml`
- `state/control/evolution/recertifications/<recertification-id>.yml`
- `state/control/evolution/ledger.yml`

`state/evidence/**`
- `state/evidence/evolution/candidates/<candidate-id>/**`
- `state/evidence/evolution/simulations/<simulation-id>/**`
- `state/evidence/evolution/lab-gates/<gate-id>/**`
- `state/evidence/evolution/proposals/<proposal-id>/**`
- `state/evidence/evolution/promotions/<promotion-id>/**`
- `state/evidence/evolution/recertifications/<recertification-id>/**`
- `state/evidence/evolution/rollbacks/<rollback-id>/**`

`state/continuity/**`
- `state/continuity/evolution/programs/<program-id>/summary.yml`
- `state/continuity/evolution/open-candidates.yml`
- `state/continuity/evolution/open-risks.yml`
- `state/continuity/evolution/next-reviews.yml`

`generated/**`
- derived evolution dashboards and projections only, never authority.

`inputs/**`
- proposal packets and exploratory lineage only; no runtime or policy dependency.
