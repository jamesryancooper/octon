# Acceptance Criteria

The migration and rollout completion review proposal is ready for promotion
when all of the following are true:

1. The proposal explicitly defines Packet 15 as a post-migration completion
   review rather than a new topology-design exercise.
2. The proposal explicitly requires migration completion to be proved from
   live canonical surfaces plus retained receipts.
3. The proposal explicitly treats unresolved `CRITICAL` and `HIGH` findings as
   blockers for any clean-completion verdict.
4. The proposal explicitly defines `CRITICAL`, `HIGH`, `MEDIUM`, and `LOW`
   severity classes for review findings.
5. The proposal explicitly requires four mandatory audit layers:
   grep sweep, cross-reference audit, semantic read-through, and
   self-challenge.
6. The proposal explicitly requires lens isolation between those review
   layers.
7. The proposal explicitly requires coverage proof rather than findings-only
   reporting.
8. The proposal explicitly requires self-challenge to look for blind spots and
   counter-examples before completion is declared.
9. The proposal explicitly defines a final retained review bundle under
   `state/evidence/migration/**`.
10. The proposal explicitly requires the final review bundle to include
    `bundle.yml`.
11. The proposal explicitly requires the final review bundle to include
    `evidence.md`.
12. The proposal explicitly requires the final review bundle to include
    `commands.md`.
13. The proposal explicitly requires the final review bundle to include
    `validation.md`.
14. The proposal explicitly requires the final review bundle to include
    `inventory.md`.
15. The proposal explicitly maps every ratified phase from 1 through 15 to a
    required review proof.
16. The proposal explicitly requires the five-class super-root to remain the
    only live topology.
17. The proposal explicitly requires `framework/`, `instance/`, `inputs/`,
    `state/`, and `generated/` to exist as the canonical class roots.
18. The proposal explicitly requires `octon.yml`,
    `framework/manifest.yml`, and `instance/manifest.yml` to remain the
    canonical root and companion manifests for review.
19. The proposal explicitly requires the class-root bindings and profile model
    to be re-verified from `.octon/octon.yml`.
20. The proposal explicitly requires repo-root `AGENTS.md` and `CLAUDE.md` to
    remain thin adapters to `.octon/AGENTS.md`.
21. The proposal explicitly requires review of the canonical ingress at
    `.octon/instance/ingress/AGENTS.md`.
22. The proposal explicitly requires review of `.octon/README.md`.
23. The proposal explicitly requires review of
    `.octon/instance/bootstrap/START.md`.
24. The proposal explicitly requires review of
    `.octon/framework/cognition/_meta/architecture/specification.md`.
25. The proposal explicitly requires review of
    `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`.
26. The proposal explicitly requires the raw-input dependency ban to remain
    fail-closed.
27. The proposal explicitly requires runtime and policy consumers to remain
    isolated from raw `inputs/**`.
28. The proposal explicitly requires grep-sweep detection of direct runtime or
    policy reads from `inputs/additive/extensions/**`.
29. The proposal explicitly requires grep-sweep detection of direct runtime or
    policy reads from `inputs/exploratory/proposals/**`.
30. The proposal explicitly requires grep-sweep detection of legacy
    `.proposals/**` references outside historical resources or receipts.
31. The proposal explicitly requires grep-sweep detection of numbered active
    proposal-package directories.
32. The proposal explicitly requires grep-sweep detection of
    `repo_snapshot_minimal`.
33. The proposal explicitly requires grep-sweep detection of mixed-path or
    external-workspace assumptions that contradict the ratified blueprint.
34. The proposal explicitly requires `repo_snapshot` to remain behaviorally
    complete in v1.
35. The proposal explicitly requires enabled-pack dependency closure to remain
    part of `repo_snapshot`.
36. The proposal explicitly forbids reintroducing a v1 minimal
    `repo_snapshot` profile.
37. The proposal explicitly requires generated runtime-facing outputs to
    publish only from `generated/effective/**`.
38. The proposal explicitly requires generated proposal discovery to publish
    from `generated/proposals/registry.yml`.
39. The proposal explicitly requires `generated/proposals/registry.yml` to
    remain non-authoritative.
40. The proposal explicitly requires raw proposal material to remain
    non-canonical before, during, and after review.
41. The proposal explicitly requires active and archived proposals to live
    under `inputs/exploratory/proposals/**`.
42. The proposal explicitly requires all ratified packet proposals 1 through
    14 to remain archived and discoverable under
    `.octon/inputs/exploratory/proposals/.archive/architecture/**`.
43. The proposal explicitly requires review correlation to
    `.octon/instance/cognition/context/shared/migrations/index.yml`.
44. The proposal explicitly requires review correlation to retained cutover
    bundles under `.octon/state/evidence/migration/**`.
45. The proposal explicitly requires retained migration evidence to remain in
    `state/**` rather than be treated as generated cache.
46. The proposal explicitly requires repo continuity to live under
    `state/continuity/repo/**`.
47. The proposal explicitly requires scope continuity to live under
    `state/continuity/scopes/<scope-id>/**`.
48. The proposal explicitly requires proof that repo continuity migrated
    before scope continuity.
49. The proposal explicitly requires scope continuity to depend on validated
    locality.
50. The proposal explicitly requires locality authority to remain under
    `instance/locality/**`.
51. The proposal explicitly requires extension raw packs to remain under
    `inputs/additive/extensions/**`.
52. The proposal explicitly requires the desired/actual/quarantine/compiled
    extension split to survive migration review unchanged.
53. The proposal explicitly requires review of
    `.octon/instance/extensions.yml` as desired authored extension state.
54. The proposal explicitly requires review of
    `.octon/state/control/extensions/active.yml` as actual published
    extension truth.
55. The proposal explicitly requires review of
    `.octon/state/control/extensions/quarantine.yml` as current blocked-state
    truth.
56. The proposal explicitly requires review of
    `.octon/generated/effective/extensions/**` as the compiled runtime-facing
    extension publication family.
57. The proposal explicitly requires publication coherence across extension
    active state, quarantine state, generation lock, and retained publication
    receipts.
58. The proposal explicitly requires review of
    `.octon/generated/effective/locality/**` and
    `.octon/generated/effective/capabilities/**` as compiled runtime-facing
    views.
59. The proposal explicitly requires no second authored authority surface
    outside `framework/**` and `instance/**`.
60. The proposal explicitly requires no live runtime, policy, or authoring
    dependency on legacy paths before declaring completion.
61. The proposal explicitly requires any surviving shim to be thin and
    non-authoritative.
62. The proposal explicitly requires shim retirement conditions to be checked
    before completion is declared.
63. The proposal explicitly requires rollback guidance to preserve retained
    migration receipts rather than revive abandoned dual-authority paths.
64. The proposal explicitly requires final completion claims to be promotable
    into durable assurance, workflow, architecture, and evidence surfaces
    rather than left proposal-local.
