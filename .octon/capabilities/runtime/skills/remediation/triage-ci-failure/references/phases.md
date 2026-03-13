---
behavior:
  phases:
    - name: "Fetch"
      steps:
        - "Identify the failing CI run from PR number or branch name"
        - "Run `gh run list --branch <branch> --status failure --limit 1` to find the latest failing run"
        - "Run `gh run view <run_id>` to get job-level status"
        - "Identify the first failing job and step"
        - "Run `gh run view <run_id> --log-failed` to get the failing step's logs"
        - "If logs are truncated, fetch full logs: `gh api repos/{owner}/{repo}/actions/runs/{run_id}/logs`"
        - "Record: run ID, failing job name, failing step name, log length"
    - name: "Diagnose"
      steps:
        - "Read the last 100 lines of the failing step's log"
        - "Search for error patterns matching the failure categories"
        - "Classify the failure: TEST_FAILURE, BUILD_ERROR, LINT_VIOLATION, DEPENDENCY, TIMEOUT, INFRA"
        - "Identify the specific file and line causing the failure (if determinable)"
        - "Cross-reference with the PR diff: is this a new failure or pre-existing?"
        - "If multiple failures, prioritize: the first error is usually the root cause"
        - "Record diagnosis: category, root cause, affected file(s), confidence level"
    - name: "Fix"
      steps:
        - "Based on diagnosis category, apply the appropriate fix strategy"
        - "TEST_FAILURE: read the failing test, understand the assertion, fix the code or update the test"
        - "BUILD_ERROR: fix the import, type error, or missing dependency"
        - "LINT_VIOLATION: apply auto-fix or manually fix the violation"
        - "DEPENDENCY: update lockfile, pin version, or add missing package"
        - "TIMEOUT: optimize the slow operation or increase timeout (with justification)"
        - "INFRA: do not fix — report as infrastructure issue"
        - "Record: what was changed, which files, and why"
    - name: "Verify"
      steps:
        - "Run the failing check locally to confirm the fix"
        - "For test failures: run the specific failing test(s)"
        - "For build errors: run the build command"
        - "For lint violations: run the linter"
        - "Record: local verification result (pass/fail), command used"
        - "If local verification fails, return to Diagnose phase"
    - name: "Report"
      steps:
        - "Generate triage report with diagnosis and fix details"
        - "Include: failure category, root cause, fix applied, verification result"
        - "Include: CI run link, failing job/step, relevant log excerpt"
        - "Write report to output/reports/analysis/"
        - "Write execution log with metadata"
        - "Update log index"
  goals:
    - "Identify the root cause of the CI failure accurately"
    - "Apply a targeted fix (not a workaround)"
    - "Verify the fix locally before declaring success"
    - "Document the diagnosis for future reference"
    - "Distinguish between code issues and infrastructure issues"
---

# Behavior Reference

Detailed phase-by-phase behavior for the triage-ci-failure skill.

## Phase 1: Fetch

Retrieve failing CI logs from GitHub Actions.

### Fetch Steps

1. **Find the failing run:**

   From a PR:
   ```bash
   gh pr checks 123 --json name,state,link --jq '.[] | select(.state == "FAILURE")'
   ```

   From a branch:
   ```bash
   gh run list --branch feature/my-branch --status failure --limit 1 --json databaseId,name,conclusion
   ```

2. **Get job details:**

   ```bash
   gh run view <run_id> --json jobs --jq '.jobs[] | select(.conclusion == "failure") | {name, conclusion, steps: [.steps[] | select(.conclusion == "failure")]}'
   ```

3. **Get failing logs:**

   ```bash
   gh run view <run_id> --log-failed
   ```

   If logs are too long, focus on the last 100 lines of the first failing step.

### Fetch Result

Failing log content with job/step metadata, ready for diagnosis.

---

## Phase 2: Diagnose

Identify the root cause from the log output.

### Diagnosis Protocol

1. **Start with the first error** — In CI, the first failure is usually the root cause. Later failures are often cascading.

2. **Pattern matching** — Search the log for category-specific patterns:

   | Category | Patterns to Search |
   |----------|-------------------|
   | TEST_FAILURE | `FAIL`, `✕`, `AssertionError`, `Expected`, `toBe`, `toEqual` |
   | BUILD_ERROR | `error TS`, `SyntaxError`, `Cannot find module`, `Module not found` |
   | LINT_VIOLATION | `error`, `warning`, lint rule names, `--fix` suggestions |
   | DEPENDENCY | `ERESOLVE`, `peer dep`, `404 Not Found`, `npm ERR!` |
   | TIMEOUT | `exceeded`, `timed out`, `SIGTERM`, `SIGKILL` |
   | INFRA | `rate limit`, `ECONNREFUSED`, `ENOMEM`, `disk full` |

3. **Locate the source** — Find the specific file and line from the error output.

4. **Check the diff** — Determine if this is a regression from this PR or pre-existing:
   ```bash
   gh pr diff 123 -- <affected_file>
   ```

### Diagnosis Result

Root cause identified with category, affected files, and confidence level.

---

## Phase 3: Fix

Apply the targeted repair.

### Fix Strategies by Category

**TEST_FAILURE:**
- Read the failing test to understand the assertion
- Read the code under test to understand the actual behavior
- Fix the code if the test is correct, or update the test if the behavior changed intentionally

**BUILD_ERROR:**
- Fix the import path or add the missing export
- Fix the type error using the compiler's suggestion
- Add the missing dependency to package.json

**LINT_VIOLATION:**
- Try auto-fix first: `npx eslint --fix <file>`
- If auto-fix doesn't cover it, apply the fix manually
- Never disable the rule without explicit justification

**DEPENDENCY:**
- Delete lockfile and regenerate if resolution conflict
- Pin the conflicting dependency version
- Add missing peer dependency

**TIMEOUT:**
- Profile the slow operation
- Optimize or parallelize
- Only increase timeout as a last resort (document why)

**INFRA:**
- Do NOT attempt to fix
- Document the issue and suggest retry or ops escalation

---

## Phase 4: Verify

Run the failing check locally.

### Verification Protocol

1. Run the exact command that failed in CI:
   - Tests: `npm test -- --testPathPattern=<failing_test>`
   - Build: `npm run build`
   - Lint: `npm run lint`

2. Confirm the specific failure no longer occurs

3. If verification fails, return to Phase 2 with new information

### Verification Outcomes

| Outcome | Next Step |
|---------|-----------|
| Local pass | Proceed to Report |
| Local fail (same error) | Return to Diagnose — fix was incomplete |
| Local fail (different error) | Fix introduced a new issue — revert and re-diagnose |
| Cannot reproduce locally | Note environment difference, apply fix with lower confidence |

---

## Phase 5: Report

Document the triage results.

### Report Structure

```markdown
# CI Triage Report

**Date:** YYYY-MM-DD
**PR:** #123 (or branch: feature/my-branch)
**CI Run:** <link>
**Failing Job:** job-name / step-name

## Diagnosis

**Category:** TEST_FAILURE
**Root Cause:** Assertion in `auth.test.ts:42` expects old API response format
**Confidence:** HIGH
**Pre-existing:** No (introduced by this PR's changes to auth endpoint)

## Fix Applied

**File:** src/api/auth.ts:28
**Change:** Updated response shape to include `refreshToken` field
**Commit:** abc1234

## Verification

**Command:** `npm test -- --testPathPattern=auth.test`
**Result:** PASS (12 tests passed)

## Log Excerpt

\`\`\`
[relevant error output]
\`\`\`
```
