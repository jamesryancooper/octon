# ADR 083: Unified Execution Constitution Phase 7 Build-To-Delete Institutionalization

- Date: 2026-03-29
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-29-unified-execution-constitution-phase7-build-to-delete-institutionalization/plan.md`
  - `/.octon/state/evidence/migration/2026-03-29-unified-execution-constitution-phase7-build-to-delete-institutionalization/`
  - `/.octon/state/evidence/validation/publication/build-to-delete/2026-03-29/`
  - `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/`

## Context

After Phase 6, the repo had removed major transitional scaffolding, but the
Phase 7 gap from the packet and audit remained:

- retirement governance still centered on a narrow policy plus a one-date
  closeout packet
- drift, support-target, and adapter reviews existed more as retained evidence
  than as durable recurring review contracts
- deletion intent existed, but ablation-backed receipts for delete, retain, or
  demote decisions were not yet institutionalized

That meant build-to-delete was real in policy, but not yet durable enough to
govern future simplification without re-deriving the process each time.

## Decision

Execute Phase 7 as the institutionalization pass for build-to-delete.

Rules:

1. `retirement-registry.yml` is the canonical inventory for registered,
   historical-retained, and retired compensating mechanisms.
2. Drift, support-target, adapter, and retirement reviews are explicit blocking
   contracts with triggers, owners, and evidence requirements.
3. Deletion and retention decisions require an ablation-driven workflow receipt.
4. The final target-state claim fails closed when the build-to-delete review
   packet is missing, stale, or contradicted by the retirement registry.
5. Historical closeout packets remain lineage only; the canonical gate moves to
   the recurring build-to-delete packet.

## Consequences

### Benefits

- Retirement status is now visible, reviewable, and machine-checkable.
- Future deletions can be governed by ablation evidence instead of ad hoc
  judgment.
- The final unified-execution claim has a durable closeout gate instead of a
  point-in-time checklist.

### Costs

- Governance contract surface area increases because recurring review contracts
  and receipts are now first-class artifacts.
- Historical lineage remains in the repo, but now with explicit non-authority
  and retirement semantics.

## Completion

This decision is complete once:

- the retirement registry, review contracts, and ablation workflow are active
- CI and closeout validation enforce the new build-to-delete packet
- final target-state claim criteria pass with no missing review or retirement
  evidence
