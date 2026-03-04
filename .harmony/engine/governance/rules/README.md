# Engine Governance Rules

`rules/` is the canonical, harness-agnostic source for cross-harness rule policy
packs and harness-specific adapter renderings.

This surface centralizes instruction-layer steering artifacts used by harness
integrations while preserving engine governance authority over runtime-facing
execution behavior.

## Layout

- `manifest.yml` - machine-readable mapping of rule ids to profiles and harness adapters.
- `profiles/` - harness-agnostic rule intent and policy declarations.
- `adapters/` - harness-native renderings (for example Codex `.rules`, Cursor `RULE.md`).
- `_ops/scripts/` - render, validate, and symlink utilities.

## Canonical Pattern

1. Author/modify a harness-agnostic profile in `profiles/`.
2. Render or edit harness adapters under `adapters/`.
3. Materialize harness links into `.<harness>/rules/` via
   `_ops/scripts/setup-harness-rule-links.sh`.
4. Validate mapping and adapter integrity via
   `_ops/scripts/validate-harness-rules.sh`.

## Commands

```bash
# Validate profile + adapter mapping integrity
.harmony/engine/governance/rules/_ops/scripts/validate-harness-rules.sh

# Create/update symlinks in .cursor/rules and .codex/rules
.harmony/engine/governance/rules/_ops/scripts/setup-harness-rule-links.sh

# Re-render generated adapter content
.harmony/engine/governance/rules/_ops/scripts/render-harness-rules.sh approval-prompts
```

## Boundary

- Canonical policy ownership for runtime-facing execution behavior remains in
  `engine/governance/`.
- Harness adapter directories (`.cursor/rules/`, `.codex/rules/`) are treated as
  integration surfaces, not policy source of truth.
