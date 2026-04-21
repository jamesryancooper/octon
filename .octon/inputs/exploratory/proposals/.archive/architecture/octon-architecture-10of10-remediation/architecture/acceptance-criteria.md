# Acceptance Criteria for 10/10 Target-State Architecture

The architecture may be declared target-state-grade only when all criteria below pass.

## A. Authority and topology

- [ ] One machine-readable registry identifies every canonical class root, path family, authority class, allowed consumer, forbidden consumer, validator, and generated doc target.
- [ ] Active docs are generated from or registry-checked against that registry.
- [ ] No active doc contains contradictory hand-maintained topology truth.
- [ ] `framework/**` and `instance/**` remain the only authored authority roots.
- [ ] `generated/**` remains derived-only.
- [ ] `inputs/**` remains non-authoritative.

## B. Runtime authorization

- [ ] Every material side-effect path is inventoried.
- [ ] Every material side-effect path is bound to `authorize_execution(...)` before side effects.
- [ ] Negative bypass tests exist and pass for every path family.
- [ ] Missing grant, support tuple, rollback plan, evidence root, or required policy posture fails closed.
- [ ] Denials emit machine-readable reason codes and retained evidence.

## C. Authority-engine maintainability

- [ ] The authority engine is decomposed into auditable modules.
- [ ] Module boundaries map to stable decision concepts.
- [ ] Each module has fixture-driven tests.
- [ ] The prior monolithic implementation is removed or reduced to a compatibility facade.
- [ ] Reviewers can audit allow/stage/deny/escalate logic without reading a massive file.

## D. Evidence and proof

- [ ] Evidence-store contract exists and is registered.
- [ ] CI artifacts are classified as transport/projection unless retained under the evidence-store contract.
- [ ] Consequential run closeout requires evidence completeness.
- [ ] RunCards, HarnessCards, replay bundles, denial bundles, and disclosure bundles are generated from retained evidence only.
- [ ] Support claims cite retained proof.

## E. Promotion semantics

- [ ] Every movement from `inputs/**` or `generated/**` into `framework/**`, `instance/**`, `state/control/**`, or runtime-facing `generated/effective/**` has a promotion or publication receipt.
- [ ] Direct project-finding publication into durable context without receipt is removed or reclassified as human-authored direct edit with evidence.
- [ ] Promotion receipts include source, target, actor, authority basis, validation, rollback, and evidence root.

## F. Run lifecycle

- [ ] Formal run lifecycle state machine is registered.
- [ ] Every transition declares authority, evidence, rollback, support, operator notification, and closeout requirements.
- [ ] Invalid transitions fail closed.
- [ ] Paused, revoked, failed, and rolled_back paths are tested.

## G. Support-target proofing

- [ ] No support tuple is admitted without proof bundle.
- [ ] Each admitted tuple has live and denied scenario evidence.
- [ ] Support matrix generation consumes admissions and proof dossiers.
- [ ] Stage-only and unsupported surfaces cannot appear in live claims.

## H. Operator legibility

- [ ] Operator views exist for missions, runs, grants, support, evidence, and closeout readiness.
- [ ] Operator views are generated read models and cannot mint authority.
- [ ] Every operator view field traces to canonical authority/control/evidence/continuity source.
- [ ] A reviewer can answer what is running, why it is allowed, what is blocked, what evidence exists, and what can be recovered without reading raw YAML families.

## I. Architecture self-validation

- [ ] All architecture validators are wired into local assurance and CI.
- [ ] Closure certification evidence is retained under `state/evidence/validation/architecture/10of10-remediation/**`.
- [ ] Decision records document adoption, registry consolidation, authorization coverage, evidence-store closeout, and promotion semantics.
- [ ] The proposal packet is archived and remains non-authoritative lineage.

Failure of any mandatory item prevents a 10/10 declaration.
