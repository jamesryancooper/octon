# Harmony CI Cost Optimization Execution Plan

## Profile Selection Receipt

- `change_profile`: `atomic`
- `release_state`: `pre-1.0` (repo version `0.4.1`)
- `selection_facts`:
  - `downtime_tolerance`: CI configuration updates are reversible and can be shipped in one PR.
  - `external_consumer_coordination`: No external API consumer migration is required.
  - `data_migration_backfill`: None.
  - `rollback_mechanism`: Revert commit restores prior workflows immediately.
  - `blast_radius_uncertainty`: Moderate, bounded to GitHub Actions behavior.
  - `compliance_policy_constraints`: Required checks and governance gates must remain enforced.
- `hard_gate_evaluation`:
  - zero-downtime gate: false
  - external coordination gate: false
  - coexistence migration gate: false
  - staged validation gate: false
- `selected_mode`: Clean break / big-bang rollout in one PR.

## Goal / Outcome

- Primary target: reduce Actions usage by approximately 80% with no weakening of required governance checks.
- Secondary target: eliminate duplicate or stale runs that create billing churn and merge blockage.
- Safety invariant: required branch-protection checks must continue to report deterministically.

## Context & Constraints

- Incident confirmed that billing lockouts can leave stale failed contexts attached to a head SHA.
- Required checks are currently blocking merge when failed or stale contexts persist.
- Repo has frequent AI-driven PR updates and label churn, amplifying event-triggered workflow costs.
- For required checks, workflow-level skip behavior must not cause "Waiting for status" deadlocks.

## Implementation Plan

1. Baseline and target lock
- Run 30-day baseline capture and set explicit KPI targets (minutes reduction + latency guardrail).

2. High-cost workflow optimization
- Update AI gate to run heavy provider matrix only when needed (non-label, risky diff).
- Update perf regression workflow trigger scope and add Rust cache discipline.
- Update Codex review to risk/label-gated execution.

3. Duplicate-run and stale-run suppression
- Add or standardize workflow concurrency for required check workflows.
- Lower schedule cadence for maintenance-only workflows.
- De-duplicate smoke vs harness self-containment checks.

4. Retention and timeout discipline
- Shorten artifact retention where artifacts are operationally short-lived.
- Add or tighten timeout-minutes on long-running jobs.

5. Operational resilience documentation
- Add runbook note for billing-incident stale-context recovery (fresh SHA no-op commit path).

6. Codify for future workflows
- Add CI efficiency guard (lint workflow + script) so new workflows must conform to concurrency/timeout/trigger constraints.

## Exact Edits by Workflow File

### 1) `.github/workflows/ai-review-gate.yml`

#### Edit intent
- Keep `labeled`/`unlabeled` triggers for lightweight decision updates.
- Skip provider matrix on label-only or non-risky changes.
- Keep decision job always reporting.
- Reduce artifact retention.

#### Exact edits

