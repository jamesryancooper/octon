# Implementation Plan

This proposal is a contract-tightening phase for the already-ratified
super-root architecture.
The repository already contains most of the required surfaces.
The remaining work is to make manifests, control state, generated effective
families, validator logic, and operator guidance agree on one failure model.

## Workstream 1: Normalize The Cross-Class Validation Contract

- Treat `.octon/octon.yml`, `framework/manifest.yml`, and
  `instance/manifest.yml` as the root validation anchors for topology,
  compatibility, and fail-closed hooks.
- Normalize architecture docs so they describe the same validation families,
  trust boundaries, and runtime/publication entrypoints.
- Remove or rewrite any lingering guidance that implies runtime can infer
  validity from file presence alone.

## Workstream 2: Finalize Global Fail-Closed Publication Gates

- Tighten validators so invalid required effective outputs, stale effective
  outputs, mismatched generation locks, invalid active-state references, and
  raw-input dependency violations are hard fail-closed conditions.
- Ensure runtime-facing effective families expose the metadata required to
  support those checks deterministically.
- Extend publication rules so runtime and policy consumers refuse partial or
  mismatched effective generations.

## Workstream 3: Normalize Scope Quarantine

- Treat locality validation failures as scope-local quarantine whenever
  isolation is safe.
- Keep `state/control/locality/quarantine.yml` as the canonical observable
  record for quarantined scopes and reasons.
- Ensure locality and routing generators republish without quarantined or
  stale scope contributions.
- Keep repo-wide work and unrelated scopes available when they do not depend
  on the quarantined scope.

## Workstream 4: Normalize Pack Quarantine And Extension Withdrawal

- Keep `instance/extensions.yml` as desired state,
  `state/control/extensions/active.yml` as actual published state, and
  `state/control/extensions/quarantine.yml` as current blocked-state truth.
- Enforce pack-local quarantine for manifest, dependency, compatibility,
  trust, and freshness failures.
- Republish a reduced active generation when a coherent surviving extension
  set remains.
- Withdraw to framework-plus-instance native behavior when no coherent
  extension generation survives, without permitting raw pack fallback.

## Workstream 5: Tighten Freshness, Atomicity, And Receipt Contracts

- Normalize generation-lock contracts across `generated/effective/extensions/**`,
  `generated/effective/locality/**`, and `generated/effective/capabilities/**`.
- Require source digests, generator version, schema version, generation
  timestamp, invalidation conditions, and publication status for
  runtime-facing effective families.
- Ensure active state and the corresponding compiled extension publication are
  published atomically from the runtime consumer's point of view.
- Normalize retained validation evidence under `state/evidence/validation/**`
  so audits can reconstruct why publication passed, failed, quarantined, or
  withdrew.

## Workstream 6: Align Runtime-Vs-Ops, Assurance, And Workflows

- Update `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`
  so it frames `_ops` enforcement in terms of class-root-aware publication and
  receipt rules rather than a legacy mixed-surface mental model.
- Extend validator and assurance scripts under `.octon/framework/assurance/runtime/**`
  to enforce the final Packet 14 contract.
- Extend publication, migration, and export workflows under
  `.octon/framework/orchestration/runtime/workflows/**` so quarantine,
  freshness, and fail-closed behavior are hard gates rather than operator
  suggestions.

## Downstream Dependency Impact

This proposal constrains downstream work in:

- extension publication tooling
- locality publication tooling
- capability-routing publication tooling
- migration and rollout finalization
- any future automation that depends on deterministic quarantine behavior

Downstream work may refine implementation detail, but it may not weaken the
fail-closed model, the raw-input dependency ban, or the desired/actual/
quarantine/compiled publication contract.

## Exit Condition

This proposal is complete only when the canonical manifests, control-state
schemas, runtime-facing effective families, validator scripts, workflows, and
operator docs all agree on the same class-root-aware validation model, the
same quarantine boundaries, and the same freshness-gated publication rules.
