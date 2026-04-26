# Validation Plan

## Static validation

Run or add validators for:

- proposal manifest shape
- architecture proposal shape
- schema validation
- contract registry conformance
- support-target declarations
- runtime-effective route bundle
- capability-pack route bundle
- support-target matrix
- runtime-effective handle freshness
- source-of-truth boundaries
- generated non-authority
- input non-authority
- material side-effect inventory

Representative commands:

```sh
bash .octon/framework/cognition/_meta/proposals/scripts/validate-proposal-standard.sh \
  .octon/inputs/exploratory/proposals/architecture/octon-governed-runtime-materialization-v1

bash .octon/framework/cognition/_meta/proposals/scripts/validate-architecture-proposal.sh \
  .octon/inputs/exploratory/proposals/architecture/octon-governed-runtime-materialization-v1

bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh
```

## Runtime validation

Each material side-effect path must prove:

- valid authorized effect succeeds
- missing token fails
- forged token fails
- wrong token class fails
- expired token fails
- revoked token fails
- wrong run binding fails
- wrong route binding fails
- wrong support tuple fails
- missing approval fails
- missing exception fails
- stale support route fails
- unsupported tuple fails
- evidence receipt missing blocks closure where required

## Reconciliation validation

Fixtures must prove:

- support declarations match proof-backed admissions
- generated support matrices cannot widen support
- generated support matrices cannot hide required live/proof drift
- runtime-effective routes cannot claim unproven live support
- capability-pack routes cannot widen a denied/staged route
- support cards/disclosures match reconciled support truth
- staged routes remain staged
- excluded targets remain excluded

## Run-health validation

Fixtures must prove:

- healthy run renders healthy
- review-required run renders review-required
- awaiting-approval run renders awaiting-approval
- blocked run renders blocked
- stale run renders stale
- revoked run renders revoked
- unsupported run renders unsupported
- missing evidence renders evidence-incomplete
- rollback gap renders rollback-required
- closure-ready run renders closure-ready
- generated health cannot authorize anything

## Negative-control validation

Required negative fixture families:

- `support-envelope-reconciliation/negative/**`
- `authorized-effect-token-enforcement/negative/**`
- `run-health-read-model/negative/**`

Each negative fixture must have an expected deterministic denial reason. A
negative fixture that fails for a different reason is not passing evidence.
