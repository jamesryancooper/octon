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
- Branch-pr check target (strict mode): `AI Review Gate / decision`
- Policy contract:
  `.octon/framework/execution-roles/practices/standards/ai-gate-policy.json`
- Normalized findings schema:
  `.octon/framework/execution-roles/practices/standards/ai-gate-findings.schema.json`

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
2. Current live `main` ruleset is active with required checks. The accepted
   repo-local target is route-neutral Change projection; live migration remains
   a separate operator action.
3. Actions workflow setting has `can_approve_pull_request_reviews=true`.
4. `AUTONOMY_PAT` is set as a repository Actions secret.
5. Main control-plane matches the `current_live_main` posture in
   `.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json`.
6. (Optional) `AUTONOMY_AUTO_CLOSE_ENABLED=true` if stale draft auto-close is desired.
7. (Optional) `AUTONOMY_ATTENTION_AFTER_HOURS=<n>` to tune attention indicator threshold.

Human escalation exceptions (default policy):

1. PR head branch matches `exp/*`.
2. Dependabot update is `major` or `unknown` semver transition and the agent
   cannot prove safe compatibility, validation, and rollback.
3. Live rulesets, required approvals, credentials, policy acceptance, or
   unresolved review judgment require authority the agent does not have.
4. Required evidence, mergeability, rollback safety, or post-merge
   `origin/main` state cannot be proven.
5. Canonical approval artifacts and required checks are the authority source.

High-impact `branch-pr` PRs do not default to this list. They enter
elevated-autonomy: keep progressing while checks, evidence, review-thread
state, rollback, mergeability, and protected-main controls can be proven.
Escalation must cite a concrete blocker rather than the `risk:high` label
alone.

## Autonomous Draft Completion Preflight

Agents may complete a draft PR autonomously only in the `branch-pr` route and
only after this preflight passes:

1. The PR is open and still draft.
2. The PR belongs to the autonomous `branch-pr` lane.
3. For high-impact PRs, the agent has completed explicit self-review of the
   diff, policy impact, evidence, and rollback path.
4. All required GitHub checks are passing.
5. `AI Review Gate / decision` is passing when it is required.
6. `PR Quality Standards`, `Validate branch naming`, `PR Clean State
   Enforcer`, and `Validate autonomy policy` are passing.
7. No unresolved author-action review threads remain.
8. No blocking labels, requested changes, merge conflicts, or stale head state
   remain.
9. The PR has the required Change receipt or PR closeout evidence.
10. The current live GitHub ruleset allows the protected-main merge path.

After the preflight passes, an agent may mark the PR ready for review and
request or perform the currently valid protected-main merge path. In the
current PR-required live posture, that path is GitHub squash auto-merge or a
GitHub-accepted squash merge for the PR. The agent must not push directly to
protected `main`, bypass required checks, bypass review policy, bypass
rulesets, or treat labels/comments/helper output as authority.

For high-impact PRs, the agent owns the full closeout loop after merge request:
watch until GitHub merges, fetch `origin/main`, verify the merged result is
present, and record merged ref, validation evidence, rollback handle, and
cleanup disposition. If any of those facts cannot be proven, escalate with the
exact blocker and smallest needed human decision.

Useful verification commands:

```bash
gh secret list --app actions | rg '^AUTONOMY_PAT'
gh variable list | rg '^AUTONOMY_AUTO_MERGE_ENABLED'
gh variable list | rg '^AUTONOMY_AUTO_CLOSE_ENABLED'
gh variable list | rg '^AUTONOMY_ATTENTION_AFTER_HOURS'
gh api repos/<owner>/<repo>/actions/permissions/workflow
gh api repos/<owner>/<repo>/rulesets
```

Before strict branch-pr AI gate cutover:

1. `OPENAI_API_KEY` and `ANTHROPIC_API_KEY` are configured as repository
   Actions secrets.
2. `AI_GATE_ENFORCE=true` is set as a repository variable.
3. `AI Review Gate / decision` is enforced only for branch-pr projections. It
   is not part of the target universal route-neutral `main` check set.

Control-plane baseline capture command:

```bash
.octon/framework/execution-roles/_ops/scripts/github/capture-github-control-plane-snapshot.sh
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
5. Structural refactors remain releasable because the root package declares
   `refactor` in `release-please-config.json` `changelog-sections`.

---

## GitHub CLI Auth Troubleshooting

Use this section when `gh` works in a normal terminal but fails in the
Codex-run shell or another host-managed shell with symptoms such as:

- `gh auth status --hostname github.com` says the token is invalid
- `gh auth login` completes successfully but `gh auth status` still fails
- `gh auth token --hostname github.com` says no OAuth token was found
- `gh auth status` fails even though direct `gh` API or PR commands work
- `~/.config/gh/hosts.yml` exists but the stored shape looks incomplete or odd

### Most Common Failure Modes

1. The failing shell is reading different auth state than the working shell.
2. `gh auth login` completed, but the token was not persisted in a way the
   failing shell can read.
3. `~/.config/gh/hosts.yml` drifted into a malformed `github.com` record, most
   notably a nested `users:` map without a usable top-level `oauth_token`.
4. `gh auth status` is returning a false negative for this shell even though
   real GitHub operations using the same token still work.

### Same-Shell Diagnostics

Run these in the shell where `gh` is failing:

```bash
printenv | egrep '^(GH_TOKEN|GITHUB_TOKEN|GH_HOST|GH_CONFIG_DIR|XDG_CONFIG_HOME|HOME)='

