# Validation Plan

## Goal

Prove that MSRAOM is complete by validating:

- contracts
- source-of-truth discipline
- route and mode correctness
- scheduler and directive semantics
- recovery/finalize correctness
- summary and projection generation
- control evidence coverage
- scenario differentiation

Validation is split into four layers. All four are required.

## Layer 1 — Static Contract Validation

### Required checks
- `version.txt` and `.octon/octon.yml` release-version parity
- mission charter schema validation
- full mission-control file family presence
- contract-family schema validation for all control files
- manifest and contract-registry consistency
- summary/projection root consistency
- `owner_ref` canonical usage
- no legacy `owner` reader dependency

### Required commands
```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-version-parity.sh
bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,mission-autonomy
bash .octon/framework/assurance/runtime/_ops/scripts/validate-mission-runtime-contracts.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-mission-source-of-truth.sh
```

## Layer 2 — Runtime Effective-State Validation

### Required checks
- route artifact exists for every active mission
- route ref is present in `mode-state`
- route freshness is within policy TTL
- route field normalization is satisfied
- material autonomous mode with empty intent register fails closed
- material autonomous mode with generic action fallback fails closed
- schedule controls and breaker state influence the evaluator result
- safing and break-glass precedence are reflected in effective state

### Required commands
```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh
bash .octon/framework/orchestration/runtime/_ops/scripts/evaluate-mission-control-state.sh <mission-id>
```

## Layer 3 — Scenario Conformance Suite

The scenario suite must use committed fixtures and/or scripted mission-state
mutations to prove the route and runtime differ appropriately across:

1. routine low-risk housekeeping
2. long-running campaign/refactor
3. dependency/security patching
4. release-sensitive preparation/publish boundary
5. infrastructure drift correction
6. cost optimization / cleanup
7. migration / backfill
8. external sync / external API writes
9. monitoring / guard / observe-only missions
10. production incident response
11. high-volume repetitive work
12. destructive high-impact work
13. absent human
14. late human feedback
15. conflicting human input
16. reversible work
17. compensable-only work
18. irreversible work

### Expected assertions
For each scenario, the suite must assert:
- effective oversight mode
- effective execution posture
- preview and digest behavior
- proceed-on-silence eligibility
- approval or `STAGE_ONLY` behavior
- safe-boundary class
- recovery profile
- finalize behavior
- operator digest route
- control/evidence outputs where mutations occur

### Required command
```bash
bash .octon/framework/assurance/runtime/_ops/scripts/test-mission-autonomy-scenarios.sh
```

## Layer 4 — Generated Read-Model And Evidence Validation

### Required checks
- `now.md`, `next.md`, `recent.md`, `recover.md` exist for every active mission
- operator digests exist for every routed recipient
- machine-readable `mission-view.yml` exists for every active mission
- summaries and projections cite canonical source roots
- retained control receipts exist for:
  - seeding
  - directives
  - authorize-updates
  - schedule mutations
  - budget transitions
  - breaker transitions
  - safing transitions
  - break-glass transitions
  - finalize blocks / closeout

### Example command sketch
```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-mission-views.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-control-evidence-coverage.sh
```

## CI Wiring

The default path is to extend the existing `architecture-conformance` workflow.
If job duration becomes excessive, split the heavy scenario suite into a second
workflow named `mission-autonomy-conformance.yml` and make both required.

Minimum CI job list:
1. `validate-architecture`
2. `validate-mission-runtime-contracts`
3. `validate-runtime-effective-state`
4. `test-mission-autonomy-scenarios`
5. `validate-generated-views-and-control-evidence`

## Release Evidence Bundle

Before cutting `0.6.1`, collect the following under canonical migration and
decision roots:

- validator logs
- version-parity validation proof
- scenario-suite results
- list of migrated missions
- list of generated mission views
- list of generated operator digests
- list of control receipts emitted during validation
- note proving prior completion-cutover packet has been archived

## Final Validation Rule

The release does not proceed until all four layers are green in CI and the
release evidence bundle exists in canonical repo surfaces.
