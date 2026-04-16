# Draft Artifact Contract

This file is the source of truth for capability-managed artifact names and
scratch support filenames across the `octon-decision-drafter` prompt family.

## Artifact Name Sources Of Truth

- Each bundle manifest `artifact_policy.internal_artifacts` is the source of
  truth for managed checkpoint artifact ids.
- Each bundle manifest `artifact_policy.packet_support_files` is the source of
  truth for scratch support filenames.
- `resolve-extension-prompt-bundle.sh` is the source of truth for
  `alignment_mode` behavior.

## Managed Checkpoint Artifacts

The capability-managed checkpoint root is:

- `/.octon/state/control/skills/checkpoints/octon-decision-drafter/<run-id>/`

Default artifact files under that root are:

- `artifacts/diff-input.md`
- `artifacts/changed-paths.md`
- `artifacts/grounding-evidence.md`
- `artifacts/target-surface.md`
- `artifacts/draft-output.md`
- `artifacts/route-receipt.json`

## Scratch Support Files

When `scratch-md` is requested, support artifacts should be copied or
normalized using the manifest-declared filenames:

- `support/diff-input.md`
- `support/changed-paths.md`
- `support/grounding-evidence.md`
- `support/target-surface.md`
- `support/draft-output.md`

## Lookup Order

- For diff, changed-path, grounding, and target-surface artifacts:
  checkpoint artifact first, then scratch support file, then explicit user
  input only if managed artifacts are unavailable.
- For route receipts:
  checkpoint artifact first, then explicit dry-run route output.
- Never reconstruct missing managed artifacts from memory.
