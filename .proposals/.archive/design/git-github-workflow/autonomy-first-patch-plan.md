# Autonomy-First Git + GitHub Workflow Patch Plan

Status: Draft for implementation
Owner: Governance owner (`@you`)
Primary goal: Maximize release velocity and autonomous execution for solo development with rare human check-ins.

## 1. Outcome and Constraints

## Desired outcome

- Ship more frequently with lower operational overhead.
- Default to machine-governed automation for branch creation, PR creation, labeling, risk classification, readiness, merge, and cleanup.
- Keep human involvement exception-based rather than step-based.

## Non-negotiable constraints to preserve

These remain mandatory and are not modified by this plan:

- `main` is PR-first; direct push only via break-glass override.
  - Source: `AGENTS.md`, `.harmony/cognition/governance/principles/principles.md`, `.github/workflows/main-pr-first-guard.yml`
- ACP + deny-by-default remain the authority model for durable changes.
  - Source: `.harmony/cognition/governance/principles/autonomous-control-points.md`, `.harmony/cognition/governance/principles/deny-by-default.md`
- Harmony harness structure remains under `.harmony/`.
  - Source: `.harmony/START.md`
- Existing domain safety checks remain active (agency/assurance/deny-by-default/main safety).

## 2. Target Operating Profile

## Default lane (autonomous)

- Agent creates branch/worktree, commits, opens draft PR, updates PR body, and pushes continuously.
- PR is auto-labeled (`type:*`, `area:*`, `risk:*`), auto-classified, and moved to ready when gates pass.
- PR is auto-merged (squash) and branch auto-deleted when policy allows.

## Guarded lane (rare human check-in)

- High-impact/path-sensitive changes require explicit `accept:human` label before merge.
- Human check-in is metadata-level (label/decision) rather than manual gate-running.

## Escalation lane

- ACP/contract-driven stage-only, deny, or escalate outcomes remain as-is.
- Break-glass remains explicit and auditable.

## 3. Patch Strategy (Phased)

Use four implementation phases to avoid destabilizing delivery.

### Phase A: Introduce autonomy controls without removing current gates

1. Add triage and policy workflows in parallel with existing checks.
2. Keep current commit/branch and PR-quality checks required.
3. Run new workflows as advisory for one week.

### Phase B: Switch to autonomy-first required checks

1. Make autonomy policy and triage checks required.
2. Relax per-commit strictness to advisory; keep PR-title/trunk strictness.
3. Enable auto-merge for low-risk PRs.

### Phase C: Release acceleration

1. Add release-please automation for release PR + changelog + tags.
2. Keep existing runtime release binaries workflow as downstream artifact publisher.

### Phase D: Optimize and harden

1. Add stale/auto-close policy for abandoned draft PRs.
2. Tune risk-path classification and merge policy based on 2-3 weeks of data.

## 4. File-Level Patch Plan

## A. Standards and practices updates

### 1) Update `.harmony/agency/practices/standards/commit-pr-standards.json`

Change set:

- Add branch types for autonomy workflow:
  - add `hotfix` and `exp` to `branch.allowed_types`
- Add explicit PR-title contract block:
  - `pr_title.header_format = <type>(<scope>): <summary>`
  - allowed types aligned with commit policy (plus `build` optional if desired)
- Add policy metadata for merge strategy:
  - `merge.strategy = squash`
  - `merge.require_pr_title_conventional = true`

Rationale:

- Makes PR-title/trunk commit quality machine-readable and canonical.

### 2) Update `.harmony/agency/practices/commits.md`

Change set:

- Keep Conventional Commit format for durable history.
- Add autonomy-mode clause:
  - intermediate branch commits MAY be iterative in autonomy lane
  - trunk/squash commit MUST satisfy Conventional Commit contract
- Keep branch naming section aligned to updated JSON contract.

Rationale:

- Reduces friction for autonomous iteration while preserving clean trunk history.

### 3) Update `.harmony/agency/practices/pull-request-standards.md`

Change set:

- Add autonomy-first flow section:
  - draft early, auto-label, auto-ready, auto-merge when gates green
- Add explicit high-impact acceptance clause:
  - paths requiring `accept:human`
- Add issue-link policy:
  - require `Closes #...` OR `No-Issue: <reason>`

Rationale:

- Makes exception-based human check-ins explicit and policy-backed.

### 4) Update `.github/PULL_REQUEST_TEMPLATE.md`

Change set:

- Preserve canonical headings and checklist order.
- Add explicit `No-Issue:` guidance in the relevant section.
- Add short machine-friendly markers for:
  - rollback handle
  - risk class
  - autonomy eligibility (`autonomy:auto-merge` expected/blocked)

