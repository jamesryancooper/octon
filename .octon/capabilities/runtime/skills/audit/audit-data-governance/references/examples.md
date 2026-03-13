---
title: Examples Reference
description: Example invocations and expected outputs for data-governance audit.
---

# Examples Reference

Representative examples for the audit-data-governance skill.

## Example 1: Repository-Wide Data Governance Audit

### Invocation

```text
/audit-data-governance scope=".octon"
```

### Expected Emphasis

- Discover classification, retention, lineage, privacy, and evidence artifacts.
- Surface gaps in classification-to-retention mapping, traceability, or safeguard coverage.
- Emit a coverage matrix with stable findings.

## Example 2: Service-Scope Governance Audit

### Invocation

```text
/audit-data-governance scope=".octon/capabilities/runtime/services" contract_artifacts_glob="**/services/**/SERVICE.md"
```

### Expected Emphasis

- Focus on service metadata and contract traceability.
- Validate lineage and evidence linkage for in-scope service surfaces.
- Record unknowns for surfaces lacking sufficient evidence.

## Example 3: Post-Remediation Strict Gate

### Invocation

```text
/audit-data-governance scope=".octon" post_remediation=true severity_threshold="high" convergence_k="3"
```

### Expected Emphasis

- Strict done-gate enforcement at HIGH and above.
- Convergence stability checks across controlled reruns.
- Pass only when targeted gaps are closed with evidence.

## Anti-Examples

### Inferring Governance Compliance Without Evidence

**Wrong behavior:** Declaring retention and lineage complete without artifact references.

**Why wrong:** Missing evidence is itself a finding candidate, not proof of compliance.

### Skipping a Mandatory Layer

**Wrong behavior:** Reporting after classification checks without traceability or safeguards layers.

**Why wrong:** The layered contract requires all mandatory lenses to run before completion.
