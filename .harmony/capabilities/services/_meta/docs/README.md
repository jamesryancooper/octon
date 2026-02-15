# Services Support Docs

Non-structural support documentation for the services subsystem.

## Purpose

- Keep ecosystem/platform guidance and migration notes out of structural roots.
- Preserve `services/` root for contracts, manifests, and runtime metadata.

## Contents

| File | Purpose |
|---|---|
| `platform-overview.md` | Ecosystem and platform-level overview content |
| `developer-overview.md` | Developer-facing comms stack + agent layer guide |
| `comms-guide.md` | Ports/artifacts/events communication contract guidance |
| `mcp-guide.md` | MCP provider mapping and compatibility guidance |
| `agent-guide.md` | Agent-layer policy, budget, and guardrail guidance |
| `appendices.md` | Shared glossary, schema catalog, and SLO appendices |
| `kits-reference.md` | Quick operational reference for service kits |
| `composite-services.md` | Canonical definition of composite services in Harmony |
| `docs-services-migration.md` | Migration provenance from legacy docs/services paths |

## Structural Boundary

Do not place manifests, registries, or capability schema files in this directory.
Structural files remain at:

- `.harmony/capabilities/services/manifest.yml`
- `.harmony/capabilities/services/registry.yml`
- `.harmony/capabilities/services/manifest.runtime.yml`
- `.harmony/capabilities/services/registry.runtime.yml`
- `.harmony/capabilities/services/capabilities.yml`
