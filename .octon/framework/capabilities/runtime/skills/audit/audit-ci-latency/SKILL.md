---
name: audit-ci-latency
description: >
  Report-only CI latency audit that inspects recent GitHub Actions runs,
  measures required-path performance against policy thresholds, identifies slow
  workflows and duplicate heavyweight setup/build work, and produces concrete
  tightening recommendations without mutating CI by default.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-03-12"
  updated: "2026-03-12"
skill_sets: [executor, guardian]
capabilities: [domain-specialized, self-validating, external-dependent]
allowed-tools: Read Glob Grep Bash(gh *) Bash(bash .octon/framework/execution-roles/_ops/scripts/ci/audit-ci-latency.sh *) Write(/.octon/state/evidence/validation/analysis/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Audit CI Latency

Report-only audit of GitHub Actions latency, critical-path speed, and workflow duplication for this repository.

## When to Use

Use this skill when:

- CI is getting slower and you need evidence-backed tightening recommendations
- A weekly latency report or breach issue needs follow-up analysis
- You want to inspect required-path timing, step hotspots, or duplicate workflow work
- You need a report without changing workflow YAML yet

## Quick Start

```text
/audit-ci-latency
```

With tighter scope:

```text
/audit-ci-latency window_runs="60" top_workflows="8" gate_scope="all"
```

## Core Workflow

1. **Collect** -- Run the shared latency wrapper to fetch recent Actions run/job data and local workflow scan evidence.
2. **Classify** -- Read the generated summary and determine whether status is `healthy`, `watch`, or `breach`.
3. **Recommend** -- Turn hotspots and duplicate-work findings into safe tightening recommendations.
4. **Report** -- Emit Markdown and JSON outputs suitable for issue-only control loops and manual follow-up work.

## Parameters

Parameters are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts optional controls for repository selection, audit window, top-workflow depth, and gate scope emphasis.

## Output Location

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

Primary outputs are written to:

- `.octon/state/evidence/validation/YYYY-MM-DD-ci-latency-audit-<run-id>.md`
- `.octon/state/evidence/validation/YYYY-MM-DD-ci-latency-audit-<run-id>.json`
- `/.octon/state/evidence/runs/skills/audit-ci-latency/`

## Boundaries

- Read-only by default; do not edit workflow YAML or branch-protection settings
- Use the existing GitHub control-plane contract as the source of required checks
- If run data is insufficient, report explicit unknowns rather than inventing trend conclusions
- Do not open issues or PRs directly; that is handled by the scheduled GitHub workflow

## When to Escalate

- GitHub CLI is unavailable or unauthenticated
- The run window does not contain enough successful PR samples for stable required-path metrics
- API data for required checks is inconsistent across runs or missing required contexts
- Recommended tightening would require changing required checks, merge policy, or governance contracts

## References

- [Behavior phases](references/phases.md)
- [I/O contract](references/io-contract.md)
- [Safety](references/safety.md)
- [Validation](references/validation.md)
- [Examples](references/examples.md)
- [Dependencies](references/dependencies.md)
