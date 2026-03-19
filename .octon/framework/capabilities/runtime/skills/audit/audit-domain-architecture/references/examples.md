---
title: Examples Reference
description: Example invocations and expected outputs for independent architecture critique.
---

# Examples Reference

Representative examples for the audit-domain-architecture skill.

## Canonical Domain Targets

These targets are supported directly:

- `.octon/framework/agency`
- `.octon/framework/assurance`
- `.octon/framework/capabilities`
- `.octon/framework/cognition`
- `.octon/framework/engine`
- `.octon/framework/orchestration`
- `.octon/framework/scaffolding`
- `.octon/instance`
- `.octon/inputs`
- `.octon/state`
- `.octon/generated`

## Example 1: Existing Domain Critique

### Invocation

```text
/audit-domain-architecture domain_path=".octon/framework/cognition"
```

### Expected Emphasis

- Surface mapping across governance/runtime/practices and nested subsurfaces.
- Explicit treatment of governance/contracts as analyzable artifacts, not binding rules.
- Recommendations focused on external robustness and maintainability.

### Expected Output Sections

1. Current Surface Map (with file-path evidence)
2. Critical Gaps (impact + risk)
3. Recommended Changes (priority, expected benefit, tradeoff)
4. Keep As-Is decisions (and why)
5. Open Questions / Unknowns

## Example 2: Planned Domain (Prospective Mode)

### Invocation

```text
/audit-domain-architecture domain_path=".octon/new-domain"
```

### Expected Emphasis

- Explicit mode declaration: `prospective`.
- Surface map records that domain directory is absent.
- Recommendations grounded in domain profile baseline and comparator-domain evidence.
- Unknowns call out implementation details that cannot be proven yet.

## Example 3: Runtime Slice with Custom Criteria

### Invocation

```text
/audit-domain-architecture domain_path=".octon/framework/capabilities/runtime" criteria="modularity,discoverability,coupling,change-safety,testability"
```

### Expected Emphasis

- Runtime surface decomposition and discoverability for autonomous agent consumers.
- Coupling analysis across manifests, registries, and runtime contracts.
- Change-safety assessment for structural updates.

## Example 4: Deep Evidence Pass

### Invocation

```text
/audit-domain-architecture domain_path=".octon/framework/orchestration" evidence_depth="deep" severity_threshold="medium"
```

### Expected Emphasis

- Deeper cross-surface traceability checks and stronger evidentiary thresholds.
- Filtered reporting at MEDIUM and above.
- Explicit unknowns where claims cannot be proven with available artifacts.

## Anti-Examples

### Using This Skill to Enforce Local Doctrine

**Wrong:**

```text
/audit-domain-architecture domain_path=".octon/framework/cognition" criteria="octon-policy-compliance"
```

**Why wrong:** This skill critiques architecture against external criteria, not internal doctrine compliance.

### Inferring Without Evidence

**Wrong behavior:** Declaring a critical coupling issue without citing supporting paths.

**Why wrong:** Every non-trivial claim must be evidence-backed or reclassified as unknown.
