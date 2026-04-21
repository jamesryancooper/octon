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
