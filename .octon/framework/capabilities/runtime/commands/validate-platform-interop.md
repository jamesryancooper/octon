---
title: Validate Platform Interop
description: Run native-first interop checks across core independence, adapter conformance, and degradation behavior.
access: agent
argument-hint: "[--mode all|services-core|platform-core|adapters|conformance|degradation]"
---

# Validate Platform Interop `/validate-platform-interop`

Run enforcement checks for native-first interop boundaries.

## Usage

```text
/validate-platform-interop
/validate-platform-interop --mode services-core
/validate-platform-interop --mode platform-core
/validate-platform-interop --mode adapters
/validate-platform-interop --mode conformance
/validate-platform-interop --mode degradation
```

## Parameters

| Parameter | Required | Description |
|---|---|---|
| `--mode` | No | Validation mode. Default: `all`. |

## Implementation

Run:

```bash
bash .octon/framework/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh [--mode <mode>]
```

Modes:

- `services-core`: forbidden external kit/package references in core services
- `platform-core`: provider-term leak detection in interop core files
- `adapters`: adapter registry and required adapter artifact validation
- `conformance`: adapter capability matrix, fallback contract, evidence hook, and compatibility-range checks
- `degradation`: deterministic degraded-path checks (provider unavailable, partial support, stale version, permission denied)

## Output

- Pass/fail result with explicit findings and affected files.

## References

- **Validator:** `.octon/framework/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh`
- **Allowlist:** `.octon/framework/capabilities/governance/policy/provider-term-allowlist.tsv`
