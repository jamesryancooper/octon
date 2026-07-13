# Rollback Plan

## Prepared Before Cutover

- retain the last certified desired config, availability, active/quarantine,
  generated family, transition receipt, and exact Harness generation digest;
- retain bounded exact signed envelopes/payloads for the current and configured
  prior generation under RP-07 retention;
- retain current source/signer/revocation policy and public verification refs;
- provide one disable for private import/publication that leaves bundled-first-
  party core operation available;
- prove disabling private extensions preserves core missions/candidate work;
  and
- prohibit direct edits to generated files as rollback.

## Rollback by Stage

| Stage | Action | Preserved data |
| --- | --- | --- |
| Contracts only | Keep private imports denied and repair schemas/templates. | Current bundled desired/actual/generated state |
| Import/availability only | Disable import; quarantine or retain verified releases without selection. | Signed envelopes/payloads, availability, import receipts |
| Desired pins/publisher disabled | Revert desired private entries through canonical governance or leave them ineligible. | Trust policy, exact pins, existing active generation |
| Publisher shadow | Discard staged output; keep active/generated family unchanged. | Shadow comparison, candidate work, prior generation |
| Post-activation defect | Quarantine/revoke affected release, disable new private generation use, and invoke revalidated prior restore or extension-disabled publication. | Exact current/prior inputs and all transition evidence |

## Revalidated Restore Procedure

1. Accept an exact rollback request from the existing canonical recovery route.
2. Locate the retained signed envelope/payload by source/version/digest.
3. Verify current ROD-004 source/signer/revocation policy and signature.
4. Verify manifest/payload/dependency digests and safe retained material.
5. Re-evaluate current compatibility and requested capabilities.
6. Confirm exact desired/rollback pin and no unavailable dependency.
7. Stage a new actual/generated family with a new generation ID.
8. Atomically publish active/quarantine/generated plus transition receipt.
9. Permit only future RP-11 Harnesses that bind the new exact generation.

Failure at any step leaves the prior release inactive/quarantined. If no valid
release exists, publish the extension-disabled generation and keep core Octon
available.

## Recovery Procedures

- Interrupted import: discard staging; if immutable content was retained but
  not cataloged, reverify before creating availability.
- Availability corruption: rebuild from retained signed envelopes/import
  receipts under current policy; do not infer desired selection.
- Generated corruption: rebuild through the single publisher from desired and
  actual state; never recover authority from generated output.
- Revocation race: deny affected publication/compile/launch, record the exact
  policy observation, reconcile quarantine, then require a fresh generation.
- Split/unknown publication: compare active/generated/transition receipts,
  expose neither partial family, and retry idempotently from staged inputs.
- Missing/corrupt retained prior: mark unavailable and disable rather than
  refetch automatically from an unapproved/mutable source.

## Rollback Invariant

Rollback may disable private extension import or use. It may not restore an
unsigned, untrusted, revoked, tampered, incompatible, capability-expanded, or
unpinned release; edit generated outputs directly; auto-select another version;
lose candidate/core work; or create a fallback publisher/control plane.
