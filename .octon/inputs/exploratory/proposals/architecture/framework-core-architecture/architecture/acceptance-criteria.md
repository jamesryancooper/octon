# Acceptance Criteria

The framework/core architecture proposal is ready for promotion when all of
the following are true:

1. `framework/**` is explicitly defined as the portable authored Octon core
   bundle.
2. The architecture states that `framework/**` is the base authored authority
   surface of the super-root.
3. The architecture states that `framework/**` remains internally
   domain-organized even though the super-root top level is class-first.
4. `framework/manifest.yml` is documented and validated as a required
   framework companion manifest.
5. `framework/manifest.yml` is defined to carry framework identity, release
   version, supported instance schema versions, overlay registry binding,
   subsystems, and generators.
6. `framework/overlay-points/registry.yml` is documented and validated as the
   framework-owned overlay registry.
7. The architecture states that overlay points are declared by framework and
   are never inferred by instance.
8. The architecture states that no framework artifact is implicitly
   overlayable.
9. The architecture states that instance overlay behavior is legal only at
   declared overlay points.
10. The architecture defines the canonical framework domains that belong inside
    `framework/**`.
11. The architecture explicitly allows framework `_ops/**` assets only as
    portable helpers for validation, packaging, migration, generation, or
    update work.
12. The architecture explicitly rejects repo-specific ingress, bootstrap,
    locality, context, decisions, continuity, or governance overlays from
    `framework/**`.
13. The architecture explicitly rejects mutable state and retained evidence
    from `framework/**`.
14. The architecture explicitly rejects raw extension packs and raw proposals
    from `framework/**`.
15. The architecture explicitly rejects generated effective views, registries,
    summaries, graphs, and projections from `framework/**`.
16. The architecture states that repo-specific durable authority belongs in
    `instance/**`, not in `framework/**`.
17. The architecture states that operational truth belongs in `state/**`, not
    in `framework/**`.
18. The architecture states that raw inputs belong in `inputs/**`, not in
    `framework/**`.
19. The architecture states that generated outputs belong in `generated/**`,
    not in `framework/**`.
20. `bootstrap_core` is defined to include the full framework bundle plus only
    minimal root and instance seed metadata.
21. The architecture states that normal framework updates do not directly
    rewrite repo-owned context, ADRs, continuity, proposals, or other
    repo-specific authority.
22. Framework compatibility with adopted repositories is rooted in the
    supported instance schema range declared by `framework/manifest.yml`.
23. The architecture states that first-party bundled extension packs remain
    packs under `inputs/additive/extensions/**` rather than becoming framework
    content.
24. Validators reject wrong-class placement of repo-specific durable authority
    into `framework/**`.
25. Validators reject mutable state or retained evidence placed into
    `framework/**`.
26. Validators reject direct framework runtime or policy dependence on raw
    `inputs/**`.
27. Validators reject generated outputs treated as framework source of truth.
28. Validators reject missing or schema-invalid framework manifest and overlay
    registry files.
29. Validators reject framework helper assets under `_ops/**` that act as
    repo-owned state sinks.
30. Validators reject undeclared instance shadowing of framework artifacts and
    attempts to overlay non-overlayable framework surfaces.
31. Operator guidance and architecture references describe framework as the
    portable authored core bundle rather than as a generic shared tree.
32. Downstream proposals are constrained to treat `framework/**` as the stable
    portable bundle boundary and may not reintroduce mixed-tree ambiguity about
    what belongs in framework.
