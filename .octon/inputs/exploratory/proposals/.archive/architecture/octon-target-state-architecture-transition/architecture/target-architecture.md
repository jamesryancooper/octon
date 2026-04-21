# Target Architecture

## Executive target

The target-state architecture preserves Octon's existing constitutional foundation while making runtime enforcement and proof closure first-class, validator-backed, and queryable.

Target-state Octon is:

> A repo-native constitutional engineering harness whose governed runtime cannot perform material side effects without an engine-owned authorization grant, whose generated/effective outputs are receipt-fresh projections only, whose support claims are tuple-bounded and proof-backed, and whose architecture is navigable through generated maps derived from authoritative registries.

## Preserved architectural invariants

The transition must preserve:

- the single `.octon/` super-root;
- the five class roots: `framework/`, `instance/`, `state/`, `generated/`, `inputs/`;
- authored authority in `framework/**` and `instance/**` only;
- `state/control/**` as mutable operational control truth;
- `state/evidence/**` as retained proof, disclosure, and validation evidence;
- `state/continuity/**` as resumable work state;
- `generated/**` as derived-only;
- `inputs/**` as non-authoritative;
- mission authority as continuity and long-horizon autonomy container;
- run contract as atomic consequential execution authority;
- support-target tuples as the boundary for live support claims;
- host/model adapters as replaceable, non-authoritative boundaries.

## Target layers

### 1. Constitutional and structural authority

`framework/constitution/**` remains supreme repo-local authority. `contract-registry.yml` remains the canonical machine-readable topology and authority registry. The architecture specification remains the human-readable companion and must not restate conflicting matrices.

Target improvement: the registry gains typed support for material side-effect inventory, authorization coverage maps, generated architecture map publication, and compatibility projection retirement metadata.

### 2. Authorization-boundary enforcement

Every material path that can produce durable side effects must be represented in a material side-effect inventory and must resolve through `authorize_execution(request) -> GrantBundle` or a documented fail-closed exception.

Material classes include:

- repo mutation;
- state/control mutation;
- state/evidence mutation;
- generated/effective publication;
- protected CI checks;
- service invocation with side effects;
- workflow stage execution;
- executor launch;
- support-claim publication;
- host projection publication where it can affect operator decisions.

Target artifact set:

- `material-side-effect-inventory-v1.schema.json`;
- `authorization-boundary-coverage-v1.schema.json`;
- `validate-material-side-effect-inventory.sh`;
- `validate-authorization-boundary-coverage.sh`;
- negative-control tests proving unmediated writes and stale generated outputs fail closed.

### 3. Modular runtime internals

The runtime kernel becomes a command router plus typed request builders. Runtime command families move to modules under `kernel/src/commands/**`. Authorization request construction moves to `kernel/src/request_builders/**`.

The authority engine becomes phase-auditable. `authorize_execution` remains the public boundary, but its implementation is decomposed into phases:

1. request normalization;
2. active intent binding;
3. execution environment resolution;
4. executor profile validation;
5. write-scope validation;
6. run lifecycle binding;
7. run contract loading;
8. ownership resolution;
9. support posture resolution;
10. reversibility and rollback validation;
11. egress policy;
12. budget policy;
13. approval, exception, and revocation evaluation;
14. decision artifact writing;
15. grant bundle writing;
16. retained evidence linkage.

Each phase emits a phase result record and reason-code output.

### 4. Proof-plane hardening

Proof is no longer merely a set of obligations. It becomes an enforceable closeout surface.

Target proof artifacts:

- evidence completeness receipt per consequential run;
- authorization coverage proof bundle;
- support tuple proof bundle;
- generated/effective publication receipt and freshness artifact;
- RunCard and HarnessCard generated from retained evidence only;
- negative-control evidence for generated-as-authority denial, host-authority denial, unsupported tuple denial, and unmediated side-effect denial.

### 5. Support dossier sufficiency

Support admissions remain finite and tuple-bounded. A support tuple may only be `admitted-live-claim` when its dossier has:

- current admission reference;
- current dossier reference;
- current retained representative run;
- negative-control evidence;
- recovery/replay evidence;
- proof-plane coverage across structural, functional, behavioral, governance, maintainability, and recovery planes;
- recertification date and next review date;
- generated SupportCard projection with no authority of its own.

### 6. Registry-backed navigation

Active docs remain slim. Human and agent navigation comes from generated maps:

- architecture map;
- authorization coverage map;
- publication/freshness map;
- support tuple proof map;
- compatibility retirement map;
- where-to-place-this guide.

These live under `generated/cognition/projections/materialized/**` and are derived-only.

### 7. Compatibility retirement

Compatibility projections retained for current validators and runtime tooling remain allowed only when they have:

- owner;
- consumer;
- source canonical path family;
- target replacement;
- expiry or next review date;
- retirement validator coverage;
- generated retirement map.

No compatibility projection may be treated as steady-state architecture.

## Non-targets

The target architecture does not add a new root, a second policy plane, a second runtime control plane, or a generated authority layer. It does not expand live support to stage-only adapters. It does not make proposal packets durable authority.
