---
title: Octon Git/GitHub Autonomy Workflow v1
description: Canonical overview and source-of-truth index for Octon's worktree-native Git and GitHub workflow.
---

# Octon Git/GitHub Autonomy Workflow v1

This is the central overview for Octon's Git/GitHub workflow model. Use it as
the entry point for policy, workflow behavior, and operator actions.

The workflow is defined for any Git environment that supports linked
worktrees. Octon's local helper scripts are recommended accelerators, not the
durable definition of readiness or mergeability. GitHub remains the final host
merge gate.

The machine-readable workflow contract lives at
`.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`.
Use that contract as the durable source of truth for worktree, closeout,
remediation, helper, and scenario semantics.

Detailed rules stay in the linked canonical docs. If anything conflicts,
follow the repository contract precedence in `AGENTS.md`.

---

## Scope

This workflow covers:

- Primary `main` worktree or clone posture plus branch worktree execution
- Local branch, PR, and cleanup helper scripts
- GitHub route-aware main projection, PR triage, policy checks, and autonomous
  merge behavior
- Provider-agnostic AI review gating
- Release PR automation (`release-please`)
- Daily control-plane drift detection and auto-healing issue handling
- Branch and repo hygiene expectations for worktree-native execution

---

## Operating Model

### Core execution model

1. Keep one clean primary `main` worktree or clone as the integration anchor.
2. Create one branch worktree per branch-routed Change.
3. Do implementation, validation, review remediation, and PR iteration in the
   branch worktree, not on `main`.
4. Open draft PRs only after Change routing selects branch-pr.
5. Treat ready-for-review as a state criterion:
   - the current slice is complete
   - no unresolved author action items remain
   - the lane is appropriate
6. Ready PRs that are already in the correct state report status instead of
   triggering another closeout question.
7. GitHub rulesets, required checks, and reviewer-owned thread resolution
   remain the final merge gate, with the documented solo-maintainer exception
   available only for conversation cleanup.

Shared invariants:

- Never open a PR from `main`.
- Do not stack unrelated work in one worktree.
- Keep the same branch and same PR for the life of the task.

### Route Projection Lanes

Branch-PR lane (autonomous):

1. Create branch worktree.
2. Commit and open draft PR.
3. Let triage, policy, and required checks run.
4. A draft PR in the autonomous branch-pr lane may be marked ready only when
   it is still open and draft, all required checks are green, `AI Review Gate /
   decision` is green when required, PR quality, branch naming, clean-state,
   and autonomy checks are green, no unresolved author-action review threads,
   blocking labels, requested changes, merge conflicts, or stale head state
   remain, and the PR carries required Change receipt or PR closeout evidence.
   For high-impact PRs, explicit self-review of the diff, policy impact,
   evidence, and rollback path is also required.
5. Request squash auto-merge or merge only through the currently valid
   protected-main route.
6. Let GitHub perform or accept the final merge once live rulesets, required
   checks, mergeability, and review policy are satisfied, then fetch and verify
   `origin/main` contains the merged result before recording final closeout
   evidence.

Direct-main lane:

- Land only after Change routing selects `direct-main`.
- Record durable Change receipt evidence with validation, rollback, cleanup,
  and landed-ref proof.
- Do not require PR metadata.

Branch-no-PR lane:

- Push the source branch and validate the exact source SHA.
- Land through fast-forward-only hosted update only when the provider ruleset
  is route-neutral and permits no-PR protected-main update.
- Record provider ruleset ref, pushed source branch, exact source SHA checks,
  rollback, cleanup, and proof that `origin/main` equals the landed ref.

Guarded lane (manual):

- `exp/*` branches stay in the manual lane.
- Manual handling is required only for a concrete unresolved blocker, not for
  high-impact classification alone.
- Dependabot major or unknown version jumps require human compatibility
  judgment only when safe autonomous validation and rollback cannot be proven.
- When escalation is required, report the exact blocker, evidence gathered,
  attempted remediation, and smallest human decision needed.
- Human review and merge remain explicit for escalated PRs, with auto-merge
  off.

High-impact elevated-autonomy lane:

- High-impact governance or control-plane changes stay eligible for autonomous
  `branch-pr` closeout when required evidence and checks are satisfied.
