# Packet 2 - Root Manifest, Profiles, and Export Semantics

**Proposal design packet for migrating Octon from the current mixed-tree
`.octon/` model to the ratified Super-Root manifest, profile, and
behaviorally complete export model.**

## Status

**Status:** Ratified design packet for proposal drafting
**Proposal area:** Root manifest, class-root bindings, install/export/update
profiles, and snapshot semantics
**Implementation order:** 2 of 15 in the ratified proposal sequence
**Primary outcome:** Replace path-allowlist portability and raw whole-tree
copy with a manifest-defined, profile-driven model
**Dependencies:** Packet 1 - Super-Root Semantics and Taxonomy
**Migration role:** Establish the authoritative root manifest, profile
semantics, and behaviorally complete repo snapshot contract that all later
cutovers must obey

**Packet intent:** make Octon installation, export, update, bootstrap, and
repo snapshot behavior explicit, validator-enforced, and reproducible by
defining the root manifest, its companion manifests, and the final v1 profile
model.

## 1. Why this proposal exists

Packet 1 ratified the five-class Super-Root. Packet 2 exists because that
taxonomy is not operational until Octon has one authoritative manifest model
that answers five practical questions unambiguously:

1. What are the class roots?
2. What versions and compatibility contracts are in force?
3. What is safe to install into a new repo?
4. What is safe to export from an adopted repo?
5. When are repo snapshots behaviorally complete?

The current repo still answers those questions indirectly.
`/.octon/README.md` still frames adoption as copying the `.octon/` tree.
`/.octon/octon.yml` still uses a `portable:` allowlist instead of explicit
class-root and profile semantics. The current extension proposal baseline also
assumes compatibility keys that the live `octon.yml` does not yet carry. This
packet closes that gap by making the root manifest the canonical
install/export/update contract.

## 2. Problem statement

The current architecture does not yet provide a single, ratified,
machine-enforceable answer to what should be copied, what should be preserved,
what should be regenerated, and what must never be treated as a raw
dependency. In the current repo baseline, those rules are distributed across
README guidance, `octon.yml`, extension proposal material, and subsystem
conventions.

That is not sufficient for a Super-Root architecture. Once Octon adopts
explicit class roots, the root manifest must become the source of truth for
topology, portability, compatibility, and profile behavior.

### Current baseline signals that trigger this proposal

- **`.octon/` is still presented as a copyable repo-root harness** in
  `/.octon/README.md`.
  **Migration implication:** replace whole-tree copy with profile-driven
  install/export semantics.

- **`octon.yml` still uses a `portable:` allowlist** in the live repo.
  **Migration implication:** replace path allowlists with class-root and
  profile definitions.

- **The current extension proposal expects harness release and extension API
  keys not yet present in live `octon.yml`.**
  **Migration implication:** add canonical compatibility/version keys to the
  root manifest.

- **Current proposal and extension baselines still assume external raw
  workspaces.**
  **Migration implication:** replace external-workspace assumptions with
  integrated `inputs/**` profile rules.

## 3. Final target-state decision summary

- `/.octon/octon.yml` becomes the authoritative Super-Root manifest.
- `octon.yml` must define class-root bindings, schema version, harness release
  version, supported schema versions, extension API version, and
  install/export/update profiles.
- `framework/manifest.yml` and `instance/manifest.yml` become required
  companion manifests.
- `repo_snapshot` is a **behaviorally complete** export profile in v1.
- `repo_snapshot` includes all enabled extension pack payloads and full
  transitive dependency closure.
- There is **no** `repo_snapshot_minimal` profile in v1.
- `bootstrap_core` installs only the framework bundle plus a minimal instance
  seed.
- `pack_bundle` exports selected extension packs plus dependency closure.
- `full_fidelity` remains advisory: use a normal Git clone when the goal is an
  exact repo reproduction.
- Missing enabled pack payloads or unresolved pack dependencies make
  `repo_snapshot` generation fail closed.

## 4. Scope

- Define the authoritative root manifest contract for the Super-Root.
- Define the required companion manifest roles.
- Define the v1 install/export/update profile set.
- Define the required behavior of `repo_snapshot`.
- Define the compatibility/version keys required for framework and extensions.
- Define policy hooks for raw-input dependency bans and generated-output
  staleness checks.
- Provide the canonical portability model that later proposals must obey.

## 5. Non-goals

- Detailed extension pack schema beyond the fields needed to support profile
  and compatibility semantics.
- Detailed proposal manifest schema.
- Detailed overlay merge semantics.
- Detailed remote or registry-backed extension resolution in v1.
- A v1 minimal repo snapshot profile.
- Re-litigating the five-class topology or the placement of extensions and
  proposals under `inputs/**`.

## 6. Canonical paths and artifact classes

- **`octon.yml`**
  Root manifest and authoritative control metadata for class roots, versions,
  profiles, and policy hooks.

- **`framework/manifest.yml`**
  Framework companion manifest declaring framework identity, overlay registry
  binding, bundled generators, and supported instance schema range.

