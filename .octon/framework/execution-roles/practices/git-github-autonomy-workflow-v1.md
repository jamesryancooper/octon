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
- GitHub PR triage, policy checks, and autonomous merge behavior
- Provider-agnostic AI review gating
- Release PR automation (`release-please`)
- Daily control-plane drift detection and auto-healing issue handling
- Branch and repo hygiene expectations for worktree-native execution

---

## Operating Model

### Core execution model

1. Keep one clean primary `main` worktree or clone as the integration anchor.
2. Create one branch worktree per task or PR.
3. Do implementation, validation, review remediation, and PR iteration in the
   branch worktree, not on `main`.
4. Open draft PRs early from the branch worktree.
5. Treat ready-for-review as a state criterion:
   - the current slice is complete
   - no unresolved author action items remain
   - the lane is appropriate
6. Ready PRs that are already in the correct state report status instead of
   triggering another closeout question.
7. GitHub rulesets, required checks, and reviewer-owned thread resolution
   remain the final merge gate.

Shared invariants:

- Never open a PR from `main`.
- Do not stack unrelated work in one worktree.
- Keep the same branch and same PR for the life of the task.

### Merge lanes

Default lane (autonomous):

1. Create branch worktree.
2. Commit and open draft PR.
3. Let triage, policy, and required checks run.
4. Move to ready only when the work is complete and the PR is eligible for the
   autonomous lane.
5. Request squash auto-merge.
6. Let GitHub perform the final merge once required checks and review policy
   are satisfied.

Guarded lane (manual):

- `exp/*` branches stay in the manual lane.
- High-impact governance or control-plane changes stay in the manual lane.
- Dependabot major or unknown version jumps stay in the manual lane.
- Human review and merge remain explicit, with auto-merge off.

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
- Major or unclassified version jumps stay in the manual lane.

Steady-state health lane:

- `Autonomy Release Health` detects drift, opens or updates a drift issue on
  failure, and auto-closes it when healthy.

AI review lane:

- `AI Review Gate` runs provider adapters (OpenAI and Anthropic), normalizes
  findings, and computes `AI Review Gate / decision`.
- The gate dual-writes projection state into canonical approval artifacts and
  required checks without relying on AI-gate labels.
- Shadow mode: `AI_GATE_ENFORCE=false` (decision check passes with telemetry).
- Strict mode: `AI_GATE_ENFORCE=true` with `AI Review Gate / decision`
  required in the `main` branch ruleset.
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
    commit, push, and open a draft PR?"
- **Branch worktree, existing draft PR, autonomous lane**
  - "This draft PR looks ready for Octon's autonomous merge lane. Should I
    mark it ready and request squash auto-merge?"
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
  reviewer-owned threads

Ready PR status responses:

- already ready and waiting on required checks or GitHub auto-merge
- already ready and waiting on reviewer or maintainer confirmation
- already ready in the manual lane and waiting on human review or merge

### Helper semantics

- `git-wt-new.sh` creates the branch worktree from the clean integration
  anchor.
- `git-pr-open.sh` is the helper for commit, push, and draft-PR creation.
  Later PR updates happen by pushing follow-up commits to the same branch.
- `git-pr-ship.sh` reports status by default and uses explicit flags to
  request ready-state and merge-lane transitions plus optional cleanup
  handling. It does not prove the PR is ready.
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
| Agent-driven closeout loop | `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md` |
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

- `.github/workflows/main-pr-first-guard.yml`
- `.github/workflows/main-push-safety.yml`
- `.github/workflows/commit-and-branch-standards.yml`
- `.github/workflows/pr-quality.yml`
- `.github/workflows/deny-by-default-gates.yml`

---

## Required Repository Controls

Minimum control-plane expectations:

- `main` remains PR-first and serves as the clean integration anchor.
- One branch worktree or equivalent branch workspace is the default unit of
  execution for one task or PR.
- Repository variable `AUTONOMY_AUTO_MERGE_ENABLED=true`.
- Repository secret `AUTONOMY_PAT` is configured with minimum needed
  fine-grained permissions documented in
  `.octon/framework/execution-roles/practices/github-autonomy-runbook.md`.
- Branch protection and rulesets enforce required checks on `main`.
- Required AI check is `AI Review Gate / decision` (provider-agnostic).
- Reviewer-owned thread confirmation still participates in merge gating.
- Codex review is advisory and not part of required checks.
- Squash merge is the canonical merge strategy.

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
