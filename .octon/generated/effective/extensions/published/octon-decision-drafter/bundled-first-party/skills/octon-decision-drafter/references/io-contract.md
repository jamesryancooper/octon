# I/O Contract

## Inputs

- `bundle` - optional route selector, defaults to `change-receipt`
- `diff_range` - optional git diff range
- `diff_source` - optional diff artifact path
- `changed_paths` - optional narrowed changed-path set
- `evidence_refs` - optional retained evidence refs under
  `/.octon/state/evidence/**`
- `adr_ref` - optional ADR target
- `migration_plan_ref` - optional migration-plan target
- `run_contract_ref` - optional run-contract context
- `rollback_posture_ref` - optional rollback-posture context
- `proposal_packet_ref` - optional proposal-packet context
- `output_mode` - optional `inline`, `patch-suggestion`, or `scratch-md`
- `draft_target_path` - required when `output_mode=patch-suggestion`
- `alignment_mode` - optional `auto`, `always`, or `skip`
- `dry_run_route` - optional route preview flag

Exactly one of `diff_range` or `diff_source` must be supplied.

## Outputs

- route receipt when routing is previewed or blocked
- one non-authoritative draft in the selected output mode
- run log under
  `/.octon/state/evidence/runs/skills/octon-decision-drafter/<run-id>.md`
- optional checkpoint directory under
  `/.octon/state/control/skills/checkpoints/octon-decision-drafter/<run-id>/`

## Default Intermediate Artifact Paths

Canonical managed artifact names and scratch support filenames are defined by
the selected bundle `prompts/<bundle>/manifest.yml` plus:

- `prompts/shared/draft-artifact-contract.md`

The pack should manage upstream stage outputs under the current run checkpoint
root and, when `scratch-md` is requested, copy or normalize support artifacts
into the scratch directory rather than leaving them only in transient
conversation state.

## Alignment Mode

`alignment_mode` accepts `auto`, `always`, or `skip`, but the behavioral
source of truth is:

- `/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh`

Default alignment-policy values live in:

- `prompts/<bundle>/manifest.yml`
