---
name: ci-gate-triage
description: >
  Remediation skill for CI gate failures across contract, security, and
  quality checks, producing deterministic triage summaries and prioritized
  remediation guidance aligned with Octon methodology gates.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-03-05"
  updated: "2026-03-05"
skill_sets: [executor, specialist, guardian, integrator]
capabilities: [external-dependent]
allowed-tools: Read Glob Grep Bash(gh *) Write(/.octon/state/evidence/runs/skills/*) Write(/.octon/state/evidence/validation/analysis/*)
---

# CI Gate Triage

Diagnose CI gate failures and produce bounded remediation guidance without redefining canonical policy.

## When to Use

Use this skill when:

- A PR fails required CI gates
- Contract/security/quality gate failures need fast triage
- A deterministic remediation plan is needed for gate convergence

## Quick Start

```markdown
/ci-gate-triage pr="123" repository="owner/repo" gate_scope="required"
```

## Core Workflow

1. **Pre-flight** - Resolve PR/run context and required gates
2. **Failure analysis** - Classify failing checks by gate family
3. **Remediation mapping** - Propose smallest robust fix order
4. **Output** - Emit triage report and escalation notes

## Parameters

Parameters are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts repository context, PR/run identifiers, and gate scope.

## Output Location

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

Primary outputs are triage report artifacts and execution logs.

## Boundaries

- Do not modify branch protection, required checks, or governance contracts.
- Keep triage output evidence-first and explicitly scoped.
- Do not treat provider status alone as canonical policy truth.

## When to Escalate

- Required run context cannot be resolved
- Failing checks are inconsistent across provider sources
- Proposed remediation would conflict with canonical ACP/tier policy

## References

- [Behavior phases](references/phases.md)
- [Decision logic](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
- [Validation](references/validation.md)
- [Safety](references/safety.md)
- [Glossary](references/glossary.md)
- [Dependencies](references/dependencies.md)