GH_DIR="${GH_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/gh}"
echo "$GH_DIR"
[ -f "$GH_DIR/hosts.yml" ] && sed -n '1,80p' "$GH_DIR/hosts.yml" | sed -E 's/(oauth_token:).*/\1 [redacted]/'

gh auth status --hostname github.com
gh auth token --hostname github.com >/dev/null && echo token-readable || echo token-unreadable
```

Interpretation:

- If `gh auth status` says the token is invalid and `gh auth token` says
  `no oauth token found`, the shell cannot read a usable persisted credential.
- If `gh auth token` succeeds but `gh auth status` still says the token is
  invalid, do not assume the token is bad yet. Run operation probes first.

### Operation Probes

Use real `gh` operations before deciding that auth is broken:

```bash
gh api user
gh pr view <number> --json number,state,isDraft,url
gh pr checks <number>
```

Interpretation:

- If `gh auth status` fails but `gh api user` succeeds, the shell has a usable
  token even if the auth-status/introspection path is reporting a failure.
- If `gh pr view <number>` or the exact command you need also succeeds, treat
  the shell as operational and stop looping on auth repair.
- Prefer the exact `gh` operation you actually need over generic status
  introspection, because some introspection paths may fail while ordinary API
  calls still work.
- If both `gh auth status` and real operation probes fail, continue with auth
  recovery below.

### Clean Reset Path

Use this first when you want to give the failing shell a chance to rebuild its
own auth state cleanly:

```bash
unset GH_TOKEN GITHUB_TOKEN GH_HOST

GH_DIR="${GH_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/gh}"

gh auth logout --hostname github.com --user jamesryancooper
rm -f "$GH_DIR/hosts.yml"
```

Then delete the `gh: github.com` item in macOS Keychain Access and re-run from
the same failing shell:

```bash
gh auth login --hostname github.com --git-protocol ssh --skip-ssh-key --web
gh auth status --hostname github.com
```

If login reports success but `gh auth status` still fails, do not keep looping
on `gh auth login`. Move to the file-backed fallback below.

### File-Backed Fallback

From a terminal where `gh` already works:

```bash
gh auth token | gh auth login -h github.com -p ssh --with-token --insecure-storage
```

This writes a plaintext token into `~/.config/gh/hosts.yml`, which a
host-managed shell can usually read even when keychain-backed auth is failing.

Tradeoff:

- This is plaintext token storage.
- Use it to restore operability quickly, not as the preferred long-term mode.

### `hosts.yml` Normalization

If the fallback writes a token but `gh auth status` still says the token is
invalid, inspect `~/.config/gh/hosts.yml`.

The failure case previously observed in this repo looked like:

```yaml
github.com:
    git_protocol: ssh
    users:
        jamesryancooper:
    user: jamesryancooper
```

That shape is suspect. Back up the file first, then normalize it to one clean
`github.com` record only.

Expected file-backed shape:

```yaml
github.com:
    user: jamesryancooper
    git_protocol: ssh
    oauth_token: <valid token>
