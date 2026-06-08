# Packet Sequence

1. `proposal-program-runner-terminal-gap-map`
2. `proposal-program-runner-workflow-retry-ids`
3. `proposal-program-runner-change-handoff-checkpoints`
4. `proposal-program-runner-aggregate-terminal-blockers`
5. `proposal-program-runner-promotion-evidence-binding`
6. `proposal-program-runner-publication-freshness-preflight`
7. `proposal-program-runner-parent-review-churn`
8. `proposal-program-runner-archive-observation-recovery`
9. `proposal-program-runner-terminal-routing-tests`

The gap map gates implementation. Workflow retry, change handoff, aggregate
blockers, promotion evidence binding, publication freshness, review freshness,
and archive observation can proceed after the gap map. The tests packet depends
on all behavior packets.

The current registry path for `proposal-program-runner-change-handoff-checkpoints`
is the child-owned archive packet path. This parent sequence preserves the
original ordering while using the registry path for lookup only; it does not
replace child-owned receipts, archive metadata, validation verdicts, promotion
targets, or terminal outcomes.
