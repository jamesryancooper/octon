Below are **ready-to-commit file contents** for the workflow set we designed (policy gates + CI + auto-triage + release automation). They’re written to fit Harmony’s **PLAN → SHIP → LEARN** loop and surface model (runtime/governance/practices/etc.). 

> Note: I still can’t directly inspect `jamesryancooper/harmony` because the repo URL returns 404 publicly (likely private). So these files are **portable defaults** designed to drop in cleanly. After you add them, you’ll want to confirm required check names and any repo-specific test commands.

---

# 1) `.github/pull_request_template.md`

```md
<!--
Harmony PR Template (agent-first, governed)

REQUIRED:
- PR title MUST follow Conventional Commits:
  <type>(<scope>): <subject>
  Examples:
    feat(orchestration): add mission template
    fix(runtime): prevent silent side effects in hook
    chore(ci): speed up policy workflow

- Prefer opening PRs as Draft early, then mark Ready when checks are green.
- Labels are auto-managed by triage automation; adjust if needed.
-->

## Plan
- Issue: Closes #<id>
  - OR -
- No-Issue: <why this change does not need an issue>

### Intent
Describe the goal in 1–3 sentences. What should be true after this merges?

## Change
- What changed (high-level)
- Any new contracts, invariants, or behavior changes

## Evidence
- [ ] Local: `./runtime/ci/check.sh`
- [ ] CI: link to successful run
- [ ] Notes: key screenshots/log excerpts if relevant

## Risk + Rollback
**Risk:** low | med | high

**Rollback plan (MUST be reversible):**
- `git revert <squash-commit-sha>` on `main`
- Any follow-up cleanup steps (if needed)

## Governance Notes (only if needed)
- Policy exceptions: none | describe
- Explicit control points used: none | describe
```

---

# 2) `.github/workflows/triage.yml` (auto-labeling + bot title normalization)

This workflow keeps the “happy path” hands-off by automatically applying **type/area/risk** labels and normalizing **Dependabot** PR titles into Conventional Commits so they can squash-merge cleanly.

