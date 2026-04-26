# Support Envelope Reconciliation Fixtures

The executable fixture coverage for this family lives in
`../../tests/test-support-envelope-reconciliation.sh`.

The test builds isolated temporary repositories from the current canonical
support surfaces and mutates them into deterministic negative controls:

- declared live tuple routed stage-only
- pack route allows while runtime route is stage-only
- generated matrix widens non-live support
- generated matrix omits a declared live claim
- live tuple proof bundle is stale
- live tuple proof bundle is missing
- support card overclaims a non-live tuple
- excluded/stage-only target is presented live

`coherent-live/fixture.yml` is the positive fixture descriptor. The live
repository is copied into a temp fixture root before every mutation so the
fixtures remain deterministic without duplicating the support surface tree.