```diff
@@
 jobs:
+  changes:
+    name: classify-changes
+    runs-on: ubuntu-latest
+    outputs:
+      risk: ${{ steps.filter.outputs.risk }}
+      provider_trigger: ${{ steps.provider_trigger.outputs.provider_trigger }}
+    steps:
+      - name: Checkout PR merge commit
+        uses: actions/checkout@v4
+        with:
+          ref: refs/pull/${{ github.event.pull_request.number }}/merge
+
+      - id: filter
+        name: Detect risky changed paths
+        uses: dorny/paths-filter@v3
+        with:
+          filters: |
+            risk:
+              - '.github/workflows/**'
+              - '.harmony/**/*.sh'
+              - '.harmony/**/*.bash'
+              - '.harmony/**/*.js'
+              - '.harmony/**/*.ts'
+              - '.harmony/**/*.rs'
+              - '.harmony/**/*.json'
+              - '.harmony/**/*.toml'
+              - '.harmony/**/*.yml'
+              - '.harmony/**/*.yaml'
+              - '.harmony/engine/runtime/run'
+              - '.harmony/engine/runtime/run.cmd'
+              - 'AGENTS.md'
+
+      - id: provider_trigger
+        name: Decide whether provider matrix must run
+        run: |
+          set -euo pipefail
+          if [[ "${{ github.event.action }}" == "labeled" || "${{ github.event.action }}" == "unlabeled" ]]; then
+            echo "provider_trigger=false" >> "${GITHUB_OUTPUT}"
+          elif [[ "${{ steps.filter.outputs.risk }}" == "true" ]]; then
+            echo "provider_trigger=true" >> "${GITHUB_OUTPUT}"
+          else
+            echo "provider_trigger=false" >> "${GITHUB_OUTPUT}"
+          fi
+
   provider-findings:
+    needs:
+      - changes
+    if: needs.changes.outputs.provider_trigger == 'true'
     name: provider-${{ matrix.provider }}
     runs-on: ubuntu-latest
+    timeout-minutes: 12
@@
       - name: Upload findings artifact
         uses: actions/upload-artifact@v4
         with:
           name: ai-gate-findings-${{ matrix.provider }}
           path: .harmony/output/.tmp/ai-gate/findings-${{ matrix.provider }}.json
           if-no-files-found: error
+          retention-days: 3
@@
   decision:
     name: AI Review Gate / decision
     runs-on: ubuntu-latest
+    timeout-minutes: 10
     needs:
+      - changes
       - provider-findings
@@
       GH_REPO: ${{ github.repository }}
       GH_PR_NUMBER: ${{ github.event.pull_request.number }}
+      PROVIDER_TRIGGER: ${{ needs.changes.outputs.provider_trigger }}
+      PROVIDER_FINDINGS_RESULT: ${{ needs.provider-findings.result }}
@@
       - name: Ensure provider findings files exist
         run: |
           set -euo pipefail
           mkdir -p .harmony/output/.tmp/ai-gate/artifacts
 
           for provider in openai anthropic; do
             file=".harmony/output/.tmp/ai-gate/artifacts/findings-${provider}.json"
             if [[ -f "${file}" ]]; then
               continue
             fi
+
+            status="unavailable"
+            summary="Provider artifact missing; marked unavailable."
+            adapter="fallback"
+
+            if [[ "${PROVIDER_TRIGGER}" != "true" || "${PROVIDER_FINDINGS_RESULT}" == "skipped" ]]; then
+              status="ok"
+              summary="Provider execution intentionally skipped for label-only or non-risky changes."
+              adapter="policy-skip"
+            fi
 
             jq -n \
               --arg provider "${provider}" \
               --arg generated_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
+              --arg status "${status}" \
+              --arg summary "${summary}" \
+              --arg adapter "${adapter}" \
               '{
                 provider: $provider,
-                status: "unavailable",
+                status: $status,
                 generated_at: $generated_at,
-                summary: "Provider artifact missing; marked unavailable.",
-                meta: { adapter: "fallback" },
+                summary: $summary,
+                meta: { adapter: $adapter },
                 findings: []
               }' > "${file}"
           done
@@
       - name: Upload AI gate decision artifact
         if: always()
         uses: actions/upload-artifact@v4
         with:
           name: ai-gate-decision
           path: .harmony/output/.tmp/ai-gate/decision.json
           if-no-files-found: error
+          retention-days: 7
```

### 2) `.github/workflows/filesystem-interfaces-perf-regression.yml`

#### Edit intent
- Narrow trigger scope from `.harmony/engine/**` to runtime-only paths.
- Add concurrency, timeout, and Rust caching.
- Stop reinstalling `cargo-component` when present.
- Shorten artifact retention.

#### Exact edits

```diff
@@
 on:
   push:
     paths:
@@
-      - '.harmony/engine/**'
+      - '.harmony/engine/runtime/**'
@@
   pull_request:
     paths:
@@
-      - '.harmony/engine/**'
+      - '.harmony/engine/runtime/**'
@@
 permissions:
   contents: read
+
+concurrency:
+  group: filesystem-interfaces-perf-${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
+  cancel-in-progress: true
@@
   perf-regression:
     name: perf-regression
     runs-on: ubuntu-latest
+    timeout-minutes: 25
     steps:
@@
       - name: Install Rust toolchain
         uses: dtolnay/rust-toolchain@stable
+
+      - name: Restore Rust cache
+        uses: swatinem/rust-cache@v2
+        with:
+          cache-bin: true
 
       - name: Install cargo-component
         run: |
-          cargo install --locked cargo-component
+          if ! command -v cargo-component >/dev/null 2>&1; then
+            cargo install --locked cargo-component
+          fi
@@
       - name: Upload perf summary artifact
         uses: actions/upload-artifact@v4
         with:
           name: filesystem-interfaces-perf-summary
           path: ${{ runner.temp }}/filesystem-interfaces-perf/filesystem-interfaces-perf.summary.tsv
-          retention-days: 30
+          retention-days: 7
@@
       - name: Upload perf raw artifact
         uses: actions/upload-artifact@v4
         with:
           name: filesystem-interfaces-perf-raw
           path: ${{ runner.temp }}/filesystem-interfaces-perf/filesystem-interfaces-perf.raw.tsv
-          retention-days: 14
+          retention-days: 3
```

### 3) `.github/workflows/smoke.yml`

#### Edit intent
- Remove PR-triggered duplicate coverage already provided by `harness-self-containment`.
- Keep schedule-only smoke checks (+ manual dispatch).

#### Exact edits

