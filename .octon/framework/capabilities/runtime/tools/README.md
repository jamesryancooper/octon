# Tools

Tool packs and custom tool contracts for invocation-driven atomic capabilities.

## Contents

| File | Purpose |
|---|---|
| `manifest.yml` | Discovery for packs and custom tools |
| `registry.yml` | Extended metadata for custom tools |
| `capabilities.yml` | Built-in tool vocabulary, interface types, and pack rules |
| `_scaffold/template/TOOL.md` | Authoring template for custom tools |
| `_ops/scripts/validate-tools.sh` | Structural and semantic validator |
| `_ops/state/logs/` | Tool subsystem operation logs |

## Discovery

1. Read `manifest.yml` first.
2. Resolve any custom tool metadata through `registry.yml`.
3. Validate pack membership against `capabilities.yml`.

## Pack References in Skills

`allowed-tools` supports pack expansion via `pack:<id>`.

Examples:

```yaml
allowed-tools: pack:read-only Write(_ops/state/logs/*)
allowed-tools: pack:file-ops pack:ci-integration WebFetch
```

Pack expansion is additive and backward-compatible with existing inline tool permissions.
