# Target Architecture

_Status: In-review parent-program target_

This parent program targets a tiered evidence architecture only after child
packets prove the contracts, storage boundaries, receipt schemas, validators,
and migration evidence required to promote it.

## Program-Level Target State

1. Octon's existing retained-evidence model remains valid.
2. `.octon/state/evidence/runs/**` becomes publishable claim evidence by
   contract, not a raw-log dumping ground.
3. `.octon/state/evidence/local/**` carries private local raw evidence and is
   ignored by default.
4. `.octon/state/evidence/disclosure/**` carries operator and release
   disclosure derived from publishable evidence.
5. `.octon/generated/**` remains derived-only and cannot satisfy evidence
   gates.
6. Promotion from local raw evidence to publishable evidence requires
   summarization, redaction, declared limitations, and a publishable receipt.
7. Validators prevent tracked local raw evidence, missing `disclosure_tier`
   metadata, oversized publishable evidence, and hosted closeout dependence on
   local-only artifacts.
8. Closeout and repo-hygiene flows retain local debugging evidence while
   publishing concise claim-sufficient receipts.
9. Existing residue is migrated, locally archived, replaced by publishable
   receipts, or explicitly retained only after child-owned safety evidence.

## Non-Target State

The parent program does not target raw transcript publication, generated
read-model authority, proposal-local evidence authority, automatic raw-copy
promotion, or a clean-sheet replacement for Octon's evidence roots.
