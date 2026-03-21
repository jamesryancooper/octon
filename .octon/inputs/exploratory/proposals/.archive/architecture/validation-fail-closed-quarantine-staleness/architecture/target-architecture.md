# Target Architecture

## Decision

Ratify one unified validation and failure-semantics contract across the
five-class super-root where:

- validation is class-root aware across `framework/**`, `instance/**`,
  `inputs/**`, `state/**`, and `generated/**`
- runtime and policy consumers may trust only authored authority in
  `framework/**` and `instance/**`, mutable operational truth in `state/**`,
  and fresh validated compiled publications in `generated/effective/**`
- raw `inputs/**` paths never become direct runtime or policy dependencies
- failures that undermine authoritative or runtime-facing trust fail globally
  closed
- locality-specific failures quarantine at the scope boundary when isolation
  is safe
- extension-pack failures quarantine at the pack boundary when a coherent
  surviving generation still exists
- extension publication withdraws to framework-plus-instance native behavior
  when no coherent extension generation survives
- proposal validation remains workflow-local and never gains runtime or policy
  precedence
- `instance/extensions.yml`,
  `state/control/extensions/{active,quarantine}.yml`, and
  `generated/effective/extensions/**` remain the canonical desired/actual/
  quarantine/compiled publication stack
- runtime-facing effective families publish generation metadata and fail
  closed when stale or mismatched
- retained validation evidence lives under `state/evidence/validation/**`
- the legacy mixed-surface `_ops` write-allowlist framing is superseded by a
  class-root-aware validation and publication discipline

This proposal converts the repository's already-partial fail-closed direction
into one explicit contract that runtime, policy, validators, and operators
can use without inventing local exceptions.

## Status

- status: accepted proposal drafted from ratified Packet 14 inputs
- proposal area: cross-class validation families, fail-closed publication,
  scope and pack quarantine, desired-versus-actual extension state,
  generated-output freshness, validation receipts, and class-root-aware
  enforcement
- implementation order: 14 of 15 in the ratified proposal sequence
- dependencies:
  - `super-root-semantics-and-taxonomy`
  - `root-manifest-profiles-and-export-semantics`
  - `framework-core-architecture`
  - `repo-instance-architecture`
  - `overlay-and-ingress-model`
  - `locality-and-scope-registry`
  - `state-evidence-continuity`
  - `inputs-additive-extensions`
  - `inputs-exploratory-proposals`
  - `generated-effective-cognition-registry`
  - `memory-context-adrs-operational-decision-evidence`
  - `capability-routing-host-integration`
  - `portability-compatibility-trust-provenance`
- cross-packet contract sync:
  - `state-evidence-continuity`
  - `inputs-additive-extensions`
  - `generated-effective-cognition-registry`
  - `capability-routing-host-integration`
  - `portability-compatibility-trust-provenance`
  - `migration-rollout`
- migration role: replace the remaining mixed-surface enforcement assumptions
  with the final class-root-aware validation contract, normalize
  desired/actual/quarantine/compiled extension state, and make freshness and
  atomic publication mandatory runtime gates

## Why This Proposal Exists

Packets 1 through 13 established the class-root topology, overlay model,
state/evidence split, extension pipeline, proposal isolation, generated
families, capability routing, and portability/trust contract.
Packet 14 is the point where those pieces become operationally safe together.

The live repository already exposes much of the ratified direction:

- `.octon/octon.yml` already sets `raw_input_dependency: fail-closed`.
- `.octon/octon.yml` already sets `generated_staleness: fail-closed`.
- `.octon/instance/extensions.yml` already exists as the desired extension
  control file.
- `.octon/state/control/extensions/active.yml` already exists as published
  operational truth for the active extension generation.
- `.octon/state/control/extensions/quarantine.yml` and
  `.octon/state/control/locality/quarantine.yml` already exist as mutable
  quarantine control surfaces.
- `.octon/generated/effective/extensions/catalog.effective.yml` and
  `.octon/generated/effective/extensions/generation.lock.yml` already exist as
  runtime-facing publication artifacts.
- retained validation material already lives under
  `.octon/state/evidence/validation/**`.

