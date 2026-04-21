# Proof-Plane Hardening Model

## Current posture

Octon already has distinct evidence obligations, support admissions, support dossiers, lab, observability, and maintainability proof surfaces. The target-state issue is sufficiency and closure automation, not conceptual absence.

## Target proof layers

| Layer | Durable root | Target role |
|---|---|---|
| Run evidence | `.octon/state/evidence/runs/**` | Runtime receipts, checkpoints, replay, assurance, measurement, interventions, disclosure. |
| Control evidence | `.octon/state/evidence/control/execution/**` | Evidence for approvals, grants, exceptions, revocations, and control mutations. |
| Publication evidence | `.octon/state/evidence/validation/publication/**` | Generated/effective publication receipt and freshness proof. |
| Lab evidence | `.octon/state/evidence/lab/**` | Scenario, shadow-run, hidden-check, adversarial, and replay proof. |
| Architecture validation evidence | `.octon/state/evidence/validation/architecture-target-state-transition/**` | Promotion validation for this architecture transition. |
| Support proof bundles | `.octon/state/evidence/validation/support-targets/**` | Tuple-level support sufficiency proof. |

## Required closeout receipts

Each consequential run closeout must retain:

- authority route receipt;
- run contract receipt;
- grant or denial bundle;
- side-effect classification;
- rollback posture;
- evidence completeness receipt;
- replay pointer;
- disclosure artifact;
- generated/read-model freshness metadata if any generated projection is cited.

## Required negative controls

The proof plane must include negative tests for:

- generated artifact treated as authority;
- raw input treated as policy dependency;
- host label/comment/check treated as authority;
- unsupported or unadmitted support tuple claimed as live;
- material side-effect path without authorization coverage;
- stale generated/effective output used by runtime;
- support dossier with insufficient retained evidence.

## Queryable proof index

Add a generated read model that answers:

- What authorized this run?
- What support tuple applied?
- What was denied or staged?
- What evidence supports the claim?
- Were generated/effective outputs fresh?
- What rollback posture existed before execution?
- Which proof planes are complete?

This index remains generated/cognition and non-authoritative.
