# Capabilities Runtime

## Purpose

Canonical runtime surface for executable capability artifacts.
Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

## Contents

- `commands/` - Atomic instruction-driven operations.
- `skills/` - Composite instruction-driven workflows.
- `tools/` - Atomic invocation-driven tool packs.
- `services/` - Composite invocation-driven domain capabilities.

## Agent Capability Model

For autonomous AI agents, these are four capability classes in one runtime.

| Surface | Control model | Granularity |
|---|---|---|
| `commands/` | Instruction-driven | Atomic |
| `skills/` | Instruction-driven | Composite |
| `tools/` | Invocation-driven | Atomic |
| `services/` | Invocation-driven | Composite |

## Discovery

- `commands/manifest.yml`
- `skills/manifest.yml`
- `tools/manifest.yml`
- `services/manifest.yml`
