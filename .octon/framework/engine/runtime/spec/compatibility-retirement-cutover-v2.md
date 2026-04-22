# Compatibility Retirement Cutover v2

This contract defines the cutover posture for retained compatibility
projections that remain useful for lineage, audit, or migration comparison
without surviving as runtime, policy, or support authority.

## Purpose

Compatibility surfaces may remain only when they are explicitly registered,
de-authorized, successor-bound, reviewable, and fail-closed against accidental
runtime or policy use.

## In-scope surface classes

- compatibility projections under `/.octon/instance/capabilities/runtime/packs/**`
- ingress projection adapters retained for tool compatibility
- other claim-adjacent historical or transitional helpers recorded in the
  retirement register

## Required registration posture

Every retained compatibility surface must publish:

- `canonical_successor_ref`
- `status`
- `disposition`
- `claim_adjacent`
- `future_widening_blocker`
- `review_artifact_ref`
- `latest_review_packet_ref`
- `next_review_due`
- `rationale`

Claim-adjacent retained surfaces must also publish:

- `allowed_consumers`
- `forbidden_consumers`
- `evidence_refs`
- a matching non-authority register entry when the surface is generated,
  projected, or otherwise easy to mistake for live authority

## Cutover readiness criteria

A compatibility surface is ready to retain as compatibility-only or to retire
fully only when:

- a canonical successor exists,
- the successor is resolver-verified or validator-enforced at the required
  target depth,
- no runtime, policy, or support-claim consumer reads the compatibility
  surface,
- claim-adjacent surfaces are recorded in the non-authority register,
- forbidden-consumer negative controls exist, and
- retained evidence records the cutover.

## Failure rules

Reject closure-grade or target-state claims when any of the following is true:

- a compatibility surface can still influence runtime, policy, or support
  claims,
- a claim-adjacent compatibility surface lacks a canonical successor or review
  cadence,
- a retained compatibility surface lacks explicit forbidden consumers,
- direct-read prevention or forbidden-consumer evidence is missing, or
- the runtime-capability-pack projection is treated as a parallel runtime route
  instead of a compatibility-only view.

## Highest-priority cutover

`/.octon/instance/capabilities/runtime/packs/**` must remain compatibility-only
or be retired. The generated/effective pack-route surface is the runtime-facing
successor.

## Related contracts

- `/.octon/instance/governance/retirement-register.yml`
- `/.octon/instance/governance/contracts/retirement-review.yml`
- `/.octon/framework/engine/runtime/spec/runtime-effective-artifact-handle-v2.md`