```diff
@@
 on:
   schedule:
     - cron: '30 9 * * *' # daily at 09:30 UTC
-  pull_request:
-    types: [opened, synchronize, reopened]
+  workflow_dispatch:
@@
 permissions:
   contents: read
-  pull-requests: write
+
+concurrency:
+  group: harness-smoke-${{ github.workflow }}-${{ github.ref }}
+  cancel-in-progress: true
@@
   smoke:
     runs-on: ubuntu-latest
+    timeout-minutes: 10
     steps:
@@
       - name: Run harness smoke checks
         run: |
-          set +e
-          {
-            echo "Running harness smoke checks..."
-            chmod +x .harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh
-            chmod +x .harmony/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
-            .harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh
-            .harmony/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
-          } > smoke-summary.txt 2>&1
-          status=$?
-          set -e
-
-          if [ "$status" -ne 0 ]; then
-            echo "SMOKE_FAILED=1" >> "$GITHUB_ENV"
-          fi
-
-      - name: Post PR comment with results
-        if: github.event_name == 'pull_request'
-        uses: actions/github-script@v7
-        with:
-          script: |
-            const fs = require('fs');
-            const summary = fs.existsSync('smoke-summary.txt') ? fs.readFileSync('smoke-summary.txt','utf8') : 'No summary produced';
-            const failed = process.env.SMOKE_FAILED === '1';
-            const status = failed ? '❌ Failed' : '✅ Passed';
-            const body = `### Harness Smoke Checks\n\n${'```'}\n${summary}\n${'```'}\n\nStatus: ${status}`;
-            await github.rest.issues.createComment({
-              owner: context.repo.owner,
-              repo: context.repo.repo,
-              issue_number: context.issue.number,
-              body
-            });
-            if (failed) core.setFailed('Smoke checks failed');
+          echo "Running harness smoke checks..."
+          chmod +x .harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh
+          chmod +x .harmony/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
+          .harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh
+          .harmony/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
```

### 4) `.github/workflows/pr-autonomy-policy.yml`

#### Edit intent
- Add concurrency cancellation to suppress duplicate runs on rapid push churn.

#### Exact edits

```diff
@@
 permissions:
   contents: read
   pull-requests: read
