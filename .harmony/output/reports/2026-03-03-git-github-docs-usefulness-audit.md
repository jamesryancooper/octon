# Git/GitHub Docs Usefulness Audit (2026-03-03)

Sources:

- `.proposals/.git-github-workflow/git-github-workflow.md`
- `.proposals/.git-github-workflow/git-github-workflow-files.md`

Goal:

- Confirm that all useful recommendations supporting automation-first delivery
  are either implemented directly or implemented as policy-consistent
  equivalents in the current Harmony operating model.

---

## Summary

- Implemented directly: `18`
- Implemented as policy-consistent equivalent: `11`
- Intentionally not adopted: `6`
- Net useful gaps remaining: `0`

---

## Implemented Directly

1. PR-first main guardrails with required checks.
2. Squash-only merge strategy.
3. Linear history required on `main`.
4. Force-push and deletion protection for `main`.
5. Auto-delete merged branches.
6. Auto-merge support for eligible PRs.
7. PR title conventional enforcement.
8. Issue-link policy (`Closes/Fixes/Resolves` or `No-Issue`).
9. High-impact explicit `accept:human` gate.
10. Type/area/risk auto-labeling.
11. Dependabot support path.
12. Release Please automation with manifest/config/changelog.
13. Local worktree/branch helper script.
14. Local PR-open helper script.
15. Local PR-ship helper script.
16. Local label sync helper script.
17. Stale draft auto-close workflow (gated by variable).
18. Weekly Dependabot workflow updates.

---

## Equivalent Implementations (Aligned, Different Shape)

1. Proposed `policy / validate` workflow:
   - Implemented across `pr-autonomy-policy.yml`, `pr-quality.yml`,
     and `commit-and-branch-standards.yml`.
2. Proposed `ci / check` workflow:
   - Implemented through existing harness/domain workflows (`smoke`,
     `agency-validate`, `harness-self-containment`, etc.).
3. Proposed `.github/labeler.yml`:
   - Implemented in `pr-triage.yml` logic (no separate labeler config file).
4. Proposed `runtime/ops/labels.sync.sh`:
   - Implemented as `.harmony/agency/_ops/scripts/github/sync-github-labels.sh`.
5. Proposed release token naming:
   - Implemented with `AUTONOMY_PAT` policy/runbook contract.
6. Proposed PR template structure:
   - Implemented via canonical repository template and enforced checker.
7. Proposed worktree paths:
   - Implemented with Harmony `_ops` scripts and playbook.
8. Proposed “no required approvals for solo”:
   - Implemented by ruleset with `required_approving_review_count=0`.
9. Proposed release PR process:
   - Implemented with release-please workflow + release health monitoring.
10. Proposed settings drift verification via API:
    - Implemented through autonomy runbook and release health workflow.
11. Proposed stale-close exemptions:
    - Implemented (`accept:human`, `autonomy:no-automerge`, `risk:high`).

---

## Intentionally Not Adopted (With Rationale)

1. Additional branch types `hotfix/*` and `exp/*` in branch contract:
   - Not added to keep branch taxonomy tightly coupled to current commit and
     release semantics.
2. Separate standalone `policy.yml` and `ci.yml` files:
   - Not added to avoid duplicate governance surfaces and check-name drift.
3. New `runtime/ci/check.sh` + `runtime/ci/hygiene.py` stack:
   - Not added because Harmony already has stronger, domain-specific CI checks.
4. Suggested governance/practices docs at non-Harmony paths
   (`governance/git/workflow.md`, `practices/git/playbooks.md`):
   - Not added because canonical Harmony authority lives under
     `.harmony/agency/practices/` and existing governance contracts.
5. Required checks named exactly `policy / validate` + `ci / check`:
   - Not adopted because existing required check set is already policy-complete
     and stable in rulesets.
6. Enabling stale-close by default immediately:
   - Not adopted; workflow is gated by `AUTONOMY_AUTO_CLOSE_ENABLED` to allow
     controlled activation.

---

## Action Taken in This Audit

1. Added `bot:dependabot` label in `.github/dependabot.yml`.
2. Added `autonomy:stale-draft` to label sync catalog.
3. Verified Section 5 control-plane settings are aligned:
   - repo merge settings,
   - squash-only/no-bypass main ruleset,
   - required checks preserved.

Conclusion:

- For automation-first Git/GitHub operations under current Harmony principles,
  the useful recommendations from both proposal docs are fully covered.
