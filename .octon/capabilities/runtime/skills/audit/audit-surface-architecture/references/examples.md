---
title: Examples Reference
description: Example invocations and expected outputs for surface-architecture audit.
---

# Examples Reference

Representative examples for the audit-surface-architecture skill.

## Example 1: Workflow Surface

### Invocation

```text
/audit-surface-architecture surface_path=".octon/orchestration/runtime/workflows/meta/create-design-proposal"
```

### Expected Emphasis

- Classify the target as one workflow surface unit.
- Name contract artifacts, stage assets, and non-authoritative docs separately.
- Detect whether execution authority is contract-first or mixed.

## Example 2: Skill Surface

### Invocation

```text
/audit-surface-architecture surface_path=".octon/capabilities/runtime/skills/audit/audit-api-contract"
```

### Expected Emphasis

- Classify the target as one skill surface unit.
- Account for `SKILL.md`, manifest/registry metadata, and reference files.
- Detect hidden authority or validator/doc drift.

## Example 3: Methodology Surface

### Invocation

```text
/audit-surface-architecture surface_path=".octon/cognition/practices/methodology/audits/README.md"
```

### Expected Emphasis

- Classify the target as `human-led/non-executable`.
- Evaluate clarity of durable guidance and authority boundaries.
- Avoid forcing execution-contract findings onto a non-runtime surface.

## Example 4: Oversized Scope

### Invocation

```text
/audit-surface-architecture surface_path=".octon/orchestration"
```

### Expected Emphasis

- Stop at applicability classification.
- Emit `verdict=not-applicable`.
- Direct the caller to `audit-domain-architecture` or
  `audit-architecture-readiness`.

## Anti-Examples

### Forcing Workflow Structure Onto Methodology

**Wrong behavior:** Recommending `workflow.yml` or staged execution assets for a
methodology guidance file.

**Why wrong:** Surface-local design must fit the target surface's actual role,
not mimic unrelated runtime surfaces.

### Treating README As Canonical Without Evidence

**Wrong behavior:** Declaring a surface markdown-first solely because a README is
present.

**Why wrong:** The audit must identify actual authority, not assume prose is
canonical without evidence.