What remains is contract drift.
The current repository still explains mutation and enforcement partly through
the older runtime-versus-ops allowlist model, and it does not yet express one
fully normalized answer to these questions:

- which validation failures collapse the whole harness
- which failures may quarantine locally
- how desired extension config differs from actual published state
- when a generated effective output is fresh enough to trust
- how runtime proves it is consuming a coherent active generation rather than
  a stale or partial publication
- how proposal validation stays workflow-local without being mistaken for
  runtime risk

Packet 14 closes those ambiguities.

### Current Live Signals This Proposal Must Normalize

| Current live signal | Current live source | Ratified implication |
| --- | --- | --- |
| Root manifest already encodes raw-input dependency and generated-staleness as fail-closed policies | `.octon/octon.yml` | Global fail-closed is already policy-level intent and must become an end-to-end validation contract |
| Desired extension state is already authored separately from active and quarantine state | `.octon/instance/extensions.yml` and `.octon/state/control/extensions/{active,quarantine}.yml` | Desired, actual, and quarantine are already separate surfaces and must remain distinct rather than being collapsed back into one file |
| Effective extension publication already carries a generation id, source digests, and published files | `.octon/generated/effective/extensions/{catalog.effective.yml,generation.lock.yml}` | Runtime trust must key off coherent generation metadata rather than mere file presence |
| Locality quarantine already has a dedicated operational record | `.octon/state/control/locality/quarantine.yml` | Scope-local failure isolation should be explicit and observable rather than ad hoc |
| Validation evidence already lives under retained operational state | `.octon/state/evidence/validation/**` | Validation receipts belong to retained evidence, not generated convenience output |
| Runtime-vs-ops already blocks `_ops` writes outside `state/**` and `generated/**` | `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md` | Packet 14 must finish the move from write-root allowlists to class-root-aware publication, quarantine, and freshness rules |
| Capability routing and locality publication already consume generated effective families | `.octon/generated/effective/{capabilities,locality}/**` | Freshness and fail-closed publication rules must apply consistently across every runtime-facing effective family, not just extensions |

## Problem Statement

Octon needs one final validation and failure contract that is:

- class-root aware
- explicit about authored authority versus operational truth versus raw inputs
  versus generated outputs
- explicit about publication gates for runtime-facing effective views
- explicit about desired versus actual versus quarantine versus compiled
  extension state
- explicit about freshness checks and stale-output rejection
- explicit about which failures fail globally closed and which may quarantine
  locally
- explicit about where validation evidence and quarantine truth live
- strict enough to protect runtime and policy consumers
- narrow enough to keep malformed proposals or isolated scope failures from
  becoming repo-wide outages

Without this contract, the repository can drift into unsafe shortcuts such as:

- trusting generated outputs just because they exist
- letting runtime or policy consumers read raw `inputs/**` paths directly
- treating desired extension config and actual active publication as competing
  authorities
- allowing stale locality, routing, or extension publications to remain
  silently trusted
- collapsing isolated scope or pack failures into unnecessary repo-wide
  outages
- allowing proposal-workflow failures to masquerade as runtime failures

## Scope

- define the final validation model across all five class roots
- define the validation families and validation entrypoints
- define the publication gates for runtime-facing effective outputs
- define the global fail-closed conditions
- define scope-local quarantine behavior and observable control state
- define pack-local quarantine and extension withdrawal behavior
- define the desired/actual/quarantine/compiled extension consistency model
- define freshness and staleness requirements for runtime-facing generated
  outputs
- define where validation evidence, receipts, and quarantine truth live
- define migration implications for the current runtime-vs-ops contract and
  validator surfaces

## Non-Goals

- re-litigating the five-class super-root
- changing raw extension placement under `inputs/additive/extensions/**`
- changing raw proposal placement under `inputs/exploratory/proposals/**`
- creating permissive fallback from effective outputs to raw inputs
- making proposals part of runtime or policy precedence
- redefining capability-routing ranking weights
- redefining memory routing beyond the already ratified packet set
- changing the ratified generated-output commit policy matrix

## Unified Validation Contract

### Validation Families

