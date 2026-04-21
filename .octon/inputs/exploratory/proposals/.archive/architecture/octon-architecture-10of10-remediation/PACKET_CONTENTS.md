# Packet Contents Transcript

proposal_id: `octon-architecture-10of10-remediation`
transcript_role: generated packaging transcript of file-by-file contents
status: non-authoritative proposal packaging artifact under `inputs/**`

Note: This transcript includes full contents for every packet artifact except `PACKET_CONTENTS.md` itself and `SHA256SUMS.txt`, to avoid recursive self-inclusion and checksum churn. `SHA256SUMS.txt` is included as a standalone root file in the packet.

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/PACKET_MANIFEST.md

# Packet Manifest

This manifest enumerates the proposal packet artifacts for `octon-architecture-10of10-remediation`.

## Root files

| File | Role |
|---|---|
| `README.md` | Packet purpose, non-authority notice, reading order, closure intent. |
| `proposal.yml` | Lifecycle, scope, promotion targets, non-goals, source authorities. |
| `architecture-proposal.yml` | Machine-readable architecture decisions and dispositions. |
| `PACKET_MANIFEST.md` | This manifest. |
| `SHA256SUMS.txt` | Materialized checksums for packet artifacts. |

## Navigation

| File | Role |
|---|---|
| `navigation/source-of-truth-map.md` | Proposal-local precedence and non-authority map. |
| `navigation/artifact-catalog.md` | Catalog of every packet artifact and intended reviewer. |

## Architecture

| File | Role |
|---|---|
| `architecture/target-architecture.md` | True 10/10 target-state architecture. |
| `architecture/current-state-gap-map.md` | Current strengths, limitations, score drags, remedies. |
| `architecture/concept-coverage-matrix.md` | Evaluation finding to remediation/proof trace. |
| `architecture/file-change-map.md` | Concrete create/modify/relocate/delete/archive/regenerate/validate paths. |
| `architecture/implementation-plan.md` | Workstreams, sequencing, gates, evidence emission points. |
| `architecture/migration-cutover-plan.md` | Hybrid bounded cutover plan. |
| `architecture/validation-plan.md` | Deterministic validators and closure validation. |
| `architecture/acceptance-criteria.md` | Falsifiable 10/10 criteria. |
| `architecture/cutover-checklist.md` | Execution and signoff checklist. |
| `architecture/closure-certification-plan.md` | Required closure evidence and final review materials. |
| `architecture/execution-constitution-conformance-card.md` | Constitutional conformance assessment for the target state. |

## Resources

| File | Role |
|---|---|
| `resources/full-architectural-evaluation.md` | Full prior architecture evaluation preserved as source artifact. |
| `resources/repository-baseline-audit.md` | Repo-grounded baseline audit of current architecture. |
| `resources/coverage-traceability-matrix.md` | Deficit-to-change-to-validator-to-evidence trace. |
| `resources/evidence-plan.md` | Retained evidence, replay, disclosure, RunCard, HarnessCard plan. |
| `resources/decision-record-plan.md` | Required durable decision records. |
| `resources/risk-register.md` | Architectural/runtime/migration/proof risks. |
| `resources/assumptions-and-blockers.md` | Grounded assumptions and unresolved blockers. |
| `resources/rejection-ledger.md` | Alternatives explicitly rejected. |

## Additional generated packaging artifact

| File | Role |
|---|---|
| `PACKET_CONTENTS.md` | Generated transcript of all packet files in the requested `FILE:` format, excluding `SHA256SUMS.txt` to avoid recursive hash churn. |


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/README.md

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


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/architecture/acceptance-criteria.md

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


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/architecture/closure-certification-plan.md

# Closure Certification Plan

## Closure objective

Certify that the remediation program promoted all mandatory architecture corrections into durable non-proposal targets and that Octon's architecture now satisfies the target-state acceptance criteria.

## Required closure evidence

Retain evidence under:

```text
.octon/state/evidence/validation/architecture/10of10-remediation/
```

Required subfamilies:

| Evidence family | Required contents |
|---|---|
| `registry/` | Contract registry diff, generated docs, registry validation receipt. |
| `authorization-boundary/` | Side-effect inventory, coverage report, negative bypass results, GrantBundle fixtures. |
| `authority-engine/` | Module map, test report, review signoff, old-file disposition. |
| `evidence-store/` | Evidence-store schema, conformance report, completeness report, sample RunCard/HarnessCard. |
| `promotion/` | Promotion receipt examples, validator report, direct-publication removal evidence. |
| `run-lifecycle/` | State machine fixtures for allow, deny, stage, pause, revoke, fail, rollback, close. |
| `support-targets/` | Per-tuple proof cards, live and denied scenario evidence, support matrix regeneration receipt. |
| `operator-views/` | Generated view examples, traceability report, stale-source failure case. |
| `docs-simplification/` | Diff showing historical material relocated and active docs simplified. |
| `ci/` | CI run links or retained summaries for all gates. |

## Required receipts

- architecture registry publication receipt;
- authorization coverage receipt;
- evidence-store adoption receipt;
- promotion semantics adoption receipt;
- support-target proofing receipt;
- operator read-model publication receipt;
- proposal archive receipt.

## Required disclosures

- target-state HarnessCard;
- support-target claim envelope;
- known limitations after remediation;
- remaining non-live or stage-only surfaces;
- generated view non-authority statement;
- retained evidence-store statement.

## Required reviews

| Reviewer | Required signoff |
|---|---|
| Architecture owner | Target-state design and registry consolidation. |
| Runtime owner | Authorization coverage and authority engine decomposition. |
| Governance owner | Promotion semantics, fail-closed posture, support target proofing. |
| Assurance owner | Validators, evidence completeness, closure certification. |
| Operator representative | Operator read-model legibility and inspectability. |

## Closure decision record

Create:

```text
.octon/instance/cognition/decisions/architecture-10of10-remediation-closeout.md
```

It must state what changed, what remained unchanged, which validators passed, where closure evidence is retained, what support claims are admitted, what remains stage-only, where this proposal packet was archived, and why the architecture is target-state-grade.

## Archive rule

After closure, this proposal moves to:

```text
.octon/inputs/exploratory/proposals/.archive/architecture/octon-architecture-10of10-remediation/
```

Archived proposal content remains historical lineage only and must not become runtime or policy authority.


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/architecture/concept-coverage-matrix.md

# Concept Coverage Matrix

| Evaluation finding | Current repo coverage | Missing or partial coverage | Proposed remediation surfaces | Acceptance criteria | Proof artifacts |
|---|---|---|---|---|---|
| Single super-root and class roots are strong. | `.octon/README.md`, `specification.md`, `octon.yml`. | Repeated hand-maintained topology statements. | `contract-registry.yml`; generated docs. | One registry, generated/checked docs. | Registry validation receipt. |
| Generated views must never be authority. | Charter, spec, fail-closed obligations. | Need consumer checks. | `validate-generated-non-authority.sh`. | No runtime/policy code reads generated summaries as authority. | Non-authority scan receipt. |
| Inputs/proposals must never be direct dependencies. | Charter and spec. | Need scanner and promotion receipt requirement. | `validate-input-non-authority.sh`; promotion contract. | Any direct runtime/policy dependency on `inputs/**` fails. | Input dependency scan receipt. |
| Authorization boundary is central. | `execution-authorization-v1.md`, `execution-request-v3.schema.json`, runtime imports. | Total side-effect path coverage not yet proven. | `authorization-boundary-coverage-v1.md`; coverage validator. | Every material path mapped to `authorize_execution`. | Coverage matrix and negative bypass tests. |
| Authority engine must be auditable. | Rust crate exists; large implementation file. | Module decomposition and unit-test granularity. | New authority_engine module map. | No oversized monolithic authority decision implementation remains. | Module coverage/test report. |
| Evidence obligations are detailed. | `evidence.yml`, `state/evidence/**`. | Durable store contract and completeness automation. | `evidence-store-v1.md`; `validate-evidence-completeness.sh`. | Consequential run cannot close with missing required evidence. | Evidence completeness receipt. |
| CI artifacts are not canonical evidence by default. | Workflows upload artifacts. | Retention contract unclear. | Retention contract and evidence-store schema. | CI artifact transport is classified separately from retained evidence. | Evidence-store conformance card. |
| Support claims are bounded. | `support-targets.yml`. | Per-tuple proof bundles required. | `support-target-proof-bundle-v1.schema.json`; support dossiers. | No tuple admitted without proof bundle. | Support tuple proof card. |
| Mission/run split is strong. | `instance/orchestration/missions/**`, run roots in spec. | Formal state machine. | `run-lifecycle-v1.md`. | Every state transition has authority/evidence/rollback/support rules. | Run lifecycle fixture report. |
| Operator UX is weak. | CLI run commands and orchestration inspect. | Generated operator read models. | `operator-read-models-v1.md`. | Views trace to canonical sources. | Read-model consistency receipt. |
| Promotion semantics need hardening. | Inputs/generated are non-authority. | Some direct publishing paths lack receipt discipline. | `promotion-activation-v1.md`; promotion receipts contract. | No generated/input artifact becomes authority without receipt. | Promotion receipt ledger. |
| Active docs carry historical complexity. | Bootstrap/spec include waves/cutover/proposal lineage. | Relocation plan. | ADRs and migration evidence. | Active docs steady-state-first. | Doc simplification diff and decision records. |
| Architecture validates itself. | Many validators and workflows exist. | Unified self-validation for architecture invariants. | `architecture-conformance.yml` update and scripts. | All 10/10 acceptance checks pass in CI and local validator. | Closure certification bundle. |


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/architecture/current-state-gap-map.md

# Current-State Gap Map

| Current strength or limitation | Gap type | Severity | Target remedy |
|---|---|---:|---|
| Five-class super-root model is explicit and strong. | None / preserve | Low | Preserve unchanged; encode in contract registry and generated docs. |
| Authored authority limited to `framework/**` and `instance/**`. | None / preserve | Low | Preserve; add self-validation for consumers. |
| Generated non-authority rule is strong. | Proof / validation | Medium | Add `validate-generated-non-authority.sh` and generated-view traceability. |
| Raw `inputs/**` non-authority is strong but proposal paths are numerous. | Validation | Medium | Add direct runtime/policy dependency scanner for inputs/proposals. |
| Constitutional kernel is strong. | Ergonomics | Medium | Keep kernel; reduce repeated projections in active docs. |
| Structural topology repeated across README, spec, bootstrap, ingress, manifests. | Design / maintainability | High | Make `contract-registry.yml` the machine-readable topology registry and generate docs. |
| Execution authorization contract is strong. | Implementation / proof | Critical | Add total side-effect path inventory, static checks, negative tests, and receipts. |
| Runtime crates and CLI exist. | Implementation / packaging | High | Harden runtime packaging, source fallback posture, and run lifecycle state machine. |
| `authority_engine/src/implementation.rs` is oversized. | Maintainability / testability | High | Decompose into auditable modules and fixture-driven tests. |
| Evidence obligations are detailed. | Implementation / proof | High | Add evidence-store contract and completeness validator. |
| CI artifacts carry some evidence. | Design / evidence durability | High | Distinguish transport artifacts from canonical retained evidence. |
| Support-target matrix is honest and bounded. | Proof / disclosure | High | Require proof bundles for every admitted tuple. |
| Mission/run model is strong. | Implementation / UX | Medium-high | Formalize run lifecycle and generate operator read models. |
| Operator surfaces exist in CLI. | Ergonomics | High | Add mission/run/grant/evidence/support/readiness views and validators. |
| Overlay registry exists. | Validation | Medium | Ensure no undeclared overlays and generated docs align with registry. |
| Services and skills have deny-by-default guardrails. | Runtime coverage | Medium-high | Bind service/skill invocation to authorization coverage inventory. |
| Historical wave/cutover/proposal-lineage content remains active. | Complexity / legibility | Medium | Move to decision records or migration evidence and simplify active docs. |
| Project findings can flow directly to durable context without separate promotion step. | Authority leak risk | High | Require promotion receipts for all non-authored/generated-to-authority transitions. |
| Generated operator views are underdeveloped. | Ergonomics / inspectability | High | Define operator-read-models-v1 and generated projections with traceability. |
| Support expansion surfaces exist as stage-only. | Support realism | Low | Preserve stage-only posture until proofing admits them. |


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/architecture/cutover-checklist.md

# Cutover Checklist

## Pre-cutover

- [ ] Confirm remediation branch is not weakening constitutional invariants.
- [ ] Confirm proposal packet is non-authoritative and excluded from runtime/policy resolution.
- [ ] Inventory active topology statements in README, specification, bootstrap, ingress, manifests, and support docs.
- [ ] Inventory material execution path families.
- [ ] Inventory evidence roots and current evidence producers.
- [ ] Inventory support-target admissions and dossiers.
- [ ] Inventory generated/effective publication paths.
- [ ] Inventory promotion/publication paths from inputs/generated.

## Registry cutover

- [ ] Expand `contract-registry.yml`.
- [ ] Register class roots and path families.
- [ ] Register validators and generated doc targets.
- [ ] Generate or registry-check active docs.
- [ ] Run `validate-architecture-contract-registry.sh`.
- [ ] Retain registry validation evidence.

## Authorization coverage cutover

- [ ] Create `authorization-boundary-coverage-v1.md`.
- [ ] Map every material path to authorization binding.
- [ ] Add negative bypass tests.
- [ ] Run coverage validator in report mode.
- [ ] Fix missing paths.
- [ ] Enable validator as fail-closed gate.
- [ ] Retain coverage evidence.

## Authority engine cutover

- [ ] Extract modules.
- [ ] Preserve API compatibility.
- [ ] Add fixture tests.
- [ ] Reduce or remove monolithic implementation.
- [ ] Run runtime tests.
- [ ] Retain module coverage evidence.

## Evidence-store cutover

- [ ] Create evidence-store schema/spec.
- [ ] Distinguish CI transport from retained evidence.
- [ ] Add evidence completeness validator.
- [ ] Run sample allow/stage/deny/closeout fixtures.
- [ ] Enable evidence completeness for consequential closeout.
- [ ] Retain conformance evidence.

## Promotion cutover

- [ ] Create promotion receipt schema/policy.
- [ ] Replace direct project-finding publication language.
- [ ] Add promotion validator.
- [ ] Retain promotion receipt examples.
- [ ] Enable fail-closed behavior for missing receipts.

## Support-target proofing cutover

- [ ] Define support proof bundle schema.
- [ ] Add per-tuple proof bundle requirements.
- [ ] Validate existing admitted tuples.
- [ ] Regenerate support-target matrix.
- [ ] Retain support proof evidence.

## Operator read-model cutover

- [ ] Define operator-read-model contract.
- [ ] Generate mission/run/grant/evidence/support/readiness views.
- [ ] Add trace metadata.
- [ ] Validate generated views are non-authoritative.
- [ ] Expose CLI/TUI/Studio read-only views.

