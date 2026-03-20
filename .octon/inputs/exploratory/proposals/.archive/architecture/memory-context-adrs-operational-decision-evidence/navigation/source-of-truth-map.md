# Source Of Truth Map

## Canonical Authority

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Memory policy, retention classes, redaction, and flush rules | `.octon/framework/agency/governance/MEMORY.md` | Framework policy governs memory-like classes and retention behavior but does not hold repo-specific durable content |
| Super-root class routing and generated non-authority | `.octon/README.md`, `.octon/instance/bootstrap/START.md`, and `.octon/framework/cognition/_meta/architecture/specification.md` | Packet 11 consumes the already-ratified class-root model instead of re-litigating it |
| Shared durable context routing and context discovery | `.octon/instance/cognition/context/shared/**` and `.octon/instance/cognition/context/index.yml` | Shared context is durable repo-owned authority; `memory-map.md` is a routing guide and `continuity.md` is an optional signal, not active state |
| Scope durable context | `.octon/instance/cognition/context/scopes/<scope-id>/**` | Scope durable context is valid only for declared scope IDs from the locality registry |
| ADR authority and machine discovery | `.octon/instance/cognition/decisions/**` and `.octon/instance/cognition/decisions/index.yml` | Full ADR records remain the only durable decision authority; optional supporting evidence may live under `state/evidence/decisions/**` only as evidence |
| Repo continuity | `.octon/state/continuity/repo/**` | Canonical cross-scope and repo-wide active work state |
| Scope continuity | `.octon/state/continuity/scopes/<scope-id>/**` | Canonical scope-bound active work state; legal only for valid, non-quarantined scopes |
| Run evidence | `.octon/state/evidence/runs/**` plus `.octon/framework/cognition/_meta/architecture/state/continuity/runs-retention.md` | Append-oriented run receipts and digests are retained evidence, not continuity ledgers |
| Operational decision evidence | `.octon/state/evidence/decisions/**` plus `.octon/framework/cognition/_meta/architecture/state/continuity/decisions-retention.md` | Allow, block, escalate, approval, and routing records remain retained evidence rather than ADR authority |
| Validation and migration evidence | `.octon/state/evidence/{validation,migration}/**` | Retained receipts for validation and cutover traceability remain state evidence, not generated output |
| Generated cognition summaries, graphs, and projections | `.octon/generated/cognition/**` | Derived views only; Packet 10 already fixes `generated/**` as non-authoritative |
| Live duplicate-summary drift to normalize | `.octon/instance/cognition/context/shared/decisions.md`, `.octon/generated/cognition/summaries/decisions.md`, and `.octon/instance/cognition/decisions/README.md` | The repo currently carries the same generated ADR summary in both `instance/**` and `generated/**`; Packet 11 resolves the canonical summary home to `generated/cognition/summaries/**` only |

## Derived Or Enforced Projections

| Concern | Derived path or enforcement surface | Notes |
| --- | --- | --- |
| Generated ADR summary publication | `.octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh` and `.octon/generated/cognition/summaries/decisions.md` | The generator remains derived output only; the end state must stop publishing a duplicate generated summary under `instance/**` |
| Continuity and evidence lifecycle enforcement | `.octon/framework/assurance/runtime/_ops/scripts/validate-continuity-memory.sh` | Enforces retention and append-oriented handling for `state/continuity/**` and `state/evidence/**` surfaces |
| Wrong-class placement and duplicate-ledger boundary enforcement | `.octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`, `.octon/framework/assurance/runtime/_ops/scripts/validate-repo-instance-boundary.sh`, and `.octon/framework/cognition/_meta/architecture/specification.md` | Guards against durable authority leaking into `state/**` or generated summaries persisting as parallel authority in `instance/**` |
| Scope continuity legality and quarantine | `.octon/instance/locality/**`, `.octon/state/control/locality/quarantine.yml`, and `.octon/generated/effective/locality/**` | Scope continuity depends on valid scope bindings and locality validation rather than ad hoc directory creation |
| Generated cognition downstream consumers | `.octon/inputs/exploratory/proposals/architecture/generated-effective-cognition-registry/**`, `.octon/inputs/exploratory/proposals/architecture/capability-routing-host-integration/**`, and `.octon/inputs/exploratory/proposals/architecture/validation-fail-closed-quarantine-staleness/**` | Packet 11 must reuse the ratified generated contract and fail-closed model rather than inventing a second summary or projection family |
| Proposal-package discovery | `.octon/generated/proposals/registry.yml` | This proposal package remains exploratory and non-authoritative even when projected into generated discovery |

## Boundary Rules

- Memory is a routing and classification model, not a generic directory.
- No generic `memory/` class root or sidecar ledger may be introduced.
- `instance/**` owns durable context and ADR authority, not mutable work state
  or generated summaries.
- `state/**` owns active continuity, retained evidence, and mutable control
  truth, not authored ADR authority.
- `generated/cognition/**` owns summaries, graphs, and projections only and
  must never replace authored or state truth.
- Repo continuity may summarize or link scope-local work but may not duplicate
  the same detailed operational ledger.
- Evidence may support ADRs, explain routing, or justify validation outcomes,
  but evidence never becomes architecture authority without explicit ADR
  promotion.
