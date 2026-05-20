# Incoming Intake Units Clean-Break Migration Receipt

## Profile Selection Receipt

- release_state: `pre-1.0`
- change_profile: `atomic`
- rationale: this migration replaces extension-specific downloaded-pack intake
  with route-neutral additive intake and intentionally preserves no compatibility
  path for `inputs/additive/extensions/.incoming/**`, root `.archive/**`, or
  Downloads staging.

## Surface Receipt

- canonical_preclassification_intake:
  `.octon/inputs/additive/.incoming/<intake-id>/`
- retained_preclassification_archive:
  `.octon/inputs/additive/.archive/<intake-id>/`
- normalized_extension_pack_destination:
  `.octon/inputs/additive/extensions/<extension-pack-id>/`
- removed_extension_level_lifecycle_dirs:
  `.octon/inputs/additive/extensions/.incoming/` and
  `.octon/inputs/additive/extensions/.archive/`
- tracking_exceptions: `.gitignore` narrowly unignores only the canonical
  additive `.archive` directory and scaffold template `.archive` directory so
  their `.gitkeep` placeholders can be retained
- terminology_rule: use `intake unit` and `intake_id` before route
  classification; preserve `pack` and `pack_id` only for normalized extension
  packs, capability packs, context packs, export profiles, and existing schemas
  that already define `pack_id`.

## Reclassification Receipt

- intake_id: `octon-rust-skill-pack-rust-source-authority`
- source_before:
  `.octon/inputs/additive/extensions/.incoming/octon-rust-skill-pack-rust-source-authority/`
- target_after:
  `.octon/inputs/additive/.incoming/octon-rust-skill-pack-rust-source-authority/`
- semantic_status: intake-only; not installed, activated, normalized, published,
  or projected as a live capability
- excluded_noise: `.DS_Store`
- parity_check: non-noise file path and SHA-256 checksum manifests matched before
  and after the move
- source_cleanup: removed only the old extension-level `.incoming` copy after
  non-noise parity passed
- generated_extension_effect: no diff under
  `.octon/generated/effective/extensions`,
  `.octon/state/control/extensions`, or `.octon/instance/extensions.yml`

## Governance And Workflow Receipt

- renamed governance:
  `.octon/framework/engine/governance/inputs/additive/incoming-intake-processing.md`
- renamed workflow:
  `.octon/framework/orchestration/runtime/workflows/meta/process-incoming-intake/`
- canonical command wrapper:
  `.octon/framework/capabilities/runtime/commands/process-incoming-intake.md`
- command manifest registration: `process-incoming-intake` with host adapters
  `claude`, `cursor`, and `codex`
- publication route: used existing `publish-capability-routing.sh` and
  `publish-host-projections.sh`
- generated host projections:
  `.claude/commands/process-incoming-intake.md`,
  `.cursor/commands/process-incoming-intake.md`, and
  `.codex/commands/process-incoming-intake.md`
- publication_id: `capabilities-f7044b4c7b5a`
- direct host install: none

## Validation Evidence

- `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-extension-pack-contract.sh`
  - result: pass, 25 passed and 0 failed
  - proof: additive `.incoming/<intake-id>/` nonconforming material is ignored by
    extension-pack validation; extension-level `.incoming/**` fails closed
- `bash .octon/framework/assurance/runtime/_ops/tests/test-packet8-template-scaffold.sh`
  - result: pass
  - proof: scaffold includes additive `.incoming` and `.archive` and excludes
    extension-level intake lifecycle directories
- `bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh --workflow-id process-incoming-intake`
  - result: pass, errors=0 warnings=0
- `bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/generate-workflow-guides.sh`
  - result: pass; generated workflow READMEs refreshed
- `bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh`
  - result: pass, publication id `capabilities-f7044b4c7b5a`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh`
  - result: pass, errors=0
- `bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh`
  - result: pass
- `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-host-projections.sh`
  - result: pass, 3 passed and 0 failed
  - proof: `/process-incoming-intake` projects into host command directories
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh`
  - result: pass, errors=0
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh`
  - result: pass, errors=0
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
  - result: pass, errors=0 warnings=0
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-authority-surfaces.sh`
  - result: pass, errors=0
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh`
  - result: pass, errors=0
- `git diff --check`
  - result: pass
- `git diff --name-only -- .octon/generated/effective/extensions .octon/state/control/extensions .octon/instance/extensions.yml`
  - result: no output

## Cleanup Receipt

- old extension-level intake lifecycle directories were removed from the live
  harness and scaffold template
- old `install-downloaded-pack` and `incoming-pack-installation` active surfaces
  were replaced by `process-incoming-intake` and `incoming-intake-processing`
- stale path mentions that remain are explicit prohibited-path checks, negative
  tests, or historical refine-prompt evidence retained as source record rather
  than active guidance
- unrelated dirty capability, skill, and state/evidence residue present in the
  workspace was left untouched
- dependency changes: none
- remaining cleanup risk: none for this migration scope
