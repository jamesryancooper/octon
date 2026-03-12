## 1. Recommended Workflow

**Repo inspection note:** I attempted to inspect `https://github.com/jamesryancooper/harmony` but it returns **404 Not Found**, and the `jamesryancooper` profile does not list a public `harmony` repo (only 4 public repos show up). That usually means the repo is **private/unavailable to unauthenticated browsing** or the URL has changed. 
So: I’m giving a **complete, implementable operating model**, but the “repo changes” section is expressed as **add/align these files** (because I can’t verify what already exists). Step 1 of the implementation plan is an automated **repo inventory** via `gh` to reconcile with your current state.

### Happy path (PLAN → SHIP → LEARN, Harmony-aligned)

**Diagram-like flow**

* **PLAN**

  * Idea → *(optional but preferred)* Issue → worktree+branch created from `main`
* **SHIP**

  * Work locally → commits → push branch → draft PR early → CI + policy gates run → iterate until green
* **ACCEPT**

  * Convert PR to ready → (if high-impact) add explicit “human accept” control → **squash merge** via `gh`
* **LEARN**

  * Automated release PR accumulates changes → merge release PR when ready → tag+release created → cleanup branches/worktrees

**Narrative**

1. Start from `main` (always releasable).
2. Create a **short-lived topic branch** (and usually a **worktree**).
3. Commit freely during iteration (agents can do many small commits).
4. Open a **draft PR immediately** (for early CI/policy feedback).
5. Policy checks enforce naming, PR metadata, labels, and (most importantly) **PR title Conventional Commit** → this becomes the **squash commit** on `main`.
6. CI runs fast + deterministic checks.
7. When green, switch PR to “Ready”. If it touches governance/engine/.github or other “high-impact” paths, a required **explicit accept step** is enforced.
8. Merge using **squash** only → `main` stays linear and reversible via `git revert`.
9. Release automation maintains a **Release PR**; when you merge it, it tags and publishes a GitHub Release.
10. Branch/worktree cleanup happens immediately after merge.

---

## 2. Decisions + Rationale

| decision | choice | why | tradeoff |
|---|---|---|
| Development model | **Trunk-based** (`main` as trunk; short-lived branches) | Fastest loop, simplest mental model for solo + agents, keeps `main` always releasable. | Requires discipline + automation gates to prevent “slop” on trunk. |
| PR requirement | **PRs required for `main`, no direct pushes** | Enforces audit trail + CI gates; aligns with “deny-by-default” governance. Branch rules can require PRs. ([GitHub Docs][1]) | Slightly slower than direct push, but automation minimizes overhead. |
| Reviews in a solo repo | **No required approving reviews**; gate via checks + explicit accept rule | GitHub doesn’t allow PR authors to approve their own PRs, so requiring approvals can deadlock solo dev. ([GitHub Docs][2]) | You lose “formal review” as an enforceable GitHub mechanism; you replace it with deterministic checks + a human “accept” control point. |
| Merge method | **Squash merge only** | One change = one commit → clean history, easy revert, PR title drives changelog + semver. GitHub supports configurable squash defaults. ([GitHub Docs][3]) | Loses granular commit history on `main` (kept in PR, not on trunk). |
| History shape | **Linear history required** | Makes rollback + bisect easier; avoids merge-commit noise. Branch protection supports this. ([GitHub Docs][1]) | Can’t use merge commits; rebase-merge disabled to avoid variability. |
| Worktrees | **Recommended default**, required only when parallel work is active | Worktrees enable true parallelism without stashing/switching; ideal for agents running multiple tasks. | Slightly more setup; mitigated via a one-command script/playbook. |
| Branch cleanup | **Auto-delete branch on merge** (and `gh pr merge --delete-branch`) | Keeps repo clean automatically; no branch graveyard. GitHub supports auto-deletion. ([GitHub Docs][4]) | No per-branch exceptions with the built-in toggle; “keep” is handled via tags/PRs or leaving experimental branches unmerged. |
| Commit convention | **Conventional Commits enforced on `main` via PR title** | Lowest friction: agents can iterate with messy commits, but trunk stays consistent for releases. | Intermediate branch commits may be inconsistent (acceptable, since they don’t land on trunk). |
| PR title convention | **Conventional Commit format required** | Becomes squash commit; drives release notes/versioning; machine-checkable. | You must keep PR titles disciplined (enforced automatically). |
| Tagging | **Tag every release** with `vMAJOR.MINOR.PATCH` | Standard + compatible with tooling; supports revert + comparisons. | Requires release discipline; automated via release PR. |
| Tag type | **Lightweight tags** by default (via GitHub release automation) | Most GitHub-native release/tag automation creates lightweight tags; simplest automation path. Community discussion notes the difference. ([GitHub][5]) | `git describe` and some workflows prefer annotated tags; if you ever need annotated tags, add a “certified release” workflow that creates them via git. |
| Versioning | **SemVer** | Release-please maps Conventional Commits to SemVer (feat→minor, fix→patch, breaking→major). ([GitHub][6]) | Requires consistent commit typing/scoping. |
| Release notes / changelog | **Release PR + CHANGELOG.md** managed by **release-please** | Release-please automates changelog + GitHub release creation by parsing Conventional Commits and maintaining a Release PR. ([GitHub][6]) | Requires PAT (not just `GITHUB_TOKEN`) if you want CI to run on release PRs (otherwise required checks may not run). ([GitHub][6]) |
| Issue linking | **Required OR explicitly waived** | Auditability: every PR must either link an Issue (`Closes #123`) or state `No-Issue:` with reason. | Adds a small metadata burden; enforced automatically so it’s consistent. |

