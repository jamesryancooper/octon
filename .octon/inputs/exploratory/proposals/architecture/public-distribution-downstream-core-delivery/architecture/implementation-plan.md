# Implementation Plan

## Dependencies

- `public-distribution-repository-role-contracts` must satisfy its declared verification gate.

## Phases

1. Define `core-lock-v1.schema.json` plus ownership, compatibility, journal,
   cache, and command contracts; make every reader validate the lock before
   resolution or mutation.
2. Implement verified install and neutral initialization on all Tier 1 platforms.
3. Implement dry-run update, staged replacement, lock-last commit, and project-hash proof.
4. Implement interruption recovery, rollback, local-artifact offline mode, and fault injection.
5. Package and validate Tier 1 release artifacts and non-blocking Tier 2 previews.

## Migration And Compatibility

- Downstream adopters begin with new projects or an explicit adoption preflight.
- Existing projects classify current framework and project-owned paths before enabling updates.
- The source workspace is identified by repository-role metadata and update replacement is refused.

## Validation Plan

- Clean install, verify, update, injected interruption, recovery, and rollback pass on every Tier 1 target.
- A local artifact installs without network access after verification.
- Project-owned path hashes are identical before and after each operation.
- Bad checksums, provenance mismatch, incompatible instance versions, path collisions, and unsafe archives fail before replacement.
- Unknown lock fields, missing bindings, noncanonical lock encodings, and
  cross-platform lock-digest disagreement fail before retrieval or mutation.
- A simulated lock-write interruption recovers to either the old or new verified state, never a mixed state.
- Negative case NV-PD-025 (public-repository-only exclusion): a downstream install fixture proves every manifest entry labeled public-repository-only is excluded from installation; runtime-generated test data for this fixture may live inside the `.octon/framework/assurance/runtime/_ops/tests/test-downstream-core-delivery.sh` test scope, and is explicitly permitted there.

## Rollback And Interrupted Operation

This section covers the delivered tool's runtime rollback behavior inside a
downstream target. Change-level rollback of this packet's own promotion is a
separate concern, defined below.

- Preserve the previous verified core and lock until the new state passes post-swap verification.
- Journal each transition durably and make recovery idempotent.
- On failure, restore the prior core and prior lock, then verify project-owned hashes.
- If automatic recovery cannot prove one coherent state, stop with a precise manual recovery plan and no further writes.

## Change-Level Rollback Of This Packet's Promotion

The registry rollback posture for this child is rollback-route: the promotion
of this packet into the framework must itself be revertible, independent of
the delivered tool's runtime rollback above.

- `.octon/framework/scaffolding/runtime/_ops/scripts/init-project.sh` is an existing script being modified, not created; `.octon/framework/scaffolding/runtime/templates/octon/` is an existing template tree being modified. Rollback for both is `git revert` of the promotion commit that carried the scaffolding target family, restoring the prior script and template bytes exactly.
- Each promotion target family lands as a single revertible promotion commit:
  one for the scaffolding modifications (`init-project.sh` plus
  `templates/octon/`), one for the new engine deliverables
  (`downstream-core-delivery-v1.md`, `core-lock-v1.schema.json`, and
  `crates/core_delivery/`), and one for the new assurance deliverables
  (validator plus test). New-file families revert to absence; modified-file
  families revert to their prior committed content.
- After any revert, re-run the packet validators (`validate-proposal-standard.sh` and `validate-architecture-proposal.sh` against this packet) plus the affected framework validation to prove the repository returned to a coherent pre-promotion state.

## Evidence

Implementation must retain compact, non-sensitive receipts for each objective
acceptance test. Raw sensitive evidence remains local-private unless the
maintainer explicitly classifies a publishable derivative.

## Closeout Condition

Closeout is blocked until every acceptance criterion has direct evidence,
negative controls pass, residual risks are recorded, and no external effect is
misrepresented as completed.
