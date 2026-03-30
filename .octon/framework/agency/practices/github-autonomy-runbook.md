---
title: GitHub Autonomy Runbook
description: Operator runbook for PR triage, autonomy policy, and autonomous merges in GitHub Actions.
---

# GitHub Autonomy Runbook

This runbook defines the credential model and operator checks for Octon's
GitHub autonomy workflows:

- `.github/workflows/pr-triage.yml`
- `.github/workflows/pr-autonomy-policy.yml`
- `.github/workflows/pr-auto-merge.yml`
- `.github/workflows/pr-clean-state-enforcer.yml`
- `.github/workflows/pr-stale-close.yml`
- `.github/workflows/release-please.yml`
- `.github/workflows/autonomy-release-health.yml`
- `.github/workflows/ai-review-gate.yml`
- `.github/workflows/codex-pr-review.yml` (advisory)

Use this document when setting up or rotating `AUTONOMY_PAT`.

---

## Secret Contract

- Secret name: `AUTONOMY_PAT`
- Secret scope: repository secret (Actions), not environment secret
- Repository scope: only this repository
- Workflow wiring (current): `.github/workflows/pr-auto-merge.yml`
  - `GH_TOKEN: ${{ secrets.AUTONOMY_PAT || secrets.GITHUB_TOKEN }}`
  - `GITHUB_TOKEN: ${{ secrets.AUTONOMY_PAT || secrets.GITHUB_TOKEN }}`
- Workflow wiring (Phase C release acceleration):
  `.github/workflows/release-please.yml`
  - `token: ${{ secrets.AUTONOMY_PAT || secrets.GITHUB_TOKEN }}`
- Workflow wiring (Phase D steady-state monitoring):
  `.github/workflows/autonomy-release-health.yml`
  - `GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}`
  - `AUTONOMY_PAT_VALUE: ${{ secrets.AUTONOMY_PAT }}`

If `AUTONOMY_PAT` is not set, workflow falls back to `GITHUB_TOKEN`.

---

## Minimal Fine-Grained PAT Permissions

For `.github/workflows/pr-auto-merge.yml` alone, the minimal fine-grained PAT
permissions are:

- `Contents: Read and write`
- `Pull requests: Read`

For `.github/workflows/release-please.yml`, the minimal fine-grained PAT
permissions are:

- `Contents: Read and write`
- `Pull requests: Read and write`
- `Issues: Read and write`

If one `AUTONOMY_PAT` is shared across both workflows (recommended), use this
combined minimum:

- `Contents: Read and write`
- `Pull requests: Read and write`
- `Issues: Read and write`

Explicitly keep these at `No access` for this workflow:

- `Actions`
- `Workflows`
- `Administration`

`Workflows` permission is not required for autonomous merging.

---

## Important Fine-Grained PAT Limitation

As of March 3, 2026, fine-grained PATs do not support the Checks API in the
same way as classic PAT/App tokens.

Operational implication:

- Do not rely on `/commits/{sha}/check-runs` when authenticating with a
  fine-grained PAT.
- For autonomous merges, compute eligibility from PR metadata and canonical
  approval artifacts, then let branch rulesets enforce required checks at merge
  time.
- GitHub labels remain projection-only UX and must not be treated as merge
  authority.

If explicit check-run inspection is required, use a GitHub App token instead of
a fine-grained PAT.

---

## AI Gate Secrets and Variables

Provider-agnostic AI gate workflow:

- Workflow: `.github/workflows/ai-review-gate.yml`
- Required check target (strict mode): `AI Review Gate / decision`
- Policy contract:
  `.octon/framework/agency/practices/standards/ai-gate-policy.json`
- Normalized findings schema:
  `.octon/framework/agency/practices/standards/ai-gate-findings.schema.json`

Required secrets (strict mode):

- `OPENAI_API_KEY`
- `ANTHROPIC_API_KEY`

Mode control variable:

- `AI_GATE_ENFORCE=false` -> shadow mode (telemetry only, non-blocking)
- `AI_GATE_ENFORCE=true` -> strict mode (blocking on decision failures)

Waiver contract:

- AI-gate waivers are disabled in the autonomy lane

---

## Repository Preconditions

Before expecting autonomous merges:

1. `AUTONOMY_AUTO_MERGE_ENABLED=true` is set as a repository variable.
2. Main branch ruleset is active with required checks and PR-first merge.
3. Actions workflow setting has `can_approve_pull_request_reviews=true`.
4. `AUTONOMY_PAT` is set as a repository Actions secret.
5. Main control-plane matches
   `.octon/framework/agency/practices/standards/github-control-plane-contract.json`.
6. (Optional) `AUTONOMY_AUTO_CLOSE_ENABLED=true` if stale draft auto-close is desired.
7. (Optional) `AUTONOMY_ATTENTION_AFTER_HOURS=<n>` to tune attention indicator threshold.

Human-review exceptions (default policy):

