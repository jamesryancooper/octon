# Program Closeout Plan

Parent closeout is allowed only after every required child reaches an allowed
terminal outcome through its own lifecycle route. The optional retained run
evidence efficiency packet may be terminal, explicitly deferred, rejected, or
superseded without blocking core generated/projection churn closeout.

## Required Child Outcomes

- `proposal-churn-common-generator-idempotency-metrics` must close with common no-op write and churn metric evidence.
- `proposal-churn-run-health-read-model-compaction` must close with evidence that run-health output churn is proportional to changed runs.
- `proposal-churn-effective-publication-idempotency` must close with evidence that runtime-facing generated/effective outputs retain freshness, locks, receipts, and resolver validation.
- `proposal-churn-extension-payload-compaction` must close with evidence that unchanged extension payloads are reused or skipped.
- `proposal-churn-filesystem-snapshot-retention` must close with stable snapshot identity and producer-owned retention proof.
- `proposal-churn-proposal-artifact-compaction` must close with archive-aware changed-packet-only generation evidence.
- `proposal-churn-receipt-fanout-compaction` must close with retained evidence retrieval proof for compacted receipts.
- `proposal-churn-host-projection-idempotency` must close with no-op host projection proof and non-authority parity evidence.
- `proposal-churn-tmp-engine-cache-hygiene` must close with `.tmp` file/byte budget evidence and rebuildability proof.

## Aggregate Parent Evidence

Before parent archival, parent-local aggregate receipts must show:

- parent program structure validation passed;
- child registry, human index, sequence, child contract, closeout plan, churn-class table, and metrics remained synchronized;
- every required child terminal outcome is current and child-owned;
- no child weakened freshness, lock, receipt, resolver, support-claim, closeout, or evidence-retention guarantees;
- external dependency packets were consumed by reference and not duplicated;
- no parent artifact attempted to satisfy child evidence or authority.

## Refusal Conditions

Refuse parent closeout or archive when:

- any required child remains non-terminal without explicit rejection, supersession, or replacement evidence;
- a producer-specific fix is replaced by generic path cleanup;
- generated outputs are hand-edited or treated as authority;
- runtime-facing generated/effective freshness gates are weakened;
- retained evidence is deleted without owning cleanup authority and reference-integrity proof;
- source/framework/input/archive changes are treated as cleanup candidates;
- host projections are treated as authority or generic disposable residue.