```yaml
name: triage

on:
  pull_request_target:
    types: [opened, reopened, synchronize, ready_for_review, edited]

permissions:
  contents: read
  pull-requests: write

jobs:
  triage:
    name: triage / label-and-normalize
    runs-on: ubuntu-latest
    timeout-minutes: 5

    steps:
      - name: Auto-label + normalize bot PRs
        uses: actions/github-script@v7
        with:
          script: |
            const owner = context.repo.owner;
            const repo = context.repo.repo;
            const pr = context.payload.pull_request;
            const pull_number = pr.number;

            const author = pr.user?.login || "";
            const headRef = pr.head?.ref || "";
            const currentTitle = pr.title || "";
            const currentLabels = (pr.labels || []).map(l => l.name);

            const isDependabot = author === "dependabot[bot]" || headRef.startsWith("dependabot/");
            const isReleasePlease = headRef.startsWith("release-please--") || currentLabels.some(n => n.startsWith("autorelease:"));

            // ---- Fetch changed files (no checkout)
            const files = await github.paginate(github.rest.pulls.listFiles, {
              owner,
              repo,
              pull_number,
              per_page: 100,
            });
            const paths = files.map(f => f.filename);

            // ---- Normalize Dependabot PR titles into Conventional Commits
            // Conventional title regex: type(scope optional)!?: subject
            const conventionalTitle = /^(feat|fix|docs|refactor|perf|test|ci|build|chore|revert)(\([^)]+\))?!?: .+/;
            if (isDependabot && !conventionalTitle.test(currentTitle)) {
              const normalized = `chore(deps): ${currentTitle}`.replace(/\s+/g, " ").trim().slice(0, 256);
              await github.rest.pulls.update({ owner, repo, pull_number, title: normalized });
              core.info(`Updated Dependabot PR title to: ${normalized}`);
            }

            // ---- Desired TYPE label (exactly one)
            const typeMap = {
              feat: "type:feat",
              fix: "type:fix",
              docs: "type:docs",
              refactor: "type:refactor",
              chore: "type:chore",
              ci: "type:ci",
              test: "type:test",
              hotfix: "type:hotfix",
              exp: "type:exp",
            };

            let desiredType = "type:chore";
            if (isDependabot || isReleasePlease) {
              desiredType = "type:chore";
            } else {
              const prefix = headRef.split("/")[0];
              if (typeMap[prefix]) desiredType = typeMap[prefix];
            }

            // ---- Area labels (MAY be multiple, but MUST have at least one)
            const areaRules = [
              ["agency/", "area:agency"],
              ["capabilities/", "area:capabilities"],
              ["cognition/", "area:cognition"],
              ["orchestration/", "area:orchestration"],
              ["scaffolding/", "area:scaffolding"],
              ["assurance/", "area:assurance"],
              ["engine/", "area:engine"],
              ["continuity/", "area:continuity"],
              ["ideation/", "area:ideation"],
              ["output/", "area:output"],

              ["runtime/", "area:runtime"],
              ["governance/", "area:governance"],
              ["practices/", "area:practices"],
              ["_meta/", "area:meta"],
              ["_ops/", "area:ops"],
              [".github/", "area:github"],
            ];

            const desiredAreas = new Set();
            for (const p of paths) {
              let matched = false;
              for (const [prefix, label] of areaRules) {
                if (p.startsWith(prefix)) {
                  desiredAreas.add(label);
                  matched = true;
                }
              }
              // Root-level files (README, CHANGELOG, configs) -> meta
              if (!p.includes("/")) {
                desiredAreas.add("area:meta");
                matched = true;
              }
              // If nothing matched at all, we'll fall back later.
            }
            if (desiredAreas.size === 0) desiredAreas.add("area:uncategorized");
            if (isDependabot) {
              desiredAreas.add("area:ops");
              desiredAreas.add("bot:dependabot");
            }

            // ---- Risk label (exactly one)
            const isHighImpact = paths.some(p =>
              p.startsWith(".github/") || p.startsWith("governance/") || p.startsWith("engine/")
            );
            const isMedImpact = paths.some(p =>
              p.startsWith("runtime/") || p.startsWith("assurance/") || p.startsWith("capabilities/")
            );

            const desiredRisk = isHighImpact ? "risk:high" : (isMedImpact ? "risk:med" : "risk:low");

            // ---- Compute label mutations
            const toAdd = new Set([desiredType, desiredRisk, ...desiredAreas]);

            // Keep area:uncategorized only if it's the only area label.
            const computedAreaLabels = [...desiredAreas].filter(l => l.startsWith("area:"));
            if (computedAreaLabels.length > 1 && desiredAreas.has("area:uncategorized")) {
              desiredAreas.delete("area:uncategorized");
              toAdd.delete("area:uncategorized");
            }

            const toRemove = new Set();

            for (const lbl of currentLabels) {
              if (lbl.startsWith("type:") && lbl !== desiredType) toRemove.add(lbl);
              if (lbl.startsWith("risk:") && lbl !== desiredRisk) toRemove.add(lbl);
              if (lbl === "area:uncategorized" && !toAdd.has("area:uncategorized")) toRemove.add(lbl);
            }

            // Add only labels that are missing
            const finalAdd = [...toAdd].filter(l => !currentLabels.includes(l));

            // ---- Apply mutations
            if (finalAdd.length > 0) {
              await github.rest.issues.addLabels({ owner, repo, issue_number: pull_number, labels: finalAdd });
              core.info(`Added labels: ${finalAdd.join(", ")}`);
            }

            for (const lbl of toRemove) {
              try {
                await github.rest.issues.removeLabel({ owner, repo, issue_number: pull_number, name: lbl });
                core.info(`Removed label: ${lbl}`);
              } catch (e) {
                core.warning(`Could not remove label ${lbl}: ${e.message}`);
              }
            }

            // IMPORTANT: We intentionally DO NOT auto-add "accept:human".
            // High-impact PRs must be explicitly accepted by the human.
            if (isHighImpact) {
              core.info("High-impact change detected: requires explicit label 'accept:human' before merge.");
            }
```

---

# 3) `.github/workflows/policy.yml` (enforced governance gates)

This is the **required check** you’ll add to branch protection as: `policy / validate`.