---

## 3. Policies (Enforced)

Rules are stated as **MUST/SHOULD/MAY**, and every one includes *how it’s enforced*.

| rule (normative)                                                                                 | enforcement mechanism                                                                                    | where enforced                                         |
| ------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| `main` MUST be protected; changes MUST enter via PR                                              | Branch protection: “Require a pull request before merging” ([GitHub Docs][1])                            | GitHub settings → Branch protection/ruleset            |
| Force pushes to `main` MUST be disallowed                                                        | Branch protection: disable force pushes / “Do not allow bypassing above settings” ([GitHub Docs][1])     | GitHub settings                                        |
| Merge method MUST be **squash only**                                                             | Disable merge commits + disable rebase merge in repo settings; require linear history ([GitHub Docs][3]) | GitHub settings                                        |
| PR title MUST follow Conventional Commits                                                        | CI job `policy / semantic-pr-title` fails otherwise                                                      | `.github/workflows/policy.yml` + required check        |
| Squash commit message MUST be PR title (so trunk commits are conventional)                       | Configure default squash message to “PR title” or “PR title + description” ([GitHub Docs][3])            | GitHub settings → Pull Requests                        |
| Branch names MUST match pattern (`feat/…`, `fix/…`, etc.)                                        | CI job `policy / branch-name` fails on mismatch                                                          | `.github/workflows/policy.yml`                         |
| PR body MUST include required sections (Plan, Change, Evidence, Rollback)                        | CI job `policy / pr-template` checks for headings/checkboxes                                             | `.github/workflows/policy.yml`                         |
| PR MUST link an Issue OR explicitly declare `No-Issue:`                                          | CI job `policy / issue-link` validates PR body                                                           | `.github/workflows/policy.yml`                         |
| Required labels MUST be present (`type:*`, `area:*`, `risk:*`)                                   | Auto-labeler adds; policy job fails if missing                                                           | `.github/labeler.yml` + `.github/workflows/policy.yml` |
| High-impact paths (`governance/**`, `engine/**`, `.github/**`) MUST have explicit accept control | Policy job requires label `accept:human` when high-impact diff detected                                  | `.github/workflows/policy.yml`                         |
| PRs in Draft MUST NOT be mergeable                                                               | GitHub already blocks merging draft PRs ([GitHub Docs][7]) + policy job also checks                      | GitHub + `.github/workflows/policy.yml`                |
| CI MUST run on PRs and `main`                                                                    | Required status checks configured on `main`                                                              | GitHub branch protection                               |
| Branches SHOULD be deleted after merge                                                           | Enable auto-delete head branches + `gh pr merge --delete-branch` ([GitHub Docs][4])                      | GitHub settings + agent playbook                       |
| Release MUST happen via Release PR merge (not ad-hoc tagging)                                    | release-please workflow maintains release PR; tagging is automated upon merge ([GitHub][6])              | `.github/workflows/release-please.yml`                 |
| Worktrees SHOULD be used for parallel work                                                       | Enforced by local script (refuses unsafe layouts)                                                        | `runtime/git/wt-*` scripts                             |

---

## 4. Conventions (Examples)

