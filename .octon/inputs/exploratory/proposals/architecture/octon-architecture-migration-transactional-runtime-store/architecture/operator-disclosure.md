# Operator Disclosure

## What Changes After Future RP-03 Implementation

- Consequential runtime state moves from many writable files and journal
  append sequences into one embedded SQLite/WAL store.
- Legacy runtime files remain only where a read-only projection, export, or
  payload pointer is genuinely needed.
- Crash recovery exposes explicit operation/attempt states, including
  `UNKNOWN`, instead of silently retrying or inferring success.
- Backups and restore are certified against schema, epoch/high-water,
  integrity, and accepted ROD-001 recovery invariants.

## Normal Solo-Builder Experience

There is no database ceremony in routine work. The local runtime opens and
maintains the store, applies reviewed migrations, reserves terminal headroom,
and emits only needed projections. The operator does not edit SQL, WAL, or
legacy state files and is not prompted for normal transactions, checkpoints,
or backups.

Healthy status is concise. A problem reports whether the store is unavailable,
capacity-constrained, corrupt, behind the monotonic high-water, or waiting on
external reconciliation, plus one safe next action. Detailed migration and
fault evidence remains available for diagnosis.

## Accepted Risk Invariants And Defaulted Configuration

ROD-001 is accepted: bounded local raw evidence stays outside project Git;
longer-lived signed receipts, checkpoints, and rollback references are retained;
terminal reserve and no unsigned fallback remain mandatory; and unavailable or
uncertain recovery evidence denies the dependent transition while preserving
work. No additional operator disposition remains. Engineering selects the
store path, backup mechanism, and provisional cadence,
generations, and physical reserve using conservative reversible defaults. The
recommended initial configuration is local platform application data, bounded
local raw evidence, preallocated terminal headroom, and certified backups,
measured and adjusted without weakening fail-closed behavior.

## Failure Experience

When the store or reserve is unsafe, Octon stops consequential transitions and
preserves candidate work. It does not fall back to writable YAML, a second
journal, an old database, ambient credentials, or blind retry. Safe read-only
inspection may remain available. Protected PR appears only through a fresh
valid pre-effect RP-06 decision, never because storage is unavailable or an
attempt is `ATTEMPTING`/`UNKNOWN`.

## What This Packet Does Not Provide

RP-03 does not install the broker, custody credentials, execute a privileged
provider effect, classify a Git/GitHub outcome, decide retries, sign evidence,
set retention windows, publish autonomously, or prove full Class B recovery.
RP-04, RP-07, and RP-08 retain those responsibilities. It also does not create
a project metadata database, remote database service, ORM control plane, or
second journal.
