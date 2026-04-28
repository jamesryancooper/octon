# Promotion Runtime v1

## Purpose

The Promotion Runtime verifies accepted proposal outputs against declared
durable targets and retained approval evidence. In the v5 MVP, `octon promote
apply` is a readiness and fail-closed gate: it reports whether promotion is
already represented by durable control/evidence or whether an authorized
governed run is still required for material writes. It prevents quiet authority
creation and preserves the boundary that proposal packets, generated summaries,
simulations, lab success, and model outputs are not authority.

## Required Checks

Before any promotion attempt can be treated as ready, the runtime must verify:

- proposal status permits promotion
- accepted Decision Request or human/quorum approval exists
- Constitutional Amendment Request exists when constitutional boundaries are
  affected
- declared promotion targets are present
- target roots are legal for the target class
- durable outputs do not depend on proposal paths
- promotion evidence root exists
- rollback, retirement, compatibility cutover, or compensation posture exists
- generated projections are refreshed only after durable source truth exists
- support-target claims do not widen silently
- recertification is requested after promotion

## Boundaries

Promotion Runtime does not approve its own promotion. It does not change
constitutional or governance surfaces without the required approval path. It
does not route material execution outside run contracts, context packs,
execution authorization, authorized-effect tokens, and retained evidence.

## Outputs

- `state/control/evolution/promotions/<promotion-id>.yml`
- `state/evidence/evolution/promotions/<promotion-id>/receipt.yml`
- recertification request and result refs
- generated projections that remain derived non-authority

## Failure Rule

If approval, target legality, retained evidence, rollback posture,
proposal-path cleanup, support no-widening proof, or recertification is missing,
the runtime must block or stage the promotion instead of applying it.
