# Correction Prompt: Promotion Artifact Index Parent Program Shape

finding_id: blocked-delivery-receipt-semantics-promotion-artifact-index-parent-program-shape
status: resolved
severity: blocking
created_at: 2026-06-17
resolved_at: 2026-06-18T01:04:10Z
packet: .octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics

## Blocker

Child implementation completed, but child-only promotion to `implemented` cannot
proceed because the canonical artifact-index generator crashes on this child
packet's structured `proposal.yml#parent_program` value.

Failing command:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics --check
```

Observed failure:

```text
TypeError: unsupported operand type(s) for /: 'PosixPath' and 'dict'
```

The failure occurs before artifact-index freshness can be proven. Because
`validate-proposal-lifecycle-terminal-freshness.sh --proposal <child>
--run-registry-check` depends on the same canonical artifact-index generator,
the child dependency gate cannot be satisfied.

## Current Passing Evidence

- `validate-proposal-review-gate.sh --require-implementation-authorization` passed.
- `validate-proposal-implementation-readiness.sh` passed.
- `validate-architecture-proposal.sh` passed.
- `validate-proposal-standard.sh --skip-registry-check` passed with one
  artifact-catalog warning.
- `validate-architectural-review-receipts.sh --require-pass` passed.
- `validate-proposal-packet-delivery-receipt.sh` passed.
- `validate-proposal-packet-delivery-receipt.sh --receipt
  /private/tmp/octon-blocked-delivery-receipt-semantics/valid-blocked-receipt.yml`
  passed.
- `test-validate-proposal-packet-delivery.sh` passed with `pass=31 fail=0`.
- `validate-proposal-implementation-conformance.sh --package <child>` passed.
- `validate-proposal-post-implementation-drift.sh --package <child>` passed
  with a nonblocking stale-registry warning before promotion.

## Related Registry Drift

`generate-proposal-registry.sh --check` also reports that
`.octon/generated/proposals/registry.yml` is stale relative to the new child
packets and the accepted parent program. That registry drift is repairable
through the canonical registry generator, but it does not resolve the artifact
generator type error.

## Required Correction Route

Chosen route:

1. Revise this child packet and rerun child review so
   `proposal.yml#parent_program` uses the artifact generator's expected scalar
   shape.

The child manifest now records
`parent_program: "operator-free-packet-lifecycle-autonomy"`. The artifact-index
generator was not edited because it is outside this child's declared durable
`promotion_targets`.

Original allowed routes:

1. Revise this child packet and rerun child review so
   `proposal.yml#parent_program` uses the artifact generator's expected scalar
   path shape, if that is the intended packet contract.
2. Create or link a separate proposal that updates
   `.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh`
   to accept the structured `parent_program` object shape already used by the P0
   child packets.

## Resolution Evidence

- Revision receipt:
  `support/revisions/20260618T010410Z-parent-program-scalar-shape.md`
- Child proposal review and pre-integration architecture review were refreshed
  against packet digest
  `sha256:03970f7cb81090a4b2a09dff1f2153bc37bedb389b85aa53b9f98a2958b59017`.

Do not silently edit the artifact-index generator under this child route: it is
not one of this child's declared durable `promotion_targets`.

## Refusals

Do not promote this child to `implemented`, do not promote the parent program,
do not close out, archive, publish, land, clean, delete branches, delete
retained evidence, or claim `cleaned` until the correction route has passed its
own review and the child promotion/terminal freshness gates pass.