1. PR head branch matches `exp/*`.
2. PR touches high-impact governance/control-plane paths (manual lane only).
3. Dependabot update is `major` or `unknown` semver transition (manual lane only).
4. Canonical approval artifacts and required checks are the authority source.

Useful verification commands:

```bash
gh secret list --app actions | rg '^AUTONOMY_PAT'
gh variable list | rg '^AUTONOMY_AUTO_MERGE_ENABLED'
gh variable list | rg '^AUTONOMY_AUTO_CLOSE_ENABLED'
gh variable list | rg '^AUTONOMY_ATTENTION_AFTER_HOURS'
gh api repos/<owner>/<repo>/actions/permissions/workflow
gh api repos/<owner>/<repo>/rulesets
```

Before strict AI gate cutover:

1. `OPENAI_API_KEY` and `ANTHROPIC_API_KEY` are configured as repository
   Actions secrets.
2. `AI_GATE_ENFORCE=true` is set as a repository variable.
3. `AI Review Gate / decision` is in the required checks list for `main`.

Control-plane baseline capture command:

```bash
.octon/framework/agency/_ops/scripts/github/capture-github-control-plane-snapshot.sh
```

For Phase C release acceleration:

1. `.github/workflows/release-please.yml` exists on `main`.
2. `release-please-config.json` and `.release-please-manifest.json` exist on
   `main`.
3. `AUTONOMY_PAT` includes `Contents`, `Pull requests`, and `Issues` write
   permissions.
4. Pre-1.0 cadence is pinned in `release-please-config.json` with
   `"bump-minor-pre-major": false` and
   `"bump-patch-for-minor-pre-major": true` so non-breaking `0.x` releases
   advance by patch by default.

---

## Clean-State Enforcement

`PR Clean State Enforcer` keeps PR/branch state converging to clean:

- Workflow: `.github/workflows/pr-clean-state-enforcer.yml`
- Triggers: PR events, schedule, and manual dispatch.
- Default attention threshold: 4 hours since last PR update when blocked/manual.

Remote cleanup behavior:

- Deletes closed PR head refs on origin when no open PR still references the branch.
- Labels blocked/manual PRs with `autonomy:attention-required`.
- Opens/updates issue `[autonomy-health] open-pr attention required` when action is needed.
- Auto-closes the attention issue when queue is healthy.

Local cleanup expectation:

- Use `.octon/framework/agency/_ops/scripts/git/git-pr-ship.sh` for shipping; it triggers
  local cleanup after closure (or starts a watcher for manual lanes).
- On demand, run `.octon/framework/agency/_ops/scripts/git/git-pr-cleanup.sh`.

---

## Dependabot Autonomy Policy

GitHub Actions dependency updates are split into two lanes:

- Safe lane (autonomous): `semver-patch` and `semver-minor`
  - Grouped into one weekly Dependabot PR.
  - Merged autonomously by `pr-auto-merge.yml`.
- Escalation lane (human): `semver-major` and unknown version transitions
  - Not auto-merged.
  - Leave the PR in the manual lane and merge with ordinary human review.

Configuration source:

- `.github/dependabot.yml`
  - Groups patch/minor updates.
  - Ignores `version-update:semver-major` for `github-actions` so majors do not
    create recurring PR noise.

Operator note:

- Manual lane decisions come from policy, required checks, and canonical
  approval artifacts rather than autonomy lane labels.

---

## Phase D Steady-State Monitoring

`Autonomy Release Health` runs daily (UTC) and on manual dispatch:

- Schedule: `23 08 * * *` UTC
- Workflow: `.github/workflows/autonomy-release-health.yml`

It checks for control-plane drift:

- `AUTONOMY_PAT` is present.
- `AUTONOMY_AUTO_MERGE_ENABLED=true`.
- `AUTONOMY_POLICY_ENFORCE` is effectively `true`.
- `main` ruleset required checks exactly match
  `.octon/framework/agency/practices/standards/github-control-plane-contract.json`.
- Pull-request rules require review-thread resolution.
- Repository merge settings remain squash-only and auto-merge compatible.
- Repository settings preserve `delete_branch_on_merge=true`.
- Actions workflow permission
  `can_approve_pull_request_reviews=true` remains enabled.
- `release-please-config.json` and `.release-please-manifest.json` exist.
- Latest `Release Please` workflow run is successful.
- No stale `release-please` branch exists without an open release PR.

Failure behavior:

- Workflow fails.
- Issue `[autonomy-health] control-plane drift detected` is opened or updated.
- When checks return healthy, the open drift issue is auto-closed.

Manual operations:

```bash
gh workflow run autonomy-release-health.yml
gh run list --workflow "Autonomy Release Health" --limit 5
gh run view <run-id> --log
```

Stale release branch remediation:

```bash
gh api --method DELETE repos/<owner>/<repo>/git/refs/heads/release-please--branches--main--components--octon
```

---

