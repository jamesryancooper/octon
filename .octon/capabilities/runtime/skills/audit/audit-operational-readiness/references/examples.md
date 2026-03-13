---
title: Examples Reference
description: Example invocations and expected outputs for operational-readiness audit.
---

# Examples Reference

Representative examples for the audit-operational-readiness skill.

## Example 1: Repository-Wide Operational Readiness Audit

### Invocation

```text
/audit-operational-readiness scope=".octon"
```

### Expected Emphasis

- Discover ownership/objective, runbook/incident, resilience/capacity, and evidence artifacts.
- Surface gaps in accountability, response preparedness, or sustained operability safeguards.
- Emit a coverage matrix with stable findings.

## Example 2: Service-Scope Readiness Audit

### Invocation

```text
/audit-operational-readiness scope=".octon/capabilities/runtime/services" ownership_artifacts_glob="**/SERVICE.md,**/*ownership*.md"
```

### Expected Emphasis

- Focus on critical service operational surfaces.
- Validate runbook and incident pathways plus reliability objective traceability.
- Record unknowns for high-impact paths lacking reliable evidence.

## Example 3: Post-Remediation Strict Gate

### Invocation

```text
/audit-operational-readiness scope=".octon" post_remediation=true severity_threshold="high" convergence_k="3"
```

### Expected Emphasis

- Strict done-gate enforcement at HIGH and above.
- Convergence stability checks across controlled reruns.
- Pass only when targeted gaps are closed with evidence.

## Anti-Examples

### Inferring Operational Readiness Without Evidence

**Wrong behavior:** Declaring services operationally ready without citing ownership, incident, and resilience evidence.

**Why wrong:** Missing evidence is itself a finding candidate, not proof of readiness.

### Skipping a Mandatory Layer

**Wrong behavior:** Reporting after ownership checks without incident or resilience-evidence layers.

**Why wrong:** The layered contract requires all mandatory lenses to run before completion.