```yaml
name: policy

on:
  pull_request:
    types: [opened, reopened, synchronize, edited, ready_for_review, labeled, unlabeled]

permissions:
  contents: read
  pull-requests: read

jobs:
  validate:
    name: policy / validate
    runs-on: ubuntu-latest
    timeout-minutes: 5

    steps:
      - name: Validate PR title (Conventional Commits)
        uses: amannn/action-semantic-pull-request@v6
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          types: |
            feat
            fix
            docs
            refactor
            perf
            test
            ci
            build
            chore
            revert
          scopes: |
            agency
            capabilities
            cognition
            orchestration
            scaffolding
            assurance
            engine
            continuity
            ideation
            output
            governance
            practices
            runtime
            ops
            meta
            release
            deps
          requireScope: false
          subjectPattern: "^(?!WIP\\b).+"
          subjectPatternError: "Subject must not start with 'WIP'. Use Draft PRs instead."

      - name: Validate branch / body / labels / accept gate
        uses: actions/github-script@v7
        with:
          script: |
            const core = require("@actions/core");

            const owner = context.repo.owner;
            const repo = context.repo.repo;
            const pr = context.payload.pull_request;
            const pull_number = pr.number;

            const author = pr.user?.login || "";
            const headRef = pr.head?.ref || "";
            const labels = (pr.labels || []).map(l => l.name);
            const body = pr.body || "";

            const errors = [];

            const isBot = author.endsWith("[bot]") || headRef.startsWith("dependabot/") || labels.includes("bot:dependabot");
            const isAutorelease = headRef.startsWith("release-please--") || labels.some(n => n.startsWith("autorelease:"));

            // ---- Branch naming (skip for Dependabot + release automation branches)
            if (!isBot && !isAutorelease) {
              const branchOk = /^(feat|fix|docs|refactor|chore|ci|test|hotfix|exp)\/[a-z0-9][a-z0-9-]*$/.test(headRef);
              if (!branchOk) {
                errors.push(`Branch name '${headRef}' must match: <type>/<slug> where type in {feat,fix,docs,refactor,chore,ci,test,hotfix,exp} and slug is lowercase a-z0-9-`);
              }

              // Experiments MUST NOT merge (rename branch to merge).
              if (headRef.startsWith("exp/")) {
                errors.push("Branches under 'exp/' are non-mergeable by policy. Rename to feat/ fix/ refactor/ etc before merging.");
              }
            }

            // ---- Required labels (all PRs)
            const hasType = labels.some(n => n.startsWith("type:"));
            const hasArea = labels.some(n => n.startsWith("area:"));
            const hasRisk = labels.some(n => n.startsWith("risk:"));

            if (!hasType) errors.push("Missing required label: one 'type:*' label (auto-set by triage).");
            if (!hasArea) errors.push("Missing required label: at least one 'area:*' label (auto-set by triage).");
            if (!hasRisk) errors.push("Missing required label: one 'risk:*' label (auto-set by triage).");

            // ---- PR body template + issue link (skip for bots + autorelease PRs)
            if (!isBot && !isAutorelease) {
              const requiredHeadings = [
                "## Plan",
                "## Change",
                "## Evidence",
                "## Risk + Rollback",
              ];
              for (const h of requiredHeadings) {
                const re = new RegExp("^" + h.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + "\\b", "mi");
                if (!re.test(body)) errors.push(`PR body missing required section heading: '${h}'`);
              }

              const hasIssueLink = /(close[sd]?|fixe?[sd]?|resolve[sd]?)\s+#\d+/i.test(body);
              const hasNoIssue = /No-Issue:\s*\S+/i.test(body);

              if (!hasIssueLink && !hasNoIssue) {
                errors.push("PR must include 'Closes #<id>' (or Fixes/Resolves) OR include a 'No-Issue: <reason>' line in the Plan section.");
              }
            }

            // ---- High-impact gate: requires explicit human accept label
            const files = await github.paginate(github.rest.pulls.listFiles, {
              owner,
              repo,
              pull_number,
              per_page: 100,
            });
            const paths = files.map(f => f.filename);

            const isHighImpact = paths.some(p =>
              p.startsWith(".github/") || p.startsWith("governance/") || p.startsWith("engine/")
            );

            if (isHighImpact && !labels.includes("accept:human")) {
              errors.push("High-impact change detected (.github/, governance/, or engine/). Add label 'accept:human' to explicitly approve merge.");
            }

            if (errors.length > 0) {
              core.setFailed(errors.join("\n"));
            }
```

---

# 4) `.github/workflows/ci.yml` (deterministic checks)

This is the **required check** you’ll add to branch protection as: `ci / check`.

