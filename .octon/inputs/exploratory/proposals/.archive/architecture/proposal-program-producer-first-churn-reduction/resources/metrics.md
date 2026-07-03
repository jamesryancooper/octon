# Churn Metrics

Every implemented child must report the metrics it can measure before and
after the producer change.

| Metric | Purpose | Required evidence |
| --- | --- | --- |
| Changed file count | Prove generated and projected diffs scale with changed inputs. | Baseline and post-change `git diff --name-status` or equivalent scoped count. |
| Generated no-op rewrite rate | Prove unchanged inputs do not rewrite derived outputs. | No-op producer invocation with zero tracked diffs or documented allowed exceptions. |
| Receipt fanout count | Measure timestamped validation/publication receipt growth. | Count of new receipts per representative validation/publication run. |
| Dirty-worktree residue count | Measure local residue after validation, closeout, and publication. | Scoped `git status --short` and ignored/untracked residue report. |
| `.tmp` byte/file count | Bound local scratch and engine build/cache output. | File count and byte count before and after lifecycle runs. |
| Process runtime | Prove producer changes reduce or at least do not materially worsen runtime. | Command timing for representative producer and validation paths. |
| Token budget impact | Estimate reduced review and closeout context cost from smaller diffs and receipts. | Diff line counts, generated-file counts, and summarized token estimate. |
| Validation coverage retained | Prove compaction did not remove meaningful validation. | Validator list and pass/fail evidence before and after change. |
| Freshness/lock/receipt validation retained | Prove runtime-facing effective guarantees remain live. | Freshness, lock, receipt, resolver, and negative-control validation evidence. |
| Evidence retrieval integrity | Prove compacted retained evidence remains discoverable. | Reference-integrity check from index/latest pointer to retained full proof. |