```

Rules:

- Keep exactly one `github.com` entry.
- Keep one top-level `user`.
- Keep one top-level `git_protocol`.
- Keep one top-level `oauth_token` when using insecure storage.
- Remove the nested `users:` map if it exists.

After normalization:

```bash
gh auth status --hostname github.com
gh auth token --hostname github.com >/dev/null && echo token-readable
gh api user
```

If `gh auth status` still fails after normalization but `gh api user` and the
target PR/repo commands succeed, treat that as the false-negative case and
proceed with real work. At that point the remaining issue is auth-status
reporting, not GitHub operability.

### Migrating Back Off Insecure Storage

Once `gh` works in the failing shell again, you can migrate back to keychain:

1. `gh auth logout --hostname github.com --user jamesryancooper`
2. Remove the file-backed `oauth_token` from `~/.config/gh/hosts.yml`
3. Re-run normal login:

```bash
gh auth login --hostname github.com --git-protocol ssh --skip-ssh-key --web
gh auth status --hostname github.com
```

Target end state:

- `gh auth status` shows `(keyring)` as the auth source
- `~/.config/gh/hosts.yml` contains host metadata only and no plaintext token

If `gh auth status` continues to fail but operation probes succeed, you can
still proceed with work. Keyring migration is then a hygiene step, not an
operability blocker.

### Practical Rule

If a future shell reports:

- working terminal: `Logged in ... (keyring)`
- failing shell: `token in default is invalid`

then the fastest route is:

1. file-backed fallback from the working terminal
2. normalize `~/.config/gh/hosts.yml`
3. verify in the failing shell with real `gh` operations, not `gh auth status`
   alone

Treat host projection refreshes as unrelated unless the failure explicitly
mentions `.codex/**` projection state rather than GitHub CLI auth.

---

## Clean-State Enforcement

`PR Clean State Enforcer` keeps PR/branch state converging to clean:

- Workflow: `.github/workflows/pr-clean-state-enforcer.yml`
- Triggers: PR events, schedule, and manual dispatch.
- Default attention threshold: 4 hours since last PR update when blocked/manual.

Remote cleanup behavior:

- Deletes closed PR head refs on origin when no open PR still references the branch.
- Bounds closed-ref deletion per run with `AUTONOMY_CLOSED_HEAD_CLEANUP_LIMIT`
  and treats GitHub API rate limits as cleanup deferral, not as an open-PR
  clean-state failure.
- Labels blocked/manual PRs with `autonomy:attention-required`.
- Opens/updates issue `[autonomy-health] open-pr attention required` when action is needed.
- Auto-closes the attention issue when queue is healthy.

Local cleanup expectation:

- Use `.octon/framework/execution-roles/_ops/scripts/git/git-pr-ship.sh` to request
  ready-state or merge-intent transitions. It can wait for PR closure and
  trigger local cleanup handling, but GitHub required checks and review policy
  remain the final merge gate.
- On demand, run `.octon/framework/execution-roles/_ops/scripts/git/git-pr-cleanup.sh`
  to converge refs and `main`, prune safe linked worktrees, and surface any
  manual `git worktree remove ...` follow-up still required.

---

## Dependabot Autonomy Policy

GitHub Actions dependency updates are split into two lanes:

- Safe lane (autonomous): `semver-patch` and `semver-minor`
  - Grouped into one weekly Dependabot PR.
  - Merged autonomously by `pr-auto-merge.yml`.
  - AI gate provider adapters are skipped for Dependabot-authored PRs so the
    safe lane does not fail on unavailable Actions secrets.
- Escalation lane: `semver-major` and unknown version transitions
  - Escalate when compatibility, validation coverage, or rollback safety cannot
    be proven autonomously.
  - Human merge is required only after that concrete blocker is documented.

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
- Live `main` ruleset required checks match the `current_live_main` section of
  `.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json`.
  The `target_route_neutral_main` section is repo-local projection state until
  the live ruleset migration is accepted.
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

Strict branch-pr mode cutover:

```bash
gh variable set AI_GATE_ENFORCE --body true
```

Route-neutral main ruleset migration remains separate follow-up work. The target
universal check set is:

- `route_neutral_closeout_validation`
- `branch_naming_validation`
- `route_aware_autonomy_validation`
- `exact_source_sha_validation`

Keep `AI Review Gate / decision` and `PR Quality Standards` behind branch-pr;
do not add them as universal target `main` checks.

Post-cutover verification after an accepted live migration:

```bash
.octon/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh --expect target-route-neutral --strict-live
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
  `.octon/framework/execution-roles/_ops/scripts/github/capture-github-control-plane-snapshot.sh`
- Compare baseline artifacts in `.octon/state/evidence/validation/analysis/` to confirm expected
  control-plane restoration.

Phase 1 (eventual autonomous merge reconciliation):

- Disable autonomous merging immediately with:
  `gh variable set AUTONOMY_AUTO_MERGE_ENABLED --body false`
- Existing PRs remain governed by canonical approval artifacts and required
  checks after the variable change.

Phase 3 (label contract convergence):

- Re-sync canonical label catalog:
  `.octon/framework/execution-roles/_ops/scripts/github/sync-github-labels.sh`
- Validate catalog completeness:
  `.octon/framework/execution-roles/_ops/scripts/validate/validate-autonomy-labels.sh`

Phase 4 (local cleanup enforcement outside scripted shipping):

- Uninstall local hooks:
  `.octon/framework/execution-roles/_ops/scripts/git/git-autonomy-hooks-uninstall.sh`
- Run cleanup manually when needed:
  `.octon/framework/execution-roles/_ops/scripts/git/git-pr-cleanup.sh`

Phase 2 (drift health expansion):

- Re-run health workflow to confirm drift diagnosis:
  `gh workflow run autonomy-release-health.yml`
- Restore control-plane settings to contract values and verify drift issue
  auto-closes on the next healthy cycle.

Phase 5 (provider-agnostic AI gate):

- Shadow-mode rollback (non-blocking): set `AI_GATE_ENFORCE=false`.
- Strict-mode rollback (branch-pr blocking disable): remove
  `AI Review Gate / decision` from branch-pr enforcement, then set
  `AI_GATE_ENFORCE=false`.
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
- Refactor merges are no longer opening release PRs:
  verify `release-please-config.json` keeps `refactor` in the root-package
  `changelog-sections`.
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
