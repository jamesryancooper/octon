# Rollback and Recovery Plan

> Non-authoritative. Per-packet rollback and the runtime recovery model the target
> requires. "Rollback" here = reverting a migration packet; "recovery" = runtime
> crash/fault handling the packets add.

## Part A — Migration packet rollback

Every packet must be revertable to the prior safe intermediate state (S1–S9)
without leaving a prohibited state.

| Packet | Rollback action | Post-rollback state | Risk if rolled back |
|---|---|---|---|
| PP-00 claims | Revert wording changes | Honest→prior wording | Low (docs only) |
| PP-01 launch guard | Feature-flag the guard to log-only; agent path reverts to DelegationProof | HEAD authority behavior | Re-opens GAP-01 (accept only transiently) |
| PP-02 isolation | Disable sandbox wrapper; keep env_clear | env scrubbed, no sandbox | Partial GAP-03 re-open |
| PP-03 store | SQLite reverts to read-through of YAML (YAML re-promoted) | Single writer preserved | Must not run both writable |
| PP-04 broker | Broker denies all; effects blocked (fail-closed) NOT reverted-to-ambient | No effects, no creds leaked | Blocks durable effects (safe) |
| PP-05 git adapter | Revert to prior git calls | Unsanitized git returns | Re-opens GAP-07 (accept only transiently) |
| PP-06 verifier/publication | Force PR route for all; disable no-PR | Everything escalates to PR | Slower but safe |
| PP-07 evidence/recovery | Disable signing; keep reconciliation | Hash-anchored evidence | Claims must revert too |
| PP-08 trust activation | Freeze activation; require manual operator activation | Inert landing only | No autonomous trust activation (safe) |

**Rollback rule:** a rollback that would re-open a BLOCKER-class gap (GAP-01,
GAP-02, GAP-07, GAP-08, GAP-17) is permitted only as a transient emergency state
with the affected autonomous path disabled — never as a resting state.

## Part B — Runtime recovery model (what the packets must implement)

The target's recovery correctness (FD-005, FD-012, FD-013, FD-016) rests on the
transactional store (PP-03) and reconciliation (PP-07). Required behaviors:

1. **Atomic reserve→consume→commit.** Effect tokens consumed via transactional CAS
   (`UPDATE ... WHERE status<>'consumed'`); records written temp+fsync+rename.
   *(Closes D-02/D-03/J-04.)*
2. **Attempt lifecycle.** `pending` recorded before any external effect; terminal
   outcome after. On restart every `pending` is reconciled to a terminal state
   before any retry. *(Closes D-05.)*
3. **Idempotent reconcile probes.** For git push/land: `git ls-remote` against the
   pinned target to determine whether the ref landed; retries keyed by
   idempotency_key. *(Closes D-06.)*
4. **Crash ordering.** Terminal-evidence writes (denial/failure/revocation/rollback/
   closeout) reserved first so near-full storage still records them. *(Closes
   D-04/E-04.)*
5. **Revocation races.** Revocation checked inside the same transaction as consume;
   a revoked grant cannot be consumed even under concurrency.
6. **Narrow degraded operation.** On a dependency outage, block only the affected
   consequential transition; preserve candidate work and safe Class A progress;
   never surface ambient credentials (now enforceable because the broker holds
   them). *(Preserves B-08 strength; closes its vacuous half.)*
7. **Terminal-state recovery.** Every run reaches exactly one terminal state; a
   killed run resumes to a terminal state or a clean blocked state, never a torn one.

## Part C — Trust-root activation rollback (FD-018)

The strictest recovery path. Every activation fault must end in one of:
- **old version healthy** (activation never took effect), or
- **new version healthy** (activation completed and verified), or
- **automatic rollback to old version** (activation failed mid-flight).

Never: partially-activated, self-widened, or a state where the candidate changed
its own verification/activation/rollback rules. Requires: previous-version
verifier (signed or out-of-tree), retained rollback handle, exact-version pin, and
staged (canary/soak) activation. *(Closes GAP-14; F-018-1/2.)*

## Acceptance

- Fault injection at every transition (PP-07 test harness) never repeats or loses a
  supported effect.
- A SIGKILL at each of: pre-reserve, post-reserve/pre-effect, post-effect/pre-record,
  post-record — each resolves to a correct terminal state on restart.
- A trust-root activation fault at each stage resolves to one of the three allowed
  end states above.
