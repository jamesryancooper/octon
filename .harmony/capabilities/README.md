# Capabilities

Skills, commands, and tools available to agents.

## Contents

| Subdirectory | Purpose | Discovery |
|--------------|---------|-----------|
| `skills/` | Composable capabilities with I/O contracts | `skills/manifest.yml` |
| `commands/` | Atomic deterministic operations | `commands/manifest.yml` |
| `tools/` | Tool pack definitions (placeholder) | — |

## Interaction Model

- **Skills:** Routable via intent matching. Read `skills/manifest.yml` first, then `skills/README.md` for progressive disclosure.
- **Commands:** Referenced by name. Read `commands/manifest.yml` for the index.
- **Tools:** Not yet implemented.
