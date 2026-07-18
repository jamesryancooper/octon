# Rollback and Recovery

## Principle

Rollback disables automated candidate launch and preserves or exports the
exact candidate commit when safe. It may not restore ambient credentials,
canonical repository execution, linked-worktree isolation, inherited HOME or
FDs, broad egress, broker IPC, or an unproved provider/session tuple.

## Prepared Rollback Handles

- immutable source and contract snapshots for every promoted target;
- a default-disabled isolation feature binding with one operator-visible stop;
- exact candidate repository, common-directory, object-store, and commit IDs;
- a non-executing commit-export procedure and route-neutral
  candidate-preservation destination/handle;
- one-run relay bearer revoke/expiry handle and relay shutdown handle without
  retained upstream authentication;
- process-group cancellation and descendant census;
- workspace/HOME quarantine and deterministic cleanup procedure;
- pinned sandbox profile and pre-cutover provider/client/macOS observations.

## Recovery by Failure Class

| Failure | Recovery |
| --- | --- |
| Isolation preparation or native policy fails | Do not launch the provider client; quarantine partial roots, record the denial, and keep automation disabled. |
| Exact client, upstream transport, relay, or one-run capability is unavailable or expires | Stop or do not start the candidate, atomically revoke/retire the relay, preserve non-secret work, and report the blocked isolation route; never inject a durable token, use direct provider egress, or select PR as recovery. |
| Candidate reaches the provider directly or a non-relay loopback listener | Treat the network boundary as compromised, revoke the bearer, terminate the process group and relay, quarantine all state, and block the exact tuple. |
| Credential, canonical Git, host, process, FD, IPC, or network canary succeeds | Treat the boundary as compromised, terminate the full process group, revoke/expire the session, quarantine all artifacts, preserve forensic digests without secrets, and block the tuple. |
| Useful task fails while negative probes pass | Record UE-003 as unresolved, keep the route unsupported, preserve safe candidate output if identifiable, and revise the engineering mechanism. |
| Candidate repository is linked to canonical state | Reject the run before provider launch when possible; otherwise terminate and quarantine it. Re-materialize an independent repository from the bound baseline. |
| Exact commit export is missing, ambiguous, or replaced | Do not import anything. Retain candidate state under quarantine, recompute identities through non-executing inspection, or route to manual recovery. |
| Cleanup or descendant termination is uncertain | Quarantine rather than reuse the HOME/workspace/session identity, keep automation disabled, and require operator-visible cleanup recovery. |
| Contract or integration regression appears after cutover | Disable automated launch, preserve/export exact candidate commits, revert only the faulty RP-02 binding, and repair forward behind the RP-01 guard seam. |

## Rollback Drill

A disposable drill must interrupt execution before session attachment, during
the useful task, during commit creation, during export, and during cleanup. At
every stop it must prove:

- no durable credential became candidate-readable;
- canonical Git and undeclared host paths were neither read nor mutated;
- the one-run bearer is revoked, the relay and candidate process group are
  terminated or quarantined, and no upstream authentication is retained;
- the workspace, HOME, repository, and temporary identity are never reused;
- an exact candidate commit is preserved/exported when one safely exists;
- any later publication requires a fresh RP-06 route decision; protected PR is
  available only when its valid review predicate selects it;
- no RP-04 broker, VM, Linux-production, or second control plane is required.

Any uncertainty is a failed drill. Recovery stays fail-closed and returns the
system to RP-00 containment or SI-02-disabled posture.