- **`instance/manifest.yml`**
  Instance companion manifest declaring repo-instance schema version, enabled
  overlay points, locality registry binding, and repo feature toggles.

- **`instance/extensions.yml`**
  Authoritative instance control metadata for desired extension selection,
  source policy, trust policy, and acknowledgements.

- **`inputs/additive/extensions/**`**
  Raw additive input surface for extension pack payloads included when
  required by profile semantics.

- **`inputs/exploratory/proposals/**`**
  Raw exploratory input surface for proposal/work-in-progress material
  explicitly excluded from bootstrap and repo snapshot.

- **`generated/effective/**`**
  Non-authoritative compiled runtime-facing outputs used only after validation
  and publication.

## 7. Authority and boundary implications

- The root manifest is authoritative for topology and profile semantics.
- Companion manifests are authoritative for framework- and instance-scoped
  control metadata, not for runtime or policy authority by themselves.
- Profile definitions do not relax class boundaries; they only describe
  allowed export and install units.
- `repo_snapshot` must be reproducible and behaviorally complete, not merely
  convenient.
- Raw `inputs/**` remain non-authoritative even when included in an export
  profile.
- `generated/**` is never the primary export unit for bootstrap or repo
  snapshot profiles.
- Trust, compatibility, and snapshot completeness remain control-plane
  concerns, not pack-local autonomy.

## 8. Schema, manifest, and contract changes required

### Root manifest (`octon.yml`)

The root manifest must add or standardize:

- `schema_version`
- `topology.super_root`
- `topology.class_roots`
- `versioning.harness.release_version`
- `versioning.harness.supported_schema_versions`
- `versioning.extensions.api_version`
- `profiles.bootstrap_core`
- `profiles.repo_snapshot`
- `profiles.pack_bundle`
- `profiles.full_fidelity`
- `policies.raw_input_dependency`
- `policies.generated_staleness`
- optional `zones.human_led` or excluded-zone declarations
- migration workflow references

### Framework companion manifest

`framework/manifest.yml` must declare at least:

- framework identity
- framework schema version
- overlay registry binding
- bundled generators
- supported instance schema range
- bundled policy set references

### Instance companion manifest

`instance/manifest.yml` must declare at least:

- repo-instance identity
- instance schema version
- enabled overlay points
- locality registry binding
- feature toggles
- optional migration state markers

## 9. Ratified root manifest model

### Illustrative v1 manifest shape

```yaml
schema_version: "2.0"

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
    supported_schema_versions: ["2.0"]
  extensions:
    api_version: "1.0"

profiles:
  bootstrap_core:
    include:
      - octon.yml
      - framework/**
      - instance/manifest.yml
  repo_snapshot:
    include:
      - octon.yml
      - framework/**
      - instance/**
      - inputs/additive/extensions/<enabled-and-dependent>/**
    exclude:
      - inputs/exploratory/**
      - state/**
      - generated/**
  pack_bundle:
    selector: "inputs/additive/extensions/<selected>/**"
    include_dependency_closure: true
  full_fidelity:
    advisory: "Prefer full Git clone for exact repo reproduction"

policies:
  raw_input_dependency: "fail-closed"
  generated_staleness: "fail-closed"
```

## 10. Ratified v1 profile semantics

### `bootstrap_core`

**Intended use:** clean new-repo bootstrap
**Includes:** root manifest, framework bundle, minimal instance seed
**Excludes:** all raw inputs, all state, all generated outputs
**Behavioral rule:** never imports another repo's proposals, state, or
generated views

### `repo_snapshot`

**Intended use:** behaviorally complete adopted-repo export
**Includes:** framework, instance, enabled packs, and full transitive
dependency closure
**Excludes:** proposals, state, and generated outputs
**Behavioral rule:** export fails if enabled packs or dependencies are missing

### `pack_bundle`

**Intended use:** pack reuse and distribution
**Includes:** selected extension packs and dependency closure
**Excludes:** proposals, state, generated outputs, and repo-instance authority
**Behavioral rule:** bundle must be self-contained for the selected packs

### `full_fidelity`

**Intended use:** exact repo reproduction
**Behavioral rule:** use a normal Git clone; this is advisory only and not a
synthetic export profile

## 11. Final profile and export semantics

### `bootstrap_core`

For a clean bootstrap, install:

- `octon.yml`
- `framework/**`
- minimal `instance/manifest.yml`

Do **not** install:

- `inputs/additive/**`
- `inputs/exploratory/**`
- `state/**`
- `generated/**`

### `repo_snapshot`

`repo_snapshot` is the default v1 repo export. It is **behaviorally
complete** by definition.

That means it must include:

- `octon.yml`
- `framework/**`
- `instance/**`
- every enabled extension pack declared by `instance/extensions.yml`
- full transitive dependency closure of those enabled packs

It must exclude:

- `inputs/exploratory/**`
- `state/**`
- `generated/**`

If enabled extension payloads or required dependencies are missing, export
must fail closed. The operator may not silently generate a partial snapshot.

