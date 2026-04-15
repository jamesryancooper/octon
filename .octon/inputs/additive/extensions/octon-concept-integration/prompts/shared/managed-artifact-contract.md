# Managed Artifact Contract

This file is the single source of truth for capability-managed artifact names,
lookup order, and packet support filenames across the
`octon-concept-integration` prompt-bundle family.

## Artifact Name Sources Of Truth

- Each bundle manifest `artifact_policy.internal_artifacts` is the source of
  truth for managed checkpoint artifact ids.
- Each bundle manifest `artifact_policy.packet_support_files` is the source of
  truth for packet support filenames.
- `resolve-extension-prompt-bundle.sh` is the source of truth for
  `alignment_mode` behavior; prompts may name supported modes but must not
  redefine their semantics.

## Managed Checkpoint Artifacts

The capability-managed checkpoint root is:

- `/.octon/state/control/skills/checkpoints/octon-concept-integration/<run-id>/`

The default artifact files under that root are:

- `artifacts/source-artifact.md`
- `artifacts/concept-extraction-output.md`
- `artifacts/concept-verification-output.md`
- `artifacts/selected-concepts.md`
- `artifacts/proposal-packet-path.txt`
- `artifacts/executable-implementation-prompt.md`

## Packet Support Files

When packetization succeeds, support artifacts should be copied or normalized
into the packet using the manifest-declared filenames:

- `support/source-artifact.md`
- `support/concept-extraction-output.md`
- `support/concept-verification-output.md`
- `support/executable-implementation-prompt.md`

## Lookup Order

Use these shared lookup rules unless a stage needs a narrower, stage-specific
override:

- For source, extraction, verification, and selected-concept artifacts:
  capability-managed checkpoint artifact first, then packet support file when
  rerunning after packetization, then explicit inline/tagged user input only if
  managed artifacts are genuinely unavailable.
- For proposal packet execution:
  `artifacts/proposal-packet-path.txt` first, then the materialized proposal
  directory under `/.octon/inputs/exploratory/proposals/<kind>/<proposal_id>/`,
  then an explicit user override.
- Never reconstruct missing managed artifacts from memory.
