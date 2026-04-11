# Implementation plan

## Motion summary

All actionable concepts in this packet are **adapt** motions. No concept requires a greenfield subsystem. The correct path is to extend existing assurance, objective, evidence, governance, and agency runtime surfaces.

## Ranked implementation sequence

### Phase 0 — no-change confirmations
1. Confirm that progressive-disclosure context, reversible mission/run control, and evidence/disclosure bundles remain the canonical anchors for their respective concepts.
2. Record these as already covered so the implementation effort does not duplicate them.

### Phase 1 — low-friction governance refinements
1. Add `review-finding-v1` and `review-disposition-v1` contracts.
2. Add instance review disposition policy.
3. Add run-local control/evidence companion files for active dispositions and retained findings.

**Why first:** This is relatively small, immediately improves control semantics, and reduces ambiguity in progression gating.

### Phase 2 — proposal-first mission classification
1. Extend `mission-autonomy.yml`.
2. Extend `run-contract-v1.schema.json` with classification/proposal requirement fields.
3. Add mission-local `mission-classification.yml`.
4. Add fail-closed validation that proposal-required classes cannot execute without proposal refs.

**Why second:** It narrows the autonomy envelope for the hardest work before more automation is layered on.

### Phase 3 — failure-driven hardening
1. Add failure-classification and hardening-recommendation schemas.
2. Add failure-distillation workflow contract.
3. Add retained failure-distillation bundles under `state/evidence/validation/`.
4. Connect acceptance of hardening outputs to ordinary authority-promotion paths.

**Why third:** Once review and mission-classification semantics are explicit, the repo can safely convert recurring failures into durable hardenings.

### Phase 4 — thin adapter output envelopes
1. Add tool-output envelope contract.
2. Add repo-specific output budget profile.
3. Add validation receipts showing raw payload offloading and compact live envelopes.

**Why fourth:** This is operationally valuable, but it is safer once the preceding governance and evidence refinements exist.

### Phase 5 — evidence distillation
1. Add distillation-bundle contract.
2. Add evidence-distillation workflow contract.
3. Retain distillation bundles and optional generated summaries.
4. Promote only approved outputs into instance authority surfaces.

**Why fifth:** This is the most shadow-memory-sensitive refinement and should come after the repo has explicit review, mission, and hardening semantics.

## Implementation approach justification

### Why extension/refinement is correct
The live repo already exposes:
- a constitutional kernel,
- a strong state split,
- mission/run objective contracts,
- evidence/disclosure bundles,
- enabled overlay points for repo-specific governance and runtime refinement.

Adding parallel subsystems would preserve duplication and weaken legibility.

### Why narrower alternatives were rejected
For the actionable concepts, the following were rejected:
- documentation-only treatment,
- proposal-only treatment,
- advisory-only policies without state/evidence materialization,
- generated-summary stand-ins for retained evidence.

Each of these would imply coverage without delivering a usable capability.

### Why broader alternatives were rejected
The following were rejected as unnecessarily broad:
- a new top-level review subsystem,
- a new memory subsystem,
- a new hardening platform outside evidence/proposals,
- a new mission-control taxonomy separate from `mission-autonomy.yml`.

## Delivery posture

Because this packet is externalized rather than merged directly into the live repo, the implementation plan is promotion-ready but not self-executing. Promotion should proceed only after human approval of:
- the file-change map,
- the closure criteria,
- and the packet-level conformance card.
## Backlog grouping

### Immediate refinement backlog
1. Structured review findings + disposition
2. Proposal-first mission classification
3. Failure-driven harness hardening
4. Thin adapters + token-efficient outputs

### Proposal-first but second-wave
1. Distillation pipeline from traces/comments/failures into proposal packets and shared skills

### Deferred
1. Selective dependency internalization

### Rejected
1. Unbounded domain access / approval bypass

## Why this order

- Review disposition and mission classification are governance levers with immediate leverage and comparatively contained change surface.
- Failure-driven hardening depends on clear review and mission semantics so that promoted guardrails land cleanly.
- Output-envelope refinement is highly useful but less foundational than the preceding governance moves.
- Distillation is the most shadow-memory-sensitive concept and therefore belongs after the repo has explicit review and hardening semantics.
