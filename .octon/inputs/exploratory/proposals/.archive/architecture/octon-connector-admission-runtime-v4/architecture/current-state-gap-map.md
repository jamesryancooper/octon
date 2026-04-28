# Current-State Gap Map

## Existing repo support

| Area | Current repo evidence | v4 relevance |
| --- | --- | --- |
| Proposal standard | `.octon/framework/scaffolding/governance/patterns/proposal-standard.md` | Packet must be manifest-governed and non-authoritative. |
| Architecture proposal standard | `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` | Packet must include architecture manifest and required docs. |
| Authority model | `.octon/framework/cognition/_meta/architecture/specification.md` | Connector truth must land in authored/control/evidence roots, not generated/input. |
| Support targets | `.octon/instance/governance/support-targets.yml` | Default route deny; bounded-admitted-finite; browser/api are non-live surfaces. |
| Capability packs | `.octon/instance/governance/capability-packs/registry.yml` | Connector operations must map to existing packs rather than MCP-as-pack. |
| Execution authorization | `.octon/framework/engine/runtime/spec/execution-authorization-v1.md` | Material connector operations must pass through grants and authorized effects. |
| Material side-effect inventory | `.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml` | Connector invocation maps to service invocation or other material classes. |
| Campaign criteria | `.octon/framework/orchestration/practices/campaign-promotion-criteria.md` | Campaigns remain optional/deferred; connector work must not force promotion. |
| Watcher/automation practice | `watcher-operations.md`, `automation-operations.md` | Events/routing hints do not authorize work; repeated failures must pause/escalate. |

## Gaps

1. No canonical connector-operation contract.
2. No connector admission contract with modes and proof requirements.
3. No trust dossier structure for connector operations.
4. No connector-specific control root for active/quarantined/retired posture.
5. No connector-specific retained evidence root.
6. No connector execution receipt shape.
7. No runtime/CLI inspect/admit/quarantine/retire surfaces.
8. No validator ensuring connector operations map to capability packs and material-effect classes.
9. No explicit connector drift gate.
10. No support-target expansion proof pipeline specifically for connectors.

## Why this blocks v4

Without connector admission, v4 cannot safely support MCPs, APIs, browser operations, release providers, external services, or cross-repo tool operations. Any attempt to add portfolios or release automation first would either remain coordination-only or risk bypassing the capability/support/authorization model.
