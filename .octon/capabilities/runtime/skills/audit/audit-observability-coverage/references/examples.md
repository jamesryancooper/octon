---
title: Examples Reference
description: Example invocations and expected outputs for observability coverage audit.
---

# Examples Reference

Representative examples for the audit-observability-coverage skill.

## Example 1: Service-Scope Coverage Audit

### Invocation

```text
/audit-observability-coverage scope=".octon/capabilities/runtime/services"
```

### Expected Emphasis

- Discover service manifests and associated observability artifacts.
- Surface missing telemetry/SLO/alert/runbook/dashboard links.
- Emit a coverage matrix with stable findings.

## Example 2: Explicit Baseline Contract

### Invocation

```text
/audit-observability-coverage scope=".octon/capabilities/runtime/services" observability_contract_ref=".octon/cognition/_meta/architecture/observability-requirements.md"
```

### Expected Emphasis

- Use contract guidance as baseline for required signals.
- Separate proven gaps from baseline assumptions.
- Record unknowns where contract intent cannot be mapped to artifacts.

## Example 3: Post-Remediation Strict Gate

### Invocation

```text
/audit-observability-coverage scope=".octon/capabilities/runtime/services" post_remediation=true severity_threshold="high" convergence_k="3"
```

### Expected Emphasis

- Strict done-gate enforcement at HIGH and above.
- Convergence stability checks across controlled reruns.
- Pass only when targeted gaps are closed with evidence.

## Anti-Examples

### Inferring Compliance Without Evidence

**Wrong behavior:** Declaring coverage complete because no alert file matched the glob.

**Why wrong:** Missing artifacts are evidence of potential gaps, not evidence of compliance.

### Skipping a Mandatory Layer

**Wrong behavior:** Reporting after SLO checks without runbook/dashboard coverage.

**Why wrong:** The layered contract requires all mandatory lenses to run before completion.
