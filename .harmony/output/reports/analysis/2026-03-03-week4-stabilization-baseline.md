# Week 4 Stabilization Baseline (2026-03-03)

Owner: `jamesryancooper/harmony`
Plan source: `.proposals/.git-github-workflow/autonomy-first-patch-plan.md`

## Scope

This report covers:

1. Section 5 manual GitHub settings audit
2. Week 4 stabilization kickoff from Sections 7/8:
   - required-check finalization
   - initial metrics baseline

---

## 1) Section 5 Settings Audit

Reference (plan lines 335-348):

- Pull requests:
  - allow squash merge = ON
  - allow merge commit = OFF
  - allow rebase merge = OFF
  - default squash message = PR title (or PR title + description)
  - auto-delete head branches = ON
  - allow auto-merge = ON
- Main branch ruleset:
  - require PR before merge = ON
  - require linear history = ON
  - require conversation resolution = ON
  - no force pushes, no deletions = ON
  - do not allow bypassing = ON
  - required checks include existing safety checks + autonomy checks

Observed control-plane state (from GitHub API reads during this run):

- Repository merge settings:
  - `allow_squash_merge=true` (match)
  - `allow_merge_commit=false` (match after remediation)
  - `allow_rebase_merge=false` (match after remediation)
  - `delete_branch_on_merge=true` (match after remediation)
  - `allow_auto_merge=true` (match)
  - `squash_merge_commit_title=PR_TITLE` (match after remediation)
  - `squash_merge_commit_message=PR_BODY` (match after remediation)
- Main ruleset (`id: 12881449`):
  - `pull_request` rule present (PR required) (match)
  - `required_linear_history` rule present (match)
  - `required_review_thread_resolution=true` (match)
  - `deletion` + `non_fast_forward` rules present (match for no delete/force push)
  - `allowed_merge_methods=["squash"]` (match after remediation)
  - `bypass_actors=[]` (match after remediation)
  - required checks currently:
    - `Validate branch naming`
    - `PR Quality Standards`
    - `Validate autonomy policy`

### Remediations in this run

- Applied repository settings patch successfully:
  - merge commit disabled
  - rebase merge disabled
  - auto-delete head branches enabled
  - squash defaults set to `PR_TITLE` + `PR_BODY`
- Applied main ruleset patch successfully:
  - merge methods constrained to `squash` only
  - bypass actors removed
  - required checks preserved:
    - `Validate branch naming`
    - `PR Quality Standards`
    - `Validate autonomy policy`

---

## 2) Required-Check Finalization (Week 4)

Current required set already matches the Phase B minimum:

- `PR Quality Standards / PR Quality Standards`
- `Commit and Branch Standards / Validate branch naming`
- `PR Autonomy Policy / Validate autonomy policy`

Current advisory set:

- `Commit and Branch Standards / Validate commit messages (advisory)`

Finalization recommendation for this stabilization window:

1. Keep current required set unchanged immediately (safe, proven).
2. Keep commit-message lint advisory in place while collecting additional stabilization data.
3. Defer adding additional required checks until check context names are uniquely stable across workflows (there are multiple generic `validate` contexts in this repo, which makes static required-check expansion brittle).

---

## 3) Metrics Baseline (Sections 7/8)

### Data window notes

- Baseline uses merged PRs observed in the autonomy rollout window and trailing 30-day history.
- PR identity set in this run was derived from merge commits on `main` that include `(#<pr>)` references:
  - `#1, #3, #6, #7, #9, #13, #17, #22, #24, #26, #28, #31, #32, #33, #34, #35, #36, #38, #40, #41, #43`
- Autonomy rollout window used for Week 4 signal:
  - `2026-03-02` to `2026-03-03` (PRs `#17` through `#43`)

### Week 4 signal baseline (`2026-03-02..2026-03-03`)

- Total merged PRs: `15`
- `risk:low` merged PRs: `5` (`#33, #35, #36, #41, #43`)
- Median cycle time (`risk:low`): `16s` (`0.27m`) ✅ target `< 2h`
- `risk:low` auto-merge lane rate:
  - `3 / 5 = 60%` (`#33, #35, #43`) ❌ target `>= 75%`
- Human check-in rate (`accept:human`):
  - `10 / 15 = 66.7%` ❌ target `< 10%`
- Release frequency on active days:
  - active merge days: `2` (`2026-03-02`, `2026-03-03`)
  - release merge days: `1` (`2026-03-03`)
  - `1 / 2 = 50%` ❌ target daily on active days
- Revert rate: `0 / 15 = 0%` ✅ target `< 5%`

### Trailing 30-day baseline (`2026-02-02..2026-03-03`)

- Total merged PRs: `21`
- `risk:low` merged PRs: `5`
- `risk:low` median cycle time: `16s` ✅
- `risk:low` auto-merge lane rate: `60%` ❌
- Human check-in rate: `10 / 21 = 47.6%` ❌
- Release days over active merge days:
  - release days: `1`
  - active merge days: `6`
  - `16.7%` ❌
- Revert rate: `0%` ✅

---

## 4) Stabilization Actions (Next)

1. Apply Section 5 control-plane setting corrections:
   - status: complete
   - repo merge settings remediated
   - ruleset merge method and bypass policy remediated
2. Improve low-risk auto-merge rate:
   - keep `risk:low` + `autonomy:auto-merge` lane for routine PRs
   - avoid classifying release-please PRs into low-risk auto-merge denominator
3. Reduce human check-in ratio:
   - keep `accept:human` strictly for high-impact paths
   - validate high-impact path map for false positives
4. Re-run this baseline after settings drift is corrected and after at least 5-7 active days.
