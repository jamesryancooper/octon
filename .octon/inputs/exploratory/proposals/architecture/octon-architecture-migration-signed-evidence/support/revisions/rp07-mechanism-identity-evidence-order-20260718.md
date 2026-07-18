revision_id: octon-architecture-migration-signed-evidence-revision-20260718T162544Z
source_review_id: octon-architecture-migration-signed-evidence-review-20260718T161703Z
revision_timestamp: 2026-07-18T16:25:44Z
revision_route: revise-packet
status: in-review
change_profile: atomic
release_state: pre-1.0
post_revision_digest: sha256:f47d82b3362eba36d476d5342f5fd4dc48119d7b428f83c298595a2948986795
remaining_blocking_count: 0
parent_scope_changed: false
key_or_keychain_mutated: false
filesystem_reserve_created: false
provider_attestation_created: false
evidence_deleted: false
implementation_performed: false

addressed_finding_ids:

- `RP07-ENGINEERING-MECHANISMS-001`
- `RP07-RP06-VERIFIER-IDENTITY-002`
- `RP07-IMPLEMENTATION-EVIDENCE-CYCLE-003`

# RP-07 Correction Receipt

## Exact Mechanisms

The design selects deterministic CBOR; separate Secure Enclave P-256 broker
and checkpoint roles; System-Keychain compare-and-advance heads; 64 non-sparse
64-KiB double-header terminal slots with 32-KiB payload ceiling and 16-slot low
water; and explicit quotas, pins, retention, backup, compaction, dependency,
rotation, loss, and degraded-state behavior. Whole-host/root/Keychain rollback
is excluded rather than overclaimed.

## Hosted Verifier Alignment

RP-06's hosted verifier attests the canonical verdict/observation digest with a
GitHub DSSE/Sigstore artifact attestation bound to exact workflow identity.
RP-07 retains the bundle and independently verifies cryptography, identity,
subject, and transparency material. A Check Run is not a signature. No local
private key is exported, and the local checkpoint role remains separate.

## Evidence Order

Accepted review may authorize creation of the exact design. RP-03/RP-04/RP-06
implementation verification and exact platform/dependency/Sigstore/constrained-
volume preflight gate source entry. UE-008, 30-day burden, key/anchor/reserve/
compaction attacks, conformance, and drift gate activation, completion, or
promotion. No future result is present proof.

## Scope And Next Gate

All 25 promotion targets remain unchanged and exactly equal the parent entry;
no parent revision is required. Fresh independent re-review is next. This
revision created no key, anchor, reserve, attestation, checkpoint, provider
effect, deletion, or implementation.
