---
title: Examples Reference
description: Example invocations and expected outputs for security and compliance audit.
---

# Examples Reference

Representative examples for the audit-security-compliance skill.

## Example 1: Service-Scope Security and Compliance Audit

### Invocation

```text
/audit-security-compliance scope=".octon/capabilities/runtime/services"
```

### Expected Emphasis

- Discover policy/control, safeguards, and evidence artifacts.
- Surface gaps in control coverage, secrets and access safeguards, or evidence readiness.
- Emit a coverage matrix with stable findings.

## Example 2: Explicit Baseline References

### Invocation

```text
/audit-security-compliance scope=".octon" policy_baseline_ref=".octon/assurance/practices/standards/security-and-privacy.md" control_baseline_ref=".octon/cognition/practices/methodology/security-baseline.md"
```

### Expected Emphasis

- Use baseline artifacts as expected control intent.
- Separate proven gaps from baseline assumptions.
- Record unknowns where baseline intent cannot be mapped to artifacts.

## Example 3: Post-Remediation Strict Gate

### Invocation

```text
/audit-security-compliance scope=".octon/capabilities/runtime/services" post_remediation=true severity_threshold="high" convergence_k="3"
```

### Expected Emphasis

- Strict done-gate enforcement at HIGH and above.
- Convergence stability checks across controlled reruns.
- Pass only when targeted gaps are closed with evidence.

## Anti-Examples

### Inferring Compliance Without Evidence

**Wrong behavior:** Declaring controls complete because no obvious violations were found.

**Why wrong:** Missing evidence is itself a finding candidate, not proof of compliance.

### Skipping a Mandatory Layer

**Wrong behavior:** Reporting after policy checks without safeguard or evidence layers.

**Why wrong:** The layered contract requires all mandatory lenses to run before completion.
