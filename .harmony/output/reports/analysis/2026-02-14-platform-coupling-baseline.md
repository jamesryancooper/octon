---
title: Platform Coupling Baseline
description: Backward-looking baseline of existing platform/provider coupling before native-first interop enforcement.
---

# Platform Coupling Baseline (Phase 0.5)

## Scope

- Scan date: `2026-02-14`
- Scope roots:
  - `.harmony/capabilities/services/`
  - `.harmony/cognition/context/`
  - `.harmony/capabilities/commands/`
- Search classes:
  - provider/runtime terms (`langgraph`, `openai`, `anthropic`, `vercel`, and named providers)
  - external implementation references (`packages/kits`, `@harmony/`)

## Classification Rules

- `allowed-domain`: reference is intentional for a provider-specific or external-facing domain.
- `needs-migration`: reference exists in shared/core service paths and should move behind interop contracts/adapters.
- `blocked-in-core`: reference appears in native interop core files where provider terms are prohibited.

## Findings

### allowed-domain

| Path | Evidence | Classification Reason |
|---|---|---|
| `.harmony/capabilities/services/_meta/docs/platform-overview.md` | Reference-stack sections include platform examples (for example Vercel/OpenAI). | This file is descriptive ecosystem overview content, not a core interop contract. |
| `.harmony/capabilities/services/delivery/**` | Deployment guidance uses platform examples and operational commands. | Delivery integration docs are expected to mention concrete providers. |
| `.harmony/cognition/context/dependencies.md` | External docs links for harness tooling. | Dependency catalog intentionally references external systems. |

### needs-migration

| Path | Evidence | Owner | Target Date |
|---|---|---|---|
| `.harmony/capabilities/services/manifest.yml` | `flow` service tags include `langgraph`. | `@platform` | `2026-05-31` |
| `.harmony/capabilities/services/planning/flow/SERVICE.md` | Runtime description explicitly references LangGraph implementation. | `@platform` | `2026-05-31` |
| `.harmony/capabilities/services/planning/service-roles.md` | Planning core role docs describe runtime internals by provider/runtime name. | `@platform` | `2026-06-30` |
| `.harmony/capabilities/services/operations/cost/schema/output.schema.json` | Output contract enumerates named model providers. | `@ops-cost` | `2026-06-30` |

### blocked-in-core

- No blocked findings at baseline in:
  - `.harmony/cognition/context/agent-platform-interop.md`
  - `.harmony/capabilities/services/interfaces/agent-platform/contract.md`
  - `.harmony/capabilities/services/interfaces/agent-platform/schema/*.json` (non-adapter schemas)

## Temporary Allowlist

Allowlist file:

- `.harmony/capabilities/services/_ops/state/provider-term-allowlist.tsv`

Policy:

1. Every entry requires owner and expiry.
2. Expired entries fail validation.
3. New entries require explicit review in the next coupling baseline refresh.

## Migration Backlog

1. Remove provider/runtime terms from planning core docs by moving implementation details behind adapter references.
2. Replace cost-provider enums with adapter capability negotiation output.
3. Keep `agent-platform` core contract and schemas provider-agnostic; add provider terms only inside adapter paths.

## Exit Gate Status

- Baseline generated: `PASS`
- Allowlist with owner/expiry: `PASS`
- `needs-migration` backlog identified: `PASS`
