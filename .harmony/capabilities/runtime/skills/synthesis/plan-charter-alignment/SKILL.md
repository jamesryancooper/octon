---
name: plan-charter-alignment
description: >
  Turn charter audit findings into a profile-governed alignment and remediation
  plan. Maps findings to concrete charter changes, defines acceptance criteria,
  chooses one governance change profile, and produces an agent-readable plan
  with implementation receipts, test scenarios, and scoped assumptions. Read-only
  against source files.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Harmony Framework
  created: "2026-03-05"
  updated: "2026-03-05"
skill_sets: [executor, collaborator]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(../../output/plans/*) Write(_ops/state/logs/*)
---

# Plan Charter Alignment

Transform charter audit findings into a comprehensive alignment plan without implementing the changes.

## Goal Alignment

Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

## When to Use

Use this skill when:

- You already have charter audit findings and need a concrete remediation plan
- You want the charter rewrite broken into explicit change bundles with acceptance criteria
- You need governance-profile receipts and compliance sections before implementation
- You want a plan that another engineer or agent can execute without inventing missing decisions

## Quick Start

```text
/plan-charter-alignment charter_path=".harmony/CHARTER.md" findings_source=".harmony/output/reports/2026-03-05-charter-audit.md"
```

With explicit scoring target:

```text
/plan-charter-alignment charter_path=".harmony/CHARTER.md" findings_source="report.md" target_score="98"
```

## Core Workflow

1. **Parse Findings** -- Normalize the audit results into material issues, ownership gaps, terminology drift, and control weaknesses.
2. **Select Governance Profile** -- Derive release state, collect hard-gate facts, choose exactly one `change_profile`, and emit the profile receipt.
3. **Define Target State** -- Convert findings into desired charter properties, success conditions, and explicit acceptance thresholds.
4. **Map Changes** -- Group findings into concrete rewrite bundles, metadata updates, verification work, and follow-on scope if needed.
5. **Assemble Plan** -- Produce an implementation-ready alignment plan with required receipts, test scenarios, assumptions, and scoped exclusions.
6. **Review Gaps** -- Surface unresolved ambiguities, exceptions, or follow-on work rather than silently deciding them during planning.

## Required Output Sections

Generated plans must contain:

1. `Profile Selection Receipt`
2. `Implementation Plan`
3. `Impact Map (code, tests, docs, contracts)`
4. `Compliance Receipt`
5. `Exceptions/Escalations`

## Planning Contract

The plan must:

- stay charter-focused unless the findings clearly require follow-on scope,
- map every High and Medium finding to a planned change or explicit no-change rationale,
- preserve a decision-complete implementation path for the charter file itself,
- state assumptions instead of silently widening scope,
- treat implementation as out of scope for the skill run.

## Parameters

Parameters are defined in `.harmony/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts required charter and findings inputs plus optional governance and target-score selectors.

## Output Location

Output paths are defined in `.harmony/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.harmony/output/plans/YYYY-MM-DD-charter-alignment-plan-<run-id>.md`
- `_ops/state/logs/plan-charter-alignment/`

## Boundaries

- Read-only against source charters and audit findings
- Do not implement the plan or edit the charter
- Do not invent schema or governance changes outside the findings without calling them out as scope expansion
- Do not select `transitional` unless the hard gates actually require it
- If higher-precedence governance creates tie-break ambiguity, stop and escalate instead of guessing

## When to Escalate

- Audit findings are contradictory or incomplete in ways that block decision-complete planning
- Profile selection tie-break ambiguity exists
- Findings imply mandatory changes outside the charter but the requested scope remains charter-only
- The requested score target cannot be justified without broader contract or schema changes

## References

- [Behavior phases](references/phases.md)
- [Decision rules](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
- [Interaction](references/interaction.md)
- [I/O contract](references/io-contract.md)
- [Safety policies](references/safety.md)
- [Validation](references/validation.md)
- [Examples](references/examples.md)
