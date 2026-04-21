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
