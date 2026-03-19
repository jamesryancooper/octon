# Acceptance Criteria

The super-root semantics and taxonomy proposal is ready for promotion when all
of the following are true:

1. The root architecture contract defines `framework/`, `instance/`,
   `inputs/`, `state/`, and `generated/` as the only canonical top-level
   class roots under `/.octon/`.
2. The canonical root invariant is class-first rather than domain-first.
3. `framework/**` and `instance/**` are the only authoritative authored
   surfaces.
4. `state/**` is explicitly limited to mutable operational truth and retained
   evidence.
5. `generated/**` is explicitly rebuildable and non-authoritative.
6. `inputs/**` is explicitly non-authoritative and split into additive raw
   extensions and exploratory raw proposals.
7. Runtime and policy dependency-direction rules explicitly forbid direct
   dependence on raw `inputs/**` paths.
8. The class model makes future path placement unambiguous as framework,
   instance, inputs, state, or generated.
9. The old default guidance to copy the whole `.octon/` tree is retired from
   the root architecture framing.
10. `octon.yml` is defined as the authoritative super-root manifest rather
    than a path allowlist plus incidental state bucket.
11. The root manifest model explicitly supports class-root bindings and
    profile semantics.
12. `framework/manifest.yml` and `instance/manifest.yml` are required
    companion manifests in the target state.
13. Repo-root ingress adapters are treated as thin projections only, with
    canonical ingress content under `instance/ingress/**`.
14. Instance overlays are legal only at framework-declared overlay points.
15. Validation rules explicitly reject wrong-class placement when placement is
    part of the canonical contract.
16. Validation rules explicitly reject partial cutovers that leave the repo
    depending on both legacy mixed paths and ratified class-root paths.
17. Validation rules explicitly reject stale or unresolved required effective
    outputs.
18. The v1 portability model defines `bootstrap_core`, `repo_snapshot`,
    `pack_bundle`, and `full_fidelity` as the canonical profile set.
19. `repo_snapshot` is defined as behaviorally complete and includes enabled
    extension-pack dependency closure.
20. The architecture explicitly rejects a v1 `repo_snapshot_minimal`.
21. Portability, compatibility, and trust are described as manifest and
    control-plane concerns, not accidental path behavior.
22. The proposal records that generated outputs and repo state are excluded
    from clean bootstrap by default.
23. The migration sequence is anchored on this proposal and orders downstream
    work from taxonomy first through migration cleanup last.
24. Downstream proposals are required to align to this taxonomy and are not
    permitted to assume a competing top-level topology.
25. Descendant-local `.octon/` roots, `.octon.global/`, `.octon.graphs/`, and
    a generic `memory/` surface remain explicitly rejected.