| Validation family | Canonical surfaces | Authority class | Validation purpose |
| --- | --- | --- | --- |
| Root and class-root contracts | `.octon/octon.yml`, `framework/manifest.yml`, `instance/manifest.yml` | Authored authority | Confirm topology, compatibility, overlay bindings, and global fail-closed policy hooks |
| Authoritative authored artifacts | `framework/**`, `instance/**` | Authored authority | Confirm schemas, overlay legality, and runtime/policy authority coherence |
| Raw input surfaces | `inputs/additive/extensions/**`, `inputs/exploratory/proposals/**` | Non-authoritative input | Validate structure and admissibility without granting runtime or policy authority |
| Operational truth surfaces | `state/control/**`, `state/continuity/**`, `state/evidence/**` | Operational truth and retained evidence | Confirm current-state coherence, quarantine visibility, and evidence contract compliance |
| Generated outputs | `generated/effective/**`, `generated/proposals/registry.yml` | Rebuildable non-authority | Confirm schema validity, generation freshness, artifact coherence, and publication completeness |

### Validation Entrypoints

Validation must operate at these lifecycle boundaries:

1. Authoring-time validation for manifests, schemas, and authored authority.
2. Publication-time validation for runtime-facing generated effective outputs.
3. Runtime-start validation for required effective outputs, freshness, and
   active-generation coherence.
4. Export-time validation for profile completeness and enabled-pack dependency
   closure.
5. Migration-time validation for cutover correctness and legacy-path removal
   safety.

### Publication Gates

A runtime-facing effective publication may be trusted only when all of the
following are true:

1. Authoritative source inputs are valid.
2. The raw-input dependency ban is satisfied.
3. The generated payload schema is valid.
4. The generation lock matches the published payload set.
5. Source digests in the generation lock match current authoritative or
   validated raw inputs.
6. Active control state references the same generation id as the compiled
   publication.
7. Quarantine control state does not block the referenced published set.

## Global Fail-Closed Model

Global fail-closed applies to failures that undermine the system's ability to
know what runtime or policy behavior actually is.

### Global Fail-Closed Conditions

Fail globally on:

- invalid `.octon/octon.yml`
- invalid class-root bindings
- invalid required framework contracts needed for runtime or policy decisions
- invalid required instance control metadata needed for runtime or policy
  decisions
- invalid required generated effective outputs
- stale required generated effective outputs
- generation locks that do not match the published effective payload set
- active-state references to missing or invalid generations
- native versus extension collisions in the active published generation
- direct raw-input dependency violations

### Trust Rule

Global fail-closed is not optional fallback behavior.
When one of the conditions above is present, runtime and policy consumers must
refuse the publication rather than infer intent from stale, partial, or raw
surfaces.

## Scope-Local Quarantine Model

Scope-local quarantine is the preferred isolation boundary for locality
failures that can be contained safely.

### Quarantine Triggers

Quarantine one scope when any of the following is invalid:

- `instance/locality/scopes/<scope-id>/scope.yml`
- active scope bindings or rooted-path resolution
- scope-local context under `instance/cognition/context/scopes/<scope-id>/**`
- scope continuity under `state/continuity/scopes/<scope-id>/**`
- scope operational decision evidence under
  `state/evidence/decisions/scopes/<scope-id>/**`
- scope-derived locality publication whose source digests no longer match the
  current scope inputs

### Quarantine Behavior

When a scope is quarantined:

- work targeted at that scope fails closed
- unrelated scopes may continue
- repo-wide work may continue when it does not depend on the quarantined scope
- effective locality publication must be republished without trusting stale or
  invalid scope contributions
- effective capability routing must not use quarantined scope metadata as if
  it were still active

### Canonical Control Surface

Scope quarantine records live at:

```text
state/control/locality/quarantine.yml
```

## Pack-Local Quarantine And Extension Withdrawal

### Pack Quarantine Triggers

Quarantine a pack, and any blocked dependents, for:

- malformed `pack.yml`
- dependency-closure failure
- compatibility failure
- trust failure
- forbidden content-bucket or entrypoint usage
- invalid generated publication state
- stale or mismatched extension generation locks