Rationale:

- Keeps existing enforced structure while enabling automation signals.

## B. Workflow additions

### 5) Add `.github/workflows/pr-triage.yml`

Purpose:

- Auto-label type/area/risk and bot metadata.
- Normalize bot PR titles where needed.

Key behavior:

- Trigger: `pull_request_target` (no checkout)
- Compute labels from changed paths using Harmony-aware prefixes:
  - `.harmony/agency/`, `.harmony/capabilities/`, `.harmony/cognition/`, `.harmony/orchestration/`, `.harmony/scaffolding/`, `.harmony/assurance/`, `.harmony/engine/`, `.harmony/continuity/`, `.harmony/ideation/`, `.harmony/output/`, `.github/`
- Set risk:
  - high for governance/runtime-control-plane sensitive paths
  - medium for broad runtime/ops surfaces
  - low otherwise
- Never auto-add `accept:human`

Required labels introduced:

- `type:*`
- `area:*`
- `risk:*`
- `accept:human`
- `autonomy:auto-merge`
- `autonomy:no-automerge`
- `bot:dependabot`

### 6) Add `.github/workflows/pr-autonomy-policy.yml`

Purpose:

- Enforce autonomy-specific policy.

Checks:

- PR title must match Conventional Commit format.
- Branch naming must match repo branch contract.
- PR body must meet template and issue-link policy:
  - `Closes/Fixes/Resolves #...` OR `No-Issue:`.
- High-impact path diff requires `accept:human`.
- `exp/*` branches are non-mergeable unless renamed.

High-impact path set (initial):

- `.github/**`
- `AGENTS.md`
- `.harmony/agency/governance/**`
- `.harmony/cognition/governance/**`
- `.harmony/capabilities/governance/**`
- `.harmony/engine/governance/**`
- `.harmony/engine/runtime/spec/**`
- `.harmony/assurance/governance/**`

### 7) Add `.github/workflows/pr-auto-merge.yml`

Purpose:

- Enable auto-merge when policy allows.

Key behavior:

- Trigger: PR events (`labeled`, `unlabeled`, `synchronize`, `ready_for_review`, `edited`)
- Gate conditions (all required):
  - not draft
  - label `autonomy:auto-merge`
  - no label `autonomy:no-automerge`
  - required checks currently passing
  - if high-impact, `accept:human` label present
- Action:
  - enable GitHub auto-merge using squash strategy
  - ensure branch deletion on merge

Control switches:

- Repo variable: `AUTONOMY_AUTO_MERGE_ENABLED=true|false`

### 8) Add `.github/workflows/pr-stale-close.yml`

Purpose:

- Auto-close stale draft PRs to reduce queue drag.

Key behavior:

- Mark stale after N idle days (initial `7`)
- Close after N additional idle days (initial `3`)
- Exempt labels:
  - `accept:human`
  - `autonomy:no-automerge`
  - `risk:high`

Control switch:

- Repo variable: `AUTONOMY_AUTO_CLOSE_ENABLED=true|false`

## C. Workflow modifications

### 9) Update `.github/workflows/commit-and-branch-standards.yml`

Change set:

- Keep branch-name validation as blocking.
- Convert commit-message validation from blocking -> advisory:
  - continue-on-error
  - post summary annotation rather than failing merge
- Add or defer strictness to PR-title in `pr-autonomy-policy.yml`.

Rationale:

- Removes high-friction per-commit strictness while preserving trunk quality.

### 10) Update `.github/workflows/pr-quality.yml`

Change set:

- Keep canonical-template enforcement.
- Add tolerance for bot/release automation PRs where appropriate.
- Preserve checklist enforcement for non-trivial human/agent PRs.

Rationale:

- Maintains documentation quality without penalizing automation paths.

## D. Release automation

### 11) Add `.github/workflows/release-please.yml`

Purpose:

- Continuous release PR generation and automated tagging/release.

Notes:

- Use `RELEASE_PLEASE_TOKEN` (PAT) for downstream CI-trigger compatibility.

### 12) Add `release-please-config.json`

- Conventional Commit -> semver mapping
- changelog section mapping
- root package config

### 13) Add `.release-please-manifest.json`

- seed version map

### 14) Add `version.txt`

- initial version seed

### 15) Add `CHANGELOG.md`

- release-please managed changelog entrypoint

### 16) Add `.github/dependabot.yml`

- weekly GitHub Actions dependency updates
- labels aligned to triage policy

## E. Local/agent automation scripts (Harmony-native path)

