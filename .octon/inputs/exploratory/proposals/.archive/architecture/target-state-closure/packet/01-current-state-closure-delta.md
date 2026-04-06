# 01. Current-State Closure Delta

## A. What is already substantively real

### Constitutional kernel
Current reality:
- `/.octon/framework/constitution/**` exists and is treated as the supreme repo-local control regime.
- ingress and super-root docs already bind to it.

Closure consequence:
- preserve it
- stop parallel claim logic from outranking it
- make live status and disclosure derive from it mechanically

### Class-root super-root discipline
Current reality:
- authored authority remains in `framework/**` and `instance/**`
- operational truth and retained evidence remain in `state/**`
- `generated/**` remains derived-only
- `inputs/**` remains non-authoritative

Closure consequence:
- preserve exactly
- continue using it as the base for all cutover work

### Run-first control roots
Current reality:
- `state/control/execution/runs/**` is already canonical for per-run control truth.
- `run-contract.yml`, `run-manifest.yml`, `runtime-state.yml`, rollback posture, stage-attempt roots, checkpoints, and evidence bundle roots are already part of the model.

Closure consequence:
- preserve roots
- unify run-contract lineage
- enforce cross-artifact parity

### First-class authority artifacts
Current reality:
- approvals, grants, leases, revocations, and decision artifacts are already first-class.

Closure consequence:
- preserve family
- normalize quorum
- normalize lease and revocation lifecycle semantics
- ensure support tuple and route are consistent everywhere

### Support-target and adapter architecture
Current reality:
- support-target matrix exists
- host adapters and model adapters exist
- capability packs and admission status exist

Closure consequence:
- preserve design
- add support dossiers and stricter admission/certification logic
- ensure live run bundles cannot contradict support declarations

### Lab and observability
Current reality:
- `framework/lab/**` and `framework/observability/**` are real domains, not just renamed folders.

Closure consequence:
- preserve
- deepen hidden checks, adversarial coverage, replay, and disclosure coupling

### RunCard and HarnessCard
Current reality:
- both exist as real artifacts, not just names.

Closure consequence:
- keep them
- make them generator-only outputs
- eliminate authored optimism from active claim surfaces

## B. What is still closure-blocking

### Empty evidence classifications
Current reality:
- active proof-bundle exemplar runs can still have empty evidence-classification files.

Required fix:
- new evidence-classification v2
- non-empty validator
- closure invalid if any active exemplar run has empty classification

### Contradictory closure truth
Current reality:
- status and claim truth can remain green while exemplar retained evidence contradicts them.

Required fix:
- regenerate all active closure surfaces from canonical validator outputs
- prohibit hand-authored green status

### Superseded wording drift
Current reality:
- stale “global complete” language can persist in active measurement/disclosure artifacts after the release lineage narrowed the claim.

Required fix:
- wording-coherence validator
- release-bundle regeneration from current claim scope
- explicit forbidden phrase list for active artifacts

### Cross-artifact tuple / pack / route mismatch
Current reality:
- DecisionArtifact, Run Manifest, Run Contract, RunCard, support-target matrix, and adapter declarations can disagree.

Required fix:
- cross-artifact consistency validator
- fail closure if any active proof-bundle run has conflicting tuple, pack, route, or status fields

### Split run-contract lineage
Current reality:
- `objective/run-contract-v1` and `runtime/run-contract-v2` both still matter.

Required fix:
- canonical `runtime/run-contract-v3`
- v1 and v2 become shims only
- all live authored and generated surfaces bind v3

### Under-normalized mission authority and quorum
Current reality:
- mission authority is operationally real but not fully normalized at the constitutional contract layer
- quorum is embedded inside mission-autonomy policy

Required fix:
- mission-charter schema
- standalone QuorumPolicy contract family

### Under-normalized lease and revocation lifecycle
Current reality:
- leases and revocations remain set-file semantics

Required fix:
- one-file-per-artifact lifecycle units, or a canonically justified generated-index model
- packet chooses per-artifact normalization

### Incomplete hidden-check / lab / evaluator-independence coverage
Current reality:
- lab exists, but hidden-check governance and evaluator-independence are not yet explicit enough for closure-grade proof.

Required fix:
- hidden-check and adversarial scenario contracts
- evaluator-independence policy and coverage gates

### Residual legacy active-path risk
Current reality:
- orchestrator is the default kernel role, but legacy architect / SOUL surfaces remain too near the active path.

Required fix:
- no-legacy-active-path validator
- demotion to historical shims or delete after cutover

### Incomplete build-to-delete governance
Current reality:
- simplification exists in spirit, but retirement and ablation are not yet institutionally central.

Required fix:
- retirement registry
- ablation receipts
- drift-governed retirement loop

## C. Delta summary

Octon does **not** need a new conceptual architecture.
It needs:

- closure surfaces generated from canonical sources,
- one canonical run-contract family,
- one normalized objective stack,
- one normalized authority family,
- complete evidence classification,
- explicit proof-plane and lab coverage,
- no active legacy persona path,
- and a certification regime that makes contradiction impossible to hide.

That is the closure delta.
