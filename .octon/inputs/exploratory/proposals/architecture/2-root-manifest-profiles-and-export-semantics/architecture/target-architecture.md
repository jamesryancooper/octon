# Target Architecture

## Decision

Promote `/.octon/octon.yml` to the fully authoritative super-root manifest for
topology, compatibility, install/export/update profiles, and fail-closed
control-plane policy hooks.

The ratified v1 control-plane model requires:

- one authoritative root manifest at `/.octon/octon.yml`
- required companion manifests at:
  - `framework/manifest.yml`
  - `instance/manifest.yml`
- a final profile set of:
  - `bootstrap_core`
  - `repo_snapshot`
  - `pack_bundle`
  - `full_fidelity`
- `repo_snapshot` to be behaviorally complete
- no v1 `repo_snapshot_minimal`

This proposal replaces broad path export assumptions and raw whole-tree copy
guidance with a manifest-defined, validator-enforced portability model.

## Status

- status: accepted proposal drafted from ratified Packet 2 inputs
- proposal area: root manifest, companion manifests, profiles, and export
  semantics
- implementation order: 2 of 15 in the ratified proposal sequence
- dependencies:
  - `super-root-semantics-and-taxonomy`
- migration role: establishes the authoritative install/export/update contract
  that later overlay, locality, extension, state, generated-output, and
  migration proposals must obey

## Why This Proposal Exists

Packet 1 ratified the five-class super-root, but that topology is not yet a
complete operational contract until the root manifest answers these questions
without inference:

1. What are the class roots?
2. What versions and compatibility ranges are in force?
3. What is safe to install into a clean repo?
4. What is safe to export from an adopted repo?
5. When is a repo snapshot behaviorally complete?

The live repository already carries a partial cutover:

- `.octon/octon.yml` defines class roots and early profile names
- `.octon/framework/manifest.yml` and `.octon/instance/manifest.yml` already
  exist
- `.octon/README.md` now describes class roots instead of a whole-tree copy
  model

However, the current manifest contract is still transitional rather than
final. It does not yet fully encode the ratified Packet 2 rules.

### Current Live Gaps This Proposal Closes

| Current live signal | Current live source | Ratified correction |
| --- | --- | --- |
| Root topology fields are present, but not yet expressed as the final root-manifest contract | `.octon/octon.yml` | Make the root manifest authoritative for `topology.super_root`, class-root bindings, version compatibility, policy hooks, and migration references |
| `repo_snapshot` includes the entire additive extension root rather than the enabled-pack dependency closure | `.octon/octon.yml` | Require enabled-pack payload selection plus full transitive dependency closure and fail closed on missing payloads |
| `pack_bundle` includes the whole extension input root rather than selected packs plus closure | `.octon/octon.yml` | Make `pack_bundle` selector-driven and self-contained for chosen packs only |
| `full_fidelity` is still modeled as a synthetic include profile | `.octon/octon.yml` | Downgrade `full_fidelity` to advisory clone guidance rather than a synthetic export contract |
| Extension API version and human-led zones are expressed in transitional top-level shapes | `.octon/octon.yml` | Normalize versioning and zone declarations under the ratified control-plane model |
| Companion manifests exist, but their required roles are not yet fully locked as part of the profile contract | `.octon/framework/manifest.yml`, `.octon/instance/manifest.yml` | Make them required contract surfaces for compatibility and profile validation |

## Problem Statement

The class-root cutover solved top-level taxonomy, but it did not by itself
settle installation, export, update, or snapshot completeness. Without a
ratified manifest and profile contract, the system still risks ambiguity about:

- which paths are portable versus repo-specific
- when repo authority is intentionally exported
- when raw additive inputs may travel with an export
- which compatibility checks must run before publication
- whether a snapshot is complete enough to reproduce runtime behavior

That ambiguity is unacceptable for a super-root architecture whose portability,
trust, and fail-closed behavior must be machine-enforceable.

## Scope

- define the authoritative root manifest contract for the super-root
- define the required roles of `framework/manifest.yml` and
  `instance/manifest.yml`
- define the ratified v1 install/export/update profile set
- define the behaviorally complete `repo_snapshot` contract
- define the required compatibility/version keys for framework and extensions
- define policy hooks for raw-input dependency bans and generated-output
  staleness enforcement
