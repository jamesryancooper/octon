# Evidence and Proof Plan

## Evidence roots

The migration writes validation evidence under:

```text
.octon/state/evidence/validation/runtime/governed-runtime-materialization-v1/
```

Subroots:

- `baseline/`
- `support-envelope/`
- `effect-token/`
- `run-health/`
- `integration/`
- `closure/`

## Support-envelope evidence

Required records:

- source artifact inventory with digests
- support declaration digest
- proof/admission artifact digest
- route-bundle digest
- pack-route digest
- support-matrix digest
- support-card/disclosure digest where present
- reconciliation result
- mismatches and deterministic reasons
- generated output receipt

## Effect-token evidence

Required records:

- material side-effect inventory
- effect-class mapping
- token issuance records
- token verification records
- token consumption receipts
- revocation/expiry denial records
- positive runtime test receipt
- negative bypass test receipt

## Run-health evidence

Required records:

- source run control/evidence/continuity inventory
- health generator receipt
- health artifact digest
- health validator receipt
- freshness/staleness decision
- non-authority classification
- fixture matrix result

## Closure evidence

Closure evidence must prove that validators passed after promotion targets were
updated and generated artifacts were regenerated. Proposal-local files are not
valid closure proof.
