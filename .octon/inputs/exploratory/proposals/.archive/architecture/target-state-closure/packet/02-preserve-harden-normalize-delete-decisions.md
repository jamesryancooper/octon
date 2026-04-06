# 02. Preserve / Harden / Normalize / Delete Decisions

## Preserve

### Preserve exactly
- `.octon/framework/constitution/**`
- `.octon/{framework,instance,inputs,state,generated}/**` class-root super-root
- `.octon/state/control/execution/runs/**`
- `.octon/framework/engine/runtime/{adapters,crates}/**`
- `.octon/framework/lab/**`
- `.octon/framework/observability/**`
- `.octon/framework/agency/manifest.yml`
- `.octon/instance/governance/support-targets.yml`
- `.octon/state/evidence/disclosure/{runs,releases}/**`
- RunCard and HarnessCard as the disclosure families

Why:
These are already the right abstractions. They do not need redesign. They need truth-hardening.

## Harden

### Harden immediately
- evidence classification completeness
- cross-artifact tuple / pack / route consistency
- disclosure wording coherence
- release-bundle freshness and regeneration
- host projection non-authority enforcement
- proof-plane completeness
- evaluator independence
- support-target admission checks
- no-legacy-active-path detection
- build-to-delete governance

Why:
These are the existing surfaces where the architecture is right but closure is not yet mechanically true.

## Normalize

### Normalize to one canonical family
- `objective/run-contract-v1` + `runtime/run-contract-v2` → `runtime/run-contract-v3`
- mission authority → `mission-charter-v1`
- quorum semantics → `quorum-policy-v1`
- evidence classification → `evidence-classification-v2`
- release-bundle generation artifacts → disclosure contract family
- lease / revocation lifecycle units → per-artifact files
- stage attempts → runtime family

Why:
Split families and embedded policy anchors are exactly the kinds of drift that keep closure from being machine-provable.

## Re-bound

### Re-bound authored vs generated claim surfaces
- `instance/governance/disclosure/harness-card.yml`
- `instance/governance/closure/*.yml`

New role:
- stable, generated mirrors of the active release bundle only

Why:
A claim-bearing surface that can be edited by hand is not a closure surface; it is documentation.

## Simplify

### Simplify kernel agency
- keep `orchestrator` as default
- preserve `verifier` where it provides real proof value
- demote or archive `architect`
- demote or archive `SOUL.md`
- keep assistants/teams only if they still provide real isolation or concurrency value

Why:
Persona-heavy kernel identity is not load-bearing anymore. The routing, ownership, memory, and separation-of-duties logic are load-bearing.

## Delete

### Delete from active claim path
- authored optimistic status files
- stale superseded claim wording in any active artifact
- direct dependence on host labels/comments/checks as authority
- active-path references to legacy architect/SOUL surfaces after cutover
- empty evidence-classification files in active proof bundles

Why:
These items are not “technical debt.” They are closure-invalidating contradictions.

## Postpone

### Explicitly postpone
- support-widening for frontier-governed, browser, API, GitHub, CI, Studio, or boundary-sensitive tuples beyond the currently admitted live claim
- broader locale / language-resource widening
- new capability pack families outside already declared envelopes

Why:
Closure hardening comes before support expansion. A wider claim on inconsistent foundations makes the system less honest, not more capable.

## Decision rule

Whenever there is a tension between preserving convenience and preserving closure truth, choose closure truth.
