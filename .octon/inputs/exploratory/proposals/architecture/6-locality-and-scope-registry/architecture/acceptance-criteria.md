# Acceptance Criteria

The locality and scope registry architecture proposal is ready for promotion
when all of the following are true:

1. `instance/locality/**` is explicitly defined as the canonical authored
   locality authority surface.
2. `instance/manifest.yml` is explicitly defined to bind locality through
   `locality.registry_path` and `locality.manifest_path`.
3. `instance/locality/manifest.yml` is explicitly defined as a required
   locality control manifest.
4. `instance/locality/registry.yml` is explicitly defined as the authoritative
   locality registry root.
5. `instance/locality/scopes/<scope-id>/scope.yml` is explicitly defined as
   the canonical per-scope manifest path.
6. The architecture explicitly defines `instance/locality/manifest.yml`,
   `instance/locality/registry.yml`, and per-scope `scope.yml` as repo-owned
   authority under `instance/**`.
7. The architecture explicitly states that locality does not belong in
   `framework/**`, `state/**`, `generated/**`, or `inputs/**`.
8. The architecture explicitly states that every `scope_id` declares exactly
   one `root_path` in v1.
9. The architecture explicitly states that every target path resolves to zero
   or one active scope in v1.
10. The architecture explicitly states that overlapping active scopes are
    invalid.
11. The architecture explicitly states that `include_globs` and
    `exclude_globs` may refine only the rooted subtree declared by
    `root_path`.
12. The architecture explicitly states that multi-root scopes are invalid in
    v1.
13. The architecture explicitly rejects hierarchical scope inheritance.
14. The architecture explicitly rejects ancestor-chain scope composition.
15. The architecture explicitly rejects descendant-local `.octon/` roots.
16. The architecture explicitly rejects local sidecar or capsule locality
    systems.
17. The architecture explicitly rejects mission-defined locality as a
    substitute for the registry.
18. The architecture explicitly defines the minimum required `scope.yml`
    fields.
19. The architecture explicitly requires `scope_id` to be unique across the
    repo.
20. The architecture explicitly requires `display_name`, `owner`, `status`,
    `tech_tags`, and `language_tags` in every `scope.yml`.
21. The architecture explicitly allows `routing_hints` and
    `mission_defaults` only as optional scope metadata rather than alternate
    authority surfaces.
22. Scope-local durable context is explicitly located under
    `instance/cognition/context/scopes/<scope-id>/**`.
23. The architecture explicitly distinguishes shared durable context under
    `instance/cognition/context/shared/**` from scope-local durable context.
24. Scope-local continuity is explicitly located under
    `state/continuity/scopes/<scope-id>/**`.
25. The architecture explicitly states that scope continuity may land only
    after locality registry and validation are live.
26. The architecture explicitly preserves the sequencing rule that repo
    continuity moves before scope continuity.
27. Missions are explicitly defined as scope-referencing orchestration
    containers rather than a second locality system.
28. The architecture explicitly defines the locality resolution order from
    super-root discovery through generated effective locality publication.
29. `instance/locality/manifest.yml` is explicitly required to carry
    `schema_version`, `registry_path`, and `resolution_mode`.
30. `resolution_mode` is explicitly ratified as `single-active-scope` in v1.
31. `instance/locality/registry.yml` is explicitly required to carry
    `schema_version` and `scopes`.
32. The architecture explicitly defines
    `generated/effective/locality/scopes.effective.yml`,
    `generated/effective/locality/artifact-map.yml`, and
    `generated/effective/locality/generation.lock.yml`.
33. The architecture explicitly states that generated effective locality
    outputs are non-authoritative.
34. The architecture explicitly states that generated effective locality
    outputs are committed by default under the ratified generated-output
    policy matrix.
35. The architecture explicitly states that generated effective locality
    outputs remain excluded from `bootstrap_core` and `repo_snapshot`.
36. The architecture explicitly requires effective locality outputs to carry
    source digests, generator version, schema version, and generation
    timestamp.
37. The architecture explicitly states that runtime-facing consumers fail
    closed on stale or invalid effective locality outputs.
38. `state/control/locality/quarantine.yml` is explicitly defined as the
    canonical mutable quarantine surface for invalid scope state.
39. The architecture explicitly states that a quarantined scope is unavailable
    for active resolution until repaired and republished.
40. Validators reject missing or schema-invalid
    `instance/locality/manifest.yml`.
41. Validators reject missing or schema-invalid
    `instance/locality/registry.yml`.
42. Validators reject every declared scope entry that does not resolve to a
    valid `scope.yml`.
43. Validators reject duplicate `scope_id` values.
44. Validators reject any `scope.yml` that declares more than one rooted path
    in v1.
45. Validators reject `include_globs` and `exclude_globs` that escape or
    redefine the declared rooted subtree.
46. Validators reject overlapping active scope bindings for the same target
    path.
47. Validators reject attempts to publish scope-local continuity for
    undeclared or quarantined scopes.
48. Validators reject runtime or policy dependence on raw path conventions in
    place of the authoritative locality registry.
49. Validators reject attempts to treat missions as scope-identity authority.
50. The architecture explicitly states that `instance/locality/**` is
    repo-specific and travels with `repo_snapshot`.
51. The architecture explicitly states that locality definitions do not travel
    with the portable framework bundle.
52. The architecture explicitly states that later packets must consume scope
    metadata from the locality registry and effective locality outputs rather
    than inventing alternate locality sources.
53. Operator guidance and architecture references describe locality through
    the scope registry rather than through mixed domain-path conventions or
    descendant harness topology alone.
54. Teams no longer need to infer locality behavior from mission layout,
    directory naming, or local conventions because one ratified scope registry
    contract defines the model.