### `pack_bundle`

`pack_bundle` exports selected packs plus dependency closure only. It is not a
repo snapshot and does not include repo-instance authority or state.

### `full_fidelity`

`full_fidelity` is not an export profile. It is a documented advisory that
exact reproduction of the repo should use normal Git clone semantics.

## 12. Validation, assurance, and fail-closed implications

- Validation must reject invalid or incomplete root manifest definitions.
- Validation must reject undefined class roots or profile names.
- Export validation must reject a `repo_snapshot` that omits enabled packs or
  their required dependencies.
- Validation must reject profile definitions that include forbidden classes for
  a given profile.
- Validation must reject stale or incompatible effective outputs when they are
  required by downstream runtime or policy behavior.
- Validation must enforce that raw `inputs/**` do not become direct runtime or
  policy dependencies even when those inputs are included in an export.
- Migration tooling must block partial cutovers that mix legacy portability
  assumptions with ratified profile semantics.

## 13. Portability, compatibility, and trust implications

- Portability becomes profile-driven rather than path-allowlist driven.
- Framework portability is explicit and stable.
- Repo-instance authority portability is intentional, not default.
- Proposal material remains excluded from clean bootstrap and repo snapshot
  flows.
- Extension pack portability is selective and governed.
- Compatibility is rooted in `octon.yml`, framework contracts, and pack
  manifests - not in ad hoc path assumptions.
- Trust remains repo-controlled through `instance/extensions.yml`, even when
  pack payloads travel with export profiles.
- A repo snapshot is now a reproducible control-plane export, not a best-effort
  subset.

## 14. Migration and rollout implications

- This packet must ratify before downstream extension, proposal, and
  generated-output proposals can finalize install/export behavior.
- Existing `portable:` guidance in `octon.yml` must be deprecated in favor of
  class-root profiles.
- Any existing scripts, onboarding docs, or automation that assume `cp -r
  .octon` must be retired or rewritten.
- Compatibility shims may temporarily map current mixed paths to
  class-root-aware export logic, but those shims must expire.
- Extension-pack internalization into `inputs/additive/extensions/**` must not
  ship before profile semantics and dependency-closure enforcement are live.
- Repo continuity must move into `state/**` before any downstream docs
  describe state reset or clean bootstrap against the new profiles.

## 15. Dependencies and suggested implementation order

**Dependencies:** Packet 1 - Super-Root Semantics and Taxonomy
**Suggested implementation order:** 2
**Blocks:** framework manifest, instance manifest, extension
activation/export semantics, migration tooling, and validator behavior

## 16. Acceptance criteria

- `octon.yml` explicitly defines class roots, release/API versions, and the
  ratified v1 profiles.
- `framework/manifest.yml` and `instance/manifest.yml` are part of the
  canonical contract.
- `bootstrap_core` is capable of creating a clean new repo without importing
  proposals, state, or generated outputs.
- `repo_snapshot` is defined as behaviorally complete and fails closed if
  enabled pack payloads or dependencies are missing.
- `pack_bundle` exports selected packs plus dependency closure only.
- `full_fidelity` is documented as a Git-clone use case rather than a
  synthetic export profile.
- The old `portable:` allowlist model is formally deprecated.
- No downstream proposal may redefine repo snapshot semantics in a way that
  weakens behavioral completeness.

## 17. Supporting evidence to reference

- Current `.octon/README.md` - still documents `.octon/` as a copyable
  repo-root harness and still frames adoption around copying the tree.
- Current `.octon/octon.yml` - still uses a `portable:` allowlist and lacks
  the final release/API version keys.
- Current extension proposal baseline - expects compatibility/version fields
  and already assumes that pack validity and runtime-facing effective views
  depend on pack payloads plus root compatibility metadata.
- Ratified Super-Root blueprint - sections on the root manifest, profile
  semantics, portability model, extension desired/actual/compiled model, and
  migration ordering.

Reference URLs:

- `https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/README.md`
- `https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/octon.yml`
- `https://raw.githubusercontent.com/jamesryancooper/octon/main/.proposals/architecture/extensions-sidecar-pack-system/architecture/target-architecture.md`
- `https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/cognition/_meta/architecture/shared-foundation.md`

## 18. Settled decisions that must not be re-litigated

- `/.octon/octon.yml` remains the authoritative root manifest.
- The top-level target state is a five-class Super-Root.
- `repo_snapshot` is behaviorally complete in v1.
- There is no v1 `repo_snapshot_minimal`.
- Enabled extension pack payloads and dependency closure must be included in
  `repo_snapshot`.
- Raw whole-tree `.octon` copy is not the default bootstrap/update/export
  model.
- Raw `inputs/**` paths remain non-authoritative even when profiles include
  them.
- Proposal material remains excluded from clean bootstrap and repo snapshot
  profiles.

## 19. Remaining narrow open questions

None. This packet is ratified for proposal drafting and is ready to be turned
into the formal architectural proposal.
