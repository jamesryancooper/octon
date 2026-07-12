# Minimum Proof of Architecture

## Executable slice

credentialless isolated candidate environment
→ canonical one-shot launch guard
→ local SQLite/WAL operation reservation and evidence capacity
→ separate broker with keychain credential
→ sanitized exact Git branch effect
→ candidate-immutable exact-SHA verifier
→ verified no-PR Class B fast-forward landing
→ signed broker and verifier receipts
→ crash, replay, revocation, target-race, and unknown-outcome reconciliation

## Scenario

A fixed Class B fixture repository starts at target SHA T0. authority_engine
authorizes candidate source SHA S1 for one exact transition T0 to S1. A Codex
candidate runs in the supported macOS isolation profile and cannot reach
credentials or canonical Git state. It produces S1 in an independent Git
database. The broker imports/verifies the exact object, reserves capacity,
performs a sanitized fast-forward compare-and-swap, and records its signed
observation. The independent verifier observes main at S1, exact required
validation, policy identity, and T0/S1 binding and emits a signed verdict.
Closeout succeeds only after both signatures and terminal reconciliation.

## Required test matrix

- missing, forged, stale, revoked, wrong-scope, wrong-route, wrong-harness, and
  replayed authority;
- concurrent launch and effect consumption;
- environment, HOME, keychain, SSH, GitHub, Git, filesystem, process, network,
  and common-Git-state escape probes;
- hooks, helpers, includes, filters, drivers, fsmonitor, aliases, submodules,
  protocols, LFS, and transport injection;
- target movement before/during effect;
- broker/verifier/store crash at every durable boundary;
- timeout after provider acceptance and delayed observation;
- duplicate operation/workflow/check context;
- wrong signer, evidence rechain, old snapshot, missing terminal result;
- low space and compaction interruption;
- PR escalation fixtures for higher consequence and uncertainty.

## Acceptance

- No candidate process can access or use a durable credential.
- Every launch and effect is bound to one consumed exact operation.
- Exactly one provider transition occurs or no transition occurs.
- Unknown outcomes reconcile without duplicate effect.
- Success is impossible without direct-observer signed broker and verifier
  results.
- Failure preserves candidate work and produces an actionable terminal state.
- The operator completes the scenario without routine prompts.

## Non-goals

Trust-root activation, remote GitHub effect worker, multi-provider portability,
Linux production support, arbitrary external effects, signed extension
catalog, broad Workspace Project UI, federation, enterprise identity, public
marketplace, VMs, distributed state, and every Octon command are excluded from
the minimum proof.

## Promotion consequence

Passing this proof admits the architecture to the next proposal gate; it does
not by itself authorize production trust claims, trust-root activation, or
unbounded external effects.

