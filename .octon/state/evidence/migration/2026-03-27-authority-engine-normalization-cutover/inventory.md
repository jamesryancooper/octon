# Wave 2 Change Inventory

## Constitutional And Governance Surfaces

- Added `/.octon/framework/constitution/contracts/authority/**`
- Published `/.octon/instance/governance/support-targets.yml`
- Updated constitutional registry, charter, precedence, and evidence/fail-closed obligations for Wave 2 activation

## Runtime And Control Roots

- Normalized approval, exception, and revocation control roots under
  `/.octon/state/control/execution/{approvals,exceptions,revocations}/`
- Centralized authority-routing logic in
  `/.octon/framework/engine/runtime/crates/kernel/src/authorization.rs`
- Updated runtime exception-lease loading and network-egress provenance in
  `/.octon/framework/engine/runtime/crates/core/src/execution_integrity.rs`
- Added generic authority mutation helpers under
  `/.octon/framework/engine/_ops/scripts/`

## Docs, Validators, And Evidence

- Updated architecture/bootstrap/engine docs to point at canonical authority
  roots and projection-only host affordances
- Updated harness, architecture, mission-runtime, execution-governance, and
  repo-instance validators for Wave 2 roots
- Routed GitHub PR human-accept and AI-gate waiver flows through
  `/.octon/framework/agency/_ops/scripts/github/materialize-pr-authority.sh`
- Refreshed generated effective/cognition projections as part of the harness
  alignment run

## Support Targets

- Expanded support-target coverage across workload, model, context, and locale
  tiers
- Extended runtime resolution to match the declared support-target matrix
  instead of only the workload tier
