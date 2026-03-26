# Mission-Scoped Reversible Autonomy Provenance Alignment Closeout

Historical status: implemented and archived. This packet records the final
proposal-lineage closeout after the `0.6.3` runtime closeout had already
landed. Promotion evidence lives in ADR 068 and the matching migration bundle
under `/.octon/state/evidence/migration/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/`.

This is the **final, atomic provenance-alignment proposal packet** for the
Mission-Scoped Reversible Autonomy Operating Model (MSRAOM).

It is **not** another runtime-remediation proposal. The most recent audit found
the MSRAOM implementation itself complete and integrated, with only residual
governance/proposal-workspace tension remaining:

- proposal-workspace provenance has not fully caught up to the implemented state
- active vs archived MSRAOM proposal lineage is not yet perfectly normalized
- the final closeout intent should be reflected in repo-side decision history

This packet closes those remaining tensions in **one clean-break repository
alignment change**.

The implementation-completeness assessment referenced here is in
[`resources/implementation-audit.md`](./resources/implementation-audit.md).

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- current repo baseline: `0.6.3`
- release posture: **no runtime release bump required**
- cutover style: `atomic`, `clean-break`, `provenance-alignment`, `no-runtime-delta`

## Summary

Promote one final provenance-alignment cutover that:

1. records MSRAOM completion in a canonical repo-side decision artifact
2. archives or supersedes the remaining active MSRAOM proposal-workspace items
3. updates proposal registry / navigation artifacts so the repo tells one clear story
4. updates bootstrap and architecture docs to point operators and implementers to
   canonical runtime and governance sources rather than stale proposal workspaces
5. preserves the runtime model exactly as implemented today

This packet intentionally changes **provenance, navigation, and decision-state** only.

## What This Packet Does Not Change

This packet does **not**:

- change MSRAOM runtime semantics
- change contracts, schemas, policy defaults, or evaluator behavior
- change mission-control truth, evidence, continuity, or generated route logic
- change CI semantics except where provenance checks or registry checks are added
- require a version bump solely for proposal hygiene

If any proposed change in this packet modifies runtime semantics, it is out of scope
and should be rejected.

## Why This Packet Exists

The latest implementation-audit concluded that MSRAOM is complete and integrated, but still noted one
residual tension:

> proposal-workspace provenance should catch up to the implemented state

That is a governance and traceability issue, not a missing operating-model feature.
Because Octon treats proposal packages as part of its architectural memory, the repo
should explicitly show:

- that MSRAOM is complete
- which proposal packets are historical
- which packet closed the final residual tension
- where canonical truth now lives

This packet performs that last alignment.

Since that audit was written, the repo has already landed the `0.6.3`
runtime closeout, archived the steady-state and final-closeout proposal
directories on disk, and written ADRs 066 and 067. The remaining work is now
to normalize those archived proposal manifests, project the full lineage in the
generated registry, add one explicit provenance-closeout ADR and migration
record, and update operator-facing guidance so proposal history no longer reads
like live implementation dependency.

## Promotion Targets

- `.octon/generated/proposals/registry.yml`
- `.octon/instance/cognition/decisions/index.yml`
- `.octon/instance/cognition/decisions/`
- `.octon/instance/cognition/context/shared/migrations/index.yml`
- `.octon/instance/cognition/context/shared/migrations/`
- `.octon/state/evidence/migration/`
- `.octon/README.md`
- `.octon/instance/bootstrap/START.md`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`

## Reading Order

1. `resources/implementation-audit.md`
2. `resources/current-state-traceability-gap.md`
3. `architecture/target-architecture.md`
4. `resources/provenance-alignment-plan.md`
5. `resources/archive-and-decision-map.md`
6. `resources/file-level-change-map.md`
7. `architecture/implementation-plan.md`
8. `architecture/validation-plan.md`
9. `architecture/acceptance-criteria.md`
10. `navigation/source-of-truth-map.md`
11. `navigation/change-map.md`
12. `navigation/artifact-catalog.md`
13. `architecture/cutover-checklist.md`

## Exit Path

After promotion:

- MSRAOM runtime and governance truth remain in their canonical runtime/policy roots
- proposal workspace clearly reflects history, not active implementation dependency
- a canonical ADR/decision states that MSRAOM is complete
- prior MSRAOM proposal packets are archived or marked superseded consistently
- no residual proposal-traceability ambiguity remains
