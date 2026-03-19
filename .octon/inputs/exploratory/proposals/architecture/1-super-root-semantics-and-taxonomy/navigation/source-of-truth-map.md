# Source Of Truth Map

## Canonical Authority

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Super-root topology and class semantics | `.octon/framework/cognition/_meta/architecture/specification.md` | Canonical cross-subsystem invariant after promotion; replaces the current domain-first root rule |
| Super-root manifest and class-root bindings | `.octon/octon.yml` | Declares class roots, versions, profiles, raw-input dependency policy, and generated-output freshness policy |
| Human-readable bootstrap and portability guidance | `.octon/README.md` and `.octon/instance/bootstrap/START.md` | Retires the default "copy the whole `.octon/` tree" mental model |
| Portable framework authority | `.octon/framework/**` | Authoritative authored framework surface; still domain-organized internally |
| Repo-specific durable authority | `.octon/instance/**` | Authoritative authored instance surface for repo-owned artifacts |
| Raw additive extension inputs | `.octon/inputs/additive/extensions/**` | Non-authoritative raw input only; never direct runtime or policy authority |
| Raw exploratory proposal inputs | `.octon/inputs/exploratory/proposals/**` | Non-authoritative exploratory input only; excluded from runtime and policy precedence |
| Mutable operational truth and retained evidence | `.octon/state/**` | Continuity, control state, and evidence authority only |
| Rebuildable effective, graph, projection, summary, and registry outputs | `.octon/generated/**` | Derived outputs only; never source of truth |
| Framework-declared overlay points | `.octon/framework/overlay-points/registry.yml` | Machine-declared overlay contract for later overlay work |
| Repo overlay enablement and instance identity | `.octon/instance/manifest.yml` | Repo-controlled instance metadata and enabled overlay points |

## Derived Or Enforced Projections

| Concern | Derived path or enforcement surface | Notes |
| --- | --- | --- |
| Published extension active state | `.octon/state/control/extensions/active.yml` | Derived actual active state after validation, distinct from desired config |
| Extension quarantine and withdrawal state | `.octon/state/control/extensions/quarantine.yml` | Mutable control truth for blocked packs and dependents |
| Runtime-facing compiled extension view | `.octon/generated/effective/extensions/**` | Runtime reads compiled effective views, not raw inputs |
| Runtime-facing compiled locality view | `.octon/generated/effective/locality/**` | Scope resolution is published as rebuildable effective output |
| Proposal discovery projection | `.octon/generated/proposals/registry.yml` | Derived, non-authoritative proposal index committed by default |
| Class-placement and raw-input dependency validation | `.octon/framework/assurance/runtime/**` | Validators fail closed on wrong-class placement, stale required outputs, or raw-input runtime dependence |
| Migration sequencing and cutover guardrails | `.octon/framework/orchestration/runtime/workflows/` | Migration workflows enforce class-root cutover sequencing and legacy-path removal |

## Boundary Rules

- Only `framework/**` and `instance/**` are authoritative authored surfaces.
- `state/**` is authoritative only for operational truth and retained evidence.
- `generated/**` is always rebuildable and never becomes source of truth.
- Raw `inputs/**` paths must never become direct runtime or policy
  dependencies.
- Repo-root `AGENTS.md`, `CLAUDE.md`, and similar ingress files are thin
  adapters only; canonical ingress content lives under
  `instance/ingress/**`.
- Instance overlays are legal only at framework-declared overlay points.
- Descendant-local `.octon/` roots, `.octon.global/`, `.octon.graphs/`, and
  a generic `memory/` surface remain rejected.
