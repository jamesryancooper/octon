# Source Of Truth Map

## Canonical Authority

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Root fail-closed policy declaration, class-root bindings, and generated-staleness policy | `.octon/octon.yml` | Authoritative super-root manifest for global fail-closed hooks and runtime trust policy |
| Desired extension configuration | `.octon/instance/extensions.yml` | Single repo-authored desired-control surface for extension activation in v1 |
| Current active extension publication truth | `.octon/state/control/extensions/active.yml` | Mutable operational truth for the generation runtime may currently trust |
| Current extension quarantine and withdrawal truth | `.octon/state/control/extensions/quarantine.yml` | Mutable operational truth for blocked packs, affected dependents, and acknowledgements |
| Current locality quarantine truth | `.octon/state/control/locality/quarantine.yml` | Mutable operational truth for quarantined scopes and locality-specific failure reasons |
| Retained validation evidence and enforcement receipts | `.octon/state/evidence/validation/**` | Retained operational evidence, not rebuildable generated output |
| Cross-subsystem authority, state, generated, and fail-closed invariants | `.octon/framework/cognition/_meta/architecture/specification.md` | Canonical architecture surface after promotion |
| Runtime-vs-ops write-target and enforcement boundary | `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md` | Canonical mutation and enforcement contract that Packet 14 must finalize against class-root rules |
| Human-readable bootstrap and operator guidance | `.octon/README.md` and `.octon/instance/bootstrap/START.md` | Must describe the same validation and fail-closed model as the canonical manifests and architecture docs |

## Derived Or Enforced Projections

| Concern | Derived path or enforcement surface | Notes |
| --- | --- | --- |
| Runtime-facing extension compiled view | `.octon/generated/effective/extensions/{catalog.effective.yml,artifact-map.yml,generation.lock.yml}` | Trusted only when the active state, quarantine state, and generation lock remain coherent and fresh |
| Runtime-facing locality compiled view | `.octon/generated/effective/locality/{scopes.effective.yml,artifact-map.yml,generation.lock.yml}` | Scope publication must be republished without quarantined or stale scope contributions |
| Runtime-facing capability routing view | `.octon/generated/effective/capabilities/{routing.effective.yml,artifact-map.yml,generation.lock.yml}` | Runtime may trust capability routing only as a fresh effective publication rather than raw extension or scope inputs |
| Validation, quarantine, and freshness enforcement | `.octon/framework/assurance/runtime/**` and `.octon/framework/orchestration/runtime/workflows/**` | Validators and workflows must enforce fail-closed publication, quarantine isolation, and raw-input dependency bans |
| Proposal discovery for this temporary package | `.octon/generated/proposals/registry.yml` | Derived non-authoritative registry entry for proposal discovery while this package is active |

## Boundary Rules

- `framework/**` and `instance/**` remain the only authored authority
  surfaces.
- `state/**` remains authoritative only as mutable operational truth and
  retained evidence.
- `generated/**` remains rebuildable and non-authoritative even when runtime
  reads it.
- Runtime and policy consumers may trust generated effective outputs only when
  freshness and publication checks pass.
- Raw `inputs/**` paths never become direct runtime or policy dependencies.
- Proposal validation failures remain workflow-local and must not escalate
  into runtime or policy precedence.
- Scope failures quarantine locally where safe; they do not automatically
  collapse unrelated scopes or repo-wide work.
- Pack failures quarantine locally where a coherent surviving publication
  exists; otherwise extension behavior withdraws to framework-plus-instance
  native behavior only.
- Validation receipts and quarantine truth live under `state/**`, not under
  `generated/**`.
- Publication of extension active state and the matching compiled effective
  publication must be atomic from the runtime consumer's point of view.