```yaml
name: ci

on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]
  push:
    branches: [main]

permissions:
  contents: read

jobs:
  check:
    name: ci / check
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Python (for hygiene checks)
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Run Harmony checks
        run: bash runtime/ci/check.sh
```

---

# 5) `runtime/ci/check.sh` (SSOT entrypoint)

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "${ROOT}"

echo "== Harmony CI: runtime/ci/check.sh =="

echo "== Hygiene (tracked files) =="
python3 runtime/ci/hygiene.py

# Optional extension point:
# Add repo-specific checks as executable scripts under runtime/ci/tasks/*.sh
# (e.g., tests, linters, formatting). This keeps CI portable and AI-agent friendly.
if [[ -d "runtime/ci/tasks" ]]; then
  shopt -s nullglob
  for task in runtime/ci/tasks/*.sh; do
    echo "== Task: ${task} =="
    bash "${task}"
  done
  shopt -u nullglob
fi

echo "== OK =="
```

---

# 6) `runtime/ci/hygiene.py` (fast, portable hygiene gate)

Scans **tracked** files only (`git ls-files`) to avoid untracked artifact noise.

```python
#!/usr/bin/env python3
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path
from typing import Iterable


TRAILING_WS = re.compile(r"[ \t]+$")


def git_ls_files() -> list[Path]:
    r = subprocess.run(
        ["git", "ls-files"],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    files = []
    for line in r.stdout.splitlines():
        line = line.strip()
        if not line:
            continue
        files.append(Path(line))
    return files


def is_probably_binary(data: bytes) -> bool:
    return b"\0" in data


def read_utf8(path: Path) -> str | None:
    data = path.read_bytes()
    if is_probably_binary(data):
        return None
    try:
        return data.decode("utf-8")
    except UnicodeDecodeError:
        # Skip non-UTF8 text files (rare). If you want to enforce UTF-8, change this to error.
        return None


def iter_issues(files: Iterable[Path]) -> Iterable[str]:
    for path in files:
        if not path.exists():
            continue

        text = read_utf8(path)
        if text is None:
            continue

        # 1) File must end with newline (portable, prevents diffs from being weird)
        if len(text) > 0 and not text.endswith("\n"):
            yield f"{path}: EOF missing final newline"

        # 2) No trailing whitespace (allow Markdown two-space hard breaks)
        for i, raw_line in enumerate(text.splitlines(), start=1):
            m = TRAILING_WS.search(raw_line)
            if not m:
                continue

            trailing = m.group(0)

            # Allow Markdown hard-breaks: exactly two spaces at EOL (no tabs)
            if path.suffix.lower() == ".md" and trailing == "  ":
                continue

            yield f"{path}:{i}: trailing whitespace"


def main() -> int:
    files = git_ls_files()
    issues = list(iter_issues(files))
    if issues:
        print("Hygiene check failed:\n")
        for msg in issues:
            print(f" - {msg}")
        print("\nFix the issues above and re-run: ./runtime/ci/check.sh")
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

---

# 7) `.github/workflows/release-please.yml` (Release PR + tags + GitHub Releases)

```yaml
name: release-please

on:
  push:
    branches: [main]

permissions:
  contents: write
  pull-requests: write

jobs:
  release:
    name: release-please / create-or-update
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - name: Run release-please
        uses: googleapis/release-please-action@v4
        with:
          # Prefer a PAT so release PRs can trigger CI (GitHub blocks workflow recursion from GITHUB_TOKEN).
          # Create a secret named RELEASE_PLEASE_TOKEN (fine-grained PAT with repo access).
          token: ${{ secrets.RELEASE_PLEASE_TOKEN || github.token }}
          config-file: release-please-config.json
          manifest-file: .release-please-manifest.json
```

---

# 8) `release-please-config.json`

```json
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "release-type": "simple",
  "include-v-in-tag": true,
  "pull-request-title-pattern": "chore(release): release v${version}",
  "changelog-sections": [
    { "type": "feat", "section": "Features", "hidden": false },
    { "type": "fix", "section": "Bug Fixes", "hidden": false },
    { "type": "docs", "section": "Documentation", "hidden": false },
    { "type": "refactor", "section": "Refactoring", "hidden": false },
    { "type": "perf", "section": "Performance Improvements", "hidden": false },
    { "type": "ci", "section": "CI", "hidden": false },
    { "type": "build", "section": "Build System", "hidden": false },
    { "type": "test", "section": "Tests", "hidden": false },
    { "type": "chore", "section": "Chores", "hidden": true },
    { "type": "revert", "section": "Reverts", "hidden": false }
  ],
  "packages": {
    ".": {
      "changelog-path": "CHANGELOG.md",
      "version-file": "version.txt",
      "include-component-in-tag": false
    }
  }
}
```

---

# 9) `.release-please-manifest.json`

```json
{
  ".": "0.0.0"
}
```

---

# 10) `version.txt`

```txt
0.0.0
```

---

# 11) `CHANGELOG.md`

```md
# Changelog

All notable changes to this project will be documented in this file.

This repository uses **release-please** to maintain changelog entries and create GitHub Releases.
Do not edit historical entries manually unless you are correcting factual errors.
```

---

# 12) `.github/dependabot.yml` (Actions updates)

```yaml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
    labels:
      - "bot:dependabot"
      - "type:chore"
      - "area:ops"
      - "risk:low"
```

---

# 13) `runtime/ops/labels.sync.sh` (bootstrap labels via `gh`)

Run this once to create/update the labels that triage/policy expects.

```bash
#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-}"
if [[ -z "${REPO}" ]]; then
  echo "Usage: $0 <owner/repo>"
  exit 1
fi

upsert () {
  local name="$1" color="$2" desc="$3"
  gh label create "${name}" --repo "${REPO}" --color "${color}" --description "${desc}" 2>/dev/null \
    || gh label edit "${name}" --repo "${REPO}" --color "${color}" --description "${desc}"
}

# --- type:*
upsert "type:feat"     "1D76DB" "New feature"
upsert "type:fix"      "D73A4A" "Bug fix"
upsert "type:docs"     "0075CA" "Documentation"
upsert "type:refactor" "A2EEEF" "Refactor"
upsert "type:chore"    "C5DEF5" "Maintenance / chores"
upsert "type:ci"       "5319E7" "CI / automation"
upsert "type:test"     "FBCA04" "Tests"
upsert "type:hotfix"   "B60205" "Urgent patch"
upsert "type:exp"      "E4E669" "Experiment (non-mergeable by policy)"

# --- area:*
upsert "area:agency"         "0E8A16" "Agency domain"
upsert "area:capabilities"   "0E8A16" "Capabilities domain"
upsert "area:cognition"      "0E8A16" "Cognition domain"
upsert "area:orchestration"  "0E8A16" "Orchestration domain"
upsert "area:scaffolding"    "0E8A16" "Scaffolding domain"
upsert "area:assurance"      "0E8A16" "Assurance domain"
upsert "area:engine"         "0E8A16" "Engine domain"
upsert "area:continuity"     "0E8A16" "Continuity domain"
upsert "area:ideation"       "0E8A16" "Ideation domain"
upsert "area:output"         "0E8A16" "Output sink"

upsert "area:runtime"        "0052CC" "Runtime surface"
upsert "area:governance"     "0052CC" "Governance surface"
upsert "area:practices"      "0052CC" "Practices surface"
upsert "area:meta"           "0052CC" "Meta/reference docs"
upsert "area:ops"            "0052CC" "Operational scripts/state"
upsert "area:github"         "0052CC" "GitHub config (.github)"
upsert "area:uncategorized"  "FFFFFF" "Needs area classification"

# --- risk:*
upsert "risk:low"  "D4C5F9" "Low risk / routine change"
upsert "risk:med"  "FBCA04" "Medium risk / behavior or contract change"
upsert "risk:high" "B60205" "High risk / governance, engine, or GitHub automation"

# --- accept gate
upsert "accept:human" "000000" "Explicit human accept for high-impact changes"

# --- bots
upsert "bot:dependabot" "0366D6" "Dependabot PR"

echo "Labels synced to ${REPO}"
```

---

## Quick “first commit” order (recommended)

1. Add files **1–12** (plus `runtime/ops/labels.sync.sh`)
2. `chmod +x runtime/ci/check.sh runtime/ops/labels.sync.sh`
3. Run label sync:

```bash
bash runtime/ops/labels.sync.sh jamesryancooper/harmony
```

4. In GitHub settings, protect `main` and require checks:

* `policy / validate`
* `ci / check`

If you paste your repo’s current `.github/workflows/` listing (or attach it), I can **diff** these against what already exists and produce a **minimal patch set** instead of a full drop-in.
