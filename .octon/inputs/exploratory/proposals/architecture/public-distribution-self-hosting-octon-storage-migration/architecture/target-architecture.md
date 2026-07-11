# Target Architecture

## Boundary

This packet owns `.octon` storage tracking transitions and the exact
self-hosting disclosure-retention authority update needed to select truthful
local custody. Root ignore and workflow policy must already be in place. The
working tree remains the local evidence, input, and generated-output store;
Git index changes do not change authority.

## Proposed Components

- Exact tracked-path classification inventory.
- Per-subtype classification and migration for raw intake, intake archives,
  normalized extension source, human-led ideation, proposals and lineage,
  advisory plans, syntheses, and reports.
- Compact-receipt retention allowlist contract
  (`.octon/framework/constitution/contracts/retention/octon-storage-migration-allowlist-v1.yml`),
  the definition source for the maintainer-approved keep-set and its storage
  classes.
- Backup and restore precondition gate.
- Index-only untracking transaction with progress journal.
- Generated-output rebuild and authority hash verification.
- Index rollback procedure.
- Deterministic migration validator
  (`.octon/framework/assurance/runtime/_ops/scripts/validate-octon-storage-migration.sh`)
  with its test harness
  (`.octon/framework/assurance/runtime/_ops/tests/test-octon-storage-migration.sh`)
  and checked-in fixtures
  (`.octon/framework/assurance/runtime/_ops/fixtures/octon-storage-migration/`),
  including a leak/denylist negative check proving no raw sensitive content
  appears in receipts or migration logs.

## File-Level Work Areas

### Durable Promotion Targets

- `.octon/framework/assurance/runtime/_ops/scripts/validate-octon-storage-migration.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-octon-storage-migration.sh`
- `.octon/framework/assurance/runtime/_ops/fixtures/octon-storage-migration/`
- `.octon/framework/constitution/contracts/retention/octon-storage-migration-allowlist-v1.yml`
- `.octon/instance/governance/contracts/disclosure-retention.yml`
- `.octon/state/evidence/validation/proposals/public-distribution-self-hosting-octon-storage-migration/`

### Operational Surface (Not Promotion Targets)

`.octon/state/`, `.octon/generated/`, and `.octon/inputs/` remain this packet's operational
surface through the parent registry write-scope locks. The index-state
migration operations performed there are journaled operations against
mutable or rebuildable content, not durable owned content, so those broad
roots are not promotion targets. The durable deliverables are the validator,
its test harness, the fixtures, the maintainer-approved keep-set allowlist
contract, the exact self-hosting disclosure-retention authority update, and
the child evidence root above.

## Ownership

- Canonical framework source remains untouched. The maintainer owns the one
  exact instance-authority change at
  `.octon/instance/governance/contracts/disclosure-retention.yml`; all other
  instance paths remain byte-stable.
- Local storage policy owns default handling for state, evidence, and generated output.
- The retention allowlist contract owns the keep-set definition and the enumeration of high-value raw evidence and storage classes.
- The maintainer authorizes untracking and any later deletion.
- Deterministic tooling owns path inventory, backup proof, hash checks, and the leak/denylist negative check.

## Security And Publication Implications

- Raw evidence contents must not appear in migration logs or receipts.
- Backup encryption and restore proof precede untracking of high-value local evidence.
- Compact receipts require disclosure classification before remaining hosted.
- Generated outputs inherit source sensitivity even after regeneration.

## Automation Allocation

### Deterministic Automation

- Classify tracked paths and compute content digests without emitting payloads.
- Preview exact index additions and removals.
- Verify backup coverage and restoration.
- Prove framework hashes and all non-excepted instance hashes remain unchanged,
  verify the approved instance-contract before/after digests, and regenerate
  derived outputs.
- Run the leak/denylist check in `validate-octon-storage-migration.sh` against every receipt and migration log, using checked-in positive and negative fixtures under `.octon/framework/assurance/runtime/_ops/fixtures/octon-storage-migration/`, and fail on any raw sensitive content match.

### AI-Assisted Review

- Suggest evidence classifications and compact receipt candidates from redacted metadata.
- Summarize migration diffs for maintainer approval.

AI output remains review input and cannot clear provenance, accept exposure,
authorize deletion, approve publication, or waive a failed deterministic gate.

### Maintainer-Only Authority

- Approve the exact keep and untrack sets by ratifying the enumerated allowlist contract before migration.
- Control encryption keys and disconnected backup.
- Authorize any destructive deletion in a separate operation.

## Negative Controls

- No working file is deleted by untracking.
- No framework path is removed or modified, and no instance path except the
  exact reviewed disclosure-retention contract is modified.
- No input subtype is treated homogeneously: local-only defaults and hosted
  exceptions come from the Git-posture contract and approved migration
  allowlist, and human-led ideation is classified by path and metadata only.
- No active proposal packet, lifecycle receipt, or proposal-discovery entry
  required to authorize or verify this migration is untracked before its
  terminal closeout; self-untracking cannot satisfy the migration.
- No raw sensitive content appears in receipts or migration logs, enforced by the validator's leak/denylist check with checked-in fixtures rather than by assertion alone.
- No migration begins before root ignore policy and verified backup.
- No history rewrite occurs.

## Deferred Work And Triggers

- Evidence compaction execution activates after post-release volume justifies it.
- External immutable evidence storage activates after a concrete collaboration, regulatory, or recovery need.
- Automated deletion activates only after mature policy and explicit maintainer authorization.

## Residual Risks

- Local files can still be lost if backup discipline fails after migration.
- Some compact receipts may need hosted retention and careful disclosure review.
- Hosted extension source, proposals, plans, syntheses, or reports can still
  leak restricted source material unless every exception is classified.
- Large initial index changes can make review and rollback cumbersome.
