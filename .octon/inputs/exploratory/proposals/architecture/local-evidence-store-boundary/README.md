# Local Evidence Store Boundary

_Status: Accepted child architecture proposal packet_

Establish the local-only raw evidence store under `.octon/state/evidence/local/**` with an Octon-scoped ignore rule and clear non-publishable authority posture.

This packet is child-owned under the Evidence Disclosure Tier Contract Program.
It remains proposal-local until promoted into durable targets. The parent may
sequence this packet, but it does not own this packet's manifests, acceptance
criteria, validation verdicts, promotion targets, implementation receipts, or
archive metadata.

## Scope

Local evidence root README, scoped ignore rule, and repo-hygiene policy alignment for private raw evidence.

## Boundaries

- No durable implementation occurs in this packet.
- No raw local evidence is published by this packet.
- No generated read model becomes authority.
- No hosted/shared closeout claim may depend on local-only evidence.
- No parent program evidence satisfies this child packet's receipts.
