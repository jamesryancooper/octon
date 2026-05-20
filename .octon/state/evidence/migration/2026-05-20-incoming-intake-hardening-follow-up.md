# Incoming Intake Hardening Follow-Up Evidence

## Summary

- change_id: `incoming-intake-hardening-follow-up`
- date: `2026-05-20`
- release_state: `pre-1.0`
- change_profile: `atomic`
- profile_selection_receipt: Octon remains pre-1.0 and this change hardens an
  existing clean-break intake architecture. The atomic profile is selected so
  no compatibility path is added for Downloads staging, root `.archive/**`,
  extension-level `.incoming/**`, or raw-intake authority consumption.

## Scope

This follow-up preserves the refined incoming intake model:

- canonical raw intake:
  `.octon/inputs/additive/.incoming/<intake-id>/`
- retained historical intake:
  `.octon/inputs/additive/.archive/<intake-id>/`
- route-neutral governance:
  `.octon/framework/engine/governance/inputs/additive/incoming-intake-processing.md`
- canonical human-invoked command:
  `/process-incoming-intake`

Implemented hardening:

- The incoming intake validator now uses NUL-safe traversal, rejects unsafe
  relative path characters, and preserves deterministic inventory ordering
  after unsafe-path rejection.
- The validator keeps the existing CLI
  `validate-incoming-intake-unit.sh --intake-id <intake-id>` and output schema
  `octon-incoming-intake-inventory-v1`.
- Raw input leak validation scans broader authority-sensitive framework,
  instance, generated, state/control, publication-evidence, command-manifest,
  workflow-registry, runtime/config, and host-projection surfaces for
  `.incoming/**` and `.archive/**` leakage.
- Allowed governance, workflow, and command references are required to describe
  raw intake as non-authoritative and `/process-incoming-intake` as a workflow
  facade rather than an installer.
- Live additive `.incoming` payloads are ignored by default in `.gitignore`;
  only `.incoming/.gitkeep` placeholders remain eligible for tracking.
- `/process-incoming-intake` closeout now requires
  `.incoming/<intake-id>/` to be absent after final disposition. The only
  allowed retained `.incoming` state is `stop_after_classification=true`.
- Bootstrap wording now describes normalized extension pack sources rather than
  raw extension pack input.
- Workflow guides, capability routing, and host projections were refreshed only
  through canonical publication scripts.

## Rust Intake Unit Disposition

- intake_id: `octon-rust-skill-pack-rust-source-authority`
- current_path:
  `.octon/inputs/additive/.incoming/octon-rust-skill-pack-rust-source-authority`
- meaningful_file_count: `19`
- excluded_noise_count: `0`
- git_tracking_posture: ignored raw local intake payload
- disposition: intake-only after this hardening follow-up

No installation, extension normalization, activation, core skill integration,
generated extension publication, or host-specific skill projection was
performed from the Rust intake unit.

## Git Tracking Receipt

- `.octon/inputs/additive/.incoming/*` is ignored by default.
- `.octon/inputs/additive/.incoming/.gitkeep` remains unignored.
- `.octon/framework/scaffolding/runtime/templates/octon/inputs/additive/.incoming/*`
  is ignored by default.
- `.octon/framework/scaffolding/runtime/templates/octon/inputs/additive/.incoming/.gitkeep`
  remains unignored.
- `git ls-files .octon/inputs/additive/.incoming .octon/framework/scaffolding/runtime/templates/octon/inputs/additive/.incoming`
  produced no tracked payload paths before this receipt was written.
- `git check-ignore -v .octon/inputs/additive/.incoming/octon-rust-skill-pack-rust-source-authority/README.md`
  confirmed the Rust intake payload is ignored by the additive `.incoming`
  rule.

## Generated And Projected Surfaces

Canonical publication and projection commands were used:

- `bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/generate-workflow-guides.sh`
- `bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh`
- `bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh`

Capability routing publication id after refresh:

- `capabilities-e64bd636f714`

Generated host command projections include `/process-incoming-intake` for:

- `.claude/commands/process-incoming-intake.md`
- `.codex/commands/process-incoming-intake.md`
- `.cursor/commands/process-incoming-intake.md`

These projections mirror canonical command routing and do not consume
`.incoming/**` or `.archive/**` as runtime, policy, generated, state/control,
publication, evidence, or host-projection authority.

## Validation Results

Targeted tests:

- PASS: `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-incoming-intake-unit.sh`
  - result: 9 passed, 0 failed
- PASS: `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-raw-input-dependency-ban.sh`
  - result: 15 passed, 0 failed
- PASS: `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-extension-pack-contract.sh`
  - result: 25 passed, 0 failed
- PASS: `bash .octon/framework/assurance/runtime/_ops/tests/test-packet8-template-scaffold.sh`
- PASS: `bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh --workflow-id process-incoming-intake`
  - result: errors=0 warnings=0
- PASS: `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-host-projections.sh`
  - result: 3 passed, 0 failed

Live validators and boundary checks:

- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh --intake-id octon-rust-skill-pack-rust-source-authority`
  - result: schema `octon-incoming-intake-inventory-v1`, meaningful_file_count=19, excluded_noise_count=0
- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh`
  - result: errors=0
- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
  - result: errors=0 warnings=0
- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-authority-surfaces.sh`
  - result: errors=0
- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh`
  - result: errors=0
- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh`
  - result: errors=0
- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh`
  - result: errors=0
- PASS: `git diff --check`
- PASS: `git diff --name-only -- .octon/generated/effective/extensions .octon/state/control/extensions .octon/instance/extensions.yml`
  - result: no output
- PASS: `git check-ignore -v .octon/inputs/additive/.incoming/octon-rust-skill-pack-rust-source-authority/README.md`
  - result: ignored by `.gitignore` additive `.incoming` payload rule

## Cleanup And Retention

- No tracked `.incoming` payload was removed from the index because no tracked
  additive `.incoming` payload paths were present.
- The Rust intake working copy was preserved as ignored raw local intake.
- `.archive/**` remains available only for safe, reviewable, justified retained
  historical intake; this change does not make `.archive/**` a live input.
- `.incoming/<intake-id>/` must be absent after final disposition except when
  processing intentionally stops after classification.
- Existing untracked publication/run residue outside this change scope was left
  untouched.

## Non-Goals Preserved

- Do not install the Rust intake unit.
- Do not normalize it into an extension pack.
- Do not change `.octon/instance/extensions.yml`.
- Do not publish extension state from raw intake.
- Do not bypass trust, provenance, compatibility, validation, publication, or
  host-projection rules.
- Do not hand-edit host command or skill projections.
- Do not treat raw intake as live authority.
