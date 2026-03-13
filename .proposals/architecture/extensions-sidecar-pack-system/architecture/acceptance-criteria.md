# Acceptance Criteria

The `.extensions/` sidecar boundary is ready to implement when all of the
following are true:

1. The v1 layout is defined with each pack rooted directly under
   `/.extensions/<pack-id>/`.
2. The proposal is explicit that `/.extensions/` binds only to the repo-root
   harness.
3. The allowed content set is explicit:
   - `catalog.yml`
   - `pack.yml`
   - `skills/`
   - `commands/`
   - `templates/`
   - `prompts/`
   - `context/`
   - `validation/`
   - documentation and optional archive content
4. The excluded content set is explicit:
   - governance
   - practices
   - methodology
   - agency
   - orchestration
   - engine
   - assurance authority
   - services
   - mutable runtime state
   - compiled effective indexes
5. The source-of-truth split is explicit:
   - `/.extensions/` stores pack source and selection
   - `/.octon/` stores runtime authority, governance, and derived effective
     projections
6. The required `.octon/` implementation surfaces are explicit:
   - `engine/governance`
   - `engine/runtime`
   - `capabilities/runtime`
   - `assurance/runtime`
   - `octon.yml` and architecture docs
   - `scaffolding`
   - operator-facing commands or workflows
7. Runtime behavior is explicit when extensions are available:
   - discover sidecar
   - validate packs
   - resolve enabled set
   - compile effective catalogs and artifact maps
   - consume effective catalogs only through rebased artifact resolution
   - fail closed on invalid inputs
8. Effective catalogs are defined for all supported extension buckets:
   - skills
   - commands
   - templates
   - prompts
   - context
   - validation
9. Compatibility is explicit and machine-readable against the exact root-harness
   keys:
   - `octon.yml.versioning.harness.release_version`
   - `octon.yml.extensions.api_version`
   - versioned pack dependency edges
10. Rebased runtime resolution is explicit:
    - artifact paths are rebased through an effective artifact map
    - extension-relative write scopes are mapped into Octon-owned roots
    - unsupported write or output declarations fail closed
11. Freshness and invalidation rules are explicit:
    - source digests recorded
    - active generation recorded
    - stale effective catalogs rejected
    - atomic publish required
12. Trust and provenance authority are unambiguous:
    - catalog is the selection plane
    - pack manifest is the trust/provenance plane
    - mismatches fail closed
13. Host and policy integration points are explicit for extension-enabled
    operation.
14. Disable/fallback cleanup semantics are explicit for stale or disabled
    extension projections.
15. V1 enforces one installed version per pack id.
16. Artifact naming and collision rules are explicit and fail closed.
17. Canonical Octon manifests are not edited in place by pack install or
   enable flows.
18. The proposal leaves no ambiguity about which implementation work must land
    in `/.octon/` versus repo-root `/.extensions/`.
19. The proposal includes concrete example packs showing how removed Octon
    scoped-template material is re-expressed inside `/.extensions/`:
    - `docs` as a template example plus an ARE-derived skill
    - `node-ts` as a template example
