# Validation Plan

The Mission-Scoped Reversible Autonomy cutover must validate the final state,
not a staged approximation of it. The validators and scenario suite below are
intended to block promotion if the repo would otherwise land in a mixed
operating model, a shadow control plane, or an under-evidenced autonomy path.

## Validation Principles

1. Validate durable authority and runtime contracts before validating generated
   read models.
2. Fail closed on missing autonomy context, missing control receipts, missing
   mission-control files, or summary outputs that read from non-canonical
   surfaces.
3. Treat proposal-package completeness, registry publication, and closeout
   evidence as merge-gated implementation inputs, not optional documentation
   polish.
4. Do not allow an advisory-only first pass. The branch should correct live
   drift and enable blocking validation in the same promotion.
5. Validate absence as well as presence: no legacy autonomous launch path, no
   second control store, and no second authoritative activity journal may
   survive the cutover.

## Blocking Validator Families

| Validator family | Durable targets | Promotion must fail when... |
| --- | --- | --- |
| Proposal package integrity | Proposal package files plus `/.octon/generated/proposals/registry.yml` | Required proposal artifacts are missing, reading order drifts, promotion targets are incomplete, or the active proposal registry entry is absent. |
| Manifest and architecture alignment | `.octon/octon.yml`, `framework/cognition/_meta/architecture/specification.md`, `runtime-vs-ops-contract.md`, `contract-registry.yml` | Mission-control roots, control-evidence roots, generated summary roots, or runtime-input bindings are missing or contradictory. |
| Mission authority and repo policy schemas | `instance/orchestration/missions/**`, `instance/governance/policies/mission-autonomy.yml`, `instance/governance/ownership/registry.yml` | `v2` mission charters or policy/ownership documents are missing required fields or still serialize as `v1`. |
| Runtime contract and deny-by-default enforcement | `framework/engine/runtime/spec/**`, `framework/engine/runtime/config/**`, runtime crates | Autonomous requests can still run without mission context, or receipts omit the new recovery, budget, breaker, and directive metadata. |
| Mission-scoped control truth | `state/control/execution/missions/**` | Lease, mode, intent, directive, schedule, budget, breaker, or subscription files are missing, stale, or internally inconsistent. |
| Control-plane receipts and evidence correlation | `state/evidence/control/execution/**` plus `state/evidence/runs/**` | Material control mutations or material execution attempts do not emit the required receipt family and linkage fields. |
| Generated summary correctness and freshness | `generated/cognition/summaries/**` and `generated/cognition/projections/materialized/**` | Mission/operator summaries are missing, stale, incomplete, or sourced from anything other than canonical control, evidence, and continuity surfaces. |
| Source-of-truth and no-shadow-surface enforcement | Whole repo grep and targeted path validation | A legacy autonomy path, hidden control store, or extra authoritative activity ledger survives the branch. |

## Required Assurance Entry Points

Add or upgrade these blocking entry points under
`/.octon/framework/assurance/runtime/_ops/{scripts,tests}/` as part of the
cutover:

| Entry point | Purpose |
| --- | --- |
| `validate-mission-proposal-package.sh` | Verify this proposal package has the required artifact set and active registry projection while the proposal remains active. |
| `validate-mission-authority.sh` | Validate mission registry `v2`, mission charter `v2`, mission scaffold updates, and ownership/policy schemas. |
| `validate-mission-runtime-contracts.sh` | Validate the new runtime schema set and that autonomous launches deny when mission context is missing. |
| `validate-mission-control-state.sh` | Validate mission-scoped lease, mode, intent, directive, schedule, budget, breaker, and subscription files plus precedence rules. |
| `validate-mission-control-evidence.sh` | Validate control-receipt emission, linkage into run evidence, and retained evidence placement. |
| `validate-mission-generated-summaries.sh` | Validate mission/operator summary completeness, freshness, and canonical-source sourcing. |
| `validate-mission-source-of-truth.sh` | Fail on shadow control stores, legacy autonomy paths, or a second authoritative journal. |
| `test-mission-autonomy-scenarios.sh` | Run the end-to-end scenario matrix for mode, schedule, recovery, breaker, and break-glass behavior. |

These checks should also be aggregated into one dedicated mission-autonomy
alignment entry point or profile so they can run as a single blocking gate in
both local and CI execution.

## Scenario Conformance Matrix

The scenario suite must cover at least the following grouped cases:

| Scenario group | Minimum proof required |
| --- | --- |
| Routine repo housekeeping and high-volume low-risk repetitive work | Non-blocking mode, reversible receipts, digest-oriented awareness, and no per-item approval churn. |
| Long-running refactor and scheduled dependency patching | Boundary-aware pause behavior, feedback-window or proceed-on-silence semantics, and rollback-ready receipts. |
| Release maintenance and destructive high-impact work | `STAGE_ONLY` or `approval_required` enforcement where publish/finalize or irreversible effects are involved. |
| Infra drift correction, external API sync, and data migration/backfill | Correct handling of compensable vs reversible work, checkpoint boundaries, overlap rules, and recovery-window semantics. |
| Monitoring/guard missions and production incident response | Continuous posture without chatter for monitoring, plus bounded emergency proceed-on-silence rules for incident containment only. |
| Absent operator, late feedback, and conflicting human input | Deterministic treatment of silence, late intervention before and after recovery expiry, and precedence handling for conflicting directives. |
| Rollback-path failure, breaker trip, safing entry, and break-glass | Fail-closed escalation, finalize blocking, required receipts, and post-event follow-up obligations. |

## Promotion Gate

Promotion of the implementation branch is blocked until all of the following
are true:

1. The validator families above pass locally and in CI.
2. No autonomous execution path can bypass mission context and still proceed.
3. No shadow control plane or second authoritative activity ledger exists.
4. Active missions, if any exist at implementation time, are migrated to the
   `v2` mission charter and seeded with the required mission-control files.
5. Generated mission/operator summaries are rebuilt and validated against the
   live canonical control, evidence, and continuity surfaces.
6. The cutover has a durable migration plan, a retained evidence bundle, and a
   draft ADR before merge.

## Required Closeout Evidence

When the cutover is implemented, it should retain one evidence bundle under:

```text
/.octon/state/evidence/migration/<YYYY-MM-DD>-mission-scoped-reversible-autonomy-cutover/
```

That bundle should contain at least:

- `bundle.yml`
- `evidence.md`
- `validation.md`
- `commands.md`
- `inventory.md`

The proposal remains active until the durable cutover artifacts exist and the
implementation no longer depends on proposal-local guidance.
