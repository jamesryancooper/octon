---
title: Examples
description: Example invocations for audit-cross-subsystem-coherence.
---

# Examples

## Full Harness Coherence Audit

```text
/audit-cross-subsystem-coherence scope=".octon"
```

## Focused Subsystem Set

```text
/audit-cross-subsystem-coherence scope=".octon" subsystems="agency,capabilities,orchestration,quality"
```

## High Severity Only

```text
/audit-cross-subsystem-coherence scope=".octon" severity_threshold="high"
```
