# Safety Gate Matrix

| Gate | Canonical input | Block condition | Output |
| --- | --- | --- | --- |
| Lease | `state/control/execution/missions/<mission-id>/lease.yml` | absent, expired, paused, revoked, out of scope | pause/escalate |
| Budget | `state/control/execution/missions/<mission-id>/autonomy-budget.yml` | exhausted; warning per policy | pause/escalate/narrow |
| Breaker | `state/control/execution/missions/<mission-id>/circuit-breakers.yml` | tripped or latched | pause/escalate/reset request |
| Context | context pack receipt + profile/work/support/capability refs | stale, invalid, drifted | rebuild/stage/block |
| Support | support targets + envelope | unadmitted/stale/unsupported | stage/deny/escalate |
| Capability | pack registry + posture | unadmitted/unsupported/drifted | stage/deny/escalate |
| Connector | connector/admission records | schema/egress/credential/capability/evidence/rollback drift | block operation |
| Rollback | rollback posture | missing/invalid | decision or deny |
| Progress | queue + run history | repeated failure/churn/unreachable | pause/escalate/fail |
| Closeout | runs + evidence + queue + decisions | unresolved runs/evidence/blockers | deny closeout |
