# Root Manifest and Behaviorally Complete Profile Model

This is a temporary, implementation-scoped architecture proposal for
`root-manifest-profiles-and-export-semantics`.
It translates the ratified Packet 2 design packet and the ratified super-root
blueprint into the repository's proposal format.
It is not a canonical runtime, documentation, policy, or contract authority.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- summary: Formalize `/.octon/octon.yml` as the authoritative super-root
  manifest, require companion manifests, and replace broad path portability
  with a validator-enforced profile model in which `repo_snapshot` is
  behaviorally complete and fails closed when enabled-pack closure cannot be
  exported.

## Promotion Targets

- `.octon/octon.yml`
- `.octon/framework/manifest.yml`
- `.octon/instance/manifest.yml`
- `.octon/instance/extensions.yml`
- `.octon/README.md`
- `.octon/instance/bootstrap/START.md`
- `.octon/framework/cognition/_meta/architecture/shared-foundation.md`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/assurance/runtime/`
- `.octon/framework/orchestration/runtime/workflows/`

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/octon_packet_2_root_manifest_profiles_and_export_semantics.md`
4. `resources/octon_ratified_super_root_blueprint.md`
5. `navigation/source-of-truth-map.md`
6. `architecture/target-architecture.md`
7. `architecture/acceptance-criteria.md`
8. `architecture/implementation-plan.md`

## Supporting Resources

- `resources/octon_packet_2_root_manifest_profiles_and_export_semantics.md`
  captures the ratified Packet 2 design packet used to draft this proposal.
- `resources/octon_ratified_super_root_blueprint.md` bundles the ratified
  super-root blueprint sections that constrain the manifest, profile, and
  export design.

## Exit Path

Promote the root manifest contract, companion-manifest requirements,
profile-driven install and export semantics, and fail-closed snapshot behavior
into durable `.octon/` control-plane, documentation, validation, and workflow
surfaces, then archive this proposal once the canonical root manifest no
longer depends on transitional profile semantics or broad-path export rules.
