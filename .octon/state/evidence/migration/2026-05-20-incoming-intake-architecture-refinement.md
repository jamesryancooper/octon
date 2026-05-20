# Incoming Intake Architecture Refinement Evidence

## Summary

- change_id: `incoming-intake-architecture-refinement`
- date: `2026-05-20`
- release_state: `pre-1.0`
- change_profile: `atomic`
- profile_selection_receipt: Octon is pre-1.0 and the requested change is a clean governance, validation, and projection refinement. The atomic profile is selected to avoid compatibility copies, deprecated command aliases, or alternate intake staging paths.

## Scope

This migration refined incoming additive intake from an extension-owned pack
surface into a route-neutral input-governance surface.

Implemented outcomes:

- Re-homed incoming intake governance to
  `.octon/framework/engine/governance/inputs/additive/incoming-intake-processing.md`.
- Added the additive input governance index at
  `.octon/framework/engine/governance/inputs/additive/README.md`.
- Removed the extension-owned governance file
  `.octon/framework/engine/governance/extensions/incoming-intake-processing.md`.
- Added `validate-incoming-intake-unit.sh` as a dedicated raw-intake validator.
- Wired intake validation into `/process-incoming-intake` workflow stage docs.
- Hardened raw input leak detection across generated/effective outputs,
  state/control, workflow registries, command manifests, host projections,
  publication receipts, runtime commands, publisher scripts, and tests.
- Documented additive archive retention policy: retain physical intake copies
  only when safe, reviewable, redistributable, justified, and not oversized;
  otherwise retain evidence-only disposition.
- Clarified `/process-incoming-intake` as a human-invoked agent facade over the
  workflow, not an autonomous watcher, scanner, or direct installer.

## Authority Boundary

The migration preserves these boundaries:

- `.octon/inputs/additive/.incoming/<intake-id>/` is raw, pre-classification
  intake and is not runtime, policy, publication, generated, state/control, or
  host-projection authority.
- `.octon/inputs/additive/.archive/<intake-id>/` is retained historical intake
  only and is not live input authority.
- `.octon/inputs/additive/extensions/<pack-id>/` remains reserved for
  normalized extension packs after classification and normalization.
- Extension-level `.incoming` and `.archive` directories are invalid and fail
  extension-pack validation.
- Raw intake may inform governed classification only through workflow evidence.

## Rust Intake Unit Disposition

- intake_id: `octon-rust-skill-pack-rust-source-authority`
- intake_path:
  `.octon/inputs/additive/.incoming/octon-rust-skill-pack-rust-source-authority`
- validator: `.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh`
- meaningful_file_count: `19`
- excluded_noise_count: `0`
- disposition: intake-only after this refinement

No installation, activation, extension normalization, generated extension
publication, core skill integration, or host-specific skill projection was
performed from this intake unit.

## Inventory Receipt

`validate-incoming-intake-unit.sh --intake-id octon-rust-skill-pack-rust-source-authority`
emitted deterministic inventory with these top-level files and payload groups:

- `INSTALL.md`
- `README.md`
- `install/capabilities-entry.yml`
- `install/host-projection-commands.md`
- `install/manifest-entry.yml`
- `install/registry-entry.yml`
- `install/validation-commands.md`
- `repo/.octon/framework/capabilities/runtime/skills/foundations/rust-source-authority/**`
- `tests/skill-acceptance-checklist.md`

The validator reported no excluded platform-noise files.

## Generated And Projected Surfaces

Publication and projection were run through canonical Octon scripts:

- `generate-workflow-guides.sh`
- `publish-capability-routing.sh`
- `publish-host-projections.sh`

Capability routing publication id:

- `capabilities-e64bd636f714`

Generated host command projections include `/process-incoming-intake` for:

- `.claude/commands/process-incoming-intake.md`
- `.codex/commands/process-incoming-intake.md`
- `.cursor/commands/process-incoming-intake.md`

These projections mirror the canonical command source and do not consume
`.incoming/**` as source authority.

## Validation Results

Targeted tests:

- PASS: `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-incoming-intake-unit.sh`
- PASS: `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-raw-input-dependency-ban.sh`
- PASS: `bash .octon/framework/assurance/runtime/_ops/tests/test-packet8-template-scaffold.sh`
- PASS: `bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh --workflow-id process-incoming-intake`
- PASS: `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-extension-pack-contract.sh`

Live validators:

- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh --intake-id octon-rust-skill-pack-rust-source-authority`
- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh`
- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-authority-surfaces.sh`
- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh`
- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh`
- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh`
- PASS: `git diff --check`

Boundary checks:

- PASS: `git diff --name-only -- .octon/generated/effective/extensions .octon/state/control/extensions .octon/instance/extensions.yml`
  produced no output.
- PASS: old active references to
  `framework/engine/governance/extensions/incoming-intake-processing` are absent
  except for the harness-structure validator's explicit forbidden-path check.
- PASS: legacy `install-downloaded-pack` and `incoming-pack-installation`
  terminology remains only in historical migration evidence.

## Cleanup And Retention

- The old extension-owned governance file is intentionally absent.
- No compatibility governance copy was retained.
- No `/install-downloaded-pack` command alias was introduced.
- No Downloads path or root `.archive/**` staging convention was retained.
- Local publication and validation run artifacts created by canonical scripts
  are classified as workflow/tool residue or retained publication evidence,
  not intake authority.

## Non-Goals Preserved

- Do not install the Rust intake unit.
- Do not update `.octon/instance/extensions.yml`.
- Do not publish extension state from raw intake.
- Do not bypass trust, provenance, compatibility, publication, validation, or
  host-projection rules.
- Do not hand-edit host command or skill projections.
- Do not treat raw intake as runtime, policy, state/control, generated,
  publication, evidence, or host-projection authority.
