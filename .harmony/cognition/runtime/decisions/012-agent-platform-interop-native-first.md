---
title: "ADR-012: Agent Platform Interop Native-First Contract"
description: Establish a native-first, provider-agnostic interop contract where Harmony owns runtime semantics and adapters remain optional.
status: accepted
date: 2026-02-14
---

# ADR-012: Agent Platform Interop Native-First Contract

## Context

Harmony needs interoperability with external agent platforms while preserving core autonomy.
Before this ADR, interop semantics (session policy, context budgeting, compaction behavior, routing precedence, and presence evidence) were not formalized as Harmony-owned contract content.

Without a canonical boundary, provider-specific concepts can leak into core contracts and create lock-in.

## Decision

Adopt a native-first, provider-agnostic interop architecture with these rules:

1. Harmony must run fully with zero adapters.
2. Harmony owns interop semantics in a canonical context contract.
3. Adapters are optional and own provider-specific mappings only.
4. Provider-specific terms are restricted to adapter paths.
5. Enforcement is implemented in validators and quality gates, not policy prose only.

Canonical contract:

- `.harmony/cognition/context/agent-platform-interop.md`

Core service surface:

- `.harmony/capabilities/services/interfaces/agent-platform/`

## Rationale

- Preserves portability and long-term reversibility.
- Prevents provider lock-in in core governance and memory semantics.
- Enables adapter onboarding without core contract churn.
- Keeps risk controls enforceable through deterministic gates.

## Consequences

### Positive

- Native operation is explicit, testable, and mandatory.
- Session policy and context budgeting become stable Harmony semantics.
- Memory flush and compaction policy is standardized with fail-closed behavior.
- Adapter onboarding becomes bounded to adapter directories and registry metadata.

### Costs

- Additional schemas, validator logic, and adapter conformance artifacts to maintain.
- Short-term migration overhead to baseline and classify pre-existing coupling references.

## Alternatives Considered

1. Platform-first integration with native fallback.
   - Rejected: makes native behavior secondary and weakens core autonomy.
2. Documentation-only boundary without validator enforcement.
   - Rejected: insufficient to prevent drift and lock-in over time.
3. Per-provider semantics in core contracts.
   - Rejected: violates provider-agnostic architecture and increases coupling.

## Implementation Notes

- Phase 0.5 baseline report:
  - `.harmony/output/reports/analysis/2026-02-14-platform-coupling-baseline.md`
- Core schemas:
  - `.harmony/capabilities/services/interfaces/agent-platform/schema/capabilities.schema.json`
  - `.harmony/capabilities/services/interfaces/agent-platform/schema/session-policy.schema.json`
- Enforcement script extension:
  - `.harmony/capabilities/services/_ops/scripts/validate-service-independence.sh`
