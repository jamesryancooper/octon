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
.octon/engine/governance/rules/_ops/scripts/validate-harness-rules.sh

# Create/update symlinks in .cursor/rules and .codex/rules
.octon/engine/governance/rules/_ops/scripts/setup-harness-rule-links.sh

# Re-render generated adapter content
.octon/engine/governance/rules/_ops/scripts/render-harness-rules.sh approval-prompts
```

## Codex Approval Prompt Strategy

This repository intentionally uses declarative rules first and does not create a
dedicated skill for approval-question-box triggers by default.

- Option A (`execpolicy` command triggers): implemented via
  `profiles/approval-prompts.yml` and `adapters/codex/approval-prompts.rules`.
- Option C (repo-scoped sharing): implemented via `manifest.yml` mappings and
  symlink materialization into `.codex/rules/` and `.cursor/rules/`.
- Option B (boundary posture): documented baseline below; this remains a runtime
  posture choice and is not hardcoded in rules.

### Option B Baseline (Recommended Runtime Posture)

Use these Codex defaults unless a workflow needs stricter settings:

- `sandbox_mode = "workspace-write"`
- `approval_policy = "on-request"`

Rationale: boundary crossings (network, outside-workspace writes, privileged
operations) continue to trigger approval prompts without bypassing sandbox
controls.

### Verification Runbook

Run the following from repo root:

```bash
# 1) Validate manifest and symlink integrity
.octon/engine/governance/rules/_ops/scripts/validate-harness-rules.sh --check-links

# 2) Should prompt (destructive filesystem)
codex execpolicy check --pretty --rules .codex/rules/approval-prompts.rules -- rm -rf build

# 3) Should be forbidden (history rewrite)
codex execpolicy check --pretty --rules .codex/rules/approval-prompts.rules -- git reset --hard HEAD~1

# 4) Should not match this profile (safe rm variant)
codex execpolicy check --pretty --rules .codex/rules/approval-prompts.rules -- rm -f file.txt
```

Expected decisions:

- `rm -rf build` -> `prompt`
- `git reset --hard HEAD~1` -> `forbidden`
- `rm -f file.txt` -> no matched rule from `approval-prompts.rules`

## Boundary

- Canonical policy ownership for runtime-facing execution behavior remains in
  `engine/governance/`.
- Harness adapter directories (`.cursor/rules/`, `.codex/rules/`) are treated as
  integration surfaces, not policy source of truth.
