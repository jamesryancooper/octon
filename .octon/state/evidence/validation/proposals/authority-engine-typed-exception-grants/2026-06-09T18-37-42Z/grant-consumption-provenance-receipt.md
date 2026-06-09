# Grant Consumption Provenance Receipt

verdict: pass
recorded_at: 2026-06-09T18:37:42Z
proposal_id: authority-engine-typed-exception-grants

## Runtime Enforcement

The authority engine now validates active approval grants before route allow:

- active grants must carry one exact typed exception boundary;
- the requested boundary must match the active grant boundary when supplied;
- `grant_consumption_mode` must be `delegated-execution`;
- active grants must carry expiry or retirement metadata;
- active grants must carry revocation behavior;
- active grants must cite retained authority provenance under state control or evidence roots;
- generated-output and read-model authority sources deny the route;
- importance-only rationale stages the route.

## Consumption Evidence

The retained authority grant bundle now records:

- `typed_exception_boundary`;
- `authority_provenance_refs`;
- `grant_consumption.mode`;
- `grant_consumption.consumes_bound_grant_only`;
- `grant_consumption.mints_fresh_authority: false`;
- `grant_consumption.consumption_receipt_ref`.

## Effect Verification

Effect-token approval verification now rejects approval-bound material effects unless the grant also carries:

- a valid typed exception boundary;
- delegated grant consumption mode;
- retained authority provenance.

## Proof

- `cargo test -p octon_authority_engine grant`: pass, 7 tests.
- `cargo test -p octon_authority_engine`: pass, 75 tests.

Both runs used `CARGO_TARGET_DIR=/private/tmp/octon-runtime-crates-target` because the sandbox blocked the repository default Cargo target lock path.
