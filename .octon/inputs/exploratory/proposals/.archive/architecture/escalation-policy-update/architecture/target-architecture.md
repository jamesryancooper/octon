# Target Architecture

Routine-autonomous issues are repaired and validated without operator
escalation. Soft blockers use bounded retries, repair, refresh, or delegated
cleanup before escalation.

Hard blockers remain:

- destructive action without cleanup authority or explicit approval;
- ambiguous ownership;
- missing child-owned authority or child receipts;
- parent summaries as the only proof of child state;
- unsupported scope expansion;
- external permission, provider, or human-review requirements;
- validation failures that cannot be safely repaired within declared scope.
