# Capabilities

Capability subsystems for agent behavior and invocation contracts.

## Taxonomy

```text
                Atomic                    Composite
           ┌───────────────────┬────────────────────────┐
Instruction│   Commands        │   Skills               │
-driven    │   (agent follows  │   (agent follows       │
           │    single .md)    │    SKILL.md workflow)  │
           ├───────────────────┼────────────────────────┤
Invocation │   Tools           │   Services             │
-driven    │   (agent calls,   │   (agent invokes       │
           │    gets result)   │    domain capability)  │
           └───────────────────┴────────────────────────┘
```

## Contents

| Subdirectory | Model | Purpose | Discovery |
|---|---|---|---|
| `_meta/architecture/` | Documentation | Capabilities subsystem architecture and contracts | `_meta/architecture/README.md` |
| `commands/` | Instruction-driven, atomic | Deterministic one-shot operations | `commands/manifest.yml` |
| `skills/` | Instruction-driven, composite | Multi-step workflows with references and contracts | `skills/manifest.yml` |
| `tools/` | Invocation-driven, atomic | Tool packs and custom tool definitions | `tools/manifest.yml` |
| `services/` | Invocation-driven, composite | Domain capabilities with typed I/O contracts | `services/manifest.yml` |

## Interaction Model

- **Commands:** agent reads one command file and executes it deterministically.
- **Skills:** agent follows `SKILL.md` and resolved references.
- **Tools:** agent invokes a tool and consumes its immediate result.
- **Services:** agent invokes a typed domain capability behind a stable interface.

## Compatibility Notes

- Existing `allowed-tools` declarations remain valid.
- `allowed-tools` now supports `pack:<id>` expansion through `tools/manifest.yml`.
- Skills may optionally declare `allowed-services` with IDs from `services/manifest.yml`.