## Documentation simplification

- [ ] Move historical wave/cutover content to decision records or migration evidence.
- [ ] Keep active docs steady-state-first.
- [ ] Remove duplicated topology truth after generated replacements pass.

## Final signoff

- [ ] All validators pass locally.
- [ ] All validators pass in CI.
- [ ] All required decision records are present.
- [ ] Closure evidence retained.
- [ ] Proposal packet archived.
- [ ] Final architecture score re-evaluation records target-state-grade status.


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/architecture/execution-constitution-conformance-card.md

# Execution Constitution Conformance Card

## Proposal

`octon-architecture-10of10-remediation`

## Constitutional posture

The proposal strengthens Octon's constitutional regime. It does not replace or rival it.

## Conformance checks

| Principle | Current constitutional requirement | Proposal effect | Conformance |
|---|---|---|---|
| Single super-root | `/.octon/` is the authoritative super-root. | Preserves and validates class-root registry. | Strengthens. |
| Authored authority | Only `framework/**` and `instance/**` are authored authority. | Keeps this boundary and adds promotion receipt checks. | Strengthens. |
| Generated non-authority | `generated/**` is derived-only. | Adds validators and traceable read-model rules. | Strengthens. |
| Raw input non-authority | `inputs/**` cannot be direct runtime/policy dependency. | Adds input dependency scanner and promotion receipts. | Strengthens. |
| Fail closed | Missing authority/evidence/support blocks or stages. | Adds missing-coverage and missing-receipt fail-closed cases. | Strengthens. |
| Material execution authorization | Material execution must cross engine-owned boundary. | Adds total coverage proof and negative bypass tests. | Strengthens. |
| Evidence obligations | Consequential execution retains evidence. | Adds evidence-store contract and completeness gate. | Strengthens. |
| Support boundedness | Live support is admitted finite tuple set. | Adds proof bundles before tuple claims. | Strengthens. |
| Adapter non-authority | Host/model adapters are replaceable and non-authoritative. | Adds adapter projection coverage and support proofing. | Strengthens. |
| Mission-backed long horizon autonomy | Recurring/long-running autonomy must be mission-backed. | Formalizes run lifecycle and operator views. | Strengthens. |
| Host projections non-authority | Labels/checks/comments mirror only. | Adds operator view and host projection traceability validators. | Strengthens. |

## No weakening motions

The proposal explicitly rejects treating generated summaries as authority, broadening support claims without proof, direct runtime/policy reads from proposal inputs, creating a second control plane, weakening deny-by-default behavior, or collapsing evidence into CI artifact transport.

## Required conformance evidence

Before closure, retain registry conformance receipt, authorization coverage receipt, generated/input non-authority receipts, support-target proof receipts, evidence completeness receipts, operator read-model consistency receipts, and final closure decision record.

## Judgment

The target-state is constitutionally conformant because it converts Octon's existing constitutional commitments into mechanical validators, runtime enforcement coverage, durable evidence, proof-backed support claims, and operator-legible read models while preserving the existing source-of-truth hierarchy.


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/architecture/file-change-map.md

# File Change Map

## Create

| Path | Purpose |
|---|---|
| `.octon/framework/constitution/contracts/retention/evidence-store-v1.schema.json` | Retained evidence backend contract schema. |
| `.octon/framework/constitution/contracts/authority/promotion-receipt-v1.schema.json` | Receipt schema for promotion/activation. |
| `.octon/framework/constitution/contracts/disclosure/run-card-v1.schema.json` | RunCard disclosure schema. |
| `.octon/framework/constitution/contracts/disclosure/harness-card-v1.schema.json` | HarnessCard disclosure schema. |
| `.octon/framework/constitution/contracts/assurance/support-target-proof-bundle-v1.schema.json` | Support tuple proof bundle schema. |
| `.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md` | Required side-effect path coverage contract. |
| `.octon/framework/engine/runtime/spec/evidence-store-v1.md` | Runtime retained evidence store contract. |
| `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md` | Formal run lifecycle state machine. |
| `.octon/framework/engine/runtime/spec/operator-read-models-v1.md` | Non-authoritative operator view contract. |
| `.octon/framework/engine/runtime/spec/promotion-activation-v1.md` | Promotion and publication lifecycle contract. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-contract-registry.sh` | Validate canonical registry and generated docs. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh` | Validate side-effect path coverage. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-completeness.sh` | Validate retained evidence completeness. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh` | Validate generated surfaces are not authority inputs. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh` | Validate raw inputs/proposals are not runtime/policy dependencies. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-promotion-receipts.sh` | Validate promotion/activation receipts. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-support-target-proofing.sh` | Validate admitted tuple proof bundles. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-operator-read-models.sh` | Validate generated views trace to canonical sources. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-docs-consistency.sh` | Validate docs align with registry/runtime contracts. |
| `.octon/instance/governance/contracts/promotion-receipts.yml` | Repo-owned promotion receipt policy. |
| `.octon/instance/governance/contracts/support-target-proofing.yml` | Repo-owned proofing requirements for support admissions. |
| `.octon/instance/governance/policies/promotion-semantics.yml` | Policy forbidding quiet authority creation. |
| `.octon/instance/cognition/decisions/architecture-10of10-remediation-adoption.md` | Adoption decision for the remediation program. |
| `.octon/instance/cognition/decisions/architecture-topology-registry-consolidation.md` | Decision for contract registry consolidation. |
| `.octon/instance/cognition/decisions/authorization-boundary-coverage-closeout.md` | Closeout decision for enforcement coverage. |
| `.octon/instance/cognition/decisions/evidence-store-and-proof-plane-closeout.md` | Closeout decision for evidence durability. |
| `.octon/instance/cognition/decisions/promotion-semantics-hardening.md` | Decision for promotion semantics. |
| `.octon/state/evidence/validation/architecture/10of10-remediation/` | Closure evidence root. |

## Modify

| Path | Required change |
|---|---|
| `.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Make it the single machine-readable registry for topology, authority, consumers, validators, publication, and generated docs. |
| `.octon/framework/cognition/_meta/architecture/specification.md` | Reduce hand-maintained path matrices; reference generated docs from registry. |
| `.octon/README.md` | Keep concise class-root summary; generated from registry or registry-checked. |
| `.octon/instance/bootstrap/START.md` | Move historical/cutover-heavy content out; keep steady-state boot path. |
| `.octon/instance/ingress/AGENTS.md` | Remove duplicated read-order content once generated from ingress manifest/registry. |
| `.octon/framework/constitution/contracts/registry.yml` | Register new retention, promotion, run-card, harness-card, support-proof contracts. |
| `.octon/framework/constitution/obligations/evidence.yml` | Add evidence-store completeness and retention backend references. |
| `.octon/framework/constitution/obligations/fail-closed.yml` | Add explicit denial for missing promotion receipts and missing authorization coverage. |
| `.octon/framework/engine/runtime/README.md` | Link runtime lifecycle, evidence-store, authorization coverage, and operator read-model specs. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/lib.rs` | Re-export decomposed modules. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation.rs` | Shrink to compatibility facade or remove after modularization. |
| `.github/workflows/architecture-conformance.yml` | Add registry, boundary, evidence, promotion, read-model validators. |
| `.github/workflows/deny-by-default-gates.yml` | Include authorization coverage and bypass negative tests. |
| `.github/workflows/runtime-binaries.yml` | Enforce strict packaging expectations for target runtime lanes. |

## Relocate or archive

| Source | Target | Reason |
|---|---|---|
| Active-doc wave/cutover narrative in `specification.md` and `START.md` | `.octon/instance/cognition/decisions/**` or `.octon/state/evidence/migration/**` | Keep active docs steady-state and reduce operator complexity. |
| Proposal-lineage closeout explanations in active docs | Decision records and migration evidence | Proposal packets are historical lineage, not runtime authority. |
| Direct project-finding publication language | Promotion-semantics policy and decision record | Eliminate quiet authority creation path. |

## Delete after replacement

| Path/pattern | Condition |
|---|---|
| Duplicate hand-maintained topology tables in active docs | Generated equivalents exist and registry validator passes. |
| Deprecated compatibility artifacts for run lifecycle | Formal run lifecycle state machine and migration evidence are complete. |
| Any generated/effective output lacking generation lock and publication receipt | Replacement publication path exists or surface is removed from runtime use. |

## Regenerate

| Path | Generator/source |
|---|---|
| `.octon/generated/cognition/summaries/operators/**` | Operator read-model generator from authority/control/evidence/continuity roots. |
| `.octon/generated/cognition/projections/materialized/runs/**` | Run lifecycle and evidence roots. |
| `.octon/generated/cognition/projections/materialized/evidence/**` | Evidence-store index. |
| `.octon/generated/effective/governance/support-target-matrix.yml` | `instance/governance/support-targets.yml` plus proof dossiers. |
| `.octon/generated/proposals/registry.yml` | Proposal manifests only; discovery projection. |

## Validate

| Validator | Applies to |
|---|---|
| `validate-architecture-contract-registry.sh` | Topology registry and generated docs. |
| `validate-authorization-boundary-coverage.sh` | Runtime material path inventory and call coverage. |
| `validate-evidence-completeness.sh` | Run/lab/control/publication evidence roots. |
| `validate-generated-non-authority.sh` | All generated consumers. |
| `validate-input-non-authority.sh` | Runtime/policy imports and path reads. |
| `validate-promotion-receipts.sh` | Promotions from inputs/generated to authority/control/effective. |
| `validate-support-target-proofing.sh` | Tuple admissions and support claims. |
| `validate-operator-read-models.sh` | Generated operator projections. |
| `validate-runtime-docs-consistency.sh` | Runtime README/spec/docs alignment. |


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/architecture/implementation-plan.md

# Implementation Plan

## Program posture

Use a **hybrid bounded cutover**. The constitutional invariants stay live. New validators, registry consolidation, evidence-store contracts, promotion receipts, and operator views are introduced in staged gates. Runtime enforcement changes cut over only when coverage and negative tests pass.

## Workstream 1 — Registry consolidation

Dependencies: none.

Steps:

1. Audit all active topology/source-of-truth statements.
2. Expand `framework/cognition/_meta/architecture/contract-registry.yml` to include path families, authority class, allowed consumers, forbidden consumers, validators, publication rules, and doc-generation targets.
3. Add `validate-architecture-contract-registry.sh`.
4. Generate or registry-check `.octon/README.md`, `specification.md`, `START.md`, and ingress summaries.
5. Move historical wave/cutover narrative to decision records.

Stabilization gate: registry validator passes and active docs contain no hand-maintained contradictory path matrices.

Evidence: `state/evidence/validation/architecture/10of10-remediation/registry-consolidation/`.

## Workstream 2 — Authorization-boundary coverage

Dependencies: registry identifies material execution path families.

Steps:

1. Create side-effect path inventory.
2. Define `authorization-boundary-coverage-v1.md`.
3. Add static scan for side-effect-capable calls and required `authorize_execution` binding.
4. Add negative bypass tests for service, workflow, executor launch, repo mutation, publication, protected CI, adapter projection, egress, and model-backed execution.
5. Gate protected execution and deny-by-default workflows on coverage report.

Stabilization gate: no material path lacks coverage, and all bypass fixtures fail closed.

Evidence: coverage matrix, negative test receipts, grant/denial fixture results.

## Workstream 3 — Authority engine decomposition

Dependencies: authorization coverage inventory.

Steps:

1. Identify stable modules.
2. Extract pure validation/decision submodules first.
3. Preserve public API: `authorize_execution`, `finalize_execution`, receipt helpers.
4. Convert monolithic implementation to a thin facade.
5. Add fixture-driven unit tests per module.
6. Add code-size/auditability budget for authority modules.

Stabilization gate: existing runtime tests pass; new fixture tests cover allow/stage/deny/escalate outcomes.

Evidence: module map, test coverage report, reviewer signoff.

## Workstream 4 — Evidence durability and completeness

Dependencies: run lifecycle draft.

Steps:

1. Create evidence-store schema and runtime spec.
2. Define evidence classes, retention classes, hash/index format, and transport-vs-retained distinction.
3. Add `validate-evidence-completeness.sh`.
4. Make run closeout fail when required evidence is missing.
5. Generate RunCards, HarnessCards, replay bundles, denial bundles, and disclosure bundles from retained evidence only.

Stabilization gate: sample consequential run can close only after evidence completeness passes.

Evidence: evidence-store conformance bundle.

## Workstream 5 — Promotion semantics hardening

Dependencies: registry and evidence-store root.

Steps:

1. Create promotion receipt schema and repo policy.
2. Inventory current promotion/publication paths.
3. Require receipts for `inputs/**` or `generated/**` moving into `framework/**`, `instance/**`, `state/control/**`, or runtime-facing `generated/effective/**`.
4. Replace direct project-finding publication language with promotion workflow.
5. Add validator.

Stabilization gate: no quiet authority creation paths remain.

Evidence: promotion receipt ledger and validator report.

## Workstream 6 — Run lifecycle state machine

Dependencies: authorization/evidence contracts.

Steps:

1. Define `run-lifecycle-v1.md`.
2. Bind each state transition to authority, evidence, rollback, support, and operator visibility requirements.
3. Implement transition validation in runtime.
4. Update CLI inspect/replay/disclose/close behavior.
5. Add fixtures for denied, staged, paused, revoked, failed, rolled_back, and closed paths.

Stabilization gate: invalid transitions fail closed; closeout requires evidence completeness.

Evidence: lifecycle fixture report.

## Workstream 7 — Support-target proofing

Dependencies: evidence-store and validation.

Steps:

1. Define proof bundle schema.
2. Add `support-target-proofing.yml`.
3. Require proof bundle for each admitted tuple.
4. Validate live and denied scenarios.
5. Regenerate support-target matrix from admissions and proof dossiers.

Stabilization gate: support claims fail if proof bundle is missing or stale.

Evidence: per-tuple support proof card.

## Workstream 8 — Operator-grade read models

Dependencies: run lifecycle, evidence-store, support proofing.

Steps:

1. Define `operator-read-models-v1.md`.
2. Generate mission, run, grant, support, evidence, and closeout views.
3. Add traceability metadata to every generated field.
4. Add consistency validator.
5. Update CLI/TUI/Studio surfaces to consume read models as projections only.

Stabilization gate: operator views are complete, traceable, and non-authoritative.

Evidence: read-model consistency receipts.

## Completion conditions

The remediation program completes when all workstreams pass validators, evidence is retained, decision records are created, generated read models are traceable, and closure certification records the architecture as target-state-grade.


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/architecture/migration-cutover-plan.md

# Migration and Cutover Plan

## Cutover posture

The correct posture is **hybrid bounded cutover**.

