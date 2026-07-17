# Rollback and Recovery

Before any live run, revert the precursor commit to remove the inert boundary.
After a credential may have been issued, preserve all actual state and follow
the lifecycle envelope:

- before-send failure: terminalize the same credential; no provider mutation
  is claimed;
- terminal response: continue only if the response and post-read satisfy the
  manifest;
- outcome unknown: do not resend; perform separately authorized authoritative
  reads and reconcile the exact request digest;
- terminalization accepted: do not resubmit revocation; poll only the allowed
  identity probe until the deadline;
- absent genuine `401`, local destruction, or clean secret census: record
  `RP00-CREDENTIAL-UNRESOLVED` and block replacement, SI-00, closeout, and DAG
  continuation.

Rollback never restores an unsafe direct-main route, weakens provider
protection, fabricates evidence, or deletes the journal.
