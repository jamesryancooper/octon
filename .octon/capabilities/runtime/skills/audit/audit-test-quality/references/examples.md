---
title: Examples Reference
description: Example invocations and expected outputs for test-quality audit.
---

# Examples Reference

Representative examples for the audit-test-quality skill.

## Example 1: Repository-Wide Test Quality Audit

### Invocation

```text
/audit-test-quality scope=".octon"
```

### Expected Emphasis

- Discover strategy, test-surface, assurance, reliability, and evidence artifacts.
- Surface gaps in test-depth coverage, contract/integration traceability, or gate readiness.
- Emit a coverage matrix with stable findings.

## Example 2: Interface-Scope Assurance Audit

### Invocation

```text
/audit-test-quality scope=".octon/capabilities/runtime/services/interfaces" contract_integration_artifacts_glob="**/contracts/**,**/compatibility.yml"
```

### Expected Emphasis

- Focus on contract and integration assurance for interface services.
- Validate traceability from contracts to executable evidence.
- Record unknowns for critical paths lacking reliable test evidence.

## Example 3: Post-Remediation Strict Gate

### Invocation

```text
/audit-test-quality scope=".octon" post_remediation=true severity_threshold="high" convergence_k="3"
```

### Expected Emphasis

- Strict done-gate enforcement at HIGH and above.
- Convergence stability checks across controlled reruns.
- Pass only when targeted gaps are closed with evidence.

## Anti-Examples

### Inferring Test Readiness Without Evidence

**Wrong behavior:** Declaring critical paths release-ready without citing executed test evidence.

**Why wrong:** Missing evidence is itself a finding candidate, not proof of quality.

### Skipping a Mandatory Layer

**Wrong behavior:** Reporting after strategy checks without assurance or reliability layers.

**Why wrong:** The layered contract requires all mandatory lenses to run before completion.
