# Executable Implementation Prompt

implementation_prompt_id: octon-change-first-github-projection-policy-implementation-prompt-20260617T171851Z
proposal_path: .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-06-17T17:18:51Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace Change receipts, or substitute for retained evidence.
GitHub workflows and templates are projection hosts only; durable Change-first
authority remains in `.octon/framework/product/contracts/default-work-unit.md`,
`.octon/framework/product/contracts/default-work-unit.yml`, and
`.octon/framework/product/contracts/change-receipt-v1.schema.json`.

## Prompt Generation Gate Receipt

The generate-packet-implementation-prompt route observed both prerequisite
gates passing before writing this prompt:

```sh
.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy --require-implementation-authorization
```

Observed result at prompt-generation time: `errors=0 warnings=0` for both
commands.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: align repo-local GitHub projections to the already-promoted
  Change-first default work unit without changing Octon authority contracts
- transitional exception: not authorized

## Mandatory Preflight

Before durable implementation edits, read the repo ingress, constitutional
kernel, default work unit product contract, this packet, all listed promotion
targets, and current worktree status. Preserve unrelated existing edits.

Run:

```sh
.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
.octon/framework/assurance/runtime/_ops/scripts/validate-policy-proposal.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy --require-implementation-authorization
.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
```

Stop if any gate fails, if the review digest is stale, if implementation
authorization is missing, or if the target list has changed without a fresh
accepted review.

## Delegation And Subagent Boundaries

Subagents are optional execution aids, not lifecycle authorities. Use them only
for bounded inspection, comparison, review, or validation-support work where
parallelism reduces implementation risk. The primary implementer owns final
scope control, source edits, receipt authorship, validator execution, and the
closeout recommendation.

Permitted delegation:

- independent read-throughs of one `.github/**` workflow family or PR template
  family against the accepted packet
- validator inventory, command-output summarization, or evidence directory
  inspection
- focused drift checks for stale PR-first terminology, proposal-path
  backreferences, or route/metadata contradictions
- review of candidate diffs after the primary implementer has made source
  edits

Delegation limits:

- do not let subagents edit source files, write packet receipts, change
  `proposal.yml#status`, or expand promotion targets
- do not let subagents decide whether implementation, conformance, drift, or
  closeout has passed
- do not treat subagent findings as retained evidence unless their checked
  paths, commands, and conclusions are cited in packet-local receipts
- do not split canonical Change route semantics across agents; the primary
  implementer must reconcile all route terminology before validation

## Live State Snapshot

The current accepted manifest targets only repo-local GitHub projection files.
All listed targets exist in the current worktree, including the route-aware
main guard and route-neutral closeout projection workflows:

