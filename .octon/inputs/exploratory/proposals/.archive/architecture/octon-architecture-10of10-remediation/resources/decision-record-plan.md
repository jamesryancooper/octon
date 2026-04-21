# Decision Record Plan

proposal_id: `octon-architecture-10of10-remediation`  
resource_role: durable decision-record planning  
status: non-authoritative proposal resource under `inputs/**`

---

## 1. Decision-record thesis

This proposal is non-canonical while it remains under `inputs/**`. Durable architecture decisions must land outside the proposal workspace after review and promotion. The preferred target for durable decision records is:

```text
/.octon/instance/cognition/decisions/
```

Where a decision is framework-general and should apply across Octon instances, it should also update the relevant framework authority surface under `/.octon/framework/**`, with a decision record that explains why.

---

## 2. Required decision records

| Decision record ID | Target path | Decision |
|---|---|---|
| ADR-ARCH-001 | `/.octon/instance/cognition/decisions/architecture/ADR-ARCH-001-preserve-class-root-authority.md` | Preserve five-class super-root model and authored authority limitation. |
| ADR-ARCH-002 | `/.octon/instance/cognition/decisions/architecture/ADR-ARCH-002-contract-registry-as-topology-ssot.md` | Extend existing `contract-registry.yml` as the single machine-readable topology/authority registry; reject rival registry. |
| ADR-RUNTIME-001 | `/.octon/instance/cognition/decisions/runtime/ADR-RUNTIME-001-total-authorization-boundary-coverage.md` | Require every material side-effect path to prove authorization-boundary coverage. |
| ADR-RUNTIME-002 | `/.octon/instance/cognition/decisions/runtime/ADR-RUNTIME-002-authority-engine-decomposition.md` | Decompose authority engine into auditable modules. |
| ADR-EVIDENCE-001 | `/.octon/instance/cognition/decisions/evidence/ADR-EVIDENCE-001-retained-evidence-store-contract.md` | Adopt retained evidence store contract and distinguish CI transport artifacts from canonical retained evidence. |
| ADR-GOV-001 | `/.octon/instance/cognition/decisions/governance/ADR-GOV-001-promotion-receipts-required.md` | Require promotion/activation receipts for any generated/input-to-authority movement. |
| ADR-RUN-001 | `/.octon/instance/cognition/decisions/runtime/ADR-RUN-001-run-lifecycle-state-machine.md` | Adopt formal run lifecycle state machine and transition evidence requirements. |
| ADR-SUPPORT-001 | `/.octon/instance/cognition/decisions/governance/ADR-SUPPORT-001-proof-backed-support-targets.md` | Require conformance and proof bundles before admitted support claims. |
| ADR-UX-001 | `/.octon/instance/cognition/decisions/operator/ADR-UX-001-generated-operator-read-models.md` | Introduce operator-grade read models as generated, non-authoritative projections. |
| ADR-DOCS-001 | `/.octon/instance/cognition/decisions/architecture/ADR-DOCS-001-relocate-historical-cutover-language.md` | Move historical cutover/wave/proposal-lineage material out of active architecture surfaces. |

---

## 3. Decision record template

Each decision record should include:

```markdown
# ADR-ID: Title

status: proposed | accepted | superseded | retired
date:
scope:
decision_owner:
related_proposal: octon-architecture-10of10-remediation

## Context
## Decision
## Alternatives considered
## Consequences
## Promotion targets
## Validation requirements
## Evidence requirements
## Reversal / retirement path
```

---

## 4. Decision record acceptance rules

A decision record is acceptable only when:

1. it names the canonical target paths it changes;
2. it distinguishes design correction from implementation work;
3. it identifies validation and evidence obligations;
4. it does not place authority under `inputs/**`;
5. it does not weaken fail-closed posture;
6. it does not broaden support claims without proof;
7. it has a rollback or retirement path.
