---
name: triage-ci-failure
description: >
  Diagnose and repair CI pipeline failures. Fetches failing CI logs from
  GitHub Actions (or compatible CI), identifies root causes through
  structured log analysis, applies targeted fixes, and verifies the
  repair locally before pushing. Reduces mean-time-to-green by replacing
  ad-hoc debugging with a systematic triage protocol.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-02-09"
  updated: "2026-02-10"
skill_sets: [executor]
capabilities: [external-dependent]
allowed-tools: Read Glob Grep Edit Bash(gh) Bash(npm) Bash(npx) Write(/.octon/state/evidence/validation/analysis/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Triage CI Failure

Diagnose and repair CI pipeline failures.

## When to Use

Use this skill when:

- CI checks are failing on a PR or branch
- You need to identify the root cause of a test, build, or lint failure
- You want to fix CI without manual log spelunking
- A dependency update broke the build

## Quick Start

```
/triage-ci-failure pr="123"
```

Or for a specific branch:

```
/triage-ci-failure branch="feature/my-branch"
```

## Core Workflow

1. **Fetch** — Retrieve failing CI run logs via `gh run list` and `gh run view`
2. **Diagnose** — Parse logs to identify root cause category and affected files
3. **Fix** — Apply targeted repair based on diagnosis
4. **Verify** — Run the failing check locally to confirm the fix
5. **Report** — Document diagnosis, fix applied, and verification result

### Failure Categories

| Category | Signals | Common Fixes |
|----------|---------|-------------|
| TEST_FAILURE | `FAIL`, `AssertionError`, test name in output | Fix assertion, update snapshot, fix test setup |
| BUILD_ERROR | `error TS`, `SyntaxError`, `Module not found` | Fix import, add missing dependency, fix type error |
| LINT_VIOLATION | `eslint`, `prettier`, `warning/error` count | Apply auto-fix, update rule config, fix violation |
| DEPENDENCY | `ERESOLVE`, `peer dep`, `not found in registry` | Update lockfile, pin version, add missing package |
| TIMEOUT | `exceeded`, `timed out`, `SIGTERM` | Optimize test, increase timeout, fix infinite loop |
| INFRA | `rate limit`, `connection refused`, `ENOMEM` | Retry (if transient), escalate (if persistent) |

### Diagnosis Protocol

1. Start with the **first failing step** in the CI run
2. Read the **last 100 lines** of the failing step's log
3. Search for error patterns matching the categories above
4. If ambiguous, read the **full log** of the failing step
5. Identify the **specific file and line** causing the failure
6. Cross-reference with the **diff** to determine if the failure is from this PR's changes

## Parameters

Parameters are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts a PR number or branch name to identify the failing CI run, plus optional parameters for targeting specific jobs or steps.

## Output Location

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.octon/state/evidence/validation/analysis/YYYY-MM-DD-ci-triage.md` — Triage report
- `/.octon/state/evidence/runs/skills/triage-ci-failure/` — Execution logs with index

## Boundaries

- Never push fixes without local verification passing first
- Never modify CI configuration (workflow YAML) without explicit approval
- Never skip failing tests — fix them or explain why they should be updated
- Do not install new dependencies without confirming they're appropriate
- If the failure is in infrastructure (not code), report it rather than attempting a fix
- Maximum scope: 3 failing jobs per run (escalate if more)

## When to Escalate

- Failure is infrastructure-related (rate limits, OOM, network) — report, don't fix
- Failure predates the current PR's changes — flag as pre-existing
- Fix would require significant architectural changes — propose approach, don't implement
- More than 3 independent failure categories in one run — recommend separate triage passes

## References

For detailed documentation:

- [Behavior phases](references/phases.md) — Full phase-by-phase instructions
- [I/O contract](references/io-contract.md) — Inputs, outputs, log parsing schema
- [Safety policies](references/safety.md) — Git safety, CI config protection
- [Validation](references/validation.md) — Acceptance criteria for successful triage
- [Examples](references/examples.md) — Triage examples from real CI failures
- [Dependencies](references/dependencies.md) — External tool requirements (gh CLI)
