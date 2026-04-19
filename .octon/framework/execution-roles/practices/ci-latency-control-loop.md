# CI Latency Control Loop

This control loop is the repo’s report-only mechanism for watching GitHub Actions speed and surfacing safe tightening opportunities. It is intentionally conservative: it measures, classifies, and recommends, but it does not change workflow YAML or branch-protection settings on its own.

## Surfaces

- Scheduled GitHub workflow: `CI Latency Audit`
- Local skill: `/audit-ci-latency`
- Canonical Octon workflow: `/evaluate-ci-latency`
- Shared policy: `.octon/framework/execution-roles/practices/standards/ci-latency-policy.json`
- Shared wrapper: `.octon/framework/execution-roles/_ops/scripts/ci/audit-ci-latency.sh`

## Default Cadence

- Weekly, Monday 15:00 UTC
- Manual reruns via `workflow_dispatch` are allowed

## Breach Semantics

- `healthy`: no issue action beyond optional recovery closeout
- `watch`: update an existing latency issue if one is already open
- `breach`: create or update the single CI latency breach issue

## Deliberate v1 Boundaries

- Report-only and issue-only
- No auto-PR generation
- No branch-protection edits
- No `.octon/framework/orchestration/runtime/automations/*` entry yet; GitHub Actions is the periodic executor in this phase
