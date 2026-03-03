---
title: GitHub Autonomy Runbook
description: Operator runbook for PR triage, autonomy policy, and autonomous low-risk merges in GitHub Actions.
---

# GitHub Autonomy Runbook

This runbook defines the credential model and operator checks for Harmony's
GitHub autonomy workflows:

- `.github/workflows/pr-triage.yml`
- `.github/workflows/pr-autonomy-policy.yml`
- `.github/workflows/pr-auto-merge.yml`
- `.github/workflows/release-please.yml`

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

`Workflows` permission is not required for low-risk autonomous merging.

---

## Important Fine-Grained PAT Limitation

As of March 3, 2026, fine-grained PATs do not support the Checks API in the
same way as classic PAT/App tokens.

Operational implication:

- Do not rely on `/commits/{sha}/check-runs` when authenticating with a
  fine-grained PAT.
- For autonomous merges, gate by labels/policy and let branch rulesets enforce
  required checks at merge time.

If explicit check-run inspection is required, use a GitHub App token instead of
a fine-grained PAT.

---

## Repository Preconditions

Before expecting autonomous low-risk merges:

1. `AUTONOMY_AUTO_MERGE_ENABLED=true` is set as a repository variable.
2. Main branch ruleset is active with required checks and PR-first merge.
3. Actions workflow setting has `can_approve_pull_request_reviews=true`.
4. `AUTONOMY_PAT` is set as a repository Actions secret.

Useful verification commands:

```bash
gh secret list --app actions | rg '^AUTONOMY_PAT'
gh variable list | rg '^AUTONOMY_AUTO_MERGE_ENABLED'
gh api repos/<owner>/<repo>/actions/permissions/workflow
gh api repos/<owner>/<repo>/rulesets
```

For Phase C release acceleration:

1. `.github/workflows/release-please.yml` exists on `main`.
2. `release-please-config.json` and `.release-please-manifest.json` exist on
   `main`.
3. `AUTONOMY_PAT` includes `Contents`, `Pull requests`, and `Issues` write
   permissions.

---

## Scope Discipline

When broadening PAT permissions, document the reason and workflow dependency in
the same PR. Prefer the smallest permission set that keeps autonomous merging
functional.
