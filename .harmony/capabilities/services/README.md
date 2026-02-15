# Services

Domain capabilities with typed contracts for invocation-driven composite behavior.

## Independence Requirement

Production services in this harness are self-contained and must not require or reference external kit implementations.

## Contents

| File/Dir | Purpose |
|---|---|
| `manifest.yml` | Service discovery index |
| `registry.yml` | Extended service metadata |
| `manifest.runtime.yml` | Executable runtime Tier 1 discovery index (`services-manifest-v1`) |
| `registry.runtime.yml` | Executable runtime Tier 2 metadata (`services-registry-v1`) |
| `capabilities.yml` | Service capability schema and constraints |
| `conventions/` | Harness-wide cross-cutting contracts (errors, run records, observability, idempotency, rich contracts, declarative rules, fixtures, validation tiers, implementation generation) |
| `conventions/rich-contracts.md` | Rich contract completeness and compatibility profile requirements |
| `conventions/declarative-rules.md` | Declarative rule schema, ordering, and fail-closed semantics |
| `conventions/fixtures.md` | Fixture format and semantic anchoring requirements |
| `conventions/validation-tiers.md` | Tier 1 deterministic and Tier 2 semantic validation contract |
| `conventions/implementation-generation.md` | Contract-derived implementation generation workflow |
| `_scaffold/template/` | Service scaffold template |
| `_ops/scripts/validate-services.sh` | Structural and contract validator |
| `_ops/scripts/validate-service-independence.sh` | Independence validator (forbidden external package references) |
| `_ops/state/` | Service logs and run state |
| `_meta/docs/` | Non-structural support docs (platform, integration guides, migration notes) |
| `_meta/docs/composite-services.md` | Canonical definition of harness-only composite service composition |

## Interface Types

- `shell`: POSIX script entrypoint (optional; can be generated from contract)
- `mcp`: networked/MCP adapter
- `library`: runtime/library implementation pointer

## Dependency Boundary

Services are portable as declarative contract content (schemas, rules, fixtures, conventions) without project-local runtime binaries.
Host-provided prerequisites remain required: an agent runtime/model and a minimal tool adapter (`read`, `glob`, `grep`, `bash`).

## Skill Integration

Skills may whitelist services with:

```yaml
allowed-services: guard cost
```

Service IDs resolve against `services/manifest.yml` for the harness-native catalog.
Executable-runtime IDs resolve against `services/manifest.runtime.yml`.
