# Source Of Truth Map

## Canonical Authority

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Super-root class placement and generated non-authority | `.octon/README.md` and `.octon/framework/cognition/_meta/architecture/specification.md` | `generated/**` is the rebuildable-output class root only and never becomes source-of-truth |
| Root-manifest portability and generated-staleness policy | `.octon/octon.yml` | `generated/**` stays excluded from `bootstrap_core` and `repo_snapshot`; stale generated effective outputs fail closed by manifest policy |
| Runtime-vs-ops placement of rebuildable output versus retained evidence | `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md` | Mutable generated output belongs under `generated/**`; retained evidence belongs under `state/**` rather than portable `_ops/` or ad hoc generated buckets |
| Runtime-facing effective locality publication | `.octon/generated/effective/locality/{scopes.effective.yml,artifact-map.yml,generation.lock.yml}` | Canonical runtime-facing locality surface, but compiled and non-authoritative; authored scope truth stays under `instance/locality/**` and `state/control/locality/**` |
| Runtime-facing effective extension publication | `.octon/generated/effective/extensions/{catalog.effective.yml,artifact-map.yml,generation.lock.yml}` | Canonical runtime-facing extension surface, but compiled and non-authoritative; desired and actual truth stay in `instance/extensions.yml` and `state/control/extensions/**` |
| Generated cognition read models and summaries | `.octon/generated/cognition/**` | Derived graph, projection, and summary outputs aid inspection and tooling but never replace authored or state surfaces |
| Generated proposal discovery | `.octon/generated/proposals/registry.yml` | Canonical generated proposal-discovery projection, committed by default, and still non-authoritative relative to proposal manifests |
| Retained validation and assurance evidence | `.octon/state/evidence/validation/**` and the Packet 7 state/evidence architecture | Packet 10 reaffirms that retained evidence does not belong in `generated/**` even when produced by validation tooling |
| Live generated drift that must be normalized | `.octon/generated/artifacts/**`, `.octon/generated/assurance/**`, `.octon/generated/effective/assurance/**`, and `.octon/framework/assurance/runtime/README.md` | These are migration-era or packet-predecessor signals, not the final Packet 10 canonical family list |

## Derived Or Enforced Projections

| Concern | Derived path or enforcement surface | Notes |
| --- | --- | --- |
| Locality effective publication freshness and source mapping | `.octon/framework/assurance/runtime/_ops/scripts/validate-locality-publication-state.sh` | Enforces schema, source digests, generation metadata, and fail-closed freshness for `generated/effective/locality/**` |
| Extension effective publication freshness and active-state consistency | `.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh` | Enforces artifact-map, generation-lock, active-state references, dependency closure, and stale-generation refusal for `generated/effective/extensions/**` |
| Proposal package shape and generated registry projection | `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh` and `.octon/generated/proposals/registry.yml` | Ensures active proposals project into the registry without turning the registry into lifecycle authority |
| Wrong-class placement and generated boundary enforcement | `.octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`, `validate-repo-instance-boundary.sh`, and `validate-framework-core-boundary.sh` | Guard against generated or input payloads leaking into authoritative class roots and against missing generated publication scaffolds |
| Capability-routing and memory downstream consumers | `.octon/inputs/exploratory/proposals/architecture/capability-routing-host-integration/**` and `.octon/inputs/exploratory/proposals/.archive/architecture/memory-context-adrs-operational-decision-evidence/**` | Packets 11 and 12 must consume the Packet 10 generated contract rather than re-inventing alternate output families |
| Proposal discovery for this temporary package | `.octon/generated/proposals/registry.yml` | The active registry entry for this proposal is derived, rebuildable, and non-authoritative |

## Boundary Rules

- `generated/**` contains rebuildable outputs only and never becomes authored
  or operational source-of-truth.
- Runtime and policy consumers may read only published effective outputs where
  Packet 10 or downstream packets require compiled views.
- `generated/cognition/**` remains derived inspection and tooling support
  only, even when some artifacts are committed by default.
- `generated/proposals/registry.yml` is discovery only and may not replace
  proposal manifests as lifecycle authority.
- Retained validation, assurance, and other non-rebuildable receipts belong in
  `state/evidence/**`, not `generated/**`.
- `generated/artifacts/**`, `generated/assurance/**`, and the current
  `generated/effective/assurance/**` surface are migration-era drift until a
  ratified destination is applied.
