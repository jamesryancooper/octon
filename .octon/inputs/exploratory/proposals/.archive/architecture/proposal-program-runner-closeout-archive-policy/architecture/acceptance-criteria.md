# Acceptance Criteria

- Parent closeout reads and enforces the active `program.closeout_policy` from the lifecycle contract.
- The current authored policy requires non-deferred child outcomes of `archived` or `rejected`; implemented child status alone is insufficient unless a future active policy explicitly allows it.
- Archived child outcomes require passing `implementation-run`, `implementation-conformance`, `post-implementation-drift`, and `proposal-closeout` receipts with `proposal-closeout.archive_authorized: yes`; rejected outcomes require rejected review evidence.
- Child `archive-proposal` workflow routes run before parent terminal closeout when child closeout authorizes archive and the active policy requires archived child terminal outcomes.
- Parent archive mutation is delegated only through workflow-owned `archive-proposal`; blocked closeout/archive receipts are machine-readable.

## Negative Criteria

- Do not hard-code child archival as a universal prerequisite across all policies.
- Do not loosen the current authored closeout policy.
- Do not let closeout-program or closeout-packet own Git cleanup, repo-hygiene deletion, branch cleanup, hosted landing, archive mutation, or generated-state mutation outside their declared route boundary.

## Terminal Criteria

- Child implementation evidence exists only after a later
  `run-packet-implementation` route.
- Child promotion is workflow-owned by `promote-proposal` and cannot be claimed
  by parent program evidence.
- Child closeout and archive remain child-owned and route-gated.
