# Rollback And Recovery

## Rollback Objective

Rollback preserves one authority source, one store writer, one broker,
credentialless candidates, candidate work, and protected PR. It never restores
ambient Git, autonomous direct-main, candidate credentials, or dual writers.

## Before First Scratch Effect

- Disable or remove the inactive adapter.
- Remove broker-owned fixture Git state after retaining required test evidence.
- Leave current production mutation disabled or protected-PR-only.
- No external reconciliation is required because no effect was attempted.

## After A Known Scratch Success Or Denial

- Persist the result through the RP-03/RP-04 interface.
- Revoke or remove the scratch credential.
- Disable the adapter route.
- Preserve candidate commits and provider observations.
- Restore only a previously certified adapter behind the same broker boundary
  if rollback requires continued fixture testing.

## After An Unknown Outcome

- Do not repeat the effect.
- Preserve operation, attempt, expected-old, proposed-new, repository, ref,
  send boundary, and all observations.
- Ask the read-only observer for current target state.
- Report state satisfied separately from attempt performed.
- Hand the unresolved classification to RP-08 reconciliation.
- End in honest manual intervention if attribution cannot be resolved.

## Provider Or Network Failure

The adapter blocks only the remote transition. Candidate work and safe Class A
activity continue. The operator sees a concise blocked or reconciling status.
There is no fallback to an ambient credential or weaker Git command.

## Broker Failure

RP-04 supervision restarts the broker. Restart scans durable attempting or
unknown operations before dispatch. The adapter receives no new attempt until
RP-08 reconciliation permits one.

## Corrupt Broker Git State

- Quarantine the broker-owned Git state.
- Rebuild a fresh minimal repository from pinned provider identity and exact
  verified objects.
- Revalidate ancestry and request binding.
- Do not reuse candidate repository config or canonical working-tree state.

## Rollback Evidence

Retain adapter version, credential disposition, affected scratch refs,
operation/attempt identities, before/after provider observations, unknown
classification, candidate preservation proof, direct-writer inventory, and
the exact route-disable action.

## Recovery Success

Recovery succeeds only when the target is unchanged, the exact proposed-new
state is safely reconciled, or the operation ends in explicit manual
intervention with no retry. A guessed success or failure is invalid.