### Surviving-Generation Behavior

If a coherent surviving extension generation still exists:

- quarantine the invalid pack
- quarantine dependents whose requirements can no longer be satisfied
- publish a reduced active set
- republish the effective extension catalog, artifact map, and generation lock

### Withdrawal Behavior

If no coherent surviving extension generation exists:

- withdraw extension contributions from active runtime-facing behavior
- keep `instance/extensions.yml` intact as desired state
- publish native framework-plus-instance behavior only
- retain quarantine state and validation evidence under `state/**`

This is fail-closed withdrawal to native behavior.
It is never a permissive fallback to raw pack paths.

## Desired, Actual, Quarantine, And Compiled Consistency

### Canonical Four-Layer Extension Model

| Layer | Canonical path | Role |
| --- | --- | --- |
| Desired | `instance/extensions.yml` | Human-authored desired configuration |
| Actual active | `state/control/extensions/active.yml` | Current published operational truth |
| Quarantine | `state/control/extensions/quarantine.yml` | Blocked packs, blocked dependents, reasons, and acknowledgements |
| Compiled | `generated/effective/extensions/**` | Runtime-facing compiled publication |

### Consistency Rule

Runtime may trust extension behavior only when all of the following are true:

1. Desired configuration resolves successfully.
2. Active state references a published generation id.
3. The referenced generation lock is fresh.
4. Quarantine state does not block the referenced generation.
5. The compiled outputs match the active state's generation id and dependency
   closure.

### Atomic Publication Rule

Publication of the following surfaces must be atomic from the runtime
consumer's point of view:

- `state/control/extensions/active.yml`
- `generated/effective/extensions/catalog.effective.yml`
- `generated/effective/extensions/artifact-map.yml`
- `generated/effective/extensions/generation.lock.yml`

## Proposal-Local Validation

Proposal validation remains workflow-local.

It may block:

- proposal authoring workflows
- proposal audit workflows
- proposal registry generation

It may not block:

- runtime behavior
- policy precedence
- framework or instance authority

Invalid proposals remain exploratory failures, not runtime failures.

## Freshness And Staleness Contract

### Required Metadata For Runtime-Facing Effective Families

Every runtime-facing effective family must carry:

- source digests
- generator version
- schema version
- generation timestamp
- invalidation conditions
- publication status

### Staleness Rule

Runtime and policy consumers must fail closed when:

- a required effective output is stale
- a required generation lock is missing
- a generation lock no longer matches current authoritative or validated input
  digests
- active state references a generation that is missing or invalid

### Human-Facing Generated Outputs

Human-facing generated summaries, graphs, and projections may still be viewed
when stale only if clearly marked stale.
They remain non-authoritative and do not loosen runtime gates.

## Evidence, Observability, And Auditability

### Validation Evidence

Validation receipts live under:

```text
state/evidence/validation/**
```

Each retained receipt family should answer:

- what was validated
- against which schema or contract
- when validation ran
- which validator or generator version produced the result
- whether validation passed, blocked, quarantined, or withdrew publication

### Control-State Observability

Control-state files under `state/control/**` must remain human-readable enough
for operators to inspect:

- what is currently active
- what is currently quarantined
- why a pack or scope was blocked
- which generation runtime is allowed to trust

### Auditability Rule

Receipts and evidence remain operational truth.
They stay in `state/**` even when produced by automated validation tooling.

## Migration And Rollout Implications

Packet 14 authorizes a normalization pass rather than a greenfield design.
The repo already has the major surfaces; the remaining work is to make them
agree on one contract.

### Required Migration Outcome

- keep raw-input dependency enforcement fail closed
- keep desired, active, quarantine, and compiled extension surfaces separate
- normalize freshness and atomic publication rules across every runtime-facing
  effective family
- align scope quarantine with the final locality registry model
- replace legacy write-target and mutation guidance that still assumes older
  mixed-surface paths

### Sequencing Constraint

Packet 14 lands after Packets 1 through 13 and before Packet 15 migration and
rollout finalization.
It must be in place before extension activation, stale-publication handling,
and final mixed-path removal can be considered complete.
