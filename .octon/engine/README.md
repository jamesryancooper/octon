# Engine

The `engine/` domain is the executable harness authority. It is organized into bounded surfaces so runtime behavior, normative policy, and operating standards are explicit and independently governed.

Authority boundary with `capabilities/`: engine governs runtime execution
semantics and enforcement behavior; capabilities governs capability declaration
semantics.

## Surface Map

| Surface | Role | Canonical Contents |
|---|---|---|
| `runtime/` | Executable authority | launchers, crates, runtime contracts, runtime config |
| `governance/` | Normative runtime policy | protocol versioning, compatibility policy, release gates |
| `practices/` | Operating standards | release runbook, incident ops, local validation |
| `_ops/` | Mutable operational assets | binaries and runtime state |
| `_meta/` | Architecture/evidence docs | architecture contracts and verification evidence |

## Convention Authority

- Domain-local naming, authoring, and operating conventions belong in `practices/`.
- `_meta/` reference docs are not the canonical conventions surface.
- Cross-domain baseline conventions come from `/.octon/conventions.md`.

## Invariants

- `engine/runtime/` is the only executable authority surface.
- `engine/governance/` is the only normative policy surface for engine behavior.
- `engine/practices/` is the only operating standards surface for engine work.
- Legacy top-level `/.octon/runtime/` paths are prohibited.
