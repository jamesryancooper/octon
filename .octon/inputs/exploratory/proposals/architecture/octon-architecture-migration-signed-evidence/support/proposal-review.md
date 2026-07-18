review_id: octon-architecture-migration-signed-evidence-review-20260718T161703Z
reviewed_at: 2026-07-18T16:17:03Z
reviewer: octon-proposal-lifecycle-review-packet
verdict: revision-required
implementation_prompt_authorized: no
reviewed_packet_digest: sha256:42273a7d2475c1eac7195c3ff97ee059e1c970659e9c78cbd136be7ad94e4805
open_blocking_findings_count: 3
prior_review_id: none
final_route: revise-packet
final_route_target: octon-architecture-migration-signed-evidence

# RP-07 Independent Proposal Review

## Review Basis

Reviewed all 22 packet files, accepted RP-03/RP-04/RP-06 interfaces, ROD-001,
key/anchor/reserve/retention design, degraded behavior, UE-008 plan, and exact
25-target parent parity.

## Approved Promotion Targets

None while revision is required. All 25 proposed targets match the parent.

## Blocking Findings

### RP07-ENGINEERING-MECHANISMS-001 — high

The packet leaves signer algorithms/providers, verifier attestation format,
candidate-inaccessible anchor, physical reserve layout/commit protocol, quotas,
retention windows, pins, backup generations, and provisional capacities open.
These are authorized engineering dispositions, not operator decisions, but one
exact reversible design receipt is required before implementation authorization.

### RP07-RP06-VERIFIER-IDENTITY-002 — high

The draft assumes a platform-Keychain-backed verifier key, while accepted
RP-06 runs the verifier emitter on GitHub-hosted infrastructure. The packets
need one non-circular identity contract—e.g. workflow-bound Sigstore/GitHub
attestation for the hosted verifier plus a separate local checkpoint signer—
without exporting a local private key or treating a Check Run as a signature.

### RP07-IMPLEMENTATION-EVIDENCE-CYCLE-003 — high

Dependency implementation exits, mechanism proof, UE-008, and 30-day burden
results gate proposal authorization although they require the authorized
implementation. Accepted exact design may authorize creation; dependency and
platform preflight gate source entry; dynamic evidence gates completion,
activation, or promotion.

## Nonblocking Findings

- ROD-001 is settled and requires no new operator vote.
- Direct-observation limits, honest incompleteness, compaction ordering,
  degraded behavior, ownership, rollback, and scope parity are coherent.

## Exclusions

No key, signer, attestation, anchor, reserve, checkpoint, evidence deletion,
provider request, implementation, publication, promotion, archive, or cleanup
effect occurred. Planned UE-008 evidence is not current proof.

## Final Route Recommendation

Keep RP-07 in review, select exact mechanisms and evidence order, align the
hosted verifier identity, then independently re-review. Do not implement RP-07.
