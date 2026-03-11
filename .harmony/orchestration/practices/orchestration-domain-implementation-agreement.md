# Orchestration Domain Implementation Agreement

These practices govern engineering work that implements or promotes the
orchestration domain from
`/.design-packages/orchestration-domain-design-package/`.

## Scope

Applies to:

- runtime implementation work for orchestration-domain surfaces
- validator and assurance work that proves orchestration behavior
- documentation and promotion work that lands package-defined authority into
  live `/.harmony/orchestration/`
- PRs that touch orchestration contracts, lifecycle rules, routing, evidence,
  recovery, or promotion targets

Does not change higher-precedence repository governance or continuity
ownership.

## Working Agreement

1. Treat the design package as the package-local source of truth.
   - Use
     `/.design-packages/orchestration-domain-design-package/navigation/source-of-truth-map.md`
     to resolve conflicts.
   - Inside the package, use this order:
     1. specific contract docs
     2. detailed control docs
     3. core normative docs
     4. readiness and canonicalization docs
     5. surface references
     6. history and ADRs
2. Preserve continuity ownership.
   - Durable decision evidence stays under `/.harmony/continuity/decisions/`.
   - Durable run evidence stays under `/.harmony/continuity/runs/`.
   - Orchestration runtime projections must not absorb or replace continuity
     evidence authority.
3. Do not invent architecture.
   - If a behavior is defined by a package contract or control doc, implement
     that behavior directly.
   - If two package documents appear to conflict, escalate with both paths
     rather than choosing ad hoc behavior.
4. Keep projections subordinate.
   - `README.md`, `registry.yml`, indexes, dashboards, counters, and mutable
     state files never outrank schema-backed contracts or canonical object
     artifacts.
5. Keep side effects gated.
   - No external side effects before decision, required approval, required
     coordination, canonical run creation, and executor acknowledgement.
6. Keep optional surfaces optional.
   - `campaigns` are deferred by default.
   - Promote `campaigns` only when multi-mission coordination pressure is
     demonstrated and documented.

## Current Surface Decision

Current implementation targets:

- strengthen live `workflows`
- strengthen live `missions`
- implement and promote `runs`
- implement and promote `automations`
- implement and promote `incidents` runtime state when needed
- implement and promote `queue`
- implement and promote `watchers`

Current deferred or optional surface:

- `campaigns`

Current non-blocking subordinate choices:

- storage backend product
- launcher or executor transport
- dashboard or operator UI
- timeout, heartbeat, retry, and tick defaults

Those choices may vary, but they must preserve the package contracts and
ordering rules.

## PR Requirements

1. Every orchestration-domain implementation PR must cite:
   - at least one backlog ID from
     `/.harmony/output/plans/2026-03-10-orchestration-domain-phase0-backlog.md`
   - the package path
   - the primary authority documents used for the change
2. Use the scoped PR template:
   - `/.github/PULL_REQUEST_TEMPLATE/orchestration-domain-implementation.md`
3. If a PR changes live authority surfaces, it must state whether the change is:
   - strengthening an existing live surface
   - promoting a new live surface
   - validator-only groundwork
   - deferred because the surface remains optional
4. If a PR cannot map a behavior to a package authority document, stop and
   escalate before implementation.

## Phase 0 Checklist

- [x] Package validator passes with zero errors and zero warnings.
- [x] Team is using the package source-of-truth map for conflict resolution.
- [x] Continuity boundaries for decisions and runs are accepted and explicit.
- [x] Current implementation targets are explicit.
- [x] Optional surfaces are explicit.
- [x] Orchestration PRs use the scoped PR template and cite backlog IDs.
