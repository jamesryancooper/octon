# Rollback and Recovery

## Principle

Rollback never re-promotes YAML/JSON/NDJSON files, a stale projection, or an
older database directly to live authority. Consequential effects remain
disabled whenever store, WAL, epoch/high-water, capacity, backup, or external
outcome is uncertain.

## Prepared Handles

- exact immutable legacy-source digest bundle and import/parity receipt;
- immutable certified database/WAL cutover snapshot before first effect;
- candidate-inaccessible activation epoch and high-water observation;
- ordered migration checksums and SQLite library/engine/compile-option identity;
- consistent backup generations satisfying the ROD-001 objective;
- offline integrity, foreign-key, application-invariant, and projection checks;
- writer-disable switch, process/connection census, and protected recovery
  instructions; and
- generic operation/attempt/outbox/UNKNOWN export for later reconciliation.

## Before the First Consequential Effect

If activation or parity fails before any effect in the new epoch, disable the
writer and restore the immutable certified cutover DB/WAL snapshot at the same
epoch/high-water. Re-run full certification before reactivation. Legacy files
remain import evidence or projections and are never made writable authority.

## After the First Consequential Effect

An older snapshot cannot be activated directly. Keep effects disabled and:

1. observe the current database/WAL and candidate-inaccessible epoch/high-water;
2. recover the newest crash-consistent certified state if it is not behind;
3. enumerate every `ATTEMPTING`, `UNKNOWN`, unacknowledged outbox, and terminal
   obligation crossing the recovery boundary;
4. hand provider-specific observations to RP-08 reconciliation when available;
5. revoke uncertain authority or advance the epoch/high-water before resuming;
   and
6. repair forward when no certified non-resurrecting restore exists.

## Recovery by Failure Class

| Failure | Recovery |
| --- | --- |
| Store cannot open, wrong engine/options, or schema mismatch | Keep effects disabled, open offline/read-only when safe, validate exact dependency/schema identity, and migrate or repair through the trusted route. |
| WAL missing, truncated, corrupt, or inconsistent | Do not delete or recreate it opportunistically. Preserve forensic copies, use SQLite-consistent recovery/integrity tools, and certify recovered high-water before activation. |
| Disk full or terminal reserve unavailable | Deny new T1 before consumption/send; use reserved headroom for the required terminal record, then free governed non-authoritative/raw capacity or expand through ROD-001 policy. |
| T1 acknowledgement lost | Reopen by operation/idempotency identity; the committed row decides. Never create a second attempt speculatively. |
| External response lost or T2 fails | Persist or reconstruct `UNKNOWN`, block retry, preserve the attempt identity, and hand outcome classification to RP-08. |
| Outbox delivery uncertain | Reclaim by durable outbox identity and acknowledgement state; duplicate delivery must be idempotent and cannot repeat the external effect. |
| Migration/import mismatch | Do not activate. Correct mapping or source disposition offline and repeat from the exact frozen baseline. |
| Projection stale or malformed | Regenerate from the store after source validation; never write the projection back. |
| Backup restore is older than high-water | Reject activation, preserve it as recovery evidence, and use a newer certified generation or forward repair with epoch advance. |
| Multiple write-capable identities discovered | Disable all consequential writes, preserve state, revoke access to all but the admitted identity, rerun census and race proof, then reactivate through review. |

## Rollback Drill

The drill covers before/after activation, before/after first effect, every T1,
external, T2, outbox, checkpoint, backup, and projection boundary. It must show
one explicit durable state, no duplicate attempt, no authority resurrection,
terminal evidence survival, read-only projections, and recovery within the
ROD-001 objective. Any uncertainty fails the drill and leaves effects disabled.
