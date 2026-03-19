---
title: Examples Reference
description: Example invocations and expected outputs for architecture-readiness audit.
---

# Examples Reference

Representative examples for the audit-architecture-readiness skill.

## Example 1: Whole-Harness Architecture Readiness Audit

### Invocation

```text
/audit-architecture-readiness target_path=".octon"
```

### Expected Emphasis

- Classify the target as `whole-harness`.
- Score the full Octon control plane.
- Surface hard-gate failures, failure modes, and remediation artifacts.

## Example 2: Bounded-Domain Architecture Readiness Audit

### Invocation

```text
/audit-architecture-readiness target_path=".octon/framework/capabilities" severity_threshold="high"
```

### Expected Emphasis

- Classify the target as `bounded-domain`.
- Focus on domain-local readiness and boundary integrity.
- Emit critical and high gaps with exact artifact updates.

## Example 3: Unsupported Target

### Invocation

```text
/audit-architecture-readiness target_path=".octon/inputs/exploratory/ideation"
```

### Expected Emphasis

- Stop at applicability classification.
- Emit `verdict=not-applicable`.
- Explain why human-led domains are outside the framework scope.

## Anti-Examples

### Scoring a Surface-Only Path

**Wrong behavior:** Running the full scorecard on `.octon/framework/capabilities/governance`.

**Why wrong:** Surface-only paths are outside the supported target model and
must be marked `not-applicable`. Use `audit-surface-architecture` when the goal
is to evaluate one durable surface unit.

### Inferring Readiness Without Evidence

**Wrong behavior:** Declaring implementation-ready status without citing policy, evidence, recovery, or boundary artifacts.

**Why wrong:** Missing evidence is itself a finding candidate, not proof of readiness.
