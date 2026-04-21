# Octon Architecture 10/10 Remediation Program

`proposal_id: octon-architecture-10of10-remediation`

## Purpose

This proposal packet defines the architecture remediation program required to move Octon from the current evaluated architecture score of **7.1 / 10** to a true **10 / 10 target-state architecture**. The packet is implementation-grade: it identifies the exact durable Octon surfaces that must be created, modified, relocated, validated, or archived outside this proposal workspace.

## Non-authority notice

This packet is an exploratory proposal under:

```text
/.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/
```

It is **non-canonical while it remains in `inputs/**`**. It must not be consumed directly by runtime, policy, support-target routing, generated effective publications, mission authority, or operator control surfaces. Promotion must land as durable authored authority, runtime contracts, governance declarations, validation scripts, decision records, or evidence contracts outside this proposal tree.

## Controlling architectural judgment

The mandatory architectural evaluation used as the packet's source artifact concluded:

- current architecture score: **7.1 / 10**
- severity: **moderate restructuring, not architectural re-foundation**
- preserve the five-class super-root model, constitutional kernel, generated-non-authority rule, support-target boundedness, mission/run split, adapter non-authority, and overlay-point restriction
- close the main score-drag factors: authorization-boundary proof, durable evidence completeness, canonical topology registry consolidation, authority-engine decomposition, operator-grade read models, support-target proofing, promotion semantics, active-doc simplification, and architecture self-validation

## Remediation stance

This program does not create a rival authority model. It strengthens Octon's existing model:

1. keep `/.octon/` as the single authoritative super-root;
2. keep authored authority in `framework/**` and `instance/**`;
3. keep `inputs/**` non-authoritative;
4. keep `generated/**` derived-only;
5. keep `state/**` as operational truth, control truth, continuity, and retained evidence;
6. make material execution mechanically unable to bypass the engine-owned authorization boundary;
7. make evidence complete and durable by construction;
8. make support claims mechanically provable before being admitted.

## Reading order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `resources/full-architectural-evaluation.md`
5. `resources/repository-baseline-audit.md`
6. `architecture/target-architecture.md`
7. `architecture/current-state-gap-map.md`
8. `architecture/file-change-map.md`
9. `architecture/implementation-plan.md`
10. `architecture/validation-plan.md`
11. `architecture/acceptance-criteria.md`
12. `architecture/closure-certification-plan.md`

## Closure intent

This proposal is closure-ready only when every mandatory remediation item has been promoted into durable non-proposal targets, validated, evidenced, and covered by final closure certification.

## Promotion must land outside this workspace

Promotion targets include, at minimum:

- `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `/.octon/framework/cognition/_meta/architecture/specification.md`
- `/.octon/framework/constitution/contracts/registry.yml`
- `/.octon/framework/constitution/contracts/retention/evidence-store-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `/.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
- `/.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md`
- `/.octon/framework/engine/runtime/crates/authority_engine/src/**`
- `/.octon/framework/assurance/runtime/_ops/scripts/**`
- `/.octon/instance/governance/contracts/promotion-receipts.yml`
- `/.octon/instance/governance/contracts/support-target-proofing.yml`
- `/.octon/instance/governance/support-target-admissions/**`
- `/.octon/instance/cognition/decisions/**`
- `/.octon/state/evidence/**`
- `/.octon/generated/cognition/**` as non-authoritative operator read models only

No proposal file may become runtime authority by reference.
