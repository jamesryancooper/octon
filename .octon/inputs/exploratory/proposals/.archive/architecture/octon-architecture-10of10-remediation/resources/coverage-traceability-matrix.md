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