- Before ready or merge request, perform explicit self-review of the diff,
  policy impact, evidence, and rollback path.
- Continue the closeout loop through ready, squash auto-merge request, merge
  watch, `origin/main` verification, and final closeout evidence unless a
  concrete blocker requires escalation.

Release lane:

- `release-please` opens or updates release PRs and release metadata.
- Release PRs follow the same draft-first and lane-selection model unless
  explicitly routed to human check-in.
- Runtime binary publishing stays downstream.

Dependency lane (Dependabot):

- `github-actions` patch and minor updates are grouped and auto-merged when
  checks pass.
- Dependabot-authored PRs skip provider-backed AI review when Actions secrets
  are unavailable; the required AI gate remains active through the
  non-provider path.
- Major or unclassified version jumps require escalation only when the agent
  cannot prove compatibility, validation coverage, and rollback safety.

Steady-state health lane:

- `Autonomy Release Health` detects drift, opens or updates a drift issue on
  failure, and auto-closes it when healthy.

AI review lane:

- `AI Review Gate` runs provider adapters (OpenAI and Anthropic), normalizes
  findings, and computes `AI Review Gate / decision`.
- The gate dual-writes branch-pr projection state into canonical approval
  artifacts and PR checks without relying on AI-gate labels.
- Shadow mode: `AI_GATE_ENFORCE=false` (decision check passes with telemetry).
- Strict mode: `AI_GATE_ENFORCE=true`; `AI Review Gate / decision` remains a
  branch-pr check and is not a universal route-neutral `main` requirement.
- Codex-specific review remains advisory and non-blocking.

### Contextual closeout gate

Closeout prompts are completion-aware and context-sensitive. Ask about
closeout only at a credible completion point or when the operator explicitly
asks to finish, ship, or closeout.

Prompt set:

- **Primary `main` worktree**
  - "This work is on the main worktree, and Octon does not open PRs from
    `main`. Should I branch it into a feature worktree and prepare a draft
    PR?"
- **Branch worktree, no PR yet**
  - "This branch worktree looks ready for PR closeout. Should I stage,
    commit, validate, record a Change receipt, and open a draft PR only if
    branch-pr is selected?"
- **Branch worktree, existing draft PR, autonomous lane**
  - "This draft PR meets Octon's autonomous branch-pr completion policy. Should
    I mark it ready and request squash auto-merge through the protected-main
    route?"
- **Branch worktree, existing draft PR, manual lane**
  - "This draft PR looks ready for the manual lane. Should I mark it ready for
    human review and keep auto-merge off?"
- **Blocked state**
  - No closeout prompt; report blockers instead.

Suppress closeout prompting when:

- active implementation continues
- an open PR has red required checks
- unresolved author action items remain
- a ready PR is waiting on reviewer or maintainer confirmation of
  reviewer-owned threads, or on the documented solo-maintainer exception
  evidence needed to resolve them

Ready PR status responses:

- already ready and waiting on required checks or GitHub auto-merge
- already ready and waiting on reviewer or maintainer confirmation, or on
  solo-maintainer exception evidence
- already ready in the manual lane and waiting on human review or merge

### Helper semantics

- `git-wt-new.sh` creates the branch worktree from the clean integration
  anchor.
- `git-pr-open.sh` is the helper for commit, push, and draft-PR creation.
  Later PR updates happen by pushing follow-up commits to the same branch.
- `git-pr-ship.sh` reports status by default and uses explicit flags to
  request ready-state and merge-lane transitions plus optional cleanup
  handling. It does not prove the PR is ready; autonomous draft completion
  eligibility must be verified before requesting ready or auto-merge.
- `git-pr-cleanup.sh` converges refs and `main` after closure, prunes safe
  linked worktrees when possible, and prints manual follow-up steps when the
  current or another in-use worktree cannot be removed automatically.
- `/closeout-pr` owns the full agent-driven closeout loop from current branch
  worktree through checks, conversations, ready state, and merge or explicit
  blocker.

---

## Source of Truth Map

Use this table to find canonical detail by concern.