Place scripts under `.harmony/agency/_ops/scripts/`.

### 17) Add `.harmony/agency/_ops/scripts/git/git-wt-new.sh`

Purpose:

- one-command worktree + branch creation

### 18) Add `.harmony/agency/_ops/scripts/git/git-pr-open.sh`

Purpose:

- commit/push/open draft PR with template-aware body

### 19) Add `.harmony/agency/_ops/scripts/git/git-pr-ship.sh`

Purpose:

- set labels, mark ready, enable auto-merge

### 20) Add `.harmony/agency/_ops/scripts/github/sync-github-labels.sh`

Purpose:

- idempotent creation/update of required labels

### 21) Add `.harmony/agency/practices/git-autonomy-playbook.md`

Purpose:

- human/operator runbook for autonomous lanes and exceptions

## 5. Required GitHub Settings (Manual)

Apply these repository settings after Phase A validation:

- Pull Requests:
  - allow squash merge = ON
  - allow merge commit = OFF
  - allow rebase merge = OFF
  - default squash message = PR title (or PR title + description)
  - auto-delete head branches = ON
  - allow auto-merge = ON
- Branch protection/ruleset for `main`:
  - require PR before merge = ON
  - require linear history = ON
  - require conversation resolution = ON
  - no force pushes, no deletions = ON
  - do not allow bypassing = ON
  - required checks include existing safety checks + new autonomy checks

Do not remove existing domain/safety checks from required status set.

## 6. Required Checks Strategy

## Keep required

- `Main PR-First Guard / Enforce PR-first main updates`
- `PR Quality Standards / PR Quality Standards`
- `Commit and Branch Standards / Validate branch naming`
- Domain/path-specific workflows when touched:
  - agency, assurance, deny-by-default, principles, etc.
- New:
  - `PR Autonomy Policy / validate`

## Advisory (after Phase B)

- `Commit and Branch Standards / Validate commit messages`

## Optional required (team preference)

- `Codex PR Review / Run Codex Review`

## 7. Rollout Timeline

### Week 1 (shadow)

- Add new workflows/scripts/docs.
- Run autonomy policy in non-blocking mode.
- Observe label accuracy and false positives.

### Week 2 (enforce)

- Make `PR Autonomy Policy / validate` required.
- Enable `AUTONOMY_AUTO_MERGE_ENABLED=true` for `risk:low` only.
- Keep stale-close disabled.

### Week 3 (expand)

- Expand auto-merge to `risk:med` excluding high-impact paths.
- Enable stale-close with conservative thresholds.

### Week 4 (stabilize)

- Finalize required-check set.
- Move commit-message lint to advisory if metrics support it.

## 8. Verification and Success Criteria

## Functional verification

- Autonomous PR path:
  - branch -> draft PR -> labels -> checks -> ready -> auto-merge -> branch deleted
- Guarded path:
  - high-impact PR blocked until `accept:human` added
- Release path:
  - release PR generated and merged, tag emitted, runtime binary release workflow still functions

## Metrics (first 30 days)

- Median PR cycle time target: `< 2h` for `risk:low`
- Auto-merge rate target: `>= 75%` of `risk:low` PRs
- Human check-ins target: `< 10%` of total PRs
- Release frequency target: at least daily on active days
- Revert rate target: `< 5%`

## 9. Rollback Plan

If autonomy causes regressions, rollback in this order:

1. Disable auto-merge immediately:
   - set `AUTONOMY_AUTO_MERGE_ENABLED=false`
2. Disable stale auto-close:
   - set `AUTONOMY_AUTO_CLOSE_ENABLED=false`
3. Keep triage + policy checks, continue manual merge.
4. Restore strict commit-message blocking by reverting `commit-and-branch-standards.yml` change.
5. If needed, revert new autonomy workflows as a single rollback PR.

## 10. Implementation Commit Plan

Recommended commit sequence:

1. `chore(ci): add autonomy triage and policy workflows in advisory mode`
2. `docs(agency): add autonomy-first git workflow standards and playbook`
3. `chore(ci): add auto-merge workflow with kill switch`
4. `chore(release): add release-please automation and changelog seed`
5. `refactor(ci): relax commit-message lint to advisory in autonomy mode`

## 11. Open Decisions to Confirm Before Implementation

1. Should `risk:med` be auto-merge eligible by default, or remain manual-label opt-in?
2. Should `Codex PR Review` remain required for all non-draft PRs or only `risk:med/high`?
3. Should `exp/*` PRs be auto-closed after a fixed window or remain manual?
4. Is release-please the default for all tags, or only product-level releases while keeping engine/runtime tags manually curated?