### Branch names (exact spec)

**Format**

* `feat/<slug>`
* `fix/<slug>`
* `docs/<slug>`
* `refactor/<slug>`
* `chore/<slug>`
* `ci/<slug>`
* `test/<slug>`
* `hotfix/<slug>`
* `exp/<slug>` *(experiments only; not mergeable without rename)*

**Slug rules**

* lowercase, digits, `-` only (no spaces)
* optional issue prefix: `<issue>-<slug>`

**Examples**

* `feat/142-agent-policy-gate`
* `fix/bug-merge-check-name`
* `docs/governance-git-workflow`
* `hotfix/ci-token-permissions`
* `exp/prototype-assurance-scoring`

### Worktree layout (recommended)

**Workspace root**

```
~/ws/harmony/
  main/                         # normal clone, always on main
  wt/
    feat-142-agent-policy-gate/ # worktrees (one per branch)
    hotfix-ci-token-perms/
```

**Rule:** worktree folder name = `<type>-<slug>`.

### Commit messages (what lands on `main`)

**Rule:** The **squash commit** on `main` uses the PR title, and MUST be Conventional Commits.

**Examples**

* `feat(assurance): add policy gate summary`
* `fix(ci): pin third-party actions by SHA`
* `docs(governance): define branch + PR conventions`
* `refactor(engine)!: change runtime contract resolver`

**Allowed scopes (Harmony-oriented)**
Use one of: `agency`, `capabilities`, `cognition`, `orchestration`, `scaffolding`, `assurance`, `engine`, `continuity`, `ideation`, `governance`, `practices`, `runtime`, `ops`, `meta`.

### PR titles (must match squash commit convention)

**Same as above** (Conventional Commits). Examples:

* `feat(orchestration): add mission template`
* `fix(runtime): prevent silent side effects in hook`
* `chore(ci): speed up policy workflow`

### PR body (minimum required sections)

* **Plan** (issue link or No-Issue)
* **Change**
* **Evidence** (local checks run, CI link)
* **Risk + Rollback** (explicit revert plan)

### Labels

**Type**

* `type:feat`, `type:fix`, `type:docs`, `type:refactor`, `type:chore`, `type:ci`, `type:test`, `type:hotfix`, `type:exp`

**Area** (Harmony domains/surfaces)

* `area:agency`, `area:capabilities`, …, `area:engine`
* plus surfaces: `area:governance`, `area:practices`, `area:runtime`, `area:ops`, `area:meta`

**Risk**

* `risk:low` (default)
* `risk:med`
* `risk:high` (auto when touching high-impact paths)

**Accept**

* `accept:human` (required only for high-impact paths)

### Tags / Releases

* Stable: `v0.7.0`, `v0.7.1`, `v1.0.0`
* Pre-release: `v0.8.0-rc.1`, `v0.8.0-beta.2`

Release notes are generated + maintained via a Release PR (release-please). ([GitHub][6])

---

## 5. GitHub Settings Checklist

These are the exact settings to click/configure.

### A. Repository settings → Pull Requests

1. **Allow squash merging** = ON
2. **Allow merge commits** = OFF
3. **Allow rebase merging** = OFF
4. Squash commit message default:

   * Title: **PR title**
   * Body: **PR description** (preferred for audit context)
     GitHub supports configuring the default squash message format. ([GitHub Docs][3])
5. **Automatically delete head branches** = ON ([GitHub Docs][4])
6. *(Optional)* **Allow auto-merge** = ON (we’ll only use it with an explicit “automerge” decision via `gh pr merge --auto`)

### B. Repository settings → Branches → Branch protection for `main`

Create a rule for `main` (or a ruleset targeting `main`) and set:

1. **Require a pull request before merging** = ON ([GitHub Docs][1])

   * **Do NOT enable “Require approvals”** (solo dev constraint; PR authors can’t approve their own PRs). ([GitHub Docs][2])
2. **Require status checks to pass before merging** = ON ([GitHub Docs][1])
   Required checks (exact names you’ll create in workflows):

   * `policy / validate`
   * `ci / check`
3. **Require conversation resolution** = ON ([GitHub Docs][1])
4. **Require linear history** = ON ([GitHub Docs][1])
5. **Do not allow bypassing the above settings** = ON (even for admins) ([GitHub Docs][1])
6. **Allow force pushes** = OFF
7. **Allow deletions** = OFF

### C. Repository settings → Actions

