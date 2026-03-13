---
name: incident-response
description: >
  Operations skill for bounded incident response workflows, including
  severity framing, rollback/mitigation decision support, and deterministic
  post-incident evidence capture aligned with Octon runtime policy.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-03-05"
  updated: "2026-03-05"
skill_sets: [executor, specialist, guardian]
capabilities: []
allowed-tools: Read Glob Grep Write(_ops/state/logs/*) Write(../../../output/reports/*)
---

# Incident Response

Run a bounded, evidence-first incident response workflow aligned to Octon runtime policy and governance.

## When to Use

Use this skill when:

- Active degradation, outage, or policy incident needs structured response
- Rollback/mitigation decisions need documented evidence and rationale
- A post-incident receipt and follow-up package is required

## Quick Start

```markdown
/incident-response severity="sev2" scope="runtime" mode="mitigate"
```

## Core Workflow

1. **Pre-flight** - Capture incident scope, severity, and known impact
2. **Mitigation framing** - Evaluate rollback or containment options
3. **Evidence capture** - Record timeline, decisions, and residual risk
4. **Output** - Emit incident summary and post-incident actions

## Parameters

Parameters are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts severity, scope, mode, and evidence reference inputs.

## Output Location

Output paths are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

Primary outputs are incident report artifacts and execution logs.

## Boundaries

- Do not redefine canonical incident or ACP policy in this skill.
- Keep mitigation guidance reversible and evidence-backed.
- Escalate when severity or uncertainty exceeds local authority.

## When to Escalate

- Severity classification is ambiguous and changes response authority
- Mitigation options have contradictory evidence
- Governance exceptions are required to proceed

## References

- [Behavior phases](references/phases.md)
- [Decision logic](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
- [Validation](references/validation.md)
- [Safety](references/safety.md)
- [Glossary](references/glossary.md)
