# Target Architecture

## Target-state summary

The 10/10 target state is a repo-native constitutional runtime architecture where:

1. authored authority is finite, explicit, and located only under `framework/**` and `instance/**`
2. runtime consumes a single fresh, receipt-backed effective route bundle rather than scattered
   projections, stale generated/effective files, or raw registries
3. every material side-effect path proves execution-authorization coverage before side effects
4. generated/effective outputs are runtime-facing only through hard freshness gates
5. support claims, support admissions, dossiers, proof bundles, support cards, and pack routes agree
   mechanically and path-normalize to the same partitioned claim-state model
6. extension activation has a compact desired/active/quarantine/published lifecycle with dependency
   closure and required-input expansion moved into generation locks, not mutable active state
7. proof-plane, support, publication, and runtime claims are backed by current retained evidence
8. operator read models are concise, traceable, current, and explicitly non-authoritative

## Target-state layers

### 1. Constitutional and structural authority

Preserve:

- `/.octon/framework/constitution/**`
- `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `/.octon/framework/cognition/_meta/architecture/specification.md`
- `/.octon/octon.yml` as root manifest
- `/.octon/instance/manifest.yml` as overlay enablement

Change:

- keep `octon.yml` as a thin anchor for roots, profiles, and top-level runtime-resolution pointers
- move dense runtime-resolution details into `/.octon/framework/engine/runtime/spec/runtime-resolution-v1.md`,
  `runtime-resolution-v1.schema.json`, and `/.octon/instance/governance/runtime-resolution.yml`
- update the structural contract registry to declare the runtime-resolution family, runtime-effective
  route-bundle family, and support-path normalization family explicitly

### 2. Runtime-effective route bundle

Add:

- `/.octon/framework/engine/runtime/spec/runtime-effective-route-bundle-v1.schema.json`
- `/.octon/generated/effective/runtime/route-bundle.yml`
- `/.octon/generated/effective/runtime/route-bundle.lock.yml`
- retained publication receipt under `/.octon/state/evidence/validation/architecture/10of10-target-transition/publication/freshness.yml`

The route bundle must join:

- root manifest anchors
- support targets and tuple admissions
- support dossiers and proof-bundle freshness
- capability-pack governance and runtime pack routes
- active extension generation IDs and quarantine state
- mission/run roots
- material side-effect inventory
- authorization-boundary coverage
- generated/effective publication state
- required validators

Runtime may consume the bundle only after freshness validation.

### 3. Execution authorization hard gate

Preserve the engine-owned boundary:

```rust
authorize_execution(request: ExecutionRequest) -> GrantBundle
```

Strengthen it so that all side-effect paths must enter through a request builder that binds:

- run contract
- run manifest
- support tuple
- effective route bundle digest
- requested capability packs
- execution role and executor profile
- risk/materiality classification
- rollback plan
- publication/freshness proof where generated/effective outputs participate
- evidence receipt roots

No code path may open generated/effective runtime artifacts, invoke a service, mutate repo files,
launch an executor, publish artifacts, write protected control state, or close a run without a grant
or explicit stage-only/deny/escalate receipt.

### 4. Publication freshness v2

Replace advisory freshness with hard runtime handles:

- `GeneratedEffectiveHandle::open(output_ref)` validates output, lock, artifact map, publication
  receipt, source digests, freshness window, and no-authority-widening before returning contents
- stale outputs return a fail-closed reason, not a warning
- runtime-effective files may not be read by string path in runtime code
- generated/cognition and generated/proposals remain completely unavailable for runtime authority
  routing

### 5. Support, pack, and admission alignment

Normalize support admissions and dossiers into the declared claim-state partitions:

- `support-target-admissions/live/**`
- `support-target-admissions/stage-only/**`
- `support-target-admissions/unadmitted/**`
- `support-target-admissions/retired/**`
- matching `support-dossiers/<partition>/**`

The target state eliminates the current ambiguity where support-target references name partitioned
paths while currently visible admission and dossier files are flat. Flat files may remain only as
compatibility shims with retirement records and must not be runtime-consumed.

Capability packs become three clean layers:

1. `framework/capabilities/packs/**`: portable pack contract
2. `instance/governance/capability-packs/**`: repo-owned governance/admission intent
3. `generated/effective/capabilities/pack-routes.effective.yml`: compiled runtime-facing route view

`instance/capabilities/runtime/packs/**` becomes a transitional compatibility projection or is
retired after generated/effective pack routes are runtime-consumed.

### 6. Extension lifecycle

Target extension lifecycle:

- raw additive inputs: `inputs/additive/extensions/**` only
- desired selection: `instance/extensions.yml`
- compact active state: `state/control/extensions/active.yml`
- quarantine state: `state/control/extensions/quarantine.yml`
- compiled outputs: `generated/effective/extensions/**`
- retained publication and compatibility receipts: `state/evidence/validation/**`

`active.yml` should contain only:

- desired config path and digest
- active pack IDs
- active generation ID
- effective catalog digest/ref
- artifact map digest/ref
- generation lock digest/ref
- publication receipt digest/ref
- compatibility receipt digest/ref
- compact invalidation condition IDs
- status

Large repeated `required_inputs` and dependency closure expansion belongs in the generation lock.

### 7. Proof and operator read models

Add or strengthen:

- `octon doctor --architecture` to show current authority, generated/effective freshness, support
  tuple states, admitted packs, active extensions, quarantines, shims, stale outputs, and validator
  failures
- `generated/cognition/projections/materialized/architecture-map.md`
- `generated/cognition/projections/materialized/runtime-route-map.md`
- `generated/cognition/projections/materialized/support-pack-route-map.md`

These are operator read models only and must carry source refs, generation time, freshness, and a
non-authority disclaimer.

## Target-state invariant

A consequential run cannot proceed if any of the following is true:

- run contract missing or invalid
- support tuple missing, stale, stage-only, unadmitted, or proof-incomplete
- requested pack exists but is not admitted for the tuple
- generated/effective route bundle stale or missing receipt
- raw input or proposal path participates in runtime or policy resolution
- generated/cognition output is used for authority or policy routing
- active extension generation is stale, quarantined, or unpublished
- material side-effect coverage is unproven
- required evidence roots or receipts are absent