1. Set default **Workflow permissions** to **Read repository contents** (least privilege).
2. In workflows that need write (labeling/release), grant explicit permissions in YAML (see Implementation Plan).
3. If using release-please PRs: configure a **PAT secret** (fine-grained PAT) so PRs created by release automation can trigger CI (GitHub prevents workflow recursion for actions triggered by `GITHUB_TOKEN`). ([GitHub Docs][8])

### D. Security baseline

1. Enable **dependency graph** and **Dependabot alerts** (and add dependabot.yml for action updates).
2. Enable **secret scanning** (and push protection if available for your plan).
3. *(Optional)* Code scanning if you have a compiled language or a standard analyzer.

---

## 6. Automation Design

### Responsibilities split (local vs `gh` vs CI)

#### Local git + filesystem (agent-friendly, fast loop)

* Create branch + worktree in one command.
* Run **fast checks** before pushing:

  * formatting/hygiene (whitespace, yaml validity, markdown lint if used)
  * unit tests (if any)
* Prepare PR metadata from templates.
* Clean up worktrees locally after merge.

**Recommended repo-local commands (SSOT)**

* `runtime/ci/check.sh` → runs the exact same checks locally and in CI
* `runtime/git/wt-new.sh` / `runtime/git/wt-rm.sh` → worktree lifecycle
* `runtime/git/bootstrap.sh` → sets hooks path, installs helper aliases

#### `gh` CLI (GitHub operations are scripted and auditable)

* PR create/update/labels/ready/merge
* Monitor checks and logs
* Create releases (mostly automated via Release PR; manual fallback supported)
* Query settings via API (`gh api`) for drift detection

#### GitHub Actions (enforcement + bots)

* **Policy workflow** (required): validates branch name, PR title, PR body, labels, high-impact accept gate
* **CI workflow** (required): runs `runtime/ci/check.sh`
* **Labeler workflow**: auto-apply labels based on paths/branch prefix
* **Release automation**: release-please maintains Release PR + creates tag/release on merge ([GitHub][6])

### Failure handling (agent-first)

**Detection**

* `gh pr checks --watch`
* `gh run view --log-failed`
* `gh run view <run-id> --log`

**Remediation loop**

1. Agent pulls logs, identifies failing step.
2. Agent applies minimal fix in same branch/worktree.
3. Agent pushes and rechecks.
4. Only when required checks are green does the agent move PR to ready (or enable auto-merge).

**Hard blocks (cannot merge)**

* Any required check failing (`policy / validate`, `ci / check`)
* PR is Draft ([GitHub Docs][7])
* Missing required labels
* High-impact diff without `accept:human`

**Soft blocks (allowed but discouraged)**

* Missing local evidence checkbox (policy can enforce if you choose)
* Optional security scans failing (if not required checks)

---

## 7. `gh` Playbooks

All playbooks assume:

```bash
REPO="jamesryancooper/harmony"
BASE="main"
```

### 1) Create worktree + branch

```bash
TYPE="feat"                       # feat|fix|docs|refactor|chore|ci|test|hotfix|exp
SLUG="142-agent-policy-gate"      # your slug (optionally issue-prefixed)
BRANCH="${TYPE}/${SLUG}"
WTROOT="../wt"

# Update local main
git switch "${BASE}"
git pull --ff-only

# Create worktree
mkdir -p "${WTROOT}"
git worktree add -b "${BRANCH}" "${WTROOT}/${TYPE}-${SLUG}" "${BASE}"

# Enter worktree
cd "${WTROOT}/${TYPE}-${SLUG}"
```

### 2) Commit (Conventional Commit encouraged; trunk commit enforced via PR title)

```bash
# run your repo SSOT checks (you’ll implement runtime/ci/check.sh)
./runtime/ci/check.sh

git add -A
git commit -m "feat(assurance): add PR policy gate"
git push -u origin "${BRANCH}"
```

### 3) Open PR (draft → ready later)

```bash
TITLE="feat(assurance): add PR policy gate"
gh pr create \
  --repo "${REPO}" \
  --base "${BASE}" \
  --head "${BRANCH}" \
  --draft \
  --title "${TITLE}" \
  --fill
```

*(Optional)* If you maintain a PR template file and want to force it:

```bash
gh pr create --repo "${REPO}" --base "${BASE}" --head "${BRANCH}" \
  --draft --title "${TITLE}" --body-file .github/pull_request_template.md
```

