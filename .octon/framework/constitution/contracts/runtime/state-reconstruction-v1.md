# State Reconstruction v1

`runtime-state.yml` and other mutable run-control files are derived views over
the canonical run event ledger plus bounded side artifacts.

## Reconstruction Rule

For a packet-normalized certification run:

1. Read `events.ndjson` in recorded order.
2. Apply the latest event listed in `events.manifest.yml` for each mutable
   surface under `governing_event_refs`.
3. Use the matching side artifact when an event points at a concrete file such
   as:
   - `checkpoints/**`
   - `rollback-posture.yml`
   - `authority/**`
   - `state/evidence/runs/<run-id>/**`
4. Reconstruct the final execution state from:
   - authority-request / grant / denial events
   - lease / revocation events
   - stage / attempt events
   - checkpoint events
   - intervention events
   - disclosure / close events

## Non-Canonical Inputs

The following are explicitly non-canonical for reconstruction:

- chat continuity
- operator memory
- host UI state
- generated summaries

If any reconstructed fact conflicts with a mutable file, the event ledger wins
and the mismatch is a drift incident.
