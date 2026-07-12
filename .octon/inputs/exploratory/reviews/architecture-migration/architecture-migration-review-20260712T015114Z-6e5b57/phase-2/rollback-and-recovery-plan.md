# Rollback and Recovery Plan

## General rules

- Preserve candidate work and exact source SHA before any privileged attempt.
- Roll back code/config by version; repair committed effect state forward.
- Never resurrect consumed/revoked grants or restore ambient credentials.
- Never fall back from broker/verifier failure to direct-main or unsanitized
  Git.
- Every rollback emits signed reason, previous/current version, operation ID,
  affected state, and operator action if any.

## Per-stage recovery

| Stage | Failure | Recovery | Proof |
|---|---|---|---|
| Containment | PR automation disabled unexpectedly | Manual protected PR, candidate branch preserved | No provider write from candidate |
| Guard cutover | Guard integration blocks safe work | Disable affected executor; keep stage-only planning | Unguarded launch remains impossible |
| Isolation | Sandbox cannot run tool | Preserve isolated repo and logs; route to manual intervention | Host/canonical state unchanged |
| Store migration rehearsal | Import mismatch | Discard rehearsal DB; source snapshots unchanged | Deterministic re-import digest |
| Store cutover | Health failure before first effect | Restore prior release and immutable pre-cutover files | No dual-writer interval |
| Store after effect | Process crash/corruption | Restore DB backup/WAL, reconcile operation IDs; forward repair | Backup/restore and terminal convergence |
| Broker | Crash before send | Reserved/attempt state resumes safely | No provider effect observed |
| Broker | Timeout after send | Mark unknown; verifier/provider observation reconciles | No retry until outcome classified |
| Git adapter | Target moved | Deny operation; reauthorize/reclassify | Target-pre mismatch retained |
| Verifier | Unavailable or conflicting results | Block publication only; preserve candidate and Class A | No accepted unsigned fallback |
| No-PR publication | Provider rejects | Preserve/push candidate only if broker-authorized; select PR by policy | No direct-main conversion |
| Evidence | Low disk | Stop new privileged operations; retain reserved terminal capacity | Denial/failure/rollback receipt survives |
| Compaction | Checkpoint verification fails | Abort compaction; retain raw evidence | No unverifiable deletion |
| Trust activation | Any stage unhealthy | Restore previous active pointer/version automatically | Exact old/new/rollback terminal receipt |
| Project/harness | Migration mismatch | Keep project disabled; recompile from canonical inputs | No stale manifest launch |
| Extension | Signature/revocation failure | Quarantine and restore previous generation | Exact last-known-good digest |

## Unknown external outcomes

An attempt that may have reached the provider enters unknown. The broker does
not repeat it. Reconciliation observes exact provider identity and expected
state through the verifier, then commits succeeded, failed, denied, or
manual_intervention. A new operation is authorized only after the old one is
terminal and its idempotency/target relationship is explicit.