### 4) Monitor/inspect checks + logs

```bash
# watch checks until completion
gh pr checks --repo "${REPO}" --watch

# list recent runs
gh run list --repo "${REPO}" --branch "${BRANCH}" --limit 10

# view a specific run with logs
RUN_ID="<run-id>"
gh run view --repo "${REPO}" "${RUN_ID}" --log-failed
```

### 5) Apply labels / update PR description

```bash
PR="<pr-number-or-url>"

gh pr edit "${PR}" --repo "${REPO}" \
  --add-label "type:feat" \
  --add-label "area:assurance" \
  --add-label "risk:low"

# If high-impact change:
gh pr edit "${PR}" --repo "${REPO}" --add-label "accept:human"

# Update body (e.g., add Closes #123)
gh pr edit "${PR}" --repo "${REPO}" --body "$(cat <<'EOF'
## Plan
Closes #123

## Change
...

## Evidence
- [x] ./runtime/ci/check.sh
- [x] CI green

## Risk + Rollback
Risk: low
Rollback: git revert the squash commit on main
EOF
)"
```

### 6) Merge using chosen strategy (squash + delete)

```bash
PR="<pr-number-or-url>"

# Make ready (if it was a draft)
gh pr ready "${PR}" --repo "${REPO}"

# Merge now (squash) and delete branch
gh pr merge "${PR}" --repo "${REPO}" --squash --delete-branch
```

*(Optional speed mode)* Enable auto-merge once you explicitly decide to ship:

```bash
gh pr merge "${PR}" --repo "${REPO}" --squash --delete-branch --auto
```

`gh pr merge` supports `--auto` and `--delete-branch`. ([GitHub CLI][9])

### 7) Prune worktree locally after merge

```bash
cd ../main   # back to your main checkout

# Remove worktree directory
git worktree remove "../wt/${TYPE}-${SLUG}" --force

# Prune stale worktree metadata
git worktree prune

# Delete local branch ref if it still exists
git branch -D "${BRANCH}" 2>/dev/null || true
```

### 8) Create tag + GitHub release + notes (fallback/manual)

If you’re using release-please, you normally **don’t do this manually**; you merge the Release PR. ([GitHub][6])

Manual fallback:

```bash
VERSION="v0.8.0"

git switch "${BASE}"
git pull --ff-only

git tag "${VERSION}"
git push origin "${VERSION}"

gh release create "${VERSION}" --repo "${REPO}" --generate-notes
```

### 9) Query/verify repo settings using `gh api`

```bash
# Repo merge settings summary
gh repo view "${REPO}" --json \
  defaultBranchRef,deleteBranchOnMerge,mergeCommitAllowed,rebaseMergeAllowed,squashMergeAllowed

# REST: get repo settings (merge options)
gh api "repos/${REPO}" --jq '{
  default_branch: .default_branch,
  allow_merge_commit: .allow_merge_commit,
  allow_rebase_merge: .allow_rebase_merge,
  allow_squash_merge: .allow_squash_merge,
  delete_branch_on_merge: .delete_branch_on_merge
}'

# Branch protection for main
gh api "repos/${REPO}/branches/${BASE}/protection"
```

GitHub documents these repository/branch protection endpoints. ([GitHub Docs][10])
Note: `delete_branch_on_merge` can have constraints via API (docs note org-owner requirement in some contexts). ([GitHub Docs][10])

---

## 8. Repo Implementation Plan

This is ordered so you can implement safely and keep the repo governed.

### Step 0 — Inventory the repo (so we don’t overwrite existing conventions)

Run from a machine authenticated to GitHub:

* `gh repo view "$REPO" --json name,defaultBranchRef,visibility,deleteBranchOnMerge,mergeCommitAllowed,rebaseMergeAllowed,squashMergeAllowed`
* `gh api "repos/$REPO/contents/.github/workflows"`
* `gh api "repos/$REPO/branches/main/protection" || true`

This produces your “current state” for alignment.

### Step 1 — Add the SSOT workflow docs (Harmony-aligned)

**Files**

* `governance/git/workflow.md`

  * Normative rules (the MUST/SHOULD/MAY you just adopted)
* `practices/git/playbooks.md`

  * Human/agent runbooks (the `gh` playbooks and failure handling)

**Why**

* Keeps policy authority in governance, and operational runbooks in practices (Harmony-aligned).

