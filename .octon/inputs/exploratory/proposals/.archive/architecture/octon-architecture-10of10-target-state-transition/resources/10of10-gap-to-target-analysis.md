# 10/10 Gap-to-Target Analysis

## Gap 1 — Runtime enforcement is not total enough

Current: execution authorization contract and authority engine implementation exist.

Target: every material side-effect path is mechanically proven to pass through the authorization boundary.

Closure:

- expand side-effect inventory
- bind every path to request builder and grant/receipt refs
- add negative-control tests
- make architecture health fail if any material path lacks coverage

## Gap 2 — Generated/effective freshness is not hard enough

Current: publication freshness contract and validators exist.

Target: runtime cannot consume any generated/effective artifact except through a freshness-checked handle.

Closure:

- add freshness v2 contract
- add runtime resolver/handle
- require locks, artifact maps, receipts, source digests, and freshness windows
- deny stale or unreceipt-backed artifacts before side effects

## Gap 3 — Root manifest is overloaded

Current: root manifest owns roots, profiles, runtime inputs, mission roots, support roots, execution governance,
and generated commit defaults.

Target: root manifest anchors; runtime-resolution details live in delegated spec/instance selector and compiled route bundle.

Closure:

- add runtime-resolution v1
- add instance runtime-resolution selector
- add generated/effective runtime route bundle
- update root manifest to pointer role

## Gap 4 — Support refs and paths need normalization

Current: support governance declares claim-state partitions and references partitioned paths, but current visible admissions/dossiers are flat.

Target: partitioned paths are canonical; flat files are compatibility shims only.

Closure:

- move admissions/dossiers to `live/`, `stage-only/`, `unadmitted/`, `retired/`
- update support target refs, proof bundles, support cards, validators
- register shims and retire

## Gap 5 — Pack admission can accidentally imply support

Current: runtime pack admissions include live and non-live tuples; pack status can be misread.

Target: pack route is compiled against support tuple admission and claim effect.

Closure:

- generated/effective pack route output
- no-widening test
- stage-only/non-live visible on every pack route
- runtime denies pack route absent admitted support tuple

## Gap 6 — Extension active state is over-expanded

Current: active state carries large dependency closure and repeated required inputs.

Target: compact active state; expansion in generation lock/artifact map.

Closure:

- reduce active state to digest pointers
- regenerate lock/artifact map
- add compactness validator
- add quarantine hard gate

## Gap 7 — Proof-plane maturity depends on refreshed evidence

Current: proof bundles and support cards exist.

Target: support and architecture proof claims regenerate from retained evidence and fail stale.

Closure:

- proof refresh validator
- closure evidence bundle
- negative-control evidence
- support proof due-date and freshness status as hard gate

## Gap 8 — Operator legibility is insufficient

Current: docs, registry, CLI, and projections exist but require deep navigation.

Target: `octon doctor --architecture` and read maps show current architecture health.

Closure:

- architecture doctor report
- architecture map
- runtime route map
- support pack route map
- explicit non-authority markers

## Gap 9 — Transitional shims can leak into steady state

Current: root ingress adapters are disciplined, but flat support paths, workflow wrappers, and archived proposal references need retirement handling.

Target: every shim has owner, replacement, retirement trigger, and validator.

Closure:

- retirement register updates
- compatibility validator
- cutover checklist
- closure certification
