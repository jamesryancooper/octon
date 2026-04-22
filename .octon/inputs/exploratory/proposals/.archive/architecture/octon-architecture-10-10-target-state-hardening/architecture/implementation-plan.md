# Implementation Plan

## Posture

This is a target-state hardening proposal, not a re-foundation. The correct
motion is to preserve Octon's core model while making its boundaries mechanically
unavoidable, inspectable, and closure-grade.

## Phase 0 — Packet acceptance and freeze

1. Accept this packet as a cross-domain architecture proposal.
2. Freeze proposal scope: no new control plane, no authority in generated/input
   roots, no broad adapter support widening.
3. Record decision to preserve the super-root/class-root model.
4. Identify active maintainers for architecture, runtime, support governance,
   pack/publication, proof-plane, and boot/orientation workstreams.

**Exit criterion:** packet status may move from `draft` to `in-review` only after
all workstream owners are identified.

## Phase 1 — Health contract and inventory

1. Add `architecture-health-contract-v1.md`.
2. Expand `material-side-effect-inventory.yml`.
3. Expand `authorization-boundary-coverage.yml`.
4. Add/update `validate-architecture-health.sh`.
5. Add negative-control fixture plan.

**Exit criterion:** every material side-effect class has coverage metadata and a
planned test.

## Phase 2 — Runtime enforcement proof

1. Wire every material runtime path through `authorize_execution` or prove it is
   non-material and read-only.
2. Add tests for missing grant, stale generated/effective, missing run contract,
   unadmitted pack, unsupported adapter, and host-projection-as-authority.
3. Emit retained authorization coverage evidence.
4. Ensure workflow compatibility wrapper cannot bypass run-first lifecycle.

**Exit criterion:** coverage validator and tests pass with retained evidence.

## Phase 3 — Support claim partition and invariant sealing

1. Create `live/`, `stage-only/`, `unadmitted/`, and `retired/` partitions for
   admissions and dossiers.
2. Move existing support artifacts into partitions.
3. Update `support-targets.yml` refs.
4. Add support-pack-admission alignment contract and validator.
5. Audit active missions for non-live support defaults.
6. Generate updated support matrix.

**Exit criterion:** validator fails on deliberate stage-only-as-live and
unadmitted-pack-in-live-route fixtures.

## Phase 4 — Publication freshness gates

1. Add publication freshness contract.
2. Update runtime-effective publication metadata.
3. Add validator for receipts and dependency hashes.
4. Add stale-output negative controls.
5. Ensure runtime refuses stale generated/effective outputs.

**Exit criterion:** stale runtime-effective fixtures are denied with retained
reason-code evidence.

## Phase 5 — Pack and extension lifecycle normalization

1. Normalize pack registry/admission graph.
2. Generate runtime pack projections from canonical source/control graph where
   possible.
3. Normalize extension active-state dependency locks.
4. Update skill/service projection language.
5. Add pack/extension tests.

**Exit criterion:** no manual drift remains between framework pack contracts,
instance governance, runtime admissions, support routes, and generated effective
views.

## Phase 6 — Boot/orientation simplification

1. Move closeout/merge-lane rules out of ingress manifest.
2. Keep ingress manifest focused on mandatory reads, optional orientation, and
   adapter parity.
3. Update bootstrap START with doctor/first-run path.
4. Add operator boot validator.

**Exit criterion:** a reviewer can identify mandatory boot reads in one pass and
closeout workflow logic is validated separately.

## Phase 7 — Proof-plane closeout

1. Produce support tuple proof bundles.
2. Produce representative RunCards, HarnessCards, SupportCards, denial bundles,
   replay bundles, and recovery demonstrations.
3. Add proof-plane completeness report.
4. Retain evidence under canonical evidence roots.

**Exit criterion:** every live claim has retained proof and negative controls.

## Phase 8 — Compatibility retirement

1. Update retirement register.
2. Add owner/successor/review trigger for each compatibility surface.
3. Retire deprecated prompt, symlink-era wording, and workflow-first remnants as
   feasible.
4. Block ownerless shims.

**Exit criterion:** compatibility validator passes and no shim is unlabeled.

## Phase 9 — Closure certification

1. Run full architecture health gate.
2. Run runtime tests and proof-plane validators.
3. Produce closure certification.
4. Promote durable surfaces.
5. Archive proposal after promotion evidence exists.

**Exit criterion:** proposal can become `implemented` only when durable surfaces
stand alone and retained promotion evidence exists.