A hard cutover would be too risky because runtime enforcement, evidence-store, promotion semantics, and operator views affect the control plane. A slow indefinite staged cutover would preserve liminal architecture and duplicated topology truth. The hybrid approach keeps existing constitutional invariants live, introduces new contracts and validators in staged gates, and performs hard cutovers only for bounded surfaces after proof exists.

## Phase 0 — Freeze invariants

Preserve unchanged:

- five-class super-root model;
- authored authority roots;
- generated/input non-authority;
- state/control/evidence separation;
- support-target boundedness;
- mission/run split;
- adapter non-authority;
- overlay restriction.

No remediation branch may weaken those invariants.

## Phase 1 — Registry-first consolidation

Introduce expanded `contract-registry.yml`. Existing docs remain readable but are marked registry-checked. Generated replacements are introduced alongside current docs.

Cutover gate:

- registry validation passes;
- generated docs match active docs;
- no contradiction detected.

## Phase 2 — Validators as warning gates

Add validators initially in report mode:

- authorization-boundary coverage;
- evidence completeness;
- generated/input non-authority;
- promotion receipts;
- support-target proofing;
- operator read-model traceability.

Cutover gate:

- report mode produces stable output for at least one representative run and one proposal/promotion path.

## Phase 3 — Enforcement for new paths

All newly changed material execution paths, generated/effective publications, support admissions, and promotions must satisfy the new validators.

Cutover gate:

- no new bypasses introduced;
- all new support claims proof-backed;
- all new promotions receipt-backed.

## Phase 4 — Runtime boundary hard cutover

Authorization coverage becomes required for all material paths.

Cutover gate:

- complete material path inventory;
- negative bypass suite passes;
- protected execution fails closed when coverage is missing;
- `authorize_execution` call path coverage evidence retained.

## Phase 5 — Evidence-store hard cutover

Run closeout, support disclosure, generated/effective publication, and architecture closure require retained evidence-store conformance.

Cutover gate:

- evidence completeness validator passes for sample run, denied run, staged run, publication, and support tuple.

## Phase 6 — Documentation simplification

Historical wave/cutover/proposal-lineage content is moved to decision records or migration evidence. Active docs are regenerated or registry-checked and reduced to steady-state language.

Cutover gate:

- active docs no longer repeat canonical topology in conflicting hand-maintained form;
- decision records preserve history.

## Phase 7 — Closure certification

Final closure requires:

- all validators passing;
- closure evidence retained;
- decision records created;
- operator read models generated and traceable;
- support tuple proof cards present;
- proposal archived as lineage only.


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/architecture/target-architecture.md

# Target Architecture: Octon 10/10

## Top-level architectural thesis

A 10/10 Octon architecture is a repo-native governed autonomy runtime in which every consequential action is authorized, support-bounded, evidence-retained, replayable, inspectable, and closed through a small set of stable canonical contracts.

The target-state does **not** replace Octon's current foundation. It makes the current foundation mechanically enforceable, easier to maintain, easier to validate, and easier for operators to reason about.

## Stable architecture layers

1. **Constitutional authority layer** — `framework/constitution/**`, including charter, precedence, fail-closed, evidence, support-target schemas, disclosure, retention, runtime, authority, and adapter contracts.
2. **Structural topology layer** — `framework/cognition/_meta/architecture/contract-registry.yml` as the machine-readable registry for class roots, canonical path families, authority dependencies, publication families, validation rules, and generated documentation.
3. **Instance authority layer** — `instance/**`, including workspace charter, governance, support targets, locality, missions, repo-owned policies, support admissions, and decision records.
4. **Runtime enforcement layer** — `framework/engine/runtime/**`, including authorization, run lifecycle, evidence-store, adapter, operator-read-model, and packaging contracts plus Rust implementations.
5. **Control/evidence/continuity layer** — `state/control/**`, `state/evidence/**`, and `state/continuity/**` as mutable operational truth, retained evidence, and handoff state.
6. **Generated read/effective layer** — `generated/**` as rebuildable projections and runtime-facing effective outputs that require freshness locks and publication receipts.
7. **Proposal/input layer** — `inputs/**` as non-authoritative raw material, proposals, additive packs, and ideation.

## Authority and control plane

The control plane remains repo-native. Durable authority can live only in `framework/**` and `instance/**`; mutable execution control truth can live only in `state/control/**`; retained evidence can live only in `state/evidence/**`; generated summaries and host affordances remain projections.

A 10/10 architecture requires every authority family to identify:

- canonical path;
- class root;
- authority rank;
- allowed consumers;
- forbidden consumers;
- validator;
- promotion route;
- evidence obligations;
- generated projection rules.

This is why the contract registry must become the single machine-readable topology and authority registry.

## Runtime kernel and enforcement boundary

Every material execution path must cross:

```rust
authorize_execution(request: ExecutionRequest) -> GrantBundle
```

The runtime must prove coverage for:

- service invocation;
- workflow-stage execution;
- executor launch;
- repo mutation;
- generated/effective publication;
- protected CI checks;
- adapter projection publication;
- external egress;
- model-backed execution;
- control-plane mutation;
- support-target disclosure.

The target invariant is:

> No material side effect occurs without a valid grant, support-target resolution, run/control/evidence root binding, receipt emission obligation, rollback posture, and denial/escalation reason path.

## Formal run lifecycle

The canonical run state machine is:

```text
requested
  -> authorized | denied | staged | escalated
authorized
  -> prepared -> executing -> checkpointed -> verifying -> closing
closing
  -> closed | failed | paused | revoked | rolled_back
executing
  -> checkpointed | paused | failed | revoked
paused
  -> authorized | revoked | rolled_back
failed
  -> staged | rolled_back | closed
```

Each transition must declare:

- required authority;
- required evidence;
- support tuple posture;
- rollback posture;
- allowed actor;
- operator notification behavior;
- generated read-model update;
- closeout conditions.

## Evidence plane

The evidence plane becomes durable by construction.

Canonical retained evidence belongs in:

- `state/evidence/runs/**` for run receipts, checkpoints, replay, trace pointers, classifications, measurements, interventions, assurance, disclosure, RunCards;
- `state/evidence/lab/**` for scenario bundles, benchmark evidence, HarnessCards, evaluator reviews;
- `state/evidence/control/execution/**` for grants, denials, approvals, exceptions, revocations, and control-plane mutation evidence;
- `state/evidence/validation/publication/**` for generated/effective publication receipts;
- `state/evidence/validation/architecture/**` for architecture conformance and closure evidence.

CI artifacts may transport or mirror evidence but are not the durable evidence store unless retained through the evidence-store contract.

## Operator plane

Operator-grade views are generated, non-authoritative read models. They must answer:

- What missions are active?
- What runs are requested, staged, executing, paused, denied, failed, or closed?
- What grants exist?
- What support tuple applies?
- What rollback posture applies?
- What evidence exists or is missing?
- What is blocked and why?
- What can be replayed?
- What is ready to close?

Target generated views:

- `generated/cognition/projections/materialized/missions/**`
- `generated/cognition/projections/materialized/runs/**`
- `generated/cognition/projections/materialized/evidence/**`
- `generated/cognition/summaries/operators/**`

These views must fail validation if they cannot trace every field to canonical authority, control, evidence, or continuity surfaces.

## Adapter and support-target discipline

Host and model adapters remain replaceable, non-authoritative boundaries. Support claims remain bounded by admitted tuples in `instance/governance/support-targets.yml` and associated admission/dossier proof files.

A tuple cannot be admitted unless it has:

- support-target admission record;
- support dossier;
- conformance suite;
- live scenario;
- denied unsupported scenario;
- evidence completeness check;
- disclosure artifact;
- adapter conformance criteria;
- final support claim envelope.

## Promotion and publication model

No artifact may move from `inputs/**` or `generated/**` into `framework/**`, `instance/**`, `state/control/**`, or runtime-facing `generated/effective/**` without a promotion or publication receipt.

Promotion receipt required fields:

- source path;
- target path;
- source class;
- target class;
- actor;
- authority basis;
- review result;
- validator result;
- evidence root;
- rollback plan;
- expiration or review cadence when applicable.

## Validation and closure model

The architecture validates itself through deterministic gates:

- contract-registry coherence;
- generated non-authority;
- input non-authority;
- overlay legality;
- authorization coverage;
- evidence completeness;
- promotion receipts;
- support-target proofing;
- runtime/docs consistency;
- operator view consistency;
- architecture closure certification.

## Simplification principles

- One canonical machine-readable source per concept.
- Generated human docs over repeated hand-maintained topology lists.
- Operator language limited to mission, run, grant, support envelope, evidence, rollback, pack/adapter, and closeout.
- Historical wave/cutover narrative moved to decision records or migration evidence.
- Stage-only surfaces kept explicit and out of live support claims.

## What Octon deliberately does not own

Octon should not become the owner of every adjacent system. It owns authority, authorization, mission/run control, evidence/disclosure, support-target governance, promotion/publication discipline, and architecture self-validation. It integrates, rather than owns, broad IDEs, issue trackers, CI platforms, model providers, browser automation, cloud devboxes, and general plugin marketplaces.


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/architecture/validation-plan.md

# Validation Plan

## Deterministic validators

| Validator | Fails when |
|---|---|
| `validate-architecture-contract-registry.sh` | Registry is missing paths, duplicates canonical owners, or generated docs drift. |
| `validate-generated-non-authority.sh` | Runtime/policy/authority code consumes `generated/cognition/**` or summaries as source of truth. |
| `validate-input-non-authority.sh` | Runtime/policy code reads `inputs/**` or proposal files directly. |
| `validate-overlay-points.sh` | Overlay artifacts are undeclared, disabled, or use invalid merge modes. |
| `validate-authorization-boundary-coverage.sh` | Material side-effect path lacks `authorize_execution` coverage or bypass negative tests. |
| `validate-evidence-completeness.sh` | Required run/control/lab/publication/disclosure evidence is missing or unclassified. |
| `validate-promotion-receipts.sh` | Artifact moves from `inputs/**` or `generated/**` to authority/control/effective without receipt. |
| `validate-support-target-proofing.sh` | Admitted support tuple lacks proof bundle, scenario, denial case, or disclosure. |
| `validate-operator-read-models.sh` | Generated operator view contains untraceable or stale fields. |
| `validate-runtime-docs-consistency.sh` | Runtime docs/specs disagree with implemented CLI/spec/registry surfaces. |

## Runtime coverage checks

The authorization coverage validator must inspect service invocation paths, workflow-stage execution paths, executor launch paths, repo mutation paths, publication paths, protected CI paths, host/model adapter projections, network egress, model-backed execution, and control-plane mutation paths.

For each path, validation must retain path id, caller path, action type, side-effect classification, authorization binding, evidence binding, negative bypass test result, and denial reason fixture.

## Support-target proof validation

Each admitted tuple must include support-target admission record, support dossier, conformance criteria mapping, live scenario evidence, denied unsupported scenario evidence, evidence completeness check, RunCard/HarnessCard disclosure, and final support envelope statement.

## Evidence completeness validation

A consequential run cannot close unless the validator can assemble run contract, GrantBundle or denial/stage/escalation artifact, execution receipts, runtime events, checkpoints, rollback posture, trace pointers, replay pointers or reason absent, interventions disclosure, verification evidence, RunCard, and closeout record.

## Generated-authority boundary validation

Validation must prove `generated/**` is never treated as canonical authority; `generated/effective/**` is consumed only when freshness locks and publication receipts exist; `generated/cognition/**` is read-model only; the generated proposal registry is discovery-only; and host projections are mirrors only.

## Runtime/docs consistency validation

Runtime docs must match CLI subcommands, runtime spec contracts, release target declarations, support-target posture, run lifecycle states, evidence-store obligations, and operator-read-model contracts.

## Operator-view consistency validation

Every operator view field must include source trace metadata. Any field derived from stale, missing, or forbidden source material fails validation.

## Closure validation

Closure requires all validators passing, all required evidence retained, all decision records present, all mandatory file changes promoted, this proposal archived, and no active runtime/policy dependency on the archived proposal.


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/architecture-proposal.yml

schema_version: octon-architecture-proposal-v1
proposal_id: octon-architecture-10of10-remediation
architecture_scope:
  super_root: .octon/
  affected_classes:
    - framework
    - instance
    - state
    - generated
    - inputs
  proposal_workspace_is_non_authoritative: true
decision_type: target-state-remediation-program
executive_thesis: >-
  Octon's current architecture is directionally correct and should not be
  re-founded. It should be promoted to 10/10 by making its existing constitutional
  authority model mechanically enforceable, proof-complete, maintainable,
  operator-legible, and self-validating.
