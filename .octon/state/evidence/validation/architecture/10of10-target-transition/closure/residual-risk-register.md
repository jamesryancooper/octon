# Residual Risk Register

## Open

- none

## Closed This Run

- Baseline runtime route-bundle, pack-route, capability-routing, and extension
  publication drift was reconciled through canonical publishers.
- Freshness evidence now points at current publication receipts.
- Proof-bundle executability now passes for the two stage-only bundles that
  were missing explicit replay declarations.
- Architecture-health v3 achieved-depth aggregation passes.
- Authorized-effect tokens are runtime-enforced in compiled runtime call paths.
- The runtime route-bundle publisher now emits the authored v3 lock contract.
- `cargo test -p octon_authority_engine` now passes fully.