## AI Review Gate Operations

Workflow:

- `.github/workflows/ai-review-gate.yml`
- Decision job/check: `AI Review Gate / decision`

Shadow-mode validation:

```bash
gh variable set AI_GATE_ENFORCE --body false
gh workflow run ai-review-gate.yml
gh run list --workflow "AI Review Gate" --limit 10
```

Strict-mode cutover:

```bash
gh variable set AI_GATE_ENFORCE --body true
```

Main ruleset required-check cutover command template:

```bash
RULESET_ID="<main-ruleset-id>"
gh api \
  --method PATCH \
  "repos/<owner>/<repo>/rulesets/${RULESET_ID}" \
  --input - <<'JSON'
{
  "conditions": {
    "ref_name": {
      "include": ["~DEFAULT_BRANCH"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": true,
        "required_status_checks": [
          {"context": "AI Review Gate / decision"},
          {"context": "enforce-ci-efficiency-policy"},
          {"context": "PR Quality Standards"},
          {"context": "Validate branch naming"},
          {"context": "Validate autonomy policy"}
        ]
      }
    }
  ]
}
JSON
```

Post-cutover verification:

```bash
gh workflow run autonomy-release-health.yml
gh run list --workflow "Autonomy Release Health" --limit 5
```

---

## Scope Discipline

When broadening PAT permissions, document the reason and workflow dependency in
the same PR. Prefer the smallest permission set that keeps autonomous merging
functional.

## Patch Rollback Notes (Revised)

Use this rollback checklist for the Octon Git/GitHub autonomy patch rollout.
Apply only the minimum rollback needed for incident containment.

Phase 0 (baseline + guardrails):

- Re-run baseline capture before and after rollback:
  `.octon/framework/agency/_ops/scripts/github/capture-github-control-plane-snapshot.sh`
- Compare baseline artifacts in `.octon/state/evidence/validation/analysis/` to confirm expected
  control-plane restoration.

Phase 1 (eventual autonomous merge reconciliation):

- Disable autonomous merging immediately with:
  `gh variable set AUTONOMY_AUTO_MERGE_ENABLED --body false`
- Existing PRs remain governed by canonical approval artifacts and required
  checks after the variable change.

Phase 3 (label contract convergence):

- Re-sync canonical label catalog:
  `.octon/framework/agency/_ops/scripts/github/sync-github-labels.sh`
- Validate catalog completeness:
  `.octon/framework/agency/_ops/scripts/validate/validate-autonomy-labels.sh`

Phase 4 (local cleanup enforcement outside scripted shipping):

- Uninstall local hooks:
  `.octon/framework/agency/_ops/scripts/git/git-autonomy-hooks-uninstall.sh`
- Run cleanup manually when needed:
  `.octon/framework/agency/_ops/scripts/git/git-pr-cleanup.sh`

Phase 2 (drift health expansion):

- Re-run health workflow to confirm drift diagnosis:
  `gh workflow run autonomy-release-health.yml`
- Restore control-plane settings to contract values and verify drift issue
  auto-closes on the next healthy cycle.

Phase 5 (provider-agnostic AI gate):

- Shadow-mode rollback (non-blocking): set `AI_GATE_ENFORCE=false`.
- Strict-mode rollback (merge-blocking disable): remove
  `AI Review Gate / decision` from required checks in the main ruleset, then
  set `AI_GATE_ENFORCE=false`.
- Keep `.github/workflows/codex-pr-review.yml` advisory during rollback.

## Troubleshooting

- `release-please` fails with
  `Resource not accessible by personal access token ... create-a-pull-request`:
  `AUTONOMY_PAT` is missing `Pull requests: Read and write`.
- `release-please` fails when applying labels/comments on release PR:
  `AUTONOMY_PAT` is missing `Issues: Read and write`.
- Release tags are advancing too quickly while `<1.0.0`:
  verify `release-please-config.json` keeps `"bump-minor-pre-major": false`
  and `"bump-patch-for-minor-pre-major": true`.
- `Autonomy Release Health` fails with
  `AUTONOMY_AUTO_MERGE_ENABLED=false`: set repository variable back to `true`
  unless intentionally paused for incident response.
- `Autonomy Release Health` reports stale release branch drift:
  delete stale `release-please--*` ref after confirming no release PR is open.
- `AI Review Gate` reports `fail-provider-unavailable` in strict mode:
  verify `OPENAI_API_KEY` and `ANTHROPIC_API_KEY` are present for Actions.
- `AI Review Gate` reports blockers in strict mode:
  fix blockers or handle the merge outside the autonomy lane with explicit
  human review.
- PR remains `BLOCKED` after billing was fixed and reruns are green:
  stale failed check contexts can remain attached to the old head SHA.
  Push a no-op commit to mint a fresh SHA, then rerun required checks.
  Example:
  `git commit --allow-empty -m "chore(ci): refresh required-check contexts" && git push`.
