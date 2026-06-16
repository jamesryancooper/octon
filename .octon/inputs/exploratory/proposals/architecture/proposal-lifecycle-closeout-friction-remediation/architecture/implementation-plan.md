# Implementation Plan

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Rationale: the remediation changes are tightly coupled across lifecycle
  workflow docs, validators, branch helpers, cleanup classification, and
  closeout contracts. A split implementation could leave gate prose,
  validation, and helper behavior inconsistent.

## Workstream 1: Publication Freshness Preflight

Update proposal packet terminal closeout workflow guidance and validators so
terminal closeout can run a pre-terminal freshness bundle before final
archive-ready evaluation.

Candidate durable targets:

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-workflow.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

The implementation must cover capability, extension, runtime route, host
projection, proposal registry, proposal artifact index, and generated handle
freshness without permitting generated output hand edits.

## Workstream 2: Review Digest Refresh After Prompt Generation

Clarify the create/review/implementation-prompt sequence so generating or
refreshing `support/executable-implementation-prompt.md` cannot leave a stale
accepted review digest.

Candidate durable targets:

- `.octon/framework/orchestration/runtime/workflows/meta/create-architecture-proposal/`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

The implementation must not treat implementation-grade completeness as
proposal acceptance.

## Workstream 3: Archive Residue Classification

Improve archive workflow and repo hygiene classification so validation-only
archive subruns and publication side effects route consistently:

- eligible untracked, unreferenced local run residue may be authorized for
  cleanup;
- active control state and durable evidence must be retained or explicitly
  classified for manual review;
- detection alone never authorizes deletion.

Candidate durable targets:

- `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/`
- `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/classify-change-closeout-residue.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-archive-proposal-workflow.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh`
- `.octon/instance/governance/policies/repo-hygiene.yml` only if review shows
  existing policy cannot express the needed classification.

## Workstream 4: Branch-No-PR Empty Check Rationale

Require or validate a retained rationale when `branch-no-pr` authorization uses
an explicitly allowed empty hosted check set.

Candidate durable targets:

- `.octon/framework/execution-roles/_ops/scripts/git/git-branch-authorize-hosted-no-pr.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh`
- `.octon/framework/product/contracts/default-work-unit.md`
- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.md`
- `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

The implementation must not convert `branch-no-pr` into PR-backed routing.

## Workstream 5: Sandbox Escalation Guidance

Add operator-facing guidance to branch landing, branch cleanup, and local main
sync helpers so restricted sandboxes fail with actionable messages when git
ref writes, fetches, pushes, or remote branch checks are required.

Candidate durable targets:

- `.octon/framework/execution-roles/_ops/scripts/git/git-branch-authorize-hosted-no-pr.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-branch-authorize-cleanup.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-branch-cleanup.sh`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md`

## Dependency: Packet Delivery Wrapper

This packet intentionally does not implement an aggregate
`proposal-packet-delivery` workflow, command, skill, profile schema, receipt
schema, wrapper validators, or wrapper-specific fixtures. Those targets are
owned by `proposal-packet-delivery-wrapper`.

The expected relationship is:

- this packet hardens underlying lifecycle and Change-closeout mechanisms;
- `proposal-packet-delivery-wrapper` composes those mechanisms into one
  operator-facing packet delivery route;
- neither packet may treat proposal-local receipts, generated outputs, host
  state, chat, or model memory as authority;
- overlap under `.octon/framework/assurance/runtime/_ops/tests/` is limited to
  fixture families: this packet covers underlying mechanism controls, and the
  wrapper packet covers delivery-wrapper controls.

## Evidence Plan

Retain implementation evidence under proposal support and
`.octon/state/evidence/**` as required by the implemented route. At minimum,
future implementation must retain:

- implementation run receipt;
- implementation conformance review;
- post-implementation drift/churn review;
- validator logs for terminal closeout workflow, archive workflow, publication
  freshness, change closeout lifecycle alignment, repo hygiene governance, and
  negative controls;
- generated publication receipts when generated projections are refreshed;
- branch-no-pr authorization and cleanup receipts if implementation lands by
  branch route;
- terminal current-state proof after final mutation.

## Rollback

Rollback is a normal git revert of authored workflow, validator, helper,
contract, skill, and test changes, followed by regeneration of any derived
outputs through owning scripts. Retain validation, branch, cleanup, and terminal
evidence for auditability.
