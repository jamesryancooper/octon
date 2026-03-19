# Source Of Truth Map

## Canonical Authority

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Portable framework/core identity, release binding, supported instance schema range, overlay registry binding, and bundled generators | `.octon/framework/manifest.yml` | Required framework companion manifest after promotion |
| Framework-declared overlay points and allowed overlay metadata | `.octon/framework/overlay-points/registry.yml` | Framework owns overlay-point declaration; instance may only participate through declared points |
| Cross-subsystem framework boundary and authored-authority precedence | `.octon/framework/cognition/_meta/architecture/specification.md` | Canonical invariant after promotion; framework remains the base authored authority surface |
| Human-readable super-root and framework portability guidance | `.octon/README.md`, `.octon/instance/bootstrap/START.md`, and `.octon/framework/cognition/_meta/architecture/shared-foundation.md` | Must describe framework as the portable authored core bundle rather than a mixed shared tree |
| Portable authored framework domains | `.octon/framework/agency/**`, `.octon/framework/assurance/**`, `.octon/framework/capabilities/**`, `.octon/framework/cognition/**`, `.octon/framework/engine/**`, `.octon/framework/orchestration/**`, `.octon/framework/scaffolding/**` | Portable governance, runtime authority, practices, templates, and framework helpers live here |
| Repo-specific durable authority excluded from framework | `.octon/instance/**` | Repo-owned ingress, bootstrap, locality, context, decisions, missions, and desired extension config remain instance-owned |
| Raw additive and exploratory inputs excluded from framework | `.octon/inputs/**` | Raw extension packs and raw proposals remain non-authoritative inputs |
| Mutable operational truth and retained evidence excluded from framework | `.octon/state/**` | Continuity, evidence, and control state are not part of the framework bundle |
| Rebuildable effective and inspection outputs excluded from framework | `.octon/generated/**` | Effective views, graphs, summaries, projections, and registries remain derived outputs only |
| Framework boundary validation and update enforcement | `.octon/framework/assurance/runtime/**` and `.octon/framework/orchestration/runtime/workflows/**` | Validators and workflows enforce wrong-class placement, overlay safety, portability, and update rules |

## Derived Or Enforced Projections

| Concern | Derived path or enforcement surface | Notes |
| --- | --- | --- |
| Super-root profile inclusion of the framework bundle | `.octon/octon.yml` | `bootstrap_core` and `repo_snapshot` must include the full framework bundle under the ratified profile contract |
| Repo overlay enablement against framework-declared points | `.octon/instance/manifest.yml` | Instance may enable only overlay points that the framework registry declares |
| Runtime-facing effective views that must not be mistaken for framework source | `.octon/generated/effective/**` | Runtime consumes compiled effective outputs, not generated artifacts stored under framework |
| Proposal discovery for this temporary package | `.octon/generated/proposals/registry.yml` | Derived non-authoritative registry that must list this active proposal package |
| Wrong-class placement, raw-input dependency, and undeclared-shadow rejection | validator scripts under `.octon/framework/assurance/runtime/_ops/scripts/` | Fail closed on repo-specific content in framework, raw input dependence, or arbitrary framework shadowing |
| Framework update and migration orchestration | workflow docs and scripts under `.octon/framework/orchestration/runtime/workflows/meta/` | Updates may change framework bundle and explicit migration contracts, but must not rewrite repo-owned instance, state, or proposal content as a normal path |

## Boundary Rules

- `framework/**` is the portable authored Octon core bundle.
- `framework/**` remains internally domain-organized even though the super-root
  top level is class-first.
- `framework/**` may contain portable helper assets under `_ops/**` only when
  they support validation, packaging, migration, generation, or update work
  without becoming repo-state sinks.
- Repo-specific durable authority belongs in `instance/**`, not in
  `framework/**`.
- Mutable operational truth and retained evidence belong in `state/**`, not in
  `framework/**`.
- Generated effective views, registries, summaries, graphs, and projections
  belong in `generated/**`, not in `framework/**`.
- Raw extension packs and raw proposals belong in `inputs/**`, not in
  `framework/**`.
- No framework artifact is implicitly overlayable; instance overlay behavior is
  legal only at framework-declared overlay points.
