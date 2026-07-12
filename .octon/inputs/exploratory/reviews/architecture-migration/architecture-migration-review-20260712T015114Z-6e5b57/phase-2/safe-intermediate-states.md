# Safe Intermediate States

## Permitted

1. Claim-corrected, provider-write-disabled baseline with manual/protected PR
   publication only.
2. Canonical launch guard active while legacy lifecycle authority fields
   remain visible but cannot authorize.
3. Isolated candidate dark launch while current executor remains disabled for
   privileged work.
4. SQLite import rehearsal against immutable snapshots before cutover.
5. Atomic store cutover where legacy files become read-only projections in the
   same release.
6. Broker supports only one exact Git effect; every other durable effect is
   denied or manual.
7. Sanitized Git adapter available while no-PR remains disabled.
8. Independent verifier active in observation-only shadow mode before its
   verdict is required.
9. Brokered no-PR feature flag off while PR is the only publication route.
10. Signed evidence coexists with clearly labelled unsigned legacy evidence.
11. Trust-root versions may land inert before activation automation exists.
12. Workspace Project may reference the existing Project Profile during
   migration.
13. Existing extension bundles may remain stage-only until signed and pinned.

## Prohibited

- Two authority issuers or two writable runtime sources of truth.
- Dual writes to file state and SQLite.
- Candidate credentials during any broker migration stage.
- Candidate-controlled code under provider write credentials.
- Broker credentials in the launcher, model process, environment, checkout,
  logs, or evidence.
- Publication without exact source, exact target pre-state, expiry,
  revocation, rollback, and independent verifier binding.
- Autonomous direct-main as fallback.
- Unsanitized privileged Git even for temporary no-PR use.
- A GitHub worker acting as its own authority, ledger, or reconciliation
  source.
- Trust activation before previous-version verification and executable
  rollback exist.
- Compaction before a verified signed checkpoint and retention pin decision.
- A support claim stronger than current executed proof.

## Bridge expiry

Each compatibility bridge has an owner, removal gate, and release deadline in
its proposal packet. A bridge that reaches its deadline without proof fails
closed; it is never silently made permanent.

