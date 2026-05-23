# Evidence Plan

## Proposal Creation Evidence

- `support/proposal-creation.md` records creation metadata.
- `support/implementation-grade-completeness-review.md` records packet
  completeness.
- Proposal and architecture validators provide structural evidence.

## Later Implementation Evidence

A later implementation must retain:

- run contract and run evidence for any consequential execution;
- implementation run receipt;
- implementation conformance receipt;
- post-implementation drift/churn receipt;
- lifecycle contract validator output;
- schema validation output;
- runner and executor test output;
- proposal lifecycle acceptance test output;
- generated projection publication and freshness receipts;
- rollback posture;
- final disclosure that generated and proposal-local artifacts are
  non-authoritative.

## Negative Controls

Later validation must prove denial for:

- implementation without fresh accepted review;
- implementation prompt generation with stale review digest;
- promotion without implementation run receipt;
- closeout without conformance and drift receipts;
- archive without closeout authorization;
- generated projection consumed as authority;
- proposal-local receipt consumed as runtime authority;
- executor dispatch without delegation proof;
- resume from mismatched checkpoint and event log;
- loop continuation after max iterations or cancellation.

## Retention

Retained evidence belongs under `.octon/state/evidence/**` and run control
belongs under `.octon/state/control/**`. This proposal packet's `support/**`
files are packet-local evidence only.
