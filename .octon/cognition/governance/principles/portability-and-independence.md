---
title: Portability and Independence
description: Keep Octon self-contained and platform-neutral so core behavior runs without provider lock-in, runtime lock-in, or OS lock-in.
pillar: Velocity, Trust, Continuity
status: Active
---

# Portability and Independence

> Octon core behavior must remain self-contained, tech-agnostic, and OS-agnostic by default.

## What This Means

Portability and Independence define three non-negotiable defaults for Octon:

1. **Self-contained harness:** Required contracts, discovery metadata, and governance artifacts live inside `.octon/` and do not rely on external repo structure.
2. **Tech/runtime agnostic core:** Core semantics and contracts do not depend on a specific provider, SDK, language runtime, or framework.
3. **OS-agnostic core behavior:** Core service behavior and contracts remain valid across operating systems, with OS-specific details confined to optional implementation paths.

This does not prohibit adapters or platform-specific optimizations. It requires that those remain optional and never redefine core behavior.
Ownership and boundary attestations remain deterministic and portable by treating `.octon/` ownership declarations as authoritative; repo-native and external metadata are optional projections (see [Ownership and Boundaries](./ownership-and-boundaries.md)).

## Why It Matters

### Pillar Alignment: Velocity through Reuse

Portable, independent core contracts reduce migration friction and adoption cost:

- faster harness bootstrap in new repos,
- fewer environment-specific rewrites,
- lower change amplification when tooling evolves.

### Pillar Alignment: Trust through Stable Contracts

When core behavior is independent of providers and OS-specific assumptions:

- validation results are more predictable,
- governance guarantees remain consistent,
- failure modes are easier to reason about and audit.

### Pillar Alignment: Continuity through Longevity

Portability protects institutional memory from tool churn. Decisions encoded in Octon remain usable even when teams, runtimes, or platforms change.

## In Practice

### ✅ Do

**Keep core contracts provider-agnostic:**

```yaml
# Good: core contract terms are neutral
input:
  query: string
  limit: integer
output:
  results: array
  diagnostics: object
```

**Confine provider-specific details to adapters:**

```text
interfaces/agent-platform/adapters/<provider>/
```

**Require native-first behavior:**

- Core functionality runs with zero optional adapters.
- Optional integrations extend behavior but are never required for baseline execution.

**Treat OS-specific behavior as implementation detail:**

- Preserve contract semantics across OSes.
- Keep platform-specific paths/scripts isolated and replaceable.

### ❌ Don't

- Don't embed provider API terms in core schemas.
- Don't make core execution depend on a single language runtime by default.
- Don't encode OS-specific assumptions into normative contract behavior.
- Don't reference external package paths as required harness dependencies.

## Enforcement

Portability and Independence are operationalized through:

- `.octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `.octon/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh`
- `.octon/assurance/runtime/_ops/scripts/alignment-check.sh` (`--profile harness` / `--profile services`)
- Optional CI projection: `.github/workflows/harness-self-containment.yml`

## Relationship to Other Principles

| Principle | Relationship |
|---|---|
| Single Source of Truth | Keeps portable contracts authoritative in one canonical location |
| Progressive Disclosure | Uses layered discovery (`manifest.yml` -> `registry.yml` -> full definitions) without coupling to host tooling |
| Deny by Default | Enforces fail-closed boundaries when optional providers or adapters are unavailable |
| Documentation is Code | Requires portability/independence guarantees to be versioned and reviewed with implementation |

## Related Documentation

- `.octon/cognition/_meta/architecture/specification.md`
- `.octon/cognition/practices/methodology/README.md`
- `.octon/capabilities/runtime/services/README.md`
- `.octon/cognition/runtime/context/agent-platform-interop.md`
