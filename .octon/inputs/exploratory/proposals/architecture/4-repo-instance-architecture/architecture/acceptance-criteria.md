# Acceptance Criteria

The repo-instance architecture proposal is ready for promotion when all of the
following are true:

1. `instance/**` is explicitly defined as the repo-specific durable
   authoritative layer of the super-root.
2. The architecture states that `instance/**` contains repo-owned authored
   authority and control metadata rather than mutable operational truth.
3. `instance/manifest.yml` is documented and validated as a required instance
   companion manifest.
4. `instance/manifest.yml` is defined to carry instance identity, framework
   binding, enabled overlay points, locality binding, and feature toggles.
5. Canonical internal ingress is explicitly located at
   `instance/ingress/AGENTS.md`.
6. Repo-root ingress adapters are explicitly treated as thin projections only
   and not as separate authority surfaces.
7. `instance/bootstrap/**` is explicitly defined as the canonical home for
   repo bootstrap and onboarding content.
8. `instance/locality/**` is explicitly defined as the canonical home for
   locality and scope authority.
9. `instance/cognition/context/**` is explicitly defined as the canonical home
   for durable repo context.
10. `instance/cognition/decisions/**` is explicitly defined as the canonical
    home for ADRs and other durable authored decisions.
11. `instance/capabilities/runtime/**` is allowed only for genuinely
    repo-specific capabilities.
12. The architecture states that reusable additive capabilities and packs
    belong under `inputs/additive/extensions/**`, not under instance.
13. `instance/orchestration/missions/**` is explicitly defined as the
    canonical home for repo-owned missions.
14. `instance/extensions.yml` is explicitly defined as desired extension
    configuration rather than actual active state.
15. `instance/extensions.yml` remains a one-file v1 surface with `selection`,
    `sources`, `trust`, and `acknowledgements`.
16. The architecture explicitly lists the instance-native surfaces that do not
    rely on framework overlay points.
17. The architecture explicitly lists the overlay-capable instance surfaces
    that are legal only at declared enabled overlay points.
18. The architecture states that undeclared or disabled overlay artifacts in
    overlay-capable instance paths are invalid.
19. The architecture states that Packet 5 owns detailed overlay merge
    semantics and that Packet 4 does not authorize blanket shadow trees.
20. Mutable continuity and retained evidence are explicitly excluded from
    `instance/**`.
21. Generated effective views, graphs, summaries, projections, and registries
    are explicitly excluded from `instance/**`.
22. Raw extension pack payloads are explicitly excluded from `instance/**`.
23. Raw proposals and proposal archives are explicitly excluded from
    `instance/**`.
24. The architecture states that durable repo authority belongs in
    `instance/**`, not in `framework/**`.
25. The architecture states that operational truth belongs in `state/**`, not
    in `instance/**`.
26. The architecture states that raw inputs belong in `inputs/**`, not in
    `instance/**`.
27. The architecture states that generated outputs belong in `generated/**`,
    not in `instance/**`.
28. `bootstrap_core` is defined to exclude `instance/**` except for the
    minimal `instance/manifest.yml` seed.
29. `repo_snapshot` is defined to include `instance/**` as part of the
    behaviorally complete repo export.
30. The architecture states that normal framework updates preserve
    repo-instance authority unless an explicit migration contract applies.
31. The architecture states that desired extension configuration travels with
    the repo snapshot rather than the framework bundle.
32. Validators reject wrong-class placement of mutable state or retained
    evidence into `instance/**`.
33. Validators reject generated outputs treated as repo-instance source of
    truth.
34. Validators reject direct repo-instance runtime or policy dependence on raw
    `inputs/**`.
35. Validators reject missing or schema-invalid `instance/manifest.yml`.
36. Validators reject ingress surfaces that do not resolve to canonical
    internal content under `instance/ingress/**`.
37. Validators reject schema-invalid `instance/extensions.yml` and any attempt
    to treat it as active published extension state.
38. Validators reject repo-native capabilities that silently collide with pack
    ids or enabled extension contributions without declared collision policy.
39. Operator guidance and architecture references describe `instance/**` as
    the durable repo-owned layer rather than as a generic catch-all or mutable
    workspace.
40. Downstream proposals are constrained to treat `instance/**` as the stable
    repo-owned authority boundary and may not reintroduce mixed-tree ambiguity
    about what belongs there.
