# Correction Prompt: OCFGPP-VFY-001

finding_id: OCFGPP-VFY-001
severity: P1
status: resolved
generated_at: 2026-06-17T18:34:58Z

## Finding

`.github/workflows/pr-autonomy-policy.yml` still calls
`evaluate-pr-autonomy-policy.sh` with `--request-id`, `--run-id`,
`--target-id`, and `--issued-by`. The evaluator treats those optional
arguments as a request to call `project-github-control-approval.sh`, which
materializes canonical approval/request artifacts from a GitHub workflow.

That conflicts with this packet's Change-first GitHub projection policy:
GitHub workflows may project branch-pr evidence, but they must not mint or
upload canonical Change authority artifacts.

## Affected Paths

- `.github/workflows/pr-autonomy-policy.yml`

## Correction Scope

Apply the smallest correction inside the approved `.github/**` target set:

- keep `evaluate-pr-autonomy-policy.sh` as the PR-autonomy classifier
- stop passing authority-materialization arguments from the workflow
- remove approval/request/grant artifact uploads from this workflow
- retain the generated policy result JSON as branch-pr projection evidence

Do not edit durable Change-first authority contracts, generated effective
outputs, or unapproved targets.

## Acceptance Criteria

- `pr-autonomy-policy.yml` contains no `--request-id`, `--run-id`,
  `--target-id`, or `--issued-by` arguments to
  `evaluate-pr-autonomy-policy.sh`.
- `pr-autonomy-policy.yml` no longer uploads
  `.octon/state/control/execution/approvals/**` or
  `.octon/state/evidence/control/execution` as GitHub workflow artifacts.
- `validate-github-projection-alignment.sh` still passes.
- `validate-proposal-implementation-conformance.sh` and
  `validate-proposal-post-implementation-drift.sh` still pass for the packet.

## Resolution

Resolved by removing the authority-materialization arguments and approval
artifact upload paths from `.github/workflows/pr-autonomy-policy.yml`. The
remaining execution-governance validator conflict is tracked separately as
`OCFGPP-VFY-002` because it is outside this packet's approved `.github/**`
correction scope.
