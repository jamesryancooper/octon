# Producer First Churn Reduction Program

This parent program coordinates sibling proposal packets that reduce generated,
projected, validation, and local operational churn by fixing the producers that
create it.

The program is not a cleanup pass. It does not authorize hand-editing generated
outputs, deleting retained evidence, or treating host projections as authority.
The intended architecture is producer idempotency, compact retained evidence,
owner-scoped retention, and metrics that prove no-op runs stay quiet.

## Coverage Verdict

The program covers run-health read models, runtime-facing effective outputs,
extension published payloads, filesystem snapshots, proposal generated
artifacts, `.tmp` and engine cache output, timestamped validation and
publication receipts, host projections, and the adjacent retained run evidence
efficiency question.

It intentionally excludes framework/source/input/archive changes from cleanup.
Those surfaces can trigger downstream generation, but they remain authoritative
or retained proposal lineage and must be handled by their own owners.

Ephemeral scratch residue that was created and later cleaned cannot be fully
reconstructed from current `main`. The attached audit is complete for landed
tracked churn and current dirty-state evidence, but not for already-cleaned
transient residue.

## Final Recommendation

Use one parent program with child packets. The nine core child packets are:

- `proposal-churn-common-generator-idempotency-metrics`
- `proposal-churn-run-health-read-model-compaction`
- `proposal-churn-effective-publication-idempotency`
- `proposal-churn-extension-payload-compaction`
- `proposal-churn-filesystem-snapshot-retention`
- `proposal-churn-proposal-artifact-compaction`
- `proposal-churn-receipt-fanout-compaction`
- `proposal-churn-host-projection-idempotency`
- `proposal-churn-tmp-engine-cache-hygiene`

External dependencies are referenced but not duplicated:

- `run-program-clean-delivery-test-hermeticity`
- `run-program-clean-delivery-cleanup-disposition`
- `proposal-program-loop-breaker`
- `closeout-worktree-autonomous-partition-evidence`

`proposal-churn-retained-run-evidence-efficiency` is optional adjacent
operational-efficiency work. It is in the program registry as deferred and not
required for core generated/projection churn reduction.