### Step 2 — PR template + labels

**Files**

* `.github/pull_request_template.md`
* `.github/labels.yml` *(optional if you want label sync via script)*
* `.github/labeler.yml`

**Enforces**

* Required PR structure and metadata.
* Auto-labeling based on paths (domain/surface) and reduces manual work.

### Step 3 — Policy enforcement workflow (required check)

**File**

* `.github/workflows/policy.yml`

**What it must do**

* Check PR title is Conventional Commits
* Check branch name pattern
* Check PR body contains required sections + Issue link or `No-Issue:`
* Ensure required labels exist (`type:*`, `area:*`, `risk:*`)
* Detect high-impact diffs and require `accept:human`

**Implementation approach**

* Use:

  * `amannn/action-semantic-pull-request` for PR title enforcement (robust + well-scoped)
  * `actions/github-script` (or a small Python script) for branch/labels/body/high-impact path rules

(If you use third-party actions, pin to SHAs for supply-chain hygiene.)

### Step 4 — CI workflow (required check)

**Files**

* `.github/workflows/ci.yml`
* `runtime/ci/check.sh` *(SSOT entrypoint)*

**Enforces**

* The same `check.sh` runs locally and in CI.
* CI becomes deterministic and agent-remediable.

### Step 5 — Branch protection / ruleset

Configure `main` with:

* Require PR before merge
* Require status checks: `policy / validate`, `ci / check`
* Require conversation resolution
* Require linear history
* No bypass for admins

These are explicitly supported in branch protection settings. ([GitHub Docs][1])

### Step 6 — Release automation (Release PR)

**Files**

* `.github/workflows/release-please.yml`
* `release-please-config.json`
* `.release-please-manifest.json`
* `version.txt`
* `CHANGELOG.md`

**Why**

* release-please automates CHANGELOG generation + GitHub releases by parsing Conventional Commits and maintaining a Release PR. ([GitHub][6])

**Critical note (token)**

* Use a PAT secret for release-please if you want CI checks to run on release PRs; GitHub prevents `GITHUB_TOKEN`-triggered events from spawning new workflow runs. ([GitHub Docs][8])

### Step 7 — Dependabot for GitHub Actions + ecosystem dependencies

**File**

* `.github/dependabot.yml`

**Why**

* Keeps actions versions and dependencies current with minimal effort; PRs will go through the same policy/CI gates.

### Step 8 — Local bootstrap (optional but recommended for agent speed)

**Files**

* `runtime/git/bootstrap.sh`

  * Sets `core.hooksPath` to `runtime/git/hooks`
  * Adds helpful `git`/`gh` aliases (optional)
* `runtime/git/hooks/pre-commit` (fast checks)
* `runtime/git/hooks/commit-msg` (optional; you can keep commit-msg advisory since PR title is enforced)

---

If you want, I can also produce **ready-to-commit** versions of:

* `.github/workflows/policy.yml`, `.github/workflows/ci.yml`, `.github/workflows/release-please.yml`
* `.github/pull_request_template.md`
* `release-please-config.json` + manifest files

Would you like me to generate those full file contents next (so you can paste them directly into the repo)?

[1]: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule "Managing a branch protection rule - GitHub Docs"
[2]: https://docs.github.com/articles/approving-a-pull-request-with-required-reviews "Approving a pull request with required reviews - GitHub Docs"
[3]: https://docs.github.com/articles/configuring-commit-squashing-for-pull-requests "Configuring commit squashing for pull requests - GitHub Docs"
[4]: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-the-automatic-deletion-of-branches?utm_source=chatgpt.com "Managing the automatic deletion of branches"
[5]: https://github.com/orgs/community/discussions/4924?utm_source=chatgpt.com "Github release should create annotated (not lightweight) tags"
[6]: https://raw.githubusercontent.com/googleapis/release-please-action/main/README.md "raw.githubusercontent.com"
[7]: https://docs.github.com/articles/merging-a-pull-request?utm_source=chatgpt.com "Merging a pull request"
[8]: https://docs.github.com/en/actions/concepts/security/github_token?utm_source=chatgpt.com "GITHUB_TOKEN - Secure automation in GitHub Actions"
[9]: https://cli.github.com/manual/gh_pr_merge?utm_source=chatgpt.com "gh pr merge"
[10]: https://docs.github.com/en/rest/repos/repos?utm_source=chatgpt.com "REST API endpoints for repositories"
