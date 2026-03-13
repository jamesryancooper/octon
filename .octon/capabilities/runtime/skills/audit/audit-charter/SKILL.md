---
name: audit-charter
description: >
  Closed-book charter audit for internal alignment, coherence, enforceability,
  authority clarity, normative integrity, and standalone quality. Extracts
  pitch, vision, purpose, objective, and operating model from the charter
  itself, tests contradictions and governance sufficiency, and produces the
  full structured audit package requested by the original charter-review
  prompt, including exact table contracts, rewrite guidance, and scored
  findings. Read-only against the charter source.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-03-05"
  updated: "2026-03-05"
skill_sets: [executor, guardian, specialist]
capabilities: []
allowed-tools: Read Glob Grep Write(../../output/reports/*) Write(_ops/state/logs/*)
---

# Audit Charter

Run a closed-book audit of a charter document using only the charter text as evidence.

## Goal Alignment

Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

## When to Use

Use this skill when:

- You need to evaluate whether a charter stands on its own without external context
- You want a governance-quality audit of pitch, purpose, authority, controls, and enforceability
- You need contradictions, gaps, and undefined terms surfaced with evidence
- You want exact parity with the original charter-review prompt, not a looser approximation

## Quick Start

```text
/audit-charter charter_path=".octon/CHARTER.md"
```

With narrowed reporting:

```text
/audit-charter charter_path=".octon/CHARTER.md" severity_threshold="medium" include_rewrites=true
```

## Core Workflow

1. **Extract Canonical Framing** -- Identify the charter's elevator pitch, vision, unique value proposition, purpose, primary objective, and direct answers to `what`, `does`, `why`, and `how`.
2. **Trace and Test** -- Build a claim-to-support map and test each claim for support, ambiguity, enforceability, auditability, and standalone clarity.
3. **Audit Governance Quality** -- Inspect normative clauses, authority and accountability flows, terminology consistency, success signal measurability, dependency resilience, and precedence conflict handling.
4. **Log Findings** -- Record contradictions, latent conflicts, gaps, and weak controls with severity and path-level evidence.
5. **Rewrite and Score** -- Produce targeted rewrite guidance and final category scores.

## Hard Constraints

- Closed-book review: use only the charter file named by `charter_path`
- Do not use or reference external docs, repo context, assumptions, or prior knowledge
- Judge only internal evidence, internal consistency, and standalone clarity

## Evaluation Criteria

The audit must explicitly evaluate:

- alignment across pitch, vision, unique value proposition, purpose, objective, and other sections,
- `how` sufficiency, including contracts, controls, lifecycle, authority, and enforcement,
- contradictions and latent conflicts,
- gaps between claims and operational mechanisms,
- clarity and actionability without external context,
- standalone quality for a new reader,
- normative language integrity for every `MUST`, `SHOULD`, and `MAY`,
- authority and accountability integrity,
- enforceability and auditability,
- terminology consistency,
- success signal measurability,
- external dependency resilience,
- precedence conflict resolution determinism.

## Required Method

The audit must perform these steps in order:

1. Extract canonical statements for pitch, vision, unique value proposition, purpose, and primary objective.
2. Build a traceability map from major claims to supporting sections.
3. Test each claim for support, ambiguity, enforceability, and auditability.
4. Detect contradictions and latent conflicts and simulate precedence resolution for likely conflict pairs.
5. Identify gaps in `what`, `does`, `why`, and `how` coverage.
6. Audit normative language for clarity, overlap, and conflict.
7. Validate authority and accountability coverage for decide, execute, and escalate flows.

## Required Output Contract

The audit report must include these sections:

1. `Overall Verdict`
2. `Coverage Matrix`
3. `Contradiction/Conflict Log`
4. `Normative Clause Audit`
5. `Authority/Accountability Map`
6. `Enforceability Matrix`
7. `Terminology Consistency Log`
8. `Success Signal Operability`
9. `Dependency Resilience`
10. `Gap Log`
11. `Rewrite Pack`
12. `Final Scores`

The report must preserve these exact contracts:

- `Overall Verdict`: one of `Aligned`, `Partially aligned`, or `Not aligned`, followed by a one-paragraph rationale
- `Coverage Matrix`: `Dimension (What/Does/Why/How) | Key Charter Claim | Supporting Sections | Gap? | Notes`
- `Contradiction/Conflict Log`: `ID | Sections in tension | Conflict description | Severity (High/Med/Low) | Why it matters | Precedence outcome`
- `Normative Clause Audit`: `Clause reference | Normative keyword | Requirement text (short) | Clear? | Testable? | Conflict risk | Fix`
- `Authority/Accountability Map`: `Flow/Decision | Decision owner | Execution owner | Escalation owner | Explicit in Charter? | Gap`
- `Enforceability Matrix`: `Requirement/Claim | Enforcement mechanism | Evidence artifact | Verifiable (Y/N) | Gap`
- `Terminology Consistency Log`: `Term | Definition present? | Consistent usage? | Drift/ambiguity | Fix`
- `Success Signal Operability`: `Success signal | Observable indicator | Measurement method | Threshold/condition | Gap`
- `Dependency Resilience`: `Referenced artifact/dependency | Role in Charter logic | Criticality | If missing, what breaks? | Needed mitigation text`
- `Gap Log`: `ID | Missing or weak area | Impact | Severity | Proposed fix`
- `Rewrite Pack`: exact replacement text for each `High` and `Med` issue, quoting current text and providing proposed text
- `Final Scores`: exact `0-100` scores for `Internal alignment`, `Contradiction-free coherence`, `Normative integrity`, `Authority/accountability clarity`, `How operational sufficiency`, `Enforceability/auditability`, `Standalone clarity`, and `Overall stands on its own score`

## Method Contract

The audit must:

- use only the charter file named by `charter_path`,
- determine whether the charter is internally complete, coherent, enforceable, and self-sufficient,
- treat missing definitions, owners, thresholds, or control paths as gaps,
- judge only internal evidence and internal consistency,
- distinguish direct contradictions from latent conflicts,
- simulate likely precedence conflicts using only the charter's own rules,
- avoid importing repo context, prior knowledge, or external doctrine.

## Parameters

Parameters are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts one required parameter (`charter_path`) and optional parameters for severity filtering, rewrite inclusion, and score inclusion.

## Output Location

Output paths are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.octon/output/reports/analysis/YYYY-MM-DD-charter-audit-<run-id>.md`
- `_ops/state/logs/audit-charter/`

## Boundaries

- Read only the charter file in scope for audit evidence
- Do not use other repo files, prior thread context, or external material to fill gaps
- Do not modify the charter or any related files
- Missing support is a finding, not a prompt to infer
- Keep findings evidence-backed and remediation-oriented

## When to Escalate

- The requested file is not a charter or cannot be read as a single bounded document
- The charter embeds external content by reference in a way that makes closed-book audit impossible to interpret
- The user requests implementation rather than audit output
- The scope expands from one charter to a multi-document governance system review

## References

- [Behavior phases](references/phases.md)
- [Decision rules](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
- [I/O contract](references/io-contract.md)
- [Safety policies](references/safety.md)
- [Validation](references/validation.md)
- [Examples](references/examples.md)
- [Glossary](references/glossary.md)
