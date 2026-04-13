---
title: Octon Git/GitHub Autonomy Workflow v1
description: Canonical overview and source-of-truth index for Octon's automation-first Git and GitHub workflow.
---

# Octon Git/GitHub Autonomy Workflow v1

This is the central overview for Octon's Git/GitHub autonomy model.
Use it as the entry point for policy, workflow behavior, and operator actions.

Detailed rules stay in the linked canonical docs. If anything conflicts, follow
the repository contract precedence in `AGENTS.md`.

---

## Scope

This workflow covers:

- Local branch/worktree + PR automation scripts
- GitHub PR triage, policy checks, and autonomous merge behavior
- Provider-agnostic AI review gating
- Release PR automation (`release-please`)
- Daily control-plane drift detection and auto-healing issue handling
- Branch/repo hygiene expectations for autonomy-first operation

---

## Operating Model

Default lane (autonomous):

1. Create branch/worktree.
2. Commit and open draft PR.
3. Let triage + policy + required checks run.
4. Ready + auto-merge when policy allows.
5. Auto-delete merged branch.

Guarded lane (rare human check-in):

- High-impact governance/control-plane changes stay in the manual lane.
- Dependabot major/unknown version jumps stay in the manual lane.
- Human check-in is metadata-level; enforcement runs through canonical approval
  artifacts plus CI/rulesets rather than label authority.

Release lane:

- `release-please` opens/updates release PRs and release metadata.
- Release PRs follow the same auto-merge lane unless explicitly routed to human check-in.
- Runtime binary publishing stays downstream.

Dependency lane (Dependabot):

- `github-actions` patch/minor updates are grouped and auto-merged when checks pass.
- Dependabot-authored PRs skip provider-backed AI review when Actions secrets
  are unavailable; the required AI gate remains active through the
  non-provider path.
- Major or unclassified version jumps are escalation-only and stay in the
  manual lane.

Steady-state health lane:

- `Autonomy Release Health` detects drift, opens/updates a drift issue on
  failure, and auto-closes it when healthy.

AI review lane:

- `AI Review Gate` runs provider adapters (OpenAI + Anthropic), normalizes
  findings, and computes `AI Review Gate / decision`.
- The gate dual-writes projection state into canonical approval artifacts and
  required checks without relying on AI-gate labels.
- Shadow mode: `AI_GATE_ENFORCE=false` (decision check passes with telemetry).
- Strict mode: `AI_GATE_ENFORCE=true` with `AI Review Gate / decision` required
  in the `main` branch ruleset.
- Codex-specific review remains advisory and non-blocking.

Conversation closeout gate:

- For any thread turn that produced file changes, ask:
  `Are you ready to closeout this branch?`
- If yes, execute full closeout lifecycle end-to-end.
- If no, preserve current branch state with no closeout mutations.

---

## Source of Truth Map

Use this table to find canonical detail by concern.

| Concern | Canonical source |
|---|---|
| Commit contract and branch naming | `.octon/framework/agency/practices/commits.md` |
| PR quality policy and autonomy flow | `.octon/framework/agency/practices/pull-request-standards.md` |
| Machine-enforced commit/PR contract | `.octon/framework/agency/practices/standards/commit-pr-standards.json` |
| Merge-critical control-plane contract | `.octon/framework/agency/practices/standards/github-control-plane-contract.json` |
| AI gate policy contract | `.octon/framework/agency/practices/standards/ai-gate-policy.json` |
| Local Git/operator script lane | `.octon/framework/agency/practices/git-autonomy-playbook.md` |
| GitHub token model + autonomy runbook | `.octon/framework/agency/practices/github-autonomy-runbook.md` |
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

- `main` remains PR-first (break-glass only for direct push).
- Repository variable `AUTONOMY_AUTO_MERGE_ENABLED=true`.
- Repository secret `AUTONOMY_PAT` is configured with minimum needed
  fine-grained permissions documented in:
  `.octon/framework/agency/practices/github-autonomy-runbook.md`.
- Branch protection/rulesets enforce required checks on `main`.
- Required AI check is `AI Review Gate / decision` (provider-agnostic).
- Codex review is advisory and not part of required checks.
- Squash merge is the canonical merge strategy.

---

## Operator Entry Points

For local flow:

- `.octon/framework/agency/_ops/scripts/git/git-wt-new.sh`
- `.octon/framework/agency/_ops/scripts/git/git-pr-open.sh`
- `.octon/framework/agency/_ops/scripts/git/git-pr-ship.sh`
- `.octon/framework/agency/_ops/scripts/git/git-pr-cleanup.sh`
- `.octon/framework/agency/_ops/scripts/github/sync-github-labels.sh`

For GitHub operations and drift remediation commands, use:

- `.octon/framework/agency/practices/github-autonomy-runbook.md`

---

## Change Control

Treat this doc as the central overview/index. When behavior changes:

1. Update the detailed canonical docs first (runbooks, standards, templates).
2. Update this overview to match new reality.
3. Land changes in the same PR when possible.
