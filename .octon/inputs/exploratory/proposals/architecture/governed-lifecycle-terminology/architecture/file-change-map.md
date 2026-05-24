# File Change Map

## Source-Authored Durable Targets

| Path | Intended Change |
| --- | --- |
| `.octon/framework/product/features/catalog.yml` | Rename feature id/name/roles from Lifecycle Autopilot to Governed Lifecycle Orchestration where the current capability is described. |
| `.octon/framework/product/features/lifecycle-autopilot.md` | Retire or rename this current product note. |
| `.octon/framework/product/features/governed-lifecycle-orchestration.md` | New current product note if the file rename is accepted. |
| `.octon/framework/product/roadmap/lifecycle-autopilot.md` | Retire or rename the current roadmap note. |
| `.octon/framework/product/roadmap/governed-lifecycle-orchestration.md` | New current roadmap note if the file rename is accepted. |
| `.octon/framework/engine/runtime/spec/lifecycle-program-controller-invariants.md` | Replace current capability naming with governed lifecycle terminology. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh` | Update product feature validation to enforce the renamed capability note and boundary phrases. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-product-roadmap.sh` | Update roadmap validation to enforce the renamed roadmap note. |
| `.octon/framework/assurance/runtime/_ops/tests/test-validate-product-feature-catalog.sh` | Update fixtures and expectations for the renamed capability. |
| `.octon/framework/assurance/runtime/_ops/tests/test-validate-product-roadmap.sh` | Update fixtures and expectations for the renamed roadmap. |
| `.octon/framework/assurance/runtime/contracts/alignment-profiles.yml` | Update product alignment profile paths. |
| `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/patterns/proposal-program.md` | Replace active extension prose that still calls current program runs Lifecycle Autopilot. |

## Generated Or Derived Targets

| Path | Publication Rule |
| --- | --- |
| `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/bundled-first-party/context/patterns/proposal-program.md` | Regenerate from authored extension input only. |
| Host-projected skills under `.codex/**`, `.claude/**`, and `.cursor/**` | Refresh only as derived host projections if source extension publication changes; these are not promotion targets for this octon-internal packet. |
| `.octon/generated/proposals/registry.yml` | Regenerate from proposal manifests after packet status/path changes as a derived publication output, not a promotion target. |

## Out Of Scope By Default

- Archived proposals and retained evidence with historical `Lifecycle
  Autopilot` references.
- Legacy branch names, run ids, and immutable receipt ids.
- Kaizen/Autopilot historical architecture references not naming this current
  lifecycle product capability.