- define the portability contract that later proposals must inherit

## Non-Goals

- detailed extension-pack schema beyond the fields needed for compatibility and
  snapshot semantics
- detailed proposal manifest schema
- detailed overlay merge behavior
- remote or registry-backed pack resolution in v1
- a v1 `repo_snapshot_minimal`
- re-litigating the five-class topology, integrated inputs placement, or the
  repo-owned scope model

## Control-Plane Components

| Artifact | Role | Authority status |
| --- | --- | --- |
| `octon.yml` | Authoritative root manifest for topology, versions, profiles, and policy hooks | Authoritative control metadata |
| `framework/manifest.yml` | Framework identity, overlay registry binding, bundled generators, supported instance schema range, and bundled policy references | Authoritative framework-scoped control metadata |
| `instance/manifest.yml` | Repo-instance identity, enabled overlay points, locality binding, feature toggles, and optional migration markers | Authoritative instance-scoped control metadata |
| `instance/extensions.yml` | Desired extension selection, source policy, trust policy, and acknowledgements | Authoritative repo-controlled desired extension config |
| `inputs/additive/extensions/**` | Raw additive extension payloads | Non-authoritative raw input |
| `inputs/exploratory/proposals/**` | Raw exploratory proposal material | Non-authoritative raw input |
| `generated/effective/**` | Published compiled runtime-facing views | Non-authoritative derived output |

## Root Manifest Contract

The root manifest must become the only canonical place that defines:

- the super-root home
- class-root bindings
- harness release and supported schema versions
- extension API version
- install, export, and update profiles
- raw-input dependency policy
- generated-staleness policy
- excluded or human-led zones
- migration workflow references

The exact schema label may remain versioned in Octon's own naming style, but
the field contract must be semantically equivalent to the ratified Packet 2
model.

### Illustrative Ratified Shape

```yaml
schema_version: "octon-root-manifest-v2"

topology:
  super_root: ".octon/"
  class_roots:
    framework: "framework/"
    instance: "instance/"
    inputs: "inputs/"
    state: "state/"
    generated: "generated/"

versioning:
  harness:
    release_version: "2.0.0"
    supported_schema_versions:
      - "octon-root-manifest-v2"
      - "octon-framework-manifest-v1"
      - "octon-instance-manifest-v1"
  extensions:
    api_version: "1.0"

profiles:
  bootstrap_core:
    include:
      - "octon.yml"
      - "framework/**"
      - "instance/manifest.yml"
  repo_snapshot:
    include:
      - "octon.yml"
      - "framework/**"
      - "instance/**"
      - "inputs/additive/extensions/<enabled-and-dependent>/**"
    exclude:
      - "inputs/exploratory/**"
      - "state/**"
      - "generated/**"
  pack_bundle:
    selector: "inputs/additive/extensions/<selected>/**"
    include_dependency_closure: true
  full_fidelity:
    advisory: "Prefer full Git clone for exact repo reproduction"

policies:
  raw_input_dependency: "fail-closed"
  generated_staleness: "fail-closed"

zones:
  human_led:
    - "inputs/exploratory/ideation/**"
```

## Companion Manifest Contract

### Framework Companion Manifest

`framework/manifest.yml` must declare at least:

- framework identity
- framework schema version
- overlay registry binding
- bundled generators
- supported instance schema range
- bundled policy set references

### Instance Companion Manifest

`instance/manifest.yml` must declare at least:

- repo-instance identity
- instance schema version
- enabled overlay points
- locality registry binding
- feature toggles
- optional migration state markers

Companion manifests do not replace the authority of `octon.yml`. They provide
framework- and instance-scoped control metadata required to evaluate the root
manifest's profile and compatibility rules.

## Ratified V1 Profile Model

