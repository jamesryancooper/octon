# Autonomy-First Patch Plan Coverage (2026-03-03)

Source plan: `.proposals/.git-github-workflow/autonomy-first-patch-plan.md`

## Coverage Summary

- Covered: `24`
- Partially covered: `2`
- Not covered: `0`
- Intentional deviations: `2`

---

## A) Standards and Practices

1. `commit-pr-standards.json`: **partial**
- Added PR title/merge metadata contract blocks.
- Kept existing allowed types (did **not** add `hotfix`/`exp`).

2. `commits.md`: **covered**
- Conventional commit contract retained.
- Added autonomy-mode clause for iterative branch commits vs durable trunk squash commit.

3. `pull-request-standards.md`: **covered**
- Added autonomy-first flow.
- Added explicit high-impact `accept:human` check-in model.
- Added issue-link policy (`Closes/Fixes/Resolves #...` or `No-Issue: ...`).

4. `PULL_REQUEST_TEMPLATE.md`: **covered**
- Added explicit issue-link guidance.
- Added machine-friendly markers: rollback handle and autonomy eligibility.

---

## B) Workflow Additions

5. `.github/workflows/pr-triage.yml`: **covered**

6. `.github/workflows/pr-autonomy-policy.yml`: **covered**

7. `.github/workflows/pr-auto-merge.yml`: **covered**

8. `.github/workflows/pr-stale-close.yml`: **covered**
- Added stale draft mark/close flow with kill switch:
  `AUTONOMY_AUTO_CLOSE_ENABLED`.

---

## C) Workflow Modifications

9. `.github/workflows/commit-and-branch-standards.yml`: **covered**
- Commit lint remains advisory.

10. `.github/workflows/pr-quality.yml`: **covered**
- Canonical template enforcement active with bot/release tolerance.

---

## D) Release Automation

11. `.github/workflows/release-please.yml`: **covered**

12. `release-please-config.json`: **covered**

13. `.release-please-manifest.json`: **covered**

14. `version.txt`: **covered**

15. `CHANGELOG.md`: **covered**

16. `.github/dependabot.yml`: **covered**

---

## E) Local/Agent Automation

17. `.octon/agency/_ops/scripts/git/git-wt-new.sh`: **covered**

18. `.octon/agency/_ops/scripts/git/git-pr-open.sh`: **covered**

19. `.octon/agency/_ops/scripts/git/git-pr-ship.sh`: **covered**

20. `.octon/agency/_ops/scripts/github/sync-github-labels.sh`: **covered**

21. `.octon/agency/practices/git-autonomy-playbook.md`: **covered**

---

## Section 5 Control-Plane Settings

Status: **covered**

- Repository merge settings aligned:
  - squash ON
  - merge commit OFF
  - rebase merge OFF
  - auto-merge ON
  - auto-delete branches ON
  - squash defaults `PR_TITLE` + `PR_BODY`
- Main ruleset aligned:
  - squash-only merge method
  - no bypass actors
  - required checks:
    - `Validate branch naming`
    - `PR Quality Standards`
    - `Validate autonomy policy`

---

## Week 4 Stabilization Status (Sections 6/7/8)

Status: **in progress, baseline run complete**

- Required-check finalization: baseline set finalized and enforced.
- Commit-message lint remains advisory.
- Metrics baseline run captured in:
  `.octon/output/reports/analysis/2026-03-03-week4-stabilization-baseline.md`
- Policy tuning applied:
  - release-please PRs now triage to `risk:med` to keep low-risk autonomy metrics meaningful.
  - stale-draft close automation added behind explicit variable gate.

---

## Intentional Deviations

1. `hotfix`/`exp` branch types were not added to standards.
- Reason: preserve strict branch/commit taxonomy currently enforced across checks.

2. `Main PR-First Guard` is enforced on `main` push safety rather than as a PR required check context.
- Reason: it is a trunk guardrail workflow and not a PR-head status context.

