---
title: Examples
description: Example invocations for audit-cross-subsystem-coherence.
---

# Examples

## Full Harness Coherence Audit

```text
/audit-cross-subsystem-coherence scope=".harmony"
```

## Focused Subsystem Set

```text
/audit-cross-subsystem-coherence scope=".harmony" subsystems="agency,capabilities,orchestration,quality"
```

## High Severity Only

```text
/audit-cross-subsystem-coherence scope=".harmony" severity_threshold="high"
```
