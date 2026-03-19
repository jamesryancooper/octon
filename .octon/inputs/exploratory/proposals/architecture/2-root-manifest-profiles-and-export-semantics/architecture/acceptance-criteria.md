# Acceptance Criteria

The root manifest and profile model proposal is ready for promotion when all of
the following are true:

1. `/.octon/octon.yml` is documented and validated as the authoritative
   super-root manifest.
2. The root manifest defines the super-root binding and the five class roots
   directly or via a semantically equivalent nested topology contract.
3. The root manifest defines the harness release version and supported schema
   versions.
4. The root manifest defines the extension API version as part of the
   authoritative compatibility contract.
5. `framework/manifest.yml` is required as a companion manifest with framework
   identity, overlay registry binding, generator set, and supported instance
   schema range.
6. `instance/manifest.yml` is required as a companion manifest with instance
   identity, enabled overlay points, locality binding, and feature toggles.
7. The architecture defines `bootstrap_core`, `repo_snapshot`, `pack_bundle`,
   and `full_fidelity` as the canonical v1 profile set.
8. `bootstrap_core` includes only `octon.yml`, `framework/**`, and the minimal
   instance seed needed to initialize a clean repo.
9. `bootstrap_core` explicitly excludes all `inputs/**`, all `state/**`, and
   all `generated/**`.
10. `repo_snapshot` is defined as the default v1 repo export.
11. `repo_snapshot` is defined as behaviorally complete rather than
    best-effort.
12. `repo_snapshot` includes all of `framework/**` and all of `instance/**`.
13. `repo_snapshot` includes every enabled extension pack declared by
    `instance/extensions.yml`.
14. `repo_snapshot` includes the full transitive dependency closure of those
    enabled packs.
15. `repo_snapshot` explicitly excludes `inputs/exploratory/**`, `state/**`,
    and `generated/**`.
16. Snapshot generation fails closed when an enabled pack payload or required
    dependency is missing.
17. `pack_bundle` is defined as selected packs plus dependency closure only.
18. `pack_bundle` explicitly excludes repo-instance authority, proposals,
    state, and generated outputs.
19. `full_fidelity` is documented as advisory clone guidance rather than a
    synthetic export payload.
20. The architecture explicitly rejects a v1 `repo_snapshot_minimal`.
21. Raw-input dependency policy is defined at the root-manifest level and
    remains fail-closed.
22. Generated-staleness policy is defined at the root-manifest level and
    remains fail-closed for required effective outputs.
23. Human-led or excluded zones are declared as control-plane metadata rather
    than accidental path conventions.
24. Validators reject invalid manifests, unknown profiles, or forbidden class
    inclusions for a profile.
25. Validators reject `repo_snapshot` payload sets that omit enabled pack
    closure.
26. Validators reject any attempt to turn raw `inputs/**` into direct runtime
    or policy dependencies.
27. Migration workflows block partial cutovers that mix transitional broad-path
    export assumptions with the ratified profile model.
28. Portability is described as profile-driven rather than path-allowlist
    driven.
29. Compatibility is described as rooted in the root manifest, companion
    manifests, and pack manifests.
30. Trust remains repo-controlled through `instance/extensions.yml`.
31. Downstream proposals are not allowed to weaken `repo_snapshot` behavioral
    completeness or reintroduce default whole-tree copy semantics.
