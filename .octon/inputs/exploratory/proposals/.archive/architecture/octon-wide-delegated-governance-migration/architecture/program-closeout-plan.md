# Program Closeout Plan

Program closeout requires child-owned terminal outcomes and aggregate evidence.

## Required Closeout Conditions

1. Every required child in `resources/child-packet-index.yml` reaches an
   allowed terminal outcome.
2. Every implemented child retains implementation run, validation,
   implementation-conformance, post-implementation drift/churn, and promotion
   evidence outside proposal-local inputs.
3. Deferred, rejected, superseded, or replaced work has explicit resolving
   evidence.
4. Child receipts are fresh and digest-checked against live child state.
5. Parent aggregate evidence summarizes child outcomes without satisfying child
   receipts.
6. No generated projection, read model, dashboard, external system, tool
   availability, or agent output is used as authority.

## Closeout Blockers

- Any required child is non-terminal.
- Any required child has stale or missing receipts.
- The parent owns child promotion target truth, validation truth, archive truth,
  or implementation truth.
- Generic approval defaults remain in a migrated domain without explicit typed
  exception justification.
- External irreversible effects are delegated without token, rollback,
  compensation, and irreversibility proof.
