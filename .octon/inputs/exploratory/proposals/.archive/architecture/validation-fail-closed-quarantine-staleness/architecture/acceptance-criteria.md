# Acceptance Criteria

The validation, fail-closed, quarantine, and staleness architecture proposal
is ready for promotion when all of the following are true:

1. Validation is explicitly defined as class-root aware across `framework/**`,
   `instance/**`, `inputs/**`, `state/**`, and `generated/**`.
2. The architecture explicitly defines root and class-root contracts,
   authored authority, raw inputs, operational truth, and generated outputs as
   separate validation families.
3. The architecture explicitly defines authoring-time, publication-time,
   runtime-start, export-time, and migration-time validation entrypoints.
4. Runtime and policy consumers are explicitly allowed to trust only authored
   authority, operational truth, and fresh validated effective outputs.
5. The architecture explicitly forbids raw `inputs/**` paths from becoming
   direct runtime or policy dependencies.
6. Publication gates explicitly require valid authoritative inputs, valid
   generated payload schema, matching generation locks, matching source
   digests, coherent active state, and unblocked quarantine state.
7. `.octon/octon.yml` is explicitly treated as the authoritative root
   fail-closed policy declaration surface.
8. Global fail-closed explicitly applies to invalid root manifest state.
9. Global fail-closed explicitly applies to invalid class-root bindings.
10. Global fail-closed explicitly applies to invalid required framework
    contracts.
11. Global fail-closed explicitly applies to invalid required instance control
    metadata.
12. Global fail-closed explicitly applies to invalid required generated
    effective outputs.
13. Global fail-closed explicitly applies to stale required generated
    effective outputs.
14. Global fail-closed explicitly applies to generation locks that do not
    match the published payload set.
15. Global fail-closed explicitly applies to active-state references to
    missing or invalid generations.
16. Global fail-closed explicitly applies to native/extension collisions in
    the active published generation.
17. Global fail-closed explicitly applies to raw-input dependency violations.
18. Scope-local quarantine is explicitly defined as the preferred isolation
    boundary for locality-specific failures.
19. The architecture explicitly quarantines malformed `scope.yml`.
20. The architecture explicitly quarantines overlapping active scope
    bindings.
21. The architecture explicitly quarantines malformed scope context.
22. The architecture explicitly quarantines malformed scope continuity.
23. The architecture explicitly quarantines malformed scope operational
    decision evidence.
24. The architecture explicitly quarantines stale or mismatched scope-derived
    locality publication.
25. `state/control/locality/quarantine.yml` is explicitly defined as the
    canonical scope quarantine control surface.
26. The architecture explicitly states that quarantined-scope work fails
    closed while unrelated scopes may continue.
27. The architecture explicitly requires locality and routing publication to
    stop trusting quarantined scope contributions.
28. Pack-local quarantine is explicitly defined for malformed manifests,
    dependency-closure failures, trust failures, compatibility failures,
    forbidden content usage, invalid publication state, and stale or
    mismatched extension generation locks.
29. `state/control/extensions/quarantine.yml` is explicitly defined as the
    canonical extension quarantine and withdrawal control surface.
30. The architecture explicitly requires invalid packs and unsatisfied
    dependents to be quarantined when a coherent surviving generation still
    exists.
31. The architecture explicitly requires reduced active-set republication when
    a coherent surviving extension generation still exists.
32. The architecture explicitly requires extension withdrawal to
    framework-plus-instance native behavior when no coherent extension
    generation survives.
33. The architecture explicitly states that withdrawal is fail closed and not
    a permissive fallback to raw pack paths.
34. `instance/extensions.yml` is explicitly defined as desired authored
    extension configuration.
35. `state/control/extensions/active.yml` is explicitly defined as actual
    active operational truth.
36. `state/control/extensions/quarantine.yml` is explicitly defined as
    quarantine and withdrawal truth.
37. `generated/effective/extensions/**` is explicitly defined as the compiled
    runtime-facing extension publication family.
38. Runtime trust in extension behavior explicitly requires successful desired
    resolution, a valid published generation id, a fresh generation lock, an
    unblocking quarantine state, and compiled outputs that match the active
    generation.
39. Publication of extension active state, catalog, artifact map, and
    generation lock is explicitly required to be atomic.
40. Proposal validation is explicitly defined as workflow-local only.
41. Invalid proposals are explicitly allowed to block proposal workflows and
    proposal registry generation only.
42. Invalid proposals are explicitly forbidden from blocking runtime or policy
    behavior.
43. Every runtime-facing effective family is explicitly required to carry
    source digests, generator version, schema version, generation timestamp,
    invalidation conditions, and publication status.
44. Runtime and policy consumers explicitly fail closed when a required
    effective output is stale.
45. Runtime and policy consumers explicitly fail closed when a required
    generation lock is missing.
46. Runtime and policy consumers explicitly fail closed when a generation lock
    no longer matches authoritative or validated input digests.
47. Runtime and policy consumers explicitly fail closed when active state
    references a generation that is missing or invalid.
48. Human-facing generated summaries, graphs, and projections are explicitly
    allowed to remain inspectable when stale only if clearly marked stale.
49. `state/evidence/validation/**` is explicitly defined as the canonical home
    for validation receipts and enforcement evidence.
50. The architecture explicitly states that validation receipts are retained
    operational evidence rather than generated convenience artifacts.
51. The architecture explicitly requires control-state files under
    `state/control/**` to remain human-readable enough for operator
    inspection.
52. The architecture explicitly requires validation evidence to answer what
    was validated, against which contract, when, by which validator version,
    and with what outcome.
53. The architecture explicitly requires runtime-vs-ops mutation policy to
    align to class-root-aware `state/**` and `generated/**` enforcement rather
    than mixed legacy path assumptions.
54. The architecture explicitly preserves the desired/actual/quarantine/
    compiled extension model already ratified by the super-root blueprint.
55. The architecture explicitly preserves raw-input dependency bans and does
    not reintroduce permissive fallback from required effective outputs to raw
    inputs.
56. Teams no longer need to infer whether a failure should fail globally,
    quarantine a scope, quarantine a pack, or remain proposal-local because
    one ratified contract defines the boundary.
