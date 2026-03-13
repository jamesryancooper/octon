---
title: Examples Reference
description: Example invocations and expected outputs for release-readiness audit.
---

# Examples Reference

Representative examples for the audit-release-readiness skill.

## Example 1: Repository-Wide Release Readiness Audit

### Invocation

```text
/audit-release-readiness scope=".octon"
```

### Expected Emphasis

- Discover release policy, deployment/rollback, operations, and evidence artifacts.
- Surface gaps in launch criteria coverage, rollback posture, or gate traceability.
- Emit a coverage matrix with stable findings.

## Example 2: Service-Scope Launch Audit

### Invocation

```text
/audit-release-readiness scope=".octon/capabilities/runtime/services" deployment_artifacts_glob="**/SERVICE.md,**/compatibility.yml"
```

### Expected Emphasis

- Focus on critical service launch surfaces.
- Validate deployment safeguards and rollback evidence linkage.
- Record unknowns for critical paths lacking readiness evidence.

## Example 3: Post-Remediation Strict Gate

### Invocation

```text
/audit-release-readiness scope=".octon" post_remediation=true severity_threshold="high" convergence_k="3"
```

### Expected Emphasis

- Strict done-gate enforcement at HIGH and above.
- Convergence stability checks across controlled reruns.
- Pass only when targeted gaps are closed with evidence.

## Anti-Examples

### Inferring Launch Readiness Without Evidence

**Wrong behavior:** Declaring release-safe status without citing gate or rollback evidence.

**Why wrong:** Missing evidence is itself a finding candidate, not proof of readiness.

### Skipping a Mandatory Layer

**Wrong behavior:** Reporting after policy checks without safeguard or operations-evidence layers.

**Why wrong:** The layered contract requires all mandatory lenses to run before completion.
