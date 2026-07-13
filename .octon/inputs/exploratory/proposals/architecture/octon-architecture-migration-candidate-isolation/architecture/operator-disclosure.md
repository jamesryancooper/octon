# Operator Disclosure

## What Changes After Future RP-02 Implementation

- Primary-provider candidate work runs in a disposable independent repository
  under a native macOS boundary instead of the canonical repository.
- The candidate receives a fresh HOME, a small explicit environment, closed
  inherited descriptors, bounded process/filesystem/network access, and a
  provider-native session that does not expose durable credentials.
- The only artifact leaving the boundary is the exact candidate commit and
  evidence needed for a manual/protected-PR route; trusted code does not
  execute candidate-controlled Git extensions during export.

## Normal Solo-Builder Experience

For an admitted tuple, isolation is automatic. The operator supplies the task,
not a sandbox profile, temporary HOME, repository clone recipe, FD list,
credential copy, or cleanup ceremony. Normal status shows the task outcome,
the candidate commit, whether export succeeded, and one concise recovery route.
Detailed canary and sandbox evidence remains available for diagnosis.

No standing daemon, VM fleet, Linux environment, privileged broker, new
database, or per-command approval loop is introduced by RP-02. Provider
enrollment remains outside the candidate boundary and outside this packet.

## Failure Experience

If the exact macOS/provider/session/profile tuple is unsupported, stale, or
fails proof, Octon does not silently fall back to ambient execution. It stops,
preserves or exports the exact safe candidate commit when available, and
offers manual/protected PR with one reason. Cleanup uncertainty causes
quarantine rather than reuse.

## Support Claim

RP-02 can support only the exact primary-provider native macOS tuple that
passes UE-003 and PG-02-MACOS-ISOLATION. A passing positive task without the
negative matrix is insufficient; a passing negative matrix without useful
provider work is also insufficient. Secondary providers, new client or OS
versions, Linux, VMs, and native Windows remain unsupported until separately
admitted and proved.

## What This Packet Does Not Provide

RP-02 does not create authority or guards, custody credentials, expose broker
IPC, perform privileged provider effects, sanitize privileged Git commands,
verify immutable attestations, publish autonomously, or define the generic
adapter contract. RP-01, RP-04, RP-05/RP-06, and RP-11 retain those respective
responsibilities.