- `.github/workflows/main-change-route-guard.yml`
- `.github/workflows/change-route-projection.yml`
- `.github/workflows/main-push-safety.yml`
- `.github/workflows/commit-and-branch-standards.yml`
- `.github/workflows/pr-quality.yml`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/PULL_REQUEST_TEMPLATE/kaizen.md`
- `.github/PULL_REQUEST_TEMPLATE/orchestration-domain-implementation.md`
- `.github/workflows/pr-autonomy-policy.yml`
- `.github/workflows/pr-auto-merge.yml`
- `.github/workflows/pr-triage.yml`
- `.github/workflows/pr-clean-state-enforcer.yml`
- `.github/workflows/pr-stale-close.yml`
- `.github/workflows/ai-review-gate.yml`
- `.github/workflows/codex-pr-review.yml`
- `.github/workflows/alignment-check.yml`
- `.github/workflows/harness-self-containment.yml`

The stale `.github/workflows/main-pr-first-guard.yml` target is intentionally
absent and must not be reintroduced.

## In Scope

Durable implementation may edit only the approved repo-local projection
targets listed above. Packet-local implementation receipts may be written under
this packet's `support/` directory after durable edits land.

Expected durable work:

1. Align route-aware main update checks so direct-main, branch-no-pr, branch-pr,
   and authorized break-glass outcomes are recognized as distinct Change
   routes, with exactly one accepted route per main update.
2. Keep direct-main and branch-no-pr validation free of required PR metadata.
   A direct-main or hosted no-PR path may require route-neutral closeout,
   validation, rollback, cleanup, landed-ref, and provider evidence, but it must
   not require a pull request.
3. Keep PR quality, review, triage, auto-merge, stale-close, AI review, and
   Codex review workflows scoped to `branch-pr` projection behavior.
4. Keep PR templates as Change receipt projections only. They may ask for
   route, evidence, validation, rollback, and closeout facts, but they must not
   replace canonical Change receipts.
5. Preserve `.github/**` as projection scope. Do not make GitHub labels,
   comments, checks, PR bodies, or workflow outputs authority for Change
   routing, support claims, or closeout truth.

## Out Of Scope

Do not edit `.octon/framework/product/contracts/default-work-unit.md`,
`.octon/framework/product/contracts/default-work-unit.yml`, or
`.octon/framework/product/contracts/change-receipt-v1.schema.json` in this
implementation route. Do not change support-target admissions, governance
exclusions, runtime support claims, run-contract schemas, connector posture, or
generated effective outputs by hand. Do not change `proposal.yml#status`; the
later lifecycle route owns implemented or archived status transitions.

## Ordered Workstreams

### 0. Boundary And Evidence Setup

1. Confirm worktree status and isolate this packet's `.github/**` target edits
   from unrelated local changes.
2. Create a retained evidence directory such as
   `.octon/state/evidence/validation/proposals/octon-change-first-github-projection-policy/<timestamp>/`.
3. Record command logs, target diffs, validator outputs, and rollback notes in
   that evidence directory.

### 1. Route-Aware Main And Closeout Projection

Review and update:

- `.github/workflows/main-change-route-guard.yml`
- `.github/workflows/change-route-projection.yml`

Maintain route-neutral Change semantics:

- `branch-pr` is accepted only from PR-backed evidence.
- `direct-main` requires a Change receipt and must reject PR metadata as route
  evidence.
- hosted branch-no-pr or no-PR landing requires exact source SHA and provider
  evidence without treating provider capability as route authority.
- branch and closeout projections must name Change routes and lifecycle facts,
  not a PR-first default work unit.

### 2. Direct-Main Push Validation

Review and update:

- `.github/workflows/main-push-safety.yml`
- `.github/workflows/commit-and-branch-standards.yml`
- `.github/workflows/alignment-check.yml`
- `.github/workflows/harness-self-containment.yml`

These workflows must be able to validate direct-main push or route-neutral
events without required PR fields. PR-specific checks may still run on PR
events, but push validation must not fail merely because `pull_request`
metadata is absent.

### 3. Branch-PR Review And Publication Projection

Review and update:

- `.github/workflows/pr-quality.yml`
- `.github/workflows/pr-autonomy-policy.yml`
- `.github/workflows/pr-auto-merge.yml`
- `.github/workflows/pr-triage.yml`
- `.github/workflows/pr-clean-state-enforcer.yml`
- `.github/workflows/pr-stale-close.yml`
- `.github/workflows/ai-review-gate.yml`
- `.github/workflows/codex-pr-review.yml`

Keep these workflows scoped to PR-backed Changes. They may automate or validate
branch-pr review, publication, merge, and protected PR behavior, but they must
not imply that PRs, branches, or GitHub are Octon's default work unit.

### 4. PR Template Projection

Review and update:

- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/PULL_REQUEST_TEMPLATE/kaizen.md`
- `.github/PULL_REQUEST_TEMPLATE/orchestration-domain-implementation.md`

Templates may collect Change identity, selected route, validation, evidence,
rollback, and closeout facts for PR-backed Changes. They must state or imply
that canonical Change receipts remain the durable source for Change closeout.

### 5. Packet Receipts

After durable edits and validation, create or update packet-local receipts:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md` when useful for compact command evidence

`support/implementation-conformance-review.md` must include an explicit
`verdict: pass`, `unresolved_items_count: 0`, checked evidence, promotion target
coverage, implementation map coverage, validator coverage, generated output
coverage, rollback coverage, downstream reference coverage, exclusions, and a
final closeout recommendation.

`support/post-implementation-drift-churn-review.md` must include an explicit
`verdict: pass`, `unresolved_items_count: 0`, checked evidence, backreference
scan, naming drift review, generated projection freshness, manifest and schema
validity, repo-local projection boundaries, target family boundaries, churn
review, validators run, exclusions, and a final closeout recommendation.

## Required Validation

Run the packet lifecycle validators:

```sh
.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
.octon/framework/assurance/runtime/_ops/scripts/validate-policy-proposal.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-github-projection-policy
```

Run the GitHub and Change-first projection validators:

```sh
.octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh
.octon/framework/assurance/runtime/_ops/scripts/validate-commit-pr-alignment.sh
.octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh
.octon/framework/assurance/runtime/_ops/scripts/validate-github-projection-alignment.sh
.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh
.octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh
```

Also run YAML or workflow linting already used by this repository when the
implementation changes workflow syntax.

## Rollback Posture

Rollback is a single revert of the `.github/**` target changes and packet-local
implementation receipts from this implementation route, followed by rerunning
the proposal and GitHub projection validators. Do not roll back or rewrite the
upstream Change-first product contract as part of this packet.

## Closeout And Archive Refusal Criteria

Refuse closeout or archive claims if any validator above fails, if retained
evidence is missing or stale, if `.github/**` targets contain active
backreferences to this proposal path, if stale `Work Package` naming survives
outside explicit historical or compatibility context, if direct-main or
branch-no-pr routes require PR metadata, if GitHub projections claim authority,
or if `support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` do not pass their
validators with no unresolved items.

The next lifecycle route after this prompt is `run-packet-implementation`.