| Concern | Canonical source |
|---|---|
| Machine-readable Git/worktree/PR contract | `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml` |
| Commit contract and branch naming | `.octon/framework/execution-roles/practices/commits.md` |
| PR quality policy and autonomy flow | `.octon/framework/execution-roles/practices/pull-request-standards.md` |
| Route-neutral Change closeout loop | `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md` |
| PR-backed closeout subflow | `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md` |
| Machine-enforced commit/PR contract | `.octon/framework/execution-roles/practices/standards/commit-pr-standards.json` |
| Merge-critical control-plane contract | `.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json` |
| AI gate policy contract | `.octon/framework/execution-roles/practices/standards/ai-gate-policy.json` |
| Worktree-native operator playbook | `.octon/framework/execution-roles/practices/git-autonomy-playbook.md` |
| GitHub token model and autonomy runbook | `.octon/framework/execution-roles/practices/github-autonomy-runbook.md` |
| PR body structure contract | `.github/PULL_REQUEST_TEMPLATE.md` |

---

## Workflow Components (GitHub)

Primary autonomy workflows:

- `.github/workflows/pr-triage.yml`
- `.github/workflows/pr-autonomy-policy.yml`
- `.github/workflows/pr-auto-merge.yml`
- `.github/workflows/pr-clean-state-enforcer.yml`
- `.github/workflows/pr-stale-close.yml`
- `.github/workflows/release-please.yml`
- `.github/workflows/autonomy-release-health.yml`
- `.github/workflows/ai-review-gate.yml`
- `.github/workflows/codex-pr-review.yml` (advisory)

Core guardrails that stay active with this model:

- `.github/workflows/main-change-route-guard.yml`
- `.github/workflows/change-route-projection.yml`
- `.github/workflows/main-push-safety.yml`
- `.github/workflows/commit-and-branch-standards.yml`
- `.github/workflows/pr-quality.yml`
- `.github/workflows/deny-by-default-gates.yml`

---

## Required Repository Controls

Minimum control-plane expectations:

- `main` remains Change-first and serves as the clean integration anchor.
- Change routing selects `direct-main`, `branch-no-pr`, `branch-pr`, or
  `stage-only-escalate`; branch worktrees are route outputs, not the default
  work unit.
- Repository variable `AUTONOMY_AUTO_MERGE_ENABLED=true`.
- Repository secret `AUTONOMY_PAT` is configured with minimum needed
  fine-grained permissions documented in
  `.octon/framework/execution-roles/practices/github-autonomy-runbook.md`.
- Current live branch protection may remain PR-required until the accepted live
  migration. The repo-local target is route-neutral protected `main` with
  universal route-neutral checks only.
- `AI Review Gate / decision` and `PR Quality Standards` remain branch-pr
  checks, not universal direct-main or branch-no-pr requirements.
- Reviewer-owned thread confirmation participates in branch-pr merge gating.
- Codex review is advisory and not part of required checks.
- Squash merge is the canonical merge strategy.
- Autonomous draft completion is allowed only for open draft PRs in the
  autonomous `branch-pr` lane after required checks, AI gate when required, PR
  quality, branch naming, clean-state, autonomy policy, review-thread,
  requested-change, conflict, stale-head, Change receipt, and live-ruleset
  criteria are satisfied.
- High-impact PRs require elevated self-review and evidence discipline, but
  high-impact classification alone is not a manual-lane blocker.
- Agents may mark eligible drafts ready and request the protected-main merge
  path, but they must not bypass protected-main controls.

---

## Operator Entry Points

For the recommended helper lane:

- `.octon/framework/execution-roles/_ops/scripts/git/git-wt-new.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-pr-open.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-pr-ship.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-pr-cleanup.sh`
- `.octon/framework/execution-roles/_ops/scripts/github/sync-github-labels.sh`

For managing several active worktrees and sequencing their PRs safely, use:

- `.octon/framework/execution-roles/practices/git-autonomy-playbook.md`

For GitHub operations and drift remediation commands, use:

- `.octon/framework/execution-roles/practices/github-autonomy-runbook.md`

---

## Change Control

Treat this doc as the central overview and index. When behavior changes:

1. Update the detailed canonical docs first (runbooks, standards, templates).
2. Update this overview to match new reality.
3. Land changes in the same PR when possible.