target_state_decisions:
  - id: D-001
    title: Single canonical topology and authority registry
    decision: >-
      Use .octon/framework/cognition/_meta/architecture/contract-registry.yml as
      the machine-readable canonical registry for path, authority, dependency,
      publication, and validation invariants; generate human docs from it.
  - id: D-002
    title: Total authorization-boundary coverage
    decision: >-
      Every material side-effect path must be inventoried and proven to cross
      authorize_execution(...) before side effects. Missing coverage fails CI.
  - id: D-003
    title: Decompose authority engine
    decision: >-
      Split the authority engine into auditable modules aligned to stable
      concepts: request normalization, support targets, ownership, risk,
      mission/run binding, capability admission, rollback, budget, egress,
      decisions, reasons, receipts, evidence, and finalization.
  - id: D-004
    title: Evidence durable by construction
    decision: >-
      Introduce evidence-store and evidence-completeness contracts that separate
      retained canonical evidence from CI artifact transport and generated views.
  - id: D-005
    title: Promotion semantics hardening
    decision: >-
      Require promotion/activation receipts for every generated/** or inputs/**
      artifact that becomes durable authority, durable context, runtime-facing
      effective output, or operational control truth.
  - id: D-006
    title: Formal run lifecycle state machine
    decision: >-
      Define requested, authorized, denied, staged, escalated, prepared,
      executing, checkpointed, verifying, closing, closed, failed, paused,
      revoked, and rolled_back states with authority/evidence/support/rollback
      requirements for every transition.
  - id: D-007
    title: Support-target proofing
    decision: >-
      An admitted support tuple must have conformance suites, live and denied
      scenarios, proof bundle, evidence completeness check, and disclosure.
  - id: D-008
    title: Operator-grade non-authoritative read models
    decision: >-
      Generate mission, run, grant, evidence, support, and closeout-readiness
      views from canonical authority/control/evidence surfaces only.
current_state_disposition:
  preserved_unchanged:
    - five-class super-root model
    - constitutional kernel under framework/constitution/**
    - authored authority in framework/** and instance/** only
    - generated non-authority rule
    - raw input non-authority rule
    - state/control/evidence/continuity separation
    - support-target boundedness
    - mission/run separation
    - adapter non-authority
    - overlay-point restriction
  refined:
    - framework/cognition/_meta/architecture/specification.md
    - framework/cognition/_meta/architecture/contract-registry.yml
    - framework/engine/runtime/spec/**
    - framework/constitution/contracts/**
    - instance/governance/support-targets.yml
    - instance/governance/support-target-admissions/**
  relocated:
    - historical wave/cutover/proposal-lineage content from active docs to instance/cognition/decisions/** or state/evidence/migration/**
  reduced:
    - repeated hand-maintained topology/source-of-truth tables
    - active operator vocabulary exposed before first run
  deleted:
    - any direct or implied runtime dependency on inputs/exploratory/proposals/**
    - any duplicate topology list not generated from the canonical registry
    - any quiet promotion path into instance/** without receipts
  newly_introduced:
    - evidence-store-v1 contract
    - run-lifecycle-v1 state machine
    - authorization-boundary-coverage-v1 contract
    - promotion-activation-v1 contract
    - operator-read-models-v1 contract
    - support-target-proof-bundle-v1 contract
implementation_motions:
  - inventory material execution call paths and bind them to authorization coverage tests
  - split authority_engine/src/implementation.rs into stable modules
  - add evidence completeness and durable retention validators
  - render docs from contract-registry.yml
  - add operator read-model generators and consistency validators
  - add support tuple proof bundles before any support claim expansion
deletion_motions:
  - remove duplicated canonical path matrices from active docs once generated replacements exist
  - remove or archive active-doc wave/cutover language after decision records are created
  - remove any generated/effective publication path lacking receipt-backed freshness
validation_motions:
  - architecture contract registry validation
  - authorization coverage validation
  - generated non-authority validation
  - input non-authority validation
  - promotion receipt validation
  - evidence completeness validation
  - support-target proof validation
  - runtime/docs consistency validation
  - operator read-model consistency validation
closure_motions:
  - retain closure evidence under .octon/state/evidence/validation/architecture/10of10-remediation/**
  - create closeout ADRs under .octon/instance/cognition/decisions/**
  - archive this proposal packet after promotion and closure certification


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/navigation/artifact-catalog.md

# Artifact Catalog

| Artifact | Type | Primary reviewer | Promotion effect |
|---|---|---|---|
| `README.md` | root orientation | architecture-owner | None directly; proposal-only orientation. |
| `proposal.yml` | lifecycle manifest | governance-owner | Defines intended durable targets. |
| `architecture-proposal.yml` | architecture manifest | architecture-owner | Defines preserved/refined/relocated/reduced/deleted/introduced surfaces. |
| `PACKET_MANIFEST.md` | manifest | assurance-owner | Packet completeness reference. |
| `SHA256SUMS.txt` | integrity | assurance-owner | Packet materialization integrity. |
| `navigation/source-of-truth-map.md` | navigation | governance-owner | Clarifies non-authority and proposal-local precedence. |
| `navigation/artifact-catalog.md` | navigation | assurance-owner | Review routing. |
| `architecture/target-architecture.md` | target design | architecture-owner | Basis for promoted target-state contracts. |
| `architecture/current-state-gap-map.md` | gap map | architecture-owner | Gap closure plan. |
| `architecture/concept-coverage-matrix.md` | traceability | assurance-owner | Finding-to-proof trace. |
| `architecture/file-change-map.md` | implementation map | runtime-owner | Concrete file-level target list. |
| `architecture/implementation-plan.md` | work plan | runtime-owner | Sequenced program. |
| `architecture/migration-cutover-plan.md` | cutover plan | governance-owner | Hybrid bounded cutover posture. |
| `architecture/validation-plan.md` | validation plan | assurance-owner | Validator requirements. |
| `architecture/acceptance-criteria.md` | acceptance | governance-owner | 10/10 signoff criteria. |
| `architecture/cutover-checklist.md` | checklist | release-owner | Executable signoff list. |
| `architecture/closure-certification-plan.md` | closure | assurance-owner | Required closure evidence. |
| `architecture/execution-constitution-conformance-card.md` | conformance card | governance-owner | Confirms strengthened constitutional posture. |
| `resources/full-architectural-evaluation.md` | source artifact | architecture-owner | Required analytical basis. |
| `resources/repository-baseline-audit.md` | baseline | architecture-owner | Repo-grounded current-state facts. |
| `resources/coverage-traceability-matrix.md` | traceability | assurance-owner | Deficit-to-closure map. |
| `resources/evidence-plan.md` | proof plan | assurance-owner | Evidence-store and completeness model. |
| `resources/decision-record-plan.md` | ADR plan | governance-owner | Required durable decision records. |
| `resources/risk-register.md` | risk | governance-owner | Risk controls and mitigations. |
| `resources/assumptions-and-blockers.md` | assumptions | architecture-owner | Grounded assumptions and blockers. |
| `resources/rejection-ledger.md` | rejections | architecture-owner | Alternatives rejected. |
| `PACKET_CONTENTS.md` | generated transcript | assurance-owner | Full file-by-file transcript. |


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/navigation/source-of-truth-map.md

# Proposal-Local Source-of-Truth Map

## Packet status

This proposal packet is non-authoritative because it lives under `/.octon/inputs/exploratory/proposals/**`. It may guide human review and promotion work, but it must not be referenced directly by runtime or policy code.

## Proposal-local reading precedence

1. `proposal.yml` — packet lifecycle, scope, and promotion targets.
2. `architecture-proposal.yml` — target-state decisions and current-state disposition.
3. `architecture/target-architecture.md` — human-readable target-state design.
4. `architecture/file-change-map.md` — path-specific remediation map.
5. `architecture/implementation-plan.md` and `architecture/validation-plan.md` — execution and validation programs.
6. `resources/full-architectural-evaluation.md` — mandatory evaluation source artifact.
7. Other resource files — supporting traceability, risk, evidence, and decision plans.

If proposal files conflict, `proposal.yml` and `architecture-proposal.yml` govern proposal lifecycle and intended promotion. They still do not become Octon runtime authority.

## Repo authority outside this packet

The proposal must preserve the following hierarchy:

| Class/root | Role |
|---|---|
| `/.octon/framework/**` | Portable authored framework authority and runtime contracts. |
| `/.octon/instance/**` | Repo-specific durable authored authority. |
| `/.octon/state/control/**` | Mutable operational control truth. |
| `/.octon/state/evidence/**` | Retained proof, receipts, replay, validation evidence. |
| `/.octon/state/continuity/**` | Active continuity and handoff state. |
| `/.octon/generated/**` | Derived read/effective models only; never source of truth. |
| `/.octon/inputs/**` | Non-authoritative proposals, exploratory inputs, and raw additive material. |

## Required promotion rule

Any durable remediation must be promoted to a proper authored, control, evidence, or generated-read-model target outside this packet. Direct runtime reads from this packet are invalid.

## Non-authoritative projections

Generated operator views, CI comments, GitHub checks, host labels, chat summaries, and proposal registries may mirror state but never mint authority. The target-state proposal strengthens that rule by requiring consistency validators and promotion receipts.


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/proposal.yml

schema_version: octon-proposal-v1
proposal_id: octon-architecture-10of10-remediation
title: Octon Architecture 10/10 Remediation Program
summary: >-
  Manifest-governed architecture remediation packet defining the concrete
  target-state, file-level change plan, validators, proof artifacts, and
  closure criteria required to move Octon from the evaluated 7.1/10 architecture
  to a true 10/10 architecture without replacing Octon's existing constitutional
  authority model.
proposal_kind: architecture-remediation-program
status: proposed
lifecycle:
  created_for: architecture remediation planning
  current_phase: proposal-packet-review
  may_execute_directly: false
  may_inform_promotion: true
  close_when: >-
    All mandatory remediation surfaces are promoted outside inputs/**,
    validators pass, closure certification evidence is retained, and decision
    records identify the proposal as archived lineage only.
temporary_archival_intent:
  temporary_workspace: true
  archive_after_promotion: true
  archive_path: .octon/inputs/exploratory/proposals/.archive/architecture/octon-architecture-10of10-remediation/
exit_expectation: >-
  This packet exits active proposal status only after durable framework,
  instance, state, generated-read-model, and validation surfaces are promoted
  outside the proposal tree and closure evidence is retained.
promotion_scope:
  kind: bounded-architecture-remediation
  severity: moderate-restructuring
  no_foundational_rewrite: true
  no_rival_control_plane: true
  preserve_existing_authority_model: true
explicit_promotion_targets:
  framework_authority:
    - .octon/framework/cognition/_meta/architecture/contract-registry.yml
    - .octon/framework/cognition/_meta/architecture/specification.md
    - .octon/framework/constitution/contracts/registry.yml
    - .octon/framework/constitution/contracts/retention/evidence-store-v1.schema.json
    - .octon/framework/constitution/contracts/authority/promotion-receipt-v1.schema.json
    - .octon/framework/constitution/contracts/disclosure/run-card-v1.schema.json
    - .octon/framework/constitution/contracts/disclosure/harness-card-v1.schema.json
    - .octon/framework/constitution/contracts/assurance/support-target-proof-bundle-v1.schema.json
  runtime_contracts:
    - .octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md
    - .octon/framework/engine/runtime/spec/evidence-store-v1.md
    - .octon/framework/engine/runtime/spec/run-lifecycle-v1.md
    - .octon/framework/engine/runtime/spec/operator-read-models-v1.md
    - .octon/framework/engine/runtime/spec/promotion-activation-v1.md
  runtime_implementation:
    - .octon/framework/engine/runtime/crates/authority_engine/src/request.rs
    - .octon/framework/engine/runtime/crates/authority_engine/src/normalize.rs
    - .octon/framework/engine/runtime/crates/authority_engine/src/support_targets.rs
    - .octon/framework/engine/runtime/crates/authority_engine/src/ownership.rs
    - .octon/framework/engine/runtime/crates/authority_engine/src/risk_materiality.rs
    - .octon/framework/engine/runtime/crates/authority_engine/src/mission_binding.rs
    - .octon/framework/engine/runtime/crates/authority_engine/src/run_binding.rs
    - .octon/framework/engine/runtime/crates/authority_engine/src/capability_admission.rs
    - .octon/framework/engine/runtime/crates/authority_engine/src/rollback.rs
    - .octon/framework/engine/runtime/crates/authority_engine/src/budget.rs
    - .octon/framework/engine/runtime/crates/authority_engine/src/egress.rs
    - .octon/framework/engine/runtime/crates/authority_engine/src/decision.rs
    - .octon/framework/engine/runtime/crates/authority_engine/src/reasons.rs
    - .octon/framework/engine/runtime/crates/authority_engine/src/receipts.rs
    - .octon/framework/engine/runtime/crates/authority_engine/src/evidence.rs
    - .octon/framework/engine/runtime/crates/authority_engine/src/finalize.rs
  validators:
    - .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-contract-registry.sh
    - .octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh
    - .octon/framework/assurance/runtime/_ops/scripts/validate-evidence-completeness.sh
    - .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh
    - .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh
    - .octon/framework/assurance/runtime/_ops/scripts/validate-promotion-receipts.sh
    - .octon/framework/assurance/runtime/_ops/scripts/validate-support-target-proofing.sh
    - .octon/framework/assurance/runtime/_ops/scripts/validate-operator-read-models.sh
    - .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-docs-consistency.sh
  instance_governance:
    - .octon/instance/governance/contracts/promotion-receipts.yml
    - .octon/instance/governance/contracts/support-target-proofing.yml
    - .octon/instance/governance/policies/promotion-semantics.yml
    - .octon/instance/governance/support-target-admissions/**
    - .octon/instance/governance/support-dossiers/**
  decisions:
    - .octon/instance/cognition/decisions/architecture-10of10-remediation-adoption.md
    - .octon/instance/cognition/decisions/architecture-topology-registry-consolidation.md
    - .octon/instance/cognition/decisions/authorization-boundary-coverage-closeout.md
    - .octon/instance/cognition/decisions/evidence-store-and-proof-plane-closeout.md
    - .octon/instance/cognition/decisions/promotion-semantics-hardening.md
  state_and_evidence:
    - .octon/state/evidence/validation/architecture/10of10-remediation/**
    - .octon/state/evidence/control/execution/**
    - .octon/state/evidence/runs/**
    - .octon/state/evidence/lab/**
  generated_read_models:
    - .octon/generated/cognition/summaries/operators/**
    - .octon/generated/cognition/projections/materialized/missions/**
    - .octon/generated/cognition/projections/materialized/runs/**
    - .octon/generated/cognition/projections/materialized/evidence/**
source_authorities:
  mandatory_evaluation_artifact: resources/full-architectural-evaluation.md
  repo_paths:
    - .octon/README.md
    - .octon/AGENTS.md
    - .octon/instance/ingress/AGENTS.md
    - .octon/framework/cognition/_meta/architecture/specification.md
    - .octon/framework/constitution/**
    - .octon/framework/engine/runtime/**
    - .octon/framework/capabilities/runtime/services/**
    - .octon/framework/capabilities/runtime/skills/**
    - .octon/framework/observability/**
    - .octon/framework/overlay-points/registry.yml
    - .octon/instance/manifest.yml
    - .octon/instance/governance/**
    - .octon/instance/orchestration/**
    - .octon/instance/locality/**
    - .octon/state/**
    - .github/workflows/**
non_goals:
  - foundational rewrite of Octon
  - rival authority model outside framework/** and instance/**
  - generated artifacts becoming authoritative
  - raw inputs becoming runtime or policy dependencies
  - weakening fail-closed behavior
  - broadening support claims without proof
  - turning Octon into a general IDE, CI platform, issue tracker, or plugin marketplace
related_proposals: []
review_requirements:
  required_reviewers:
    - architecture-owner
    - runtime-owner
    - governance-owner
    - assurance-owner
  closeout_requires_human_governance_approval: true


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/resources/assumptions-and-blockers.md

# Assumptions and Blockers

proposal_id: `octon-architecture-10of10-remediation`  
resource_role: grounded assumptions and unresolved blockers  
status: non-authoritative proposal resource under `inputs/**`

---

## 1. Grounded assumptions

These assumptions are grounded in observed repository surfaces and the prior architecture evaluation.

| ID | Assumption | Basis |
|---|---|---|
| A-001 | `/.octon/` remains the single authoritative super-root. | `/.octon/README.md`, architecture specification, charter. |
| A-002 | `framework/**` and `instance/**` remain the only authored authority roots. | `.octon` topology doctrine. |
| A-003 | `generated/**` remains rebuildable and never source of truth. | Architecture specification, README, precedence/fail-closed doctrine. |
| A-004 | raw `inputs/**` remain non-authoritative and cannot be direct runtime/policy dependencies. | README, architecture spec, fail-closed obligations. |
| A-005 | host UI, comments, labels, checks, chat transcripts, and generated summaries remain non-authoritative projections. | normative precedence and architecture spec. |
| A-006 | material execution must cross `authorize_execution(...)` before side effects. | execution authorization spec. |
| A-007 | support claims are bounded by `support-targets.yml`. | charter and support-target posture. |
| A-008 | no foundational architectural rewrite is required. | prior evaluation severity judgment. |
| A-009 | runtime enforcement needs proof hardening rather than replacement. | runtime sources and execution specs exist. |
| A-010 | operator-grade views must be generated/read-model surfaces, not canonical authority. | generated non-authority invariant. |
| A-011 | the live repo already identifies `contract-registry.yml` as the machine-readable execution/path/policy invariant registry. | architecture specification. |
| A-012 | broader GitHub/Studio/browser/API/frontier surfaces should remain stage-only until proof-backed. | support-target posture and bootstrap statement. |

---

## 2. Open blockers

| ID | Blocker | Required resolution |
|---|---|---|
| B-001 | Runtime execution was not locally executed during proposal generation. | Before promotion, run the full runtime test suite and material path inventory locally/CI. |
| B-002 | Exact authority-engine module ownership and current internal call graph require code-level refactor planning. | Generate call graph and refactor plan from current Rust sources. |
| B-003 | Evidence-store backend implementation choice is unresolved. | Decide local file-backed retained evidence store vs optional external immutable backend. |
| B-004 | Operator view implementation surface is unresolved. | Decide minimum viable surface: CLI-only, TUI, local web Studio, or all staged. |
| B-005 | Support-target proof suite shape needs implementation-specific fixtures. | Define tuple IDs and scenario fixtures for each admitted support tuple. |
| B-006 | Current generated/effective publication lock mechanics need source-level verification. | Audit generated/effective publication code and receipts. |
| B-007 | CI workflow changes require repo maintainer permission. | Promote through normal PR/review path after packet review. |
| B-008 | Historical/cutover material relocation needs maintainer review to avoid losing useful context. | Create relocation index and backreferences before moving. |

---

## 3. Non-blocking uncertainties

| ID | Uncertainty | Handling |
|---|---|---|
| U-001 | Whether `contract-registry.yml` can absorb all topology/authority metadata without becoming too broad. | Extend incrementally; split generated views but keep one registry of invariants. |
| U-002 | Whether evidence store should be purely repo-local. | Default repo-local retained evidence; optional external retention adapter after proof. |
| U-003 | Whether operator read models should be CLI-first or Studio-first. | Start CLI/generated files; Studio can project later. |
| U-004 | Whether long-running mission demos should be required before 10/10 certification. | Required for final certification, optional for first cutover. |


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/resources/coverage-traceability-matrix.md

# Coverage Traceability Matrix

proposal_id: `octon-architecture-10of10-remediation`  
resource_role: deficit-to-remediation traceability  
status: non-authoritative proposal resource under `inputs/**`

---

## Traceability key

| Column | Meaning |
|---|---|
| Deficit ID | Stable identifier for a remediation deficit. |
| Deficit | Architectural weakness to close. |
| Source evidence | Repository/evaluation source supporting the deficit. |
| Proposed file-level change | Concrete target paths outside the proposal workspace. |
| Validator | Mechanism that proves the change is enforceable. |
| Acceptance criterion | Falsifiable criterion for target-state readiness. |
| Closure evidence | Required proof before closing remediation. |

---

## Matrix

| Deficit ID | Deficit | Source evidence | Proposed file-level change | Validator | Acceptance criterion | Closure evidence |
|---|---|---|---|---|---|---|
| D-001 | Duplicate topology/source-of-truth truth | `/.octon/README.md`, `/.octon/framework/cognition/_meta/architecture/specification.md`, `/.octon/instance/bootstrap/START.md`, `/.octon/octon.yml`, ingress docs | Modify `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`; modify docs to generated/derived references; add generated docs under `/.octon/generated/cognition/architecture/**` | `octon architecture validate-topology-registry`; CI `architecture-conformance.yml` | One machine-readable topology/authority registry governs class roots, canonical paths, non-authority surfaces, promotion boundaries, and runtime-facing generated outputs | Registry diff, generated-doc receipt, drift report showing zero hand-maintained contradictions |
| D-002 | Authorization-boundary coverage not fully proven | `execution-authorization-v1.md`, `execution-request-v3.schema.json`, runtime CLI, prior evaluation | Create `/.octon/framework/engine/runtime/spec/material-path-inventory-v1.yml`; create `/.octon/framework/engine/runtime/tests/authorization_boundary/**`; modify runtime modules to call central gateway | `octon runtime prove-authorization-boundary`; CI protected gate | 100% of material side-effect paths require GrantBundle and evidence root before side effects | Coverage receipt, negative bypass test report, hard-enforce CI artifact retained under evidence |
| D-003 | Authority engine too monolithic | `/.octon/framework/engine/runtime/crates/authority_engine/**`; prior evaluation | Refactor into `request/`, `support_targets/`, `risk/`, `mission/`, `capability/`, `rollback/`, `budget/`, `egress/`, `decision/`, `receipts/`, `evidence/`, `finalize/` modules | Rust unit/integration tests; architecture module-boundary lint | Each stable authority concern has module-local tests and no module can emit side effects without final gateway | Refactor decision record, module map, test coverage receipt |
| D-004 | Evidence durability and completeness ambiguous | `/.octon/framework/constitution/obligations/evidence.yml`, `/.octon/state/evidence/**`, CI artifact retention | Create `/.octon/framework/engine/runtime/spec/evidence-store-v1.md`; create `/.octon/framework/constitution/contracts/evidence-store-v1.schema.json`; create `octon evidence verify` | `octon evidence verify --run-id`; CI evidence completeness gate | Every consequential run has retained, content-addressed evidence sufficient to generate RunCard, HarnessCard refs, replay, denial/disclosure bundles | Evidence-store conformance report; sample run proof bundle; RunCard from retained evidence |
| D-005 | Promotion semantics allow quiet authority | Bootstrap direct findings-to-context path; generated/input non-authority doctrine | Create `/.octon/framework/constitution/contracts/promotion-v1.schema.json`; create `/.octon/framework/cognition/_meta/architecture/promotion-boundaries.yml`; modify bootstrap/ingress docs | `octon promotion validate`; architecture conformance | No `inputs/**` or `generated/**` material is consumed by runtime/policy or moved into `instance/**`/`state/control/**` without promotion receipt | Promotion receipt fixtures and negative tests |
| D-006 | Run lifecycle not formalized as state machine | runtime README run lifecycle, run commands, execution authorization spec, mission policy | Create `/.octon/framework/engine/runtime/spec/run-lifecycle-state-machine-v1.md`; create `run-lifecycle-v1.schema.json`; bind runtime transitions | Runtime transition tests; `octon run validate-lifecycle` | All run transitions are explicit, validated, evidence-bound, support-aware, and reversible/compensable as declared | Lifecycle conformance report with positive/negative transitions |
| D-007 | Support-target claims not proof-backed enough | `support-targets.yml`, evidence obligations, bootstrap support envelope | Add `/.octon/instance/governance/support-target-proofs/**`; add `/.octon/framework/assurance/support-target-conformance/**` | `octon support prove`; CI support claim gate | Each live support tuple has conformance suite, live scenario, denied scenario, evidence completeness check, and disclosure artifact | SupportCard, proof bundle, scenario replay |
| D-008 | Active architecture vocabulary too noisy | README/spec/bootstrap/START/wave/cutover/proposal-lineage terms | Relocate historical material to `/.octon/instance/cognition/decisions/**` and `/.octon/state/evidence/migration/**`; simplify active docs | Doc lint for active-doc vocabulary; generated glossary | Active operator docs explain authority, execution, evidence, support, mission/run, grant, pack/adapter without historical cutover noise | Diff showing relocation; generated glossary receipt |
| D-009 | Operator-grade read models missing | CLI commands exist; generated non-authority; operator ergonomics low score | Add `/.octon/framework/observability/read-models/operator-views-v1.md`; generate `/.octon/generated/operator/**`; add CLI `octon operator status`/`octon run card` | View consistency validator | Operator views are generated-only, fresh, link to canonical authority/evidence, and show mission/run/grant/evidence/support/readiness state | Sample operator dashboard output and freshness receipt |
| D-010 | Architecture self-validation incomplete | Many validators exist but no full invariant suite | Add `/.octon/framework/assurance/architecture-self-validation/**`; extend `.github/workflows/architecture-conformance.yml` | `octon architecture self-validate` | Self-validation fails on generated authority, input direct-deps, illegal overlays, unsupported support claims, stale generated/effective outputs, docs/runtime mismatch | CI pass with injected negative fixture results |


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/resources/decision-record-plan.md

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


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/resources/evidence-plan.md

# Evidence Plan

proposal_id: `octon-architecture-10of10-remediation`  
resource_role: retained evidence and proof-plane design  
status: non-authoritative proposal resource under `inputs/**`

---

## 1. Evidence thesis

A 10/10 Octon architecture must make evidence complete and durable by construction. Evidence cannot be an afterthought, a generated summary, or a temporary CI artifact. CI artifacts may transport evidence, but canonical retained evidence must live under declared evidence roots or a declared retained evidence backend whose receipts are referenced from those roots.

Target invariant:

> Every consequential run, support claim, adapter admission, promotion, denial, runtime closeout, and disclosure can be reconstructed from retained evidence without trusting chat history, generated summaries, host UI comments, or temporary CI artifacts.

---

## 2. Evidence to retain

| Evidence class | Required content | Canonical path / target |
|---|---|---|
| Run start receipt | request id, run id, mission id if any, support tuple, context pack, risk tier, rollback plan, grant state | `/.octon/state/evidence/runs/<run-id>/receipts/start.json` |
| GrantBundle receipt | authorization decision, grant id, reason codes, capabilities, scope, expiry, support tuple | `/.octon/state/evidence/control/execution/grants/<grant-id>.json` |
| Denial/stage receipt | denial/stage reason codes, missing authority/proof/support/evidence, requested path | `/.octon/state/evidence/runs/<run-id>/denials/**` |
| Checkpoint receipt | stage id, checkpoint id, file hashes, command outputs, tool invocations, rollback posture | `/.octon/state/evidence/runs/<run-id>/checkpoints/**` |
| Verification receipt | tests/checks run, result, environment, command, hash of output | `/.octon/state/evidence/runs/<run-id>/verification/**` |
| Replay manifest | replay inputs, file hashes, commands, runtime version, adapter versions, evidence refs | `/.octon/state/evidence/runs/<run-id>/replay/manifest.json` |
| RunCard source bundle | retained evidence sufficient to generate non-authoritative RunCard | `/.octon/state/evidence/runs/<run-id>/disclosure/runcard-source.json` |
| HarnessCard source bundle | runtime, support, policy, model, adapter, validation refs | `/.octon/state/evidence/validation/harnesscard/**` |
| Support proof bundle | conformance suite, live scenario, denied scenario, evidence completeness result, disclosure | `/.octon/state/evidence/validation/support-targets/<tuple-id>/**` |
| Promotion receipt | source path, target path, approver, validation result, evidence hash, authority class | `/.octon/state/evidence/control/promotions/<promotion-id>.json` |
| Publication receipt | generated/effective output, source authority hash, generation lock, freshness, target path | `/.octon/state/evidence/validation/publication/<publication-id>.json` |
| Architecture self-validation receipt | invariant suite run, pass/fail, negative fixture results | `/.octon/state/evidence/validation/architecture/<run-id>.json` |

---

## 3. What can remain transport/projection only

The following may be useful but must not be treated as canonical retained evidence unless copied/hashed/registered into a retained evidence root:

- GitHub Actions uploaded artifacts;
- PR comments;
- check-run annotations;
- issue comments;
- chat transcripts;
- IDE messages;
- generated summaries;
- local terminal scrollback;
- external dashboard cards;
- model memory;
- temporary worktree logs.

Transport artifacts may include pointers to retained evidence. They must not replace retained evidence.

---

## 4. Evidence store contract

Create:

- `/.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `/.octon/framework/constitution/contracts/evidence-store-v1.schema.json`
- `/.octon/framework/assurance/evidence/evidence-store-conformance.yml`

Minimum contract requirements:

1. append-oriented writes;
2. content hash per artifact;
3. run id / mission id binding where applicable;
4. support tuple binding where applicable;
5. retention class (`ephemeral`, `retained-local`, `retained-external`, `immutable-external`);
6. generation/publication relationship for generated views;
7. replay pointer validity;
8. tamper detection at closeout;
9. evidence completeness validator compatibility;
10. disclosure bundle assembly compatibility.

---

## 5. RunCard assembly

A RunCard is generated, non-authoritative, and rebuilt from retained evidence. It must include:

- run id and mission id;
- objective;
- initiating authority;
- support tuple;
- requested and admitted capabilities;
- grant/deny/stage decision;
- risk tier;
- rollback posture;
- commands/tool invocations;
- files changed;
- tests/verifications run;
- interventions;
- evidence completeness status;
- replay pointer;
- closeout disposition.

The RunCard must link to canonical evidence, not become canonical evidence itself.

---

## 6. HarnessCard assembly

A HarnessCard is generated, non-authoritative, and rebuilt from retained evidence plus authored authority. It must include:

- constitutional version / commit;
- runtime version;
- support targets;
- admitted adapters;
- capability packs;
- policy packs;
- validation suite status;
- support-target proof status;
- known exclusions;
- evidence-store conformance status;
- runtime/docs consistency status.

---

## 7. Denial bundle assembly

A denial bundle must include:

- request;
- missing/invalid authority;
- denial reason codes;
- support-target decision;
- rollback/evidence context;
- operator-readable explanation;
- remediation hint;
- negative test reference when applicable.

---

## 8. Disclosure bundle assembly

A disclosure bundle must include:

- RunCard;
- evidence completeness report;
- retained evidence index;
- support envelope;
- hidden human intervention disclosure;
- generated/read-model disclaimers;
- excluded surfaces and unsupported claims;
- replay manifest;
- unresolved risks.

---

## 9. Retention expectations

| Evidence | Minimum retention |
|---|---|
| consequential run receipts | repo lifetime or explicit retention policy |
| support-target proof bundles | until support tuple is retired plus audit window |
| promotion receipts | repo lifetime or until target authority is retired plus audit window |
| publication receipts | while generated/effective output exists plus audit window |
| CI transport artifacts | may be short-lived if retained evidence exists |
| operator read models | rebuildable, no retention obligation as authority |

---

## 10. Proof completeness rules

A run cannot close as `closed` unless:

1. start receipt exists;
2. grant/deny/stage/escalation receipt exists;
3. support tuple is resolved;
4. evidence root is bound;
5. rollback posture is recorded;
6. verification status is recorded;
7. interventions are logged or explicitly absent;
8. generated views are not required as evidence;
9. RunCard source bundle is complete;
10. replay manifest exists or run explicitly declares non-replayable with approved reason.


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/resources/full-architectural-evaluation.md

# Full Architectural Evaluation Resource

proposal_id: `octon-architecture-10of10-remediation`  
resource_role: mandatory analytical basis  
source_basis: prior architecture evaluation in this conversation, preserved as a review artifact  
status: non-authoritative proposal resource while under `inputs/**`

---

# 1. Executive judgment

**Overall architecture score: 7.1 / 10.**  
**Confidence: medium-high for repository structure and declared architecture; medium for implemented runtime enforcement because the public repository surfaces were inspected but the runtime was not executed locally.**  
**Severity judgment: moderate restructuring, not architectural re-foundation.**

Octon’s architecture is genuinely strong in its authority model, governance posture, class-root separation, support-envelope realism, and mission/run conceptual model. The core architectural thesis is not superficial. The repository is not merely a prompt bundle; it is organized around a serious constitutional control-plane architecture.

But Octon is not yet target-state-grade. Its current architecture has three main limitations:

1. **The authority/governance model is stronger than the demonstrated runtime enforcement model.** The repo contains an execution authorization contract, schemas, CLI surfaces, Rust runtime crates, CI gates, and policy engines, but the public architecture still relies heavily on specs, YAML contracts, scripts, and generated/CI projections. It is not yet obviously an end-to-end, hardened, easily inspectable runtime system.

2. **The information architecture is coherent but too elaborate and too duplicated.** The same structural truth is repeated across `/.octon/README.md`, `/.octon/framework/cognition/_meta/architecture/specification.md`, `/.octon/instance/bootstrap/START.md`, `/.octon/octon.yml`, constitutional files, manifests, and support-target declarations. That makes the design navigable after study, but brittle under evolution.

3. **The architecture lacks a sufficiently simple operator-facing target shape.** It has run roots, missions, evidence roots, support tuples, fail-closed rules, adapters, overlays, service contracts, skills, observability, lab, assurance, generated effective views, state/control/evidence roots, and CI gates. Those are mostly justifiable. But the current system does not yet present a compact operating model that a serious operator can use to predict behavior without reading a constitutional map.

The right conclusion is:

> Octon’s architecture is directionally correct and unusually sophisticated, but it needs focused consolidation, runtime hardening, proof automation, and simplification before it deserves a 9-10 score. It does not need a new foundation; it needs the current foundation made executable, testable, legible, and less repetitive.

---

# 2. Current architectural reality

## What Octon is, in reality, today

Octon is currently a **repo-native constitutional engineering harness with an emerging governed runtime**.

The actual architecture consists of five primary classes of surfaces:

| Surface type | Current role |
|---|---|
| Authored framework authority | `/.octon/framework/**`, especially `framework/constitution/**`, runtime contracts, capabilities, assurance, lab, observability, orchestration, and engine/runtime. |
| Repo-specific authored authority | `/.octon/instance/**`, including ingress, manifest, governance, support targets, locality, missions, repo-specific context, and capabilities. |
| Operational state/control/evidence | `/.octon/state/**`, split into continuity, control, and evidence. |
| Generated read/effective models | `/.octon/generated/**`, explicitly rebuildable and non-authoritative. |
| Inputs/proposals/additive material | `/.octon/inputs/**`, explicitly non-authoritative until promoted through authored activation chains. |

The top-level `/.octon/README.md` is explicit: `.octon/` is the single authoritative super-root; only `framework/**` and `instance/**` are authored authority; `inputs/**` never participate directly in runtime or policy decisions; `state/**` stores continuity/evidence/control truth; and `generated/**` is rebuildable output only. This is one of the strongest parts of the architecture.

The umbrella architecture specification reinforces the same invariants: the canonical class roots are `framework`, `instance`, `inputs`, `state`, and `generated`; generated artifacts are never source of truth; raw inputs must not become direct runtime or policy dependencies; material execution must pass through the engine-owned `authorize_execution(...)` boundary; labels/comments/checks are non-authoritative projections; and autonomous runtime paths must not silently fall back to mission-less execution.

## Actual vs emergent vs aspirational architecture

### Actual architecture

These are present and structurally real today:

- Five-class super-root information architecture: `framework`, `instance`, `inputs`, `state`, `generated`.
- Constitutional kernel under `/.octon/framework/constitution/**`.
- Explicit normative precedence where external obligations and live revocations outrank the constitutional kernel, repo governance, run artifacts, missions, contracts, and lower informational layers.
- Fail-closed obligations with default route `DENY`.
- Evidence obligations with retained evidence roots.
- Support-target declaration with live, stage-only, and non-live support surfaces.
- Overlay-point registry limiting where instance overlays may occur.
- Runtime source tree with engine runtime crates, CLI surfaces, adapters, specs, launchers, and packaging rules.
- Service and skill domains with manifests, validators, deny-by-default rules, and allowed-tool scoping.
- CI workflows enforcing deny-by-default gates, AI review gates, PR autonomy policy, architecture conformance, runtime binaries, skills validation, and related checks.

The constitutional charter states that Octon is a Constitutional Engineering Harness whose execution core is a Governed Agent Runtime, that live support is bounded by `/.octon/instance/governance/support-targets.yml`, and that consequential autonomous engineering work must be scoped, authorized, fail-closed, observable, reviewable, and recoverable.

### Emergent architecture

These are partially implemented, but not yet proven enough to grade as target-state-complete:

- **Execution authorization as a universal runtime boundary.** The contract exists and the CLI imports `authorize_execution`, but public proof that every material path is impossible to bypass is not yet obvious from the inspected surfaces.
- **Mission-scoped reversible autonomy.** The mission/run model is well designed, and mission policies are rich, but this still looks like an emerging operating model rather than a fully mature long-running runtime.
- **RunCards, HarnessCards, replay, and disclosure.** Evidence obligations and CLI commands exist, but operator-grade artifacts and end-to-end proof bundles need stronger surfacing.
- **Runtime packaging and deployability.** The runtime README describes launchers, release targets, source fallback, strict packaging mode, and CLI surfaces, but the productized installation/runtime story is still architecturally rough.
- **Adapter discipline.** The adapter manifests are strong and non-authoritative, but broader adapter support remains stage-only or non-live in the support matrix.

### Aspirational architecture

These are not yet safe to treat as fully real:

- Broad governed frontier-model execution.
- Browser/API/GitHub/Studio control planes as fully supported live surfaces.
- Mature always-on autonomous mission operation.
- Complete proof-plane automation.
- Rich operator UX.
- Generalized pack ecosystem.
- Fully self-orienting, self-improving repo runtime.
- Enterprise-grade multi-operator governance.

The repo itself is appropriately conservative: the bootstrap file says the currently proved live consequential envelope is the retained `MT-B / WT-2 / LT-REF / LOC-EN` tuple using the `repo-shell` host adapter and `repo-local-governed` model adapter; broader adapter coverage remains architectural intent until proof and support-target publication promote it into a live claim.

---

# 3. Target-state comparison

The strongest plausible target-state for Octon is:

> A repo-native governed autonomy runtime where every consequential agent action is authorized, support-bounded, reversible or explicitly compensable, evidence-retained, replayable, inspectable, and governed by a small set of stable canonical contracts.

Against that target, Octon is architecturally promising but not complete.

The ideal target-state architecture would have:

1. A small constitutional kernel that defines authority, precedence, fail-closed rules, evidence obligations, generated/read-model status, and support claims.
2. A runtime enforcement kernel that makes bypassing authorization structurally difficult or impossible.
3. A normalized state machine for missions, runs, stage attempts, approvals, exceptions, revocations, checkpoints, rollback posture, replay, and closeout.
4. A proof plane that automatically emits durable receipts, RunCards, HarnessCards, replay bundles, denial bundles, and support-claim evidence.
5. A compact operator interface over the above, so users can see what is active, blocked, approved, denied, staged, or recoverable.
6. A validator suite that prevents architectural drift: generated artifacts becoming authoritative, host projections minting authority, stale effective outputs, unsupported support claims, invalid overlays, missing evidence, or runtime/docs mismatch.
7. A pack/adapter lifecycle that supports extensibility without turning Octon into an unsafe plugin swamp.
8. A durable evidence store where retained evidence is not merely a temporary CI artifact or generated convenience file.

Octon is unusually strong on context and constraint declarations, but weaker on visible convergence: proof automation, end-to-end benchmarks, and runtime enforcement coverage are not yet as strong as the constitutional model.

---

# 4. Architecture scorecard

| Dimension | Score | Assessment |
|---|---:|---|
| Architectural clarity | 7.0 | The architecture is explicit and deeply documented. The limiting factor is volume and repetition: many surfaces restate topology, authority, support, and run models. Clear after study; not immediately clear. |
| Conceptual coherence | 8.1 | The core concepts reinforce each other: constitutional kernel, class roots, fail-closed obligations, support targets, mission/run split, generated non-authority. The system has a real worldview. |
| Structural integrity | 7.8 | The class-root model is strong, and placement rules are well specified. Integrity is weakened by many transitional/cutover references and repeated canonical path lists. |
| Separation of concerns | 8.3 | Authored authority, generated projections, state/control/evidence, and inputs are well separated. The `state/**` split into continuity/evidence/control is particularly good. |
| Authority-model correctness | 8.6 | This is Octon’s strongest area. Generated artifacts, raw inputs, host UI, chat, comments, labels, and checks are explicitly denied authority. |
| Governance-model strength | 8.0 | Fail-closed rules, evidence obligations, support targets, exclusions, overlays, and policies are first-class. The limiting factor is enforcement proof and operator usability. |
| Runtime architecture quality | 6.4 | There is a real Rust runtime workspace, CLI, specs, adapters, policy engine, authority engine, services, and run-first surfaces. But runtime maturity is harder to verify than governance intent. |
| Maintainability | 6.1 | Strong structure helps maintenance, but the system is document-heavy, path-heavy, and likely drift-prone. The authority engine implementation is large/monolithic enough to be a maintainability concern. |
| Evolvability | 7.5 | Overlay points, adapters, support targets, capability packs, services, skills, and profile-driven portability support evolution. Complexity and duplication create drag. |
| Scalability | 6.8 | Conceptually scalable for more missions/adapters/packs. Operational scaling is less proven: runtime persistence, evidence storage, concurrency, long-running workloads, and UX still need hardening. |
| Reliability | 6.3 | Deny-by-default posture and CI gates help. But reliability depends on runtime enforcement coverage, durable evidence, replay, rollback, and operator visibility that are still emerging. |
| Recoverability / reversibility | 7.0 | Rollback posture, run roots, checkpoints, replay pointers, revocations, exceptions, mission policies, and recovery windows are architecturally present. Practical recovery demos/proofs need to be stronger. |
| Observability / inspectability | 6.7 | Observability has an authored domain for measurement, intervention accounting, telemetry, drift incidents, failure taxonomy, and report bundles. It is structurally present but still reads more like a taxonomy than a mature operating surface. |
| Evidence and auditability | 7.6 | Evidence roots are well classified, append-oriented, and distinguished from generated output. Evidence obligations are detailed. The gap is automated completeness and durable user-facing proof. |
| Portability / adapter discipline | 7.4 | Replaceable non-authoritative host/model adapters and profile-driven portability are strong. The live support envelope is intentionally narrow, which is good governance but limits practical portability today. |
| Extensibility | 7.7 | Skills, services, overlays, capability packs, adapters, and extensions give Octon a serious extension model. The limiting factor is lifecycle simplicity and safety of pack promotion/activation. |
| Complexity management | 5.6 | This is the weakest core dimension. Much complexity is load-bearing, but too much is exposed at once. The architecture needs consolidation and sharper hierarchy. |
| Boundary discipline | 8.2 | Boundary discipline is excellent in principle: host adapters cannot widen authority; generated outputs remain read models; overlays are restricted; support claims are bounded. |
| Implementation consistency with stated architecture | 6.8 | Many implementation surfaces align: CLI, runtime crates, CI gates, services, validators, support targets. But the docs/specs are ahead of the publicly visible runtime/proof plane. |
| Fitness for long-running governed agentic work | 7.4 | The mission/run model, evidence model, support targets, and fail-closed policy are highly relevant. The missing pieces are polished run lifecycle UX, durable proof bundles, concurrency, and recovery demonstrations. |
| Support-matrix realism | 8.5 | The architecture is admirably honest about what is live, stage-only, and unsupported. This is a real strength. |
| Operator ergonomics | 5.2 | CLI commands exist, and Studio is mentioned, but the operator experience is not yet architecture-grade. The system still requires too much constitutional knowledge to operate confidently. |
| Failure isolation | 6.8 | Worktrees, run roots, checkpoints, stage attempts, support tuples, and deny routes are directionally strong. Isolation is not yet as explicit as the authority model. |
| Deployment practicality | 5.8 | Packaging contracts and launchers exist, but installability, binary distribution, source fallback behavior, and support matrices need product-grade hardening. |
| Policy enforcement quality | 7.0 | CI and runtime policy hooks are real. The deny-by-default workflow validates strict policy, engine capability boundaries, and protected execution posture. But enforcement needs clearer full-path coverage. |
| Generated-vs-authored discipline | 8.7 | This is elite by current agent-harness standards. Generated surfaces are explicitly non-authoritative and freshness/receipt-bound when runtime-facing. |
| Repo legibility for humans and agents | 6.4 | The repo is highly structured but hard to absorb. Several YAML/JSON authority surfaces appear as dense raw files; even if machine-parseable, they are diff- and review-hostile. |
| Testability / validation surface quality | 7.2 | Many validators and workflows exist, including skills/services validation, overlay validation, capability/engine consistency, protected execution posture, and runtime checks. The gap is unified evidence of coverage. |
| Anti-entropy mechanisms | 6.7 | The architecture anticipates drift through validation, lab, evidence, decisions, generated/effective views, and support declarations. It still needs stronger automated convergence loops. |
| Mission / mode / run model quality | 7.8 | Mission as continuity container and run as atomic execution unit is a strong architectural choice. It should survive into target-state. |

---

# 5. Overall architecture score

## Overall: 7.1 / 10

This is a strong architecture with serious target-state potential, not a weak architecture wrapped in sophisticated language.

But a 7.1 is appropriate because Octon currently has a gap between:

- the precision of the constitutional architecture, and
- the visible maturity of the executable runtime, proof plane, operator surface, and simplification mechanisms.

A 10/10 architecture would be smaller at the conceptual center, harder to bypass at runtime, easier to validate end-to-end, and easier for an operator to inspect. Octon is not there yet.

---

# 6. What Octon is doing especially well

## A. The source-of-truth model is unusually good

The class-root model is not ornamental. It correctly separates authored authority, non-authoritative inputs, mutable state/control/evidence, generated projections, and runtime-facing effective outputs.

This directly addresses a real failure mode in agent systems: generated summaries, chat state, host UI affordances, or stale docs accidentally becoming control-plane truth. Octon’s answer is structurally clear: they may guide, mirror, or project, but they do not mint authority.

## B. The constitutional kernel is not just branding

The charter is load-bearing. It defines non-goals, non-negotiables, support claims, authority routing, adapter non-authority, evidence obligations, support targets, and final disclosure requirements. It also explicitly rejects hidden human intervention and silent authority widening.

That is architecturally meaningful because it creates a stable top-level regime against which lower surfaces can be judged.

## C. Fail-closed behavior is concrete

`/.octon/framework/constitution/obligations/fail-closed.yml` has specific cases: raw inputs as policy dependencies, generated artifacts as source of truth, host UI/chat as authority, ambiguous ownership, missing grants, stale instruction manifests, missing mission context, missing support-targets, invalid run contracts, missing evidence, unsupported claims, adapter authority widening, and prohibited action classes.

## D. Support-target honesty is excellent

Most agent systems overclaim. Octon declares a finite live support universe and marks broader surfaces as stage-only or non-live. That is architecturally mature. It prevents capability theater.

## E. Mission/run separation is a strong long-horizon model

The mission model is well framed: missions are durable continuity containers; consequential runs bind per-run objective contracts under `state/control/execution/runs/<run-id>/**`; mission-local control truth, evidence, generated views, and continuity each have distinct homes.

This is the right architecture for long-running agentic work.

## F. Runtime surfaces are real enough to matter

The runtime is not imaginary. The engine runtime has launchers, specs, adapters, policies, WIT contracts, runtime crates, packaging contracts, run-first CLI surfaces, orchestration lookup/summary, incident closure readiness, Studio, and a lifecycle model that binds run control/evidence roots before side effects.

## G. Services and skills have real contract discipline

Services have typed contracts, manifest/runtime registries, scoped permissions, deny-by-default guardrails, explicit rejection of bare shell/write, exception leases, and validation preflight through the policy engine.

Skills have progressive disclosure, manifests, registries, I/O mappings, single-source allowed-tools frontmatter, validation scripts, scoped write permissions, deny-by-default rules, and host projections.

## H. CI gates are architecturally aligned

The repo includes workflows for deny-by-default gates, architecture conformance, AI review, PR autonomy, runtime binaries, skills validation, smoke tests, and other governance-related checks.

---

# 7. What is structurally weak, missing, or misframed

## A. The architecture is over-exposed

Octon exposes too much internal conceptual machinery at the same level. Many concepts are real and useful, but the hierarchy is not yet sharp enough. A target-state architecture should let an operator or contributor understand Octon in three layers:

1. Authority: what is allowed.
2. Execution: what runs.
3. Evidence: what proves it.

Octon has these layers, but they are buried inside a wider vocabulary cloud.

## B. The same truth is repeated in too many places

The super-root topology and canonical path matrix appear in multiple locations: `/.octon/README.md`, the umbrella specification, `/.octon/instance/bootstrap/START.md`, `/.octon/octon.yml`, ingress docs, and constitutional references.

A target-state system should have one machine-readable canonical topology registry, generated human docs, validators that prevent drift, and no repeated hand-maintained canonical path lists.

## C. Runtime enforcement is not yet visibly as strong as runtime specification

The execution authorization spec is excellent, but the implementation must prove that every material execution path is impossible to run without the same enforcement boundary.

## D. Evidence exists as a class, but proof is not yet operator-grade

The evidence model is strong on paper. A target-state architecture needs evidence that is automatically complete, easy to inspect, content-addressably durable where needed, tied to support claims, linked to run/mission state, replayable, and retained beyond ephemeral CI artifact windows.

## E. Some authority-promotion paths are too loose

The bootstrap file says project findings flow from `ideation/projects/` directly to `instance/cognition/context/shared/` without a separate promotion step. This weakens Octon’s otherwise excellent generated/input promotion discipline.

## F. Runtime code may be too centralized

The authority engine implementation is large and central. Authority routing should be highly auditable. A large monolithic implementation makes it harder to reason about policy boundaries, test slices, failure modes, denial reason generation, support-target routing, and run/evidence binding.

## G. Operator ergonomics is architecturally underdeveloped

In a governed runtime, operator ergonomics is architecture. The human must understand what is running, why it is allowed, why it is blocked, what evidence exists, whether rollback is available, whether support is admitted, what changed, and whether the mission is healthy.

---

# 8. Severity judgment: how much change is actually needed

## Overall severity: moderate restructuring

Octon does not need a foundational architectural rethink. The following should survive largely intact:

- super-root/class-root model,
- constitutional kernel,
- normative/epistemic precedence,
- generated non-authority,
- raw-input non-authority,
- fail-closed obligations,
- evidence obligations,
- support-target matrix,
- mission/run split,
- adapter non-authority,
- overlay-point registry,
- state/control/evidence split.

But Octon does need moderate restructuring in four areas:

| Area | Required severity | Why |
|---|---|---|
| Runtime enforcement | Focused gap-closing to moderate restructuring | The enforcement boundary must be proven and hard to bypass. |
| Contract/information architecture | Moderate restructuring | Too much duplicate path/authority truth across docs. |
| Evidence/proof plane | Moderate restructuring | Evidence needs durable, automated, operator-grade proof bundles. |
| Operator surface | Focused gap-closing | The architecture needs a primary human operating model. |
| Runtime code decomposition | Moderate restructuring | Authority/policy code must be smaller and more auditable. |
| Generated/input promotion lifecycle | Focused correction | Any path into `instance/**` authority needs explicit promotion semantics. |

No area obviously requires re-foundation. The kernel is sound. The work is consolidation, enforcement, and operationalization.

---

# 9. What prevents a 10/10

Octon is not a 10/10 because:

1. The architecture is more complete as a constitutional map than as a proven runtime.
2. It has too many canonical surfaces.
3. It exposes too much complexity to the operator.
4. Runtime code auditability is not yet ideal.
5. Evidence retention and proof completeness are not yet visibly hardened.
6. Productized deployment is immature.
7. Some transitional/cutover language remains in the active architecture.

---

# 10. Exact changes required to reach a 10/10

## Mandatory architectural corrections

### 1. Create a single canonical topology/authority registry

Collapse repeated topology/source-of-truth statements into one canonical machine-readable registry. Because the live repository already identifies `/.octon/framework/cognition/_meta/architecture/contract-registry.yml` as the machine-readable execution/path/policy invariant registry, the remediation should extend and harden that existing surface rather than introduce a rival registry.

### 2. Prove total authorization-boundary coverage

Add tests and static checks that assert every material side-effect path calls the same authorization gateway.

Required proof artifacts:

- call-path coverage report,
- workflow-stage enforcement tests,
- service invocation enforcement tests,
- executor launch enforcement tests,
- repo mutation enforcement tests,
- publication enforcement tests,
- protected CI enforcement tests,
- adapter projection enforcement tests,
- negative tests showing direct bypass fails.

The target invariant should be:

> No side-effect-capable code path can execute without a GrantBundle, receipt obligation, support-target resolution, and evidence root binding.

### 3. Decompose the authority engine

Break authority runtime logic into auditable modules around stable concepts:

- request normalization,
- support-target resolution,
- ownership resolution,
- risk/materiality,
- capability admission,
- rollback/reversibility,
- budget/egress,
- mission/run binding,
- grant/receipt emission,
- denial/stage/escalation reason coding,
- evidence binding,
- finalization.

### 4. Make evidence durable and complete by construction

Define a retained evidence backend/store contract specifying append-only semantics, content hashes, retention class, local vs external immutable storage, CI artifact limitations, replay pointer validity, support-claim linkage, RunCard/HarnessCard generation, and evidence completeness validation.

### 5. Normalize promotion semantics

Every movement from `inputs/**` or `generated/**` into `instance/**` or `state/control/**` should require a promotion/activation receipt.

### 6. Define the run lifecycle as a formal state machine

Create a canonical run lifecycle spec and transition contract.

### 7. Make support-target admission executable

For each admitted tuple, require conformance suite, proof bundle, live scenario, denied unsupported scenario, evidence completeness test, and disclosure artifact.

### 8. Reduce active architecture vocabulary

Move historical cutover/wave/proposal-lineage material out of active operational docs and into decision/evidence history.

### 9. Build operator-grade read models

Generated read models are non-authoritative, but they are essential for usability: active missions, pending runs, denied/staged actions, grant bundles, rollback posture, evidence completeness, support envelope, open interventions, closeout readiness, stale generated/effective outputs, and adapter status.

### 10. Add architecture-conformance tests for the architecture itself

The architecture should test itself: generated never referenced as source of truth, inputs never used as runtime/policy dependencies, host projections never mint authority, state/evidence never used as active control unless explicitly in `state/control`, overlays only exist at declared enabled overlay points, support claims reference admitted tuples, runtime-facing generated/effective outputs have fresh generation locks and receipts, and dense authority files are normalized/formatted for reviewability.

---

# 11. Priority-ordered improvement sequence

1. Authorization-boundary proof.
2. Evidence completeness validator.
3. Contract de-duplication.
4. Authority engine decomposition.
5. Operator run dashboard.
6. Support-target proof packs.
7. Promotion lifecycle hardening.
8. Simplify active docs.
9. Packaging hardening.
10. Long-running mission demonstration.

---

# 12. What should be preserved unchanged

These are strong enough that changing them would likely make Octon worse:

1. Five-class super-root model: `framework`, `instance`, `inputs`, `state`, `generated`.
2. Authored-authority limitation: only `framework/**` and `instance/**` as authored authority.
3. Generated non-authority.
4. Raw inputs non-authority.
5. Constitutional kernel placement.
6. Normative precedence model.
7. Fail-closed obligations.
8. Evidence root separation.
9. Support-target boundedness.
10. Mission/run separation.
11. Adapter non-authority.
12. Overlay-point restriction.
13. Services/skills deny-by-default discipline.

---

# 13. What should be simplified, relocated, or removed

## Simplify

- The support-target taxonomy presentation.
- The active operator-facing vocabulary.
- The read order and bootstrap path.
- The number of documents that restate topology.
- The profile/wave/cutover language in active docs.
- The generated/effective/publication receipt explanation.

## Relocate

- Historical wave/cutover/proposal-lineage explanations should live in `instance/cognition/decisions/**` or `state/evidence/migration/**`.
- Generated operator summaries should live under `generated/cognition/**`, with links back to canonical authority/evidence.
- CI artifacts should be treated as projections/transport unless retained in the canonical evidence store.

## Remove or de-emphasize

- Any stage-only architecture presented too close to live architecture.
- Any duplicated canonical path inventory not generated from a single source.
- Any direct promotion path into `instance/**` lacking a promotion receipt.
- Any operator-facing docs that require understanding all constitutional layers before the first run.
- Any OS framing that implies Octon owns more runtime surface than it actually does.

---

# 14. Risks of not changing the architecture

1. Governance theater: runtime enforcement and evidence proof fail to catch up to constitutional language.
2. Architectural drift: repeated canonical truth creates contradictions.
3. Operator abandonment: the system remains too hard to use.
4. Evidence insufficiency: recovery, auditability, and support-bound execution remain under-proven.
5. Runtime bypass: any side-effect path that bypasses `authorize_execution` compromises the core architecture.
6. Pack/extension sludge: weak promotion lifecycle creates hidden authority or stale capability expansion.
7. Maintainability collapse: large centralized runtime files and dense policy artifacts become difficult to review safely.

---

# 15. Final verdict

Octon’s architecture is materially above average and in several areas genuinely excellent. The authority model, generated-vs-authored discipline, fail-closed governance, support-target honesty, adapter non-authority, and mission/run separation are all strong architectural choices.

But the current architecture is not yet elite. It is a strong constitutional blueprint with an emerging runtime, not a fully hardened autonomous engineering control plane.

The correct path is not re-foundation. The current foundation should be preserved. The necessary work is:

1. Make the authorization boundary mechanically unavoidable.
2. Make evidence complete and durable by construction.
3. Collapse duplicated topology truth into generated docs from one registry.
4. Decompose the authority/runtime implementation into auditable modules.
5. Give operators simple mission/run/grant/evidence views.
6. Make support-target claims proof-backed rather than merely declared.
7. Harden promotion semantics so generated/input artifacts never become quiet authority.
8. Move historical migration/cutover material out of active architecture paths.

If those changes are made, Octon could plausibly become a 9+ architecture. To deserve a true 10/10, it would need not only the right structure, but also strong proof that the runtime enforces that structure across all consequential execution paths.

**Final score: 7.1 / 10.**  
**Final severity: moderate restructuring, with no foundational architectural rethink required.**


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/resources/rejection-ledger.md

# Rejection Ledger

proposal_id: `octon-architecture-10of10-remediation`  
resource_role: rejected alternatives and rationale  
status: non-authoritative proposal resource under `inputs/**`

---

## 1. Purpose

This ledger records alternatives intentionally rejected by the remediation program so that the target-state does not drift toward attractive but architecture-weak choices.

---

## 2. Rejected alternatives

| ID | Rejected alternative | Reason for rejection | Preserved insight / safer substitute |
|---|---|---|---|
| REJ-001 | Foundational architectural re-write | The prior evaluation found the core foundation sound: class roots, constitutional kernel, fail-closed rules, support targets, mission/run split, generated non-authority, adapter non-authority. A re-foundation would risk discarding strong load-bearing structures. | Moderate restructuring focused on enforcement, proof, consolidation, operator legibility. |
| REJ-002 | Weakening fail-closed posture for adoption speed | Octon’s differentiated value depends on denied/staged behavior when authority, evidence, support, or rollback is missing. | Improve ergonomics and reason-code clarity without weakening default deny. |
| REJ-003 | Treating generated views as authority | Generated views are useful for operator legibility but become dangerous if runtime/policy treats them as truth. | Generated operator views may link to authority/evidence but cannot mint authority. |
| REJ-004 | Broadening support claims before proof | The support-target boundedness is a core strength. Broad claims without conformance evidence create governance theater. | Add support-target proof bundles and stage-only declarations. |
| REJ-005 | Creating a rival control plane | A second control model would collapse Octon’s source-of-truth discipline and create authority ambiguity. | Extend existing `framework/**`, `instance/**`, `state/**`, `generated/**`, `inputs/**` model. |
| REJ-006 | Creating a new topology registry instead of using existing `contract-registry.yml` | The repo already identifies `contract-registry.yml` as machine-readable execution/path/policy invariant registry. A separate registry creates duplication. | Extend `contract-registry.yml` and generate docs from it. |
| REJ-007 | Keeping duplicated topology truth | Repetition is currently useful but drift-prone. | One canonical machine-readable registry plus generated docs and drift validation. |
| REJ-008 | Preserving transitional cutover/wave language in active architecture docs | It makes steady-state operation harder to reason about and increases vocabulary load. | Relocate history to decisions/evidence/migration archives with backlinks. |
| REJ-009 | Letting CI artifacts stand in for retained evidence | CI artifacts are useful transport, but often ephemeral and host-owned. | Retained evidence store contract; CI may upload projections or transport retained bundles. |
| REJ-010 | Turning Octon into a full IDE/OS/cloud platform as part of this remediation | The 10/10 gap is authority/runtime/evidence/validation/operator legibility, not broad ownership of adjacent tooling. | Own authority, authorization, evidence, mission/run control, promotion, support governance; integrate external surfaces through adapters. |
| REJ-011 | Excessive plugin/pack sprawl | Unbounded packs/adapters risk hidden authority and tool sprawl. | Governed pack/admission lifecycle with validation, promotion receipts, and support-target proof. |
| REJ-012 | Hard cutover for all architecture changes | Too risky for runtime and evidence surfaces. | Hybrid bounded cutover: hard for invariants, staged for runtime refactor and operator projections. |
| REJ-013 | Allowing direct `inputs/**` or `generated/**` promotion without receipts | Quiet authority creation violates the architecture. | Promotion/activation contract and receipts. |
| REJ-014 | Making operator views canonical to simplify UX | It would violate generated non-authority and create stale-authority risk. | Operator views remain generated/read-model surfaces with freshness and authority backlinks. |


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/resources/repository-baseline-audit.md

# Repository Baseline Audit

proposal_id: `octon-architecture-10of10-remediation`  
resource_role: repo-grounded current-state baseline  
status: non-authoritative proposal resource under `inputs/**`

---

## 1. Audit scope

This audit covers the current Octon repository architecture as observed through the live repository surfaces that materially shape authority, runtime, governance, continuity, evidence, portability, packaging, and operator-facing control.

Primary source paths reviewed or carried forward from the governing evaluation:

- `/.octon/AGENTS.md`
- `/.octon/instance/ingress/AGENTS.md`
- `/.octon/framework/cognition/_meta/architecture/specification.md`
- `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `/.octon/framework/constitution/**`
- `/.octon/framework/engine/runtime/**`
- `/.octon/framework/capabilities/runtime/services/**`
- `/.octon/framework/capabilities/runtime/skills/**`
- `/.octon/framework/observability/**`
- `/.octon/framework/overlay-points/registry.yml`
- `/.octon/instance/manifest.yml`
- `/.octon/instance/governance/**`
- `/.octon/instance/orchestration/**`
- `/.octon/instance/locality/**`
- `/.octon/instance/governance/support-targets.yml`
- `/.github/workflows/**`
- adjacent `state/**`, `generated/**`, `inputs/**`, assurance, lab, decision, validation, and runtime packaging surfaces.

---

## 2. Authority surfaces

### 2.1 Authored framework authority

Current authoritative framework surfaces include:

- `/.octon/framework/constitution/CHARTER.md`
- `/.octon/framework/constitution/precedence/normative.yml`
- `/.octon/framework/constitution/obligations/fail-closed.yml`
- `/.octon/framework/constitution/obligations/evidence.yml`
- `/.octon/framework/cognition/_meta/architecture/specification.md`
- `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `/.octon/framework/engine/runtime/spec/**`
- `/.octon/framework/engine/runtime/adapters/**`
- `/.octon/framework/capabilities/runtime/services/**`
- `/.octon/framework/capabilities/runtime/skills/**`
- `/.octon/framework/overlay-points/registry.yml`
- `/.octon/framework/observability/**`
- `/.octon/framework/assurance/**`
- `/.octon/framework/lab/**`

Baseline judgment: framework authority is strong, but its canonical invariants are repeated across too many documents.

### 2.2 Authored instance authority

Current instance authority surfaces include:

- `/.octon/instance/manifest.yml`
- `/.octon/instance/ingress/AGENTS.md`
- `/.octon/instance/bootstrap/START.md`
- `/.octon/instance/governance/support-targets.yml`
- `/.octon/instance/governance/policies/**`
- `/.octon/instance/governance/contracts/**`
- `/.octon/instance/orchestration/missions/**`
- `/.octon/instance/locality/**`
- `/.octon/instance/cognition/context/**`
- `/.octon/instance/cognition/decisions/**`

Baseline judgment: instance authority is well separated from framework authority, but the promotion path into instance context needs hardening and receipts.

---

## 3. Generated surfaces

Current generated/read-model surfaces include:

- `/.octon/generated/**`
- `/.octon/generated/effective/**`
- generated operator/read-model projections associated with runtime, architecture, support, and effective state.

Baseline judgment: generated non-authority is one of Octon’s strongest invariants. The target-state must preserve this without weakening it for convenience.

Target remediation: add validators that assert generated surfaces are never referenced as source-of-truth authority and that runtime-facing generated/effective outputs have valid generation locks, publication receipts, and freshness metadata.

---

## 4. State/control/evidence surfaces

### 4.1 State/control

Current operational control surfaces include:

- `/.octon/state/control/**`
- run control roots under `/.octon/state/control/execution/runs/**`
- mission-local control surfaces
- approvals, exceptions, revocations, and lifecycle state.

Baseline judgment: the control root placement is sound, but the formal run lifecycle state machine needs to be canonical and mechanically validated.

### 4.2 State/evidence

Current retained evidence surfaces include:

- `/.octon/state/evidence/runs/**`
- `/.octon/state/evidence/control/execution/**`
- `/.octon/state/evidence/lab/**`
- `/.octon/state/evidence/validation/publication/**`
- replay manifests, receipts, disclosures, decision logs, and validation artifacts.

Baseline judgment: evidence categories are strong, but evidence completeness, durability, and transport-vs-retention distinctions require target-state contracts.

### 4.3 State/continuity

Current continuity surfaces include:

- `/.octon/state/continuity/**`
- mission continuity roots
- handoff and run continuity state.

Baseline judgment: continuity is architecturally appropriate for long-running governed work, but target-state should bind continuity to mission/run lifecycle transitions and evidence completeness.

---

## 5. Runtime surfaces

Current runtime surfaces include:

- `/.octon/framework/engine/runtime/README.md`
- `/.octon/framework/engine/runtime/crates/**`
- `/.octon/framework/engine/runtime/crates/kernel/src/main.rs`
- `/.octon/framework/engine/runtime/crates/authority_engine/**`
- `/.octon/framework/engine/runtime/crates/policy_engine/**`
- `/.octon/framework/engine/runtime/crates/runtime_bus/**`
- `/.octon/framework/engine/runtime/crates/replay_store/**`
- `/.octon/framework/engine/runtime/crates/telemetry_sink/**`
- `/.octon/framework/engine/runtime/crates/wasm_host/**`
- `/.octon/framework/engine/runtime/crates/studio/**`
- `/.octon/framework/engine/runtime/spec/execution-authorization-v1.md`
- `/.octon/framework/engine/runtime/spec/execution-request-v3.schema.json`
- `/.octon/framework/engine/runtime/spec/**`
- `/.octon/framework/engine/runtime/launchers/**`
- `/.octon/framework/engine/runtime/release-targets.yml`
- `/.octon/framework/engine/runtime/packaging/**`
- host/model adapter manifests.

Baseline judgment: runtime is real and directionally aligned, but total enforcement coverage and modularity of authority logic are not yet target-state-grade.

---

## 6. Support-target posture

Current support posture:

- default unsupported route is deny.
- live support universe is bounded and finite.
- admitted live tuple includes `repo-local-governed`, `repo-shell`, `ci-control-plane`, and capability packs such as repo/git/shell/telemetry.
- broader surfaces such as frontier model adapters, GitHub control-plane, Studio control-plane, browser/API control-plane are stage-only or non-live.

Baseline judgment: support-target realism is excellent and should be preserved. Target-state must make admitted support tuples proof-backed, not merely declared.

---

## 7. Runtime proof posture

Current proof posture includes:

- execution authorization spec requiring `authorize_execution(...) -> GrantBundle` before material side effects.
- execution request schema requiring support tuple, rollback plan, risk tier, capability packs, and mission fields for autonomous runs.
- runtime CLI commands for run start/inspect/resume/checkpoint/close/replay/disclose.
- CI workflows for architecture conformance, deny-by-default gates, runtime binaries, skills validation, smoke tests, and protected execution receipts.
- evidence obligations for RunCards, HarnessCards, support claims, behavioral claims, adapter-backed claims, and final disclosure.

Baseline judgment: proof posture is serious but incomplete. The remediation must add call-path coverage, bypass-resistance tests, evidence completeness validation, support-target proof bundles, and durable proof store semantics.

---

## 8. Duplication and drift risks

Known drift risks:

1. topology/source-of-truth rules repeated in multiple docs;
2. support-target semantics repeated between charter, bootstrap, support-targets, runtime specs, and disclosure requirements;
3. generated/effective rules repeated across architecture, bootstrap, and validation surfaces;
4. ingress docs and bootstrap docs contain operational topology that should be generated from a canonical registry;
5. historical cutover/wave/proposal-lineage language remains too close to active operation docs;
6. authority-engine logic appears too centralized for easy review.

Target remediation: promote a single canonical contract registry, generated human docs, architecture self-validation, and runtime/docs consistency checks.

---

## 9. Known architectural debt

| Debt | Type | Severity | Proposed target remedy |
|---|---|---:|---|
| Duplicate topology truth | Design + maintainability | High | Extend `contract-registry.yml`; generate docs; add drift validators. |
| Partial authorization proof | Runtime + proof | Critical | Add material path inventory and bypass-resistance tests. |
| Evidence durability ambiguity | Proof + storage | High | Add retained evidence store contract and validator. |
| Promotion semantics looseness | Governance | High | Add promotion contract and receipts. |
| Monolithic authority implementation | Runtime maintainability | Medium-high | Decompose into auditable modules. |
| Operator view absence | Ergonomics + architecture | Medium-high | Add generated non-authoritative read models and CLI/TUI view contract. |
| Stage-only surfaces near live surfaces | Legibility | Medium | Separate active/live docs from aspirational/stage-only projections. |
| CI artifact retention ambiguity | Evidence | Medium | Distinguish transport artifacts from retained canonical evidence. |

---

## 10. Strong structures worth preserving

Preserve:

- `/.octon/` as the single authoritative super-root.
- five class roots: `framework`, `instance`, `inputs`, `state`, `generated`.
- authored authority limited to `framework/**` and `instance/**`.
- generated as rebuildable non-authoritative read/effective outputs.
- raw inputs as non-authoritative proposals/additive/exploratory material.
- state/control/evidence/continuity split.
- constitutional kernel under `framework/constitution/**`.
- normative precedence and host projection non-authority.
- fail-closed obligations and evidence obligations.
- support-target boundedness.
- mission/run separation.
- adapter non-authority.
- overlay-point restriction and manifest enablement.
- service/skill deny-by-default contract discipline.
- CI-first validation and protected execution posture.


---

FILE: /.octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-remediation/resources/risk-register.md

# Risk Register

proposal_id: `octon-architecture-10of10-remediation`  
resource_role: architectural/runtime/migration risk register  
status: non-authoritative proposal resource under `inputs/**`

---

## Risk scale

| Level | Meaning |
|---|---|
| Critical | Can invalidate the target-state or core constitutional promise. |
| High | Can materially prevent 10/10 readiness. |
| Medium | Can slow adoption or create maintainability/reliability drag. |
| Low | Manageable cleanup or localized risk. |

---

## Register

| ID | Risk | Class | Severity | Likelihood | Impact | Mitigation | Closure evidence |
|---|---|---|---:|---:|---|---|---|
| R-001 | Authorization bypass remains possible through an unregistered material path | Runtime | Critical | Medium | Core governance promise fails | material path inventory, static call-path checks, negative bypass tests, protected CI gate | Authorization coverage receipt with 100% material path coverage |
| R-002 | Contract registry becomes another duplicate source instead of replacing duplication | Architecture | High | Medium | Drift persists | extend existing `contract-registry.yml`; generate docs; deprecate hand-maintained path matrices | drift report showing docs generated or registry-consistent |
| R-003 | Evidence store contract is underspecified | Evidence | High | Medium | RunCards/replay/disclosure cannot be trusted | define schema, conformance suite, retained evidence classes, retention policy | evidence-store conformance receipt |
| R-004 | CI artifacts are mistaken for canonical evidence | Evidence | High | Medium | evidence disappears or becomes unverifiable | label CI artifacts transport-only unless copied/hashed/registered | evidence plan adopted; validation rejects transport-only closeout |
| R-005 | Promotion hardening slows legitimate human edits too much | Governance/UX | Medium | Medium | operators bypass system | distinguish human-authored direct authority edits from generated/input promotion; keep receipts lightweight | promotion UX accepted and negative tests pass |
| R-006 | Authority engine decomposition changes behavior unintentionally | Runtime | High | Medium | regressions in grant/deny logic | golden fixtures before refactor; parity tests; staged cutover | parity report and fixture coverage |
| R-007 | Operator read models accidentally become authority | Boundary | High | Low-Medium | generated non-authority invariant weakens | generated disclaimers, validators, path restrictions, no runtime direct dependency | generated-boundary validation receipt |
| R-008 | Support-target proofing blocks all progress due to excessive proof burden | Support | Medium | Medium | support matrix stagnates | tiered support proof levels; keep stage-only honest | support proof policy with minimal live tuple proof |
| R-009 | Historical cutover relocation removes useful context | Documentation | Low-Medium | Medium | maintainers lose migration trace | archive under decisions/evidence; generate references | relocation index and backlinks |
| R-010 | Architecture self-validation becomes brittle/noisy | Validation | Medium | Medium | false positives reduce trust | fixture-based tests, severity levels, stable schemas | low-flake CI run history |
| R-011 | Runtime packaging strict mode breaks dev workflows | Packaging | Medium | Medium | adoption friction | strict mode for release, source fallback explicitly dev-only with warnings | packaging decision record and tests |
| R-012 | Proposal promoted partially, leaving inconsistent architecture | Migration | High | Medium | mixed old/new semantics | hybrid bounded cutover with gates and rollback | cutover checklist completed with transition receipts |
| R-013 | External integrations push Octon to own too much | Scope | Medium | Medium | complexity bloat | native-vs-integrated boundary: own authority/evidence/control; integrate execution surfaces | scope review and rejection ledger |
| R-014 | Pack/adapter lifecycle remains implicit | Extensibility | Medium | Medium | plugin sprawl or hidden authority | later pack/admission contracts tied to promotion/evidence | pack lifecycle validator in follow-up |
| R-015 | Operator UX remains too weak to make architecture inspectable | Ergonomics | High | Medium | architecture remains hard to trust | generated operator views, CLI/TUI status, RunCard generation | operator view acceptance tests |


---