+
+concurrency:
+  group: required-pr-${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
+  cancel-in-progress: true
```

### 5) `.github/workflows/pr-quality.yml`

#### Edit intent
- Add concurrency and timeout discipline.

#### Exact edits

```diff
@@
 permissions:
   contents: read
   pull-requests: read
+
+concurrency:
+  group: required-pr-${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
+  cancel-in-progress: true
@@
   validate-pr-template:
     name: PR Quality Standards
     runs-on: ubuntu-latest
+    timeout-minutes: 5
```

### 6) `.github/workflows/commit-and-branch-standards.yml`

#### Edit intent
- Add concurrency and timeout discipline for required checks.

#### Exact edits

```diff
@@
 permissions:
   contents: read
   pull-requests: read
+
+concurrency:
+  group: required-pr-${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
+  cancel-in-progress: true
@@
   validate-branch-name:
     name: Validate branch naming
     runs-on: ubuntu-latest
+    timeout-minutes: 5
@@
   validate-commit-messages:
     name: Validate commit messages (advisory)
     runs-on: ubuntu-latest
+    timeout-minutes: 5
```

### 7) `.github/workflows/pr-auto-merge.yml`

#### Edit intent
- Lower maintenance scan frequency.
- Prevent overlapping schedule/manual scans.

#### Exact edits

```diff
@@
   schedule:
-    - cron: '*/15 * * * *'
+    - cron: '0 * * * *'
@@
 permissions:
   contents: write
   pull-requests: write
+
+concurrency:
+  group: pr-auto-merge-${{ github.event_name }}
+  cancel-in-progress: true
```

### 8) `.github/workflows/pr-clean-state-enforcer.yml`

#### Edit intent
- Lower maintenance scan frequency.
- Cancel superseded runs.

#### Exact edits

```diff
@@
   schedule:
-    - cron: '*/30 * * * *'
+    - cron: '0 * * * *'
@@
 permissions:
   contents: write
   pull-requests: write
   issues: write
+
+concurrency:
+  group: pr-clean-state-enforcer
+  cancel-in-progress: true
```

### 9) `.github/workflows/codex-pr-review.yml`

#### Edit intent
- Gate Codex runs to risky changes or explicit override label (`codex:review`).
- Add timeout discipline.

#### Exact edits

```diff
@@
 on:
   pull_request:
     types:
       - opened
       - reopened
       - synchronize
       - ready_for_review
+      - labeled
@@
 permissions:
   contents: read
+  pull-requests: read
@@
 jobs:
+  changes:
+    name: classify-changes
+    runs-on: ubuntu-latest
+    outputs:
+      risky: ${{ steps.filter.outputs.risky }}
+    steps:
+      - name: Checkout PR merge commit
+        uses: actions/checkout@v4
+        with:
+          ref: refs/pull/${{ github.event.pull_request.number }}/merge
+
+      - id: filter
+        name: Detect risky changed paths
+        uses: dorny/paths-filter@v3
+        with:
+          filters: |
+            risky:
+              - '.github/workflows/**'
+              - '.harmony/agency/governance/**'
+              - '.harmony/cognition/governance/**'
+              - '.harmony/capabilities/runtime/**'
+              - '.harmony/engine/runtime/**'
+              - '.harmony/assurance/runtime/**'
+              - 'AGENTS.md'
+
   codex-review:
     name: Run Codex Review
+    needs:
+      - changes
     if: >-
       ${{
         !github.event.pull_request.draft &&
         github.event.pull_request.head.repo.fork == false &&
-        secrets.OPENAI_API_KEY != ''
+        secrets.OPENAI_API_KEY != '' &&
+        (
+          contains(github.event.pull_request.labels.*.name, 'codex:review') ||
+          needs.changes.outputs.risky == 'true'
+        )
       }}
     runs-on: ubuntu-latest
+    timeout-minutes: 20
```

### 10) `.harmony/agency/practices/github-autonomy-runbook.md`

#### Edit intent
- Add incident note for stale failed check contexts after billing outage recovery.

#### Exact edits

```diff
@@
 - `AI Review Gate` reports blockers in strict mode:
   fix blockers or apply temporary waiver labels (`ai-gate:waive` +
   `accept:human`) with explicit human acknowledgement.
+- PR remains `BLOCKED` after billing was fixed and reruns are green:
+  stale failed check contexts can remain attached to the old head SHA.
+  Push a no-op commit to mint a fresh SHA, then rerun required checks.
+  Example:
+  `git commit --allow-empty -m "chore(ci): refresh required-check contexts" && git push`.
```

## Codification for Future CI Workflows (Required)

### Add future guard workflow and lint script

- Add `.github/workflows/ci-efficiency-guard.yml` (proposed content in `codification/ci-efficiency-guard.yml`).
- Add `.github/scripts/ci-efficiency-guard.sh` (proposed content in `codification/ci-efficiency-guard.sh`).

Policy enforced for future workflows:

- PR-triggered workflow files must include `concurrency`.
- PR-triggered workflow files must include `timeout-minutes` on each job.
- Workflows using both `pull_request` and `push` must scope `push` to `main`/tags only.
- Schedule intervals below hourly are blocked unless explicitly allowlisted.
- Heavy workflows should avoid running on label-only events unless job-level gate is lightweight.

## Impact Map (code, tests, docs, contracts)

- `code`:
  - `.github/workflows/ai-review-gate.yml`
  - `.github/workflows/filesystem-interfaces-perf-regression.yml`
  - `.github/workflows/smoke.yml`
  - `.github/workflows/pr-autonomy-policy.yml`
  - `.github/workflows/pr-quality.yml`
  - `.github/workflows/commit-and-branch-standards.yml`
  - `.github/workflows/pr-auto-merge.yml`
  - `.github/workflows/pr-clean-state-enforcer.yml`
  - `.github/workflows/codex-pr-review.yml`
  - `.github/workflows/ci-efficiency-guard.yml` (new)
  - `.github/scripts/ci-efficiency-guard.sh` (new)
- `tests`:
  - Dry-run lint validation for all edited workflows (`actionlint` or `yamllint` + `gh workflow view` checks).
  - PR simulation for label-only, docs-only, risky-change, and schedule scenarios.
- `docs`:
  - `.harmony/agency/practices/github-autonomy-runbook.md` (billing stale-context recovery note).
  - Baseline and post-change report artifacts under `.proposals/ci-optimizations`.
- `contracts`:
  - Required-check names remain unchanged.
  - Branch-protection semantics preserved.

## Verification Plan

- Baseline capture: 30-day workflow usage before merge.
- Short-term verification: 1 week post-merge.
- Full verification: 30-day post-merge comparison.
- Guardrails:
  - No increase in merge-blocking flake.
  - No new required-check deadlocks.
  - No loss of required governance coverage.

## Compliance Receipt

- Required governance output sections are present in this plan.
- Selected profile adheres to pre-1.0 default (`atomic`).
- Merge safety remains enforced by preserving required checks and using job-level gating for expensive branches of work.
- Optimization changes are codified for future workflows via guard workflow + lint policy.

## Exceptions/Escalations

- `exception_01`: GitHub workflow-run metadata does not reliably expose PR action subtypes (`synchronize`, `labeled`, `unlabeled`) for exact run-level attribution in all APIs.
  - mitigation: collect primary event-level baseline (`pull_request`, `pull_request_target`, `push`, `schedule`) and pair with PR event telemetry where available.
  - escalation owner: repo governance owner.

