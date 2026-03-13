# Capabilities

Capability subsystem for command/skill/tool/service declaration contracts and
policy governance.
Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

Authority boundary with `engine/`: capabilities defines what capabilities are
and what they require; engine defines how runtime execution and enforcement
work.

## Bounded Surfaces

| Surface | Purpose | Canonical location |
|---|---|---|
| Runtime | Executable capability artifacts and discovery metadata | `runtime/` |
| Governance | Normative policy contracts and schemas | `governance/` |
| Practices | Operating standards and authoring conventions | `practices/` |
| Architecture reference | Non-structural specification and design docs | `_meta/architecture/` |
| Operations | Validation scripts and mutable operational state | `_ops/` |

## Convention Authority

- Domain-local naming, authoring, and operating conventions belong in `practices/`.
- `_meta/architecture/` is reference architecture, not the canonical conventions surface.
- Cross-domain baseline conventions come from `/.octon/conventions.md`.

## Runtime Taxonomy

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

For autonomous AI agents, all four runtime surfaces are capability classes.
They differ by control model (`instruction-driven` vs `invocation-driven`) and
granularity (`atomic` vs `composite`).

| Surface | Agent capability role |
|---|---|
| `commands` | Atomic instruction capability executed from a single command contract |
| `skills` | Composite instruction capability executed from a multi-step `SKILL.md` contract |
| `tools` | Atomic invocation capability where the agent calls a tool/tool-pack and consumes its result |
| `services` | Composite invocation capability where the agent calls typed domain service contracts |

Runtime discovery surfaces:

- `runtime/commands/manifest.yml`
- `runtime/skills/manifest.yml`
- `runtime/tools/manifest.yml`
- `runtime/services/manifest.yml`

## Policy Notes

- Deny-by-default policy SSOT: `governance/policy/deny-by-default.v2.yml`.
- `allowed-tools` supports `pack:<id>` expansion via `runtime/tools/manifest.yml`.
- Skills may declare `allowed-services` using IDs from `runtime/services/manifest.yml`.
