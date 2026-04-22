# Octon 10/10 Target-State Architecture Hardening

## Purpose

This packet defines a promotion-safe transition from Octon's current live
architecture to a target-state architecture that could credibly earn a true
10/10 architecture evaluation score under a rigorous architecture review.

The packet is **not** a new control plane, a rival architecture, or a proposal to
relax Octon's constitutional model. It preserves the live architecture's best
load-bearing decisions and closes the gaps that currently prevent target-state
quality: enforcement coverage, support-claim partitioning, proof maturity,
publication freshness, pack/extension lifecycle hygiene, operator boot
simplification, runtime deployment maturity, and compatibility-shim retirement.

## Non-authority notice

This packet lives under:

`/.octon/inputs/exploratory/proposals/architecture/octon-architecture-10-10-target-state-hardening/`

It is proposal-local and non-canonical. Promotion outputs must land in durable
surfaces outside `/.octon/inputs/exploratory/proposals/**`. Proposal files may
shape implementation but must never become runtime, policy, support, evidence,
or generated-effective authority.

## Current repo posture this packet assumes

- `/.octon/` is Octon's single authoritative super-root.
- `framework/**` and `instance/**` are the only durable authored authority roots.
- `state/**` is operational truth and retained evidence, not authored authority.
- `generated/**` is derived-only. `generated/effective/**` is runtime-facing only
  when publication receipts and freshness artifacts are current.
- `inputs/**` is non-authoritative and may not become a direct runtime or policy
  dependency.
- Run contracts are the atomic consequential execution unit.
- Missions are continuity containers for long-horizon or recurring autonomy.
- Host/model adapters, host labels, comments, checks, and UI state remain
  non-authoritative projections.
- Support claims are bounded by `/.octon/instance/governance/support-targets.yml`,
  support-target admissions, dossiers, proof bundles, and disclosure coverage.

## Executive architecture judgment

The current architecture is genuinely strong and does not need re-foundation.
The target-state motion is **focused gap-closing with selective moderate
restructuring**:

1. Make the execution authorization boundary mechanically unavoidable.
2. Partition support/admission/dossier artifacts by claim state.
3. Add support-pack-admission invariant gates.
4. Harden generated/effective publication freshness.
5. Consolidate pack and extension lifecycle projections.
6. Split operator boot from closeout and compatibility workflow concerns.
7. Make proof bundles, RunCards, HarnessCards, SupportCards, and replay bundles
   first-class closure artifacts.
8. Retire compatibility shims with owners, review triggers, and removal criteria.

CI workflow edits are included as implementation guidance but deliberately excluded from `promotion_targets` because this active packet is `octon-internal`; if `.github/**` changes are required, they should land through a linked `repo-local` proposal or companion change.

## Recommended reading order

1. `navigation/source-of-truth-map.md`
2. `resources/architecture-evaluation-current-state.md`
3. `resources/10-10-gap-to-target-analysis.md`
4. `architecture/current-state-gap-map.md`
5. `architecture/target-architecture.md`
6. `architecture/architecture-health-contract.md`
7. `architecture/runtime-enforcement-hardening-plan.md`
8. `architecture/support-claim-partition-plan.md`
9. `architecture/pack-extension-publication-plan.md`
10. `architecture/file-change-map.md`
11. `architecture/implementation-plan.md`
12. `architecture/validation-plan.md`
13. `architecture/acceptance-criteria.md`
14. `architecture/migration-cutover-plan.md`
15. `architecture/cutover-checklist.md`
16. `architecture/closure-certification-plan.md`

## Closure principle

This packet closes only when the target state can be demonstrated through
canonical surfaces and retained evidence, not by restating the desired state in
proposal-local documents.
