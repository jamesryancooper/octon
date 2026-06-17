# Correction Prompt: OCFGPP-VFY-002

finding_id: OCFGPP-VFY-002
severity: P1
status: resolved
generated_at: 2026-06-17T18:34:58Z
resolved_at: 2026-06-17T18:59:24Z

## Finding

`validate-execution-governance.sh` still requires protected GitHub
control-plane workflows to dual-write canonical approval artifacts. That
validator expectation conflicts with this accepted packet's Change-first
GitHub projection policy after the approved `.github/**` correction removed
GitHub-side authority materialization from PR autonomy, AI gate, and
auto-merge workflows.

## Evidence

- Retained failing log:
  `.octon/state/evidence/validation/proposals/octon-change-first-github-projection-policy/20260617T183458Z/verify-validate-execution-governance.log`
- Failure:
  `GitHub control-plane workflows must dual-write into canonical approval artifacts`

## Affected Paths

- `.octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh`
- `.github/workflows/pr-autonomy-policy.yml`
- `.github/workflows/ai-review-gate.yml`
- `.github/workflows/pr-auto-merge.yml`

## Correction Scope

This correction was not authorized inside the original packet implementation
scope. It was resolved by the follow-on operator-authorized assurance alignment
route requested after blocked closeout.

## Required Follow-On Route

Route a separate policy/assurance alignment change for
`validate-execution-governance.sh` so it recognizes GitHub workflows as
projection hosts and verifies that canonical approval artifacts are not minted
from GitHub projection checks.

## Acceptance Criteria

- `validate-execution-governance.sh` aligns with the Change-first GitHub
  projection policy.
- The validator no longer requires GitHub workflows to dual-write canonical
  approval artifacts.
- The validator still proves canonical approval tooling works where durable
  Octon authority contracts require it.
- The current packet can rerun verification with `errors=0`.

## Resolution Evidence

- Updated validator:
  `.octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh`
- Passing execution-governance log:
  `.octon/state/evidence/validation/proposals/octon-change-first-github-projection-policy/20260617T190000Z-followon/validate-execution-governance.log`
- Passing final verification summary:
  `.octon/state/evidence/validation/proposals/octon-change-first-github-projection-policy/20260617T190000Z-followon/final-verification-summary.tsv`
