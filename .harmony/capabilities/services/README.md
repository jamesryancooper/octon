# Services

Domain capabilities with typed contracts for invocation-driven composite behavior.

## Contents

| File/Dir | Purpose |
|---|---|
| `manifest.yml` | Service discovery index |
| `registry.yml` | Extended service metadata |
| `capabilities.yml` | Service capability schema and constraints |
| `conventions/` | Harness-wide cross-cutting contracts (errors, run records, observability, idempotency, rich contracts, declarative rules, fixtures, validation tiers, implementation generation) |
| `conventions/rich-contracts.md` | Rich contract completeness and compatibility profile requirements |
| `conventions/declarative-rules.md` | Declarative rule schema, ordering, and fail-closed semantics |
| `conventions/fixtures.md` | Fixture format and semantic anchoring requirements |
| `conventions/validation-tiers.md` | Tier 1 deterministic and Tier 2 semantic validation contract |
| `conventions/implementation-generation.md` | Contract-derived implementation generation workflow |
| `_template/` | Service scaffold template |
| `_scripts/validate-services.sh` | Structural and contract validator |
| `_state/` | Service logs and run state |

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

Service IDs resolve against `services/manifest.yml`.
