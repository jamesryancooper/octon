# Capabilities

Capability subsystem for command/skill/tool/service execution contracts and policy governance.

## Bounded Surfaces

| Surface | Purpose | Canonical location |
|---|---|---|
| Runtime | Executable capability artifacts and discovery metadata | `runtime/` |
| Governance | Normative policy contracts and schemas | `governance/` |
| Practices | Operating standards and authoring conventions | `practices/` |
| Architecture reference | Non-structural specification and design docs | `_meta/architecture/` |
| Operations | Validation scripts and mutable operational state | `_ops/` |

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

Runtime discovery surfaces:

- `runtime/commands/manifest.yml`
- `runtime/skills/manifest.yml`
- `runtime/tools/manifest.yml`
- `runtime/services/manifest.yml`

## Policy Notes

- Deny-by-default policy SSOT: `governance/policy/deny-by-default.v2.yml`.
- `allowed-tools` supports `pack:<id>` expansion via `runtime/tools/manifest.yml`.
- Skills may declare `allowed-services` using IDs from `runtime/services/manifest.yml`.
