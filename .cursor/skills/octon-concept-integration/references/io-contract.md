# I/O Contract

## Inputs

- `bundle` - optional bundle selector, defaults to `source-to-architecture-packet`
- `source_artifact` - optional URL, file path, or inline artifact
- `source_artifacts` - optional multi-source set for synthesis
- `proposal_packet` - optional packet input for refresh or implementation
- `repo_paths` - optional repo-native source inputs
- `subsystem_scope` - optional subsystem/domain scope
- `conflicting_kernel_rules` - optional explicit kernel-conflict map for
  constitutional challenge routing
- `proposal_id` - optional override for the generated proposal id
- `selected_concepts` - optional narrowed execution subset
- `alignment_mode` - optional `auto`, `always`, or `skip`
- `include_execution_prompt` - optional boolean

## Outputs

- bundle-specific packet or execution output under
  `/.octon/inputs/exploratory/proposals/<kind>/<proposal_id>/` when packet
  generation occurs
- run log under
  `/.octon/state/evidence/runs/skills/octon-concept-integration/<run-id>.md`
- optional checkpoint directory under
  `/.octon/state/control/skills/checkpoints/octon-concept-integration/<run-id>/`

## Default Intermediate Artifact Paths

Canonical managed artifact names and packet support filenames are defined by
the selected bundle `prompts/<bundle>/manifest.yml` plus:

- `prompts/shared/managed-artifact-contract.md`

The pack should manage upstream stage outputs under the current run checkpoint
root and, when packetization succeeds, copy or normalize the packet support
artifacts into the proposal directory rather than leaving them only in
transient conversation state.

## Alignment Mode

`alignment_mode` accepts `auto`, `always`, or `skip`, but the behavioral source
of truth is:

- `/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh`

Default alignment-policy values live in:

- `prompts/<bundle>/manifest.yml`
