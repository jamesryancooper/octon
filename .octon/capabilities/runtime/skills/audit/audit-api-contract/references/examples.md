---
title: Examples Reference
description: Example invocations and expected outputs for API-contract audit.
---

# Examples Reference

Representative examples for the audit-api-contract skill.

## Example 1: Repository-Wide API Contract Audit

### Invocation

```text
/audit-api-contract scope=".octon"
```

### Expected Emphasis

- Discover contract/spec, implementation, compatibility, and evidence artifacts.
- Surface gaps in contract completeness, conformance traceability, or lifecycle governance.
- Emit a coverage matrix with stable findings.

## Example 2: Interface-Scope Conformance Audit

### Invocation

```text
/audit-api-contract scope=".octon/capabilities/runtime/services/interfaces" spec_artifacts_glob="**/contracts/**,**/schema/**/*.json"
```

### Expected Emphasis

- Focus on interface-level contract and schema surfaces.
- Validate implementation conformance and compatibility safeguards.
- Record unknowns for critical interfaces lacking reliable evidence.

## Example 3: Post-Remediation Strict Gate

### Invocation

```text
/audit-api-contract scope=".octon" post_remediation=true severity_threshold="high" convergence_k="3"
```

### Expected Emphasis

- Strict done-gate enforcement at HIGH and above.
- Convergence stability checks across controlled reruns.
- Pass only when targeted gaps are closed with evidence.

## Anti-Examples

### Inferring Contract Conformance Without Evidence

**Wrong behavior:** Declaring interface conformance without citing spec and implementation evidence.

**Why wrong:** Missing evidence is itself a finding candidate, not proof of conformance.

### Skipping a Mandatory Layer

**Wrong behavior:** Reporting after spec checks without conformance or lifecycle-evidence layers.

**Why wrong:** The layered contract requires all mandatory lenses to run before completion.