| Profile | Intended use | Includes | Excludes | Required behavior |
| --- | --- | --- | --- | --- |
| `bootstrap_core` | Clean new-repo bootstrap | `octon.yml`, `framework/**`, minimal `instance/manifest.yml` | All `inputs/**`, all `state/**`, all `generated/**` | Never imports proposals, mutable state, or generated views from another repo |
| `repo_snapshot` | Default behaviorally complete adopted-repo export | `octon.yml`, `framework/**`, `instance/**`, enabled packs, full transitive dependency closure | `inputs/exploratory/**`, `state/**`, `generated/**` | Fails closed if enabled pack payloads or dependencies are missing |
| `pack_bundle` | Pack reuse and distribution | Selected packs and dependency closure only | Proposals, state, generated outputs, repo-instance authority | Produces a self-contained pack bundle for the selected packs |
| `full_fidelity` | Exact repo reproduction | Advisory only | Not a synthetic export payload | Direct users to normal Git clone semantics |

## Behaviorally Complete `repo_snapshot`

`repo_snapshot` is the default v1 repo export and is behaviorally complete by
definition.

That means:

- it includes `octon.yml`
- it includes all of `framework/**`
- it includes all of `instance/**`
- it includes every enabled extension pack declared by
  `instance/extensions.yml`
- it includes the full transitive dependency closure of those enabled packs
- it excludes `inputs/exploratory/**`
- it excludes `state/**`
- it excludes `generated/**`

### Fail-Closed Snapshot Rules

Export must fail closed when:

- an enabled pack payload is missing
- a required transitive dependency is missing
- the root manifest, companion manifests, or desired extension config are
  incomplete or incompatible
- required compiled effective outputs are stale when downstream behavior
  depends on them

There is no v1 `repo_snapshot_minimal`. Future externally resolvable pack
profiles may exist later, but they may not weaken the meaning of
`repo_snapshot` in v1.

## Validation And Policy Hooks

Validation must reject:

- invalid or incomplete root manifest definitions
- unknown class roots or profile names
- profile definitions that include forbidden classes for the selected profile
- raw-input dependency violations, even when raw inputs are part of an export
  payload
- stale or incompatible required effective outputs
- `repo_snapshot` payload sets that omit enabled pack payloads or their
  dependency closure
- migration states that mix legacy portability assumptions with ratified
  profile semantics

The policy hooks exposed by `octon.yml` remain control-plane rules, not pack-
local autonomy.

## Portability, Compatibility, And Trust

- portability becomes profile-driven rather than allowlist-driven
- framework portability is explicit and stable
- repo-instance authority travels only when a profile says it should
- proposal material remains excluded from clean bootstrap and repo snapshot
  flows
- extension pack portability is selective and governed
- compatibility is rooted in `octon.yml`, companion manifests, and pack
  manifests rather than ad hoc path assumptions
- trust remains repo-controlled through `instance/extensions.yml`
- raw `inputs/**` remain non-authoritative even when a profile includes them

## Migration And Rollout Implications

This proposal is the contract gate for downstream work. The migration order
must continue to obey the ratified sequence:

1. super-root semantics and taxonomy
2. root manifest, profiles, and export semantics
3. framework/core architecture
4. repo-instance architecture
5. overlay and ingress model
6. locality and scope registry
7. state, evidence, and continuity
8. inputs/additive/extensions
9. inputs/exploratory/proposals
10. generated/effective/cognition/registry
11. memory, context, ADRs, and operational decision evidence
12. capability routing and host integration
13. portability, compatibility, trust, and provenance
14. validation, fail-closed, quarantine, and staleness
15. migration and rollout

### Non-Negotiable Sequencing Constraints

- do not internalize new pack semantics before profile and dependency-closure
  enforcement are live
- do not describe `full_fidelity` as a synthetic export payload
- do not ship `repo_snapshot` without enabled-pack dependency closure
- do not remove transitional compatibility shims before validators and profile
  workflows are in place
- do not allow later proposals to weaken behavioral completeness or reintroduce
  broad-path portability semantics

## Settled Decisions Preserved Here

- `/.octon/octon.yml` remains the authoritative root manifest
- the top-level super-root remains five-class
- `repo_snapshot` is behaviorally complete in v1
- there is no v1 `repo_snapshot_minimal`
- enabled extension pack payloads and dependency closure must travel with
  `repo_snapshot`
- raw whole-tree `.octon` copy is not the default install/export/update model
- raw `inputs/**` remain non-authoritative even when they travel in a profile
- proposal material remains excluded from clean bootstrap and repo snapshot
  profiles
