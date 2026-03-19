# Source Of Truth Map

## Canonical Authority

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Super-root topology, manifest role, and profile semantics | `.octon/octon.yml` | Authoritative super-root manifest after promotion; replaces broad-path export assumptions with explicit install, export, and update profiles |
| Framework identity, generator set, overlay registry binding, and supported instance schema range | `.octon/framework/manifest.yml` | Required companion manifest for framework-scoped compatibility and profile enforcement |
| Repo-instance identity, enabled overlay points, locality binding, and feature toggles | `.octon/instance/manifest.yml` | Required companion manifest for repo-specific bindings and instance-scoped compatibility |
| Desired extension selection, sources, trust, and acknowledgements | `.octon/instance/extensions.yml` | Repo-controlled desired extension config that drives enabled-pack snapshot closure |
| Human-readable bootstrap and portability guidance | `.octon/README.md` and `.octon/instance/bootstrap/START.md` | Must describe profile-driven portability rather than whole-tree copy guidance |
| Root architecture contract | `.octon/framework/cognition/_meta/architecture/specification.md` and `.octon/framework/cognition/_meta/architecture/shared-foundation.md` | Canonical architecture surfaces after promotion; proposal content remains temporary |
| Validation and export enforcement | `.octon/framework/assurance/runtime/**` | Validators reject invalid manifests, incomplete snapshot closure, raw-input dependency violations, and forbidden profile inclusions |
| Migration, export, and update orchestration | `.octon/framework/orchestration/runtime/workflows/**` | Workflow layer enforces cutover sequencing and profile-aware install/export behavior |

## Derived Or Enforced Projections

| Concern | Derived path or enforcement surface | Notes |
| --- | --- | --- |
| Actual active extension state | `.octon/state/control/extensions/active.yml` | Runtime-valid published extension set must align to desired config and compiled outputs |
| Extension quarantine and withdrawal state | `.octon/state/control/extensions/quarantine.yml` | Missing dependencies, compatibility failures, or trust failures block publication here |
| Runtime-facing compiled extension view | `.octon/generated/effective/extensions/**` | Runtime consumes compiled validated outputs, never raw pack payloads |
| Proposal discovery projection | `.octon/generated/proposals/registry.yml` | Derived non-authoritative registry that must list this active proposal package |
| Human-led exclusion zones | declarations in `.octon/octon.yml` | Zones remain control-plane declarations even when profiles are expanded |
| Snapshot completeness checks | root-manifest profile validation and export receipts | `repo_snapshot` must prove enabled-pack payload and dependency closure before publication |

## Boundary Rules

- `/.octon/octon.yml` is the only authoritative root manifest.
- `framework/**` and `instance/**` remain the only authored authority
  surfaces.
- `state/**` remains authoritative only as operational truth and retained
  evidence.
- `generated/**` remains rebuildable and non-authoritative even when committed.
- Raw `inputs/**` may travel in selected profiles but must never become direct
  runtime or policy dependencies.
- Profile definitions describe allowed install/export units; they do not relax
  class-root boundaries or authority precedence.
- `repo_snapshot` is behaviorally complete by definition and must include the
  enabled extension-pack dependency closure.
- `full_fidelity` remains advisory only; exact repository reproduction uses
  normal Git clone semantics rather than a synthetic export profile.
