# Cutover Plan

## Preconditions

- RP-03, RP-04, and RP-06 have exited with frozen exact interfaces and retained
  dependency receipts.
- Accepted ROD-001 invariants are bound before cutover. The cutover separately
  binds proved engineering choices for signer,
  monotonic anchor, reserve implementation, backup mechanism, and provisional
  values.
- This packet is accepted and its strict pre-integration architecture review
  passes at a stable digest.
- Every current evidence/checkpoint writer and cryptographic claim is
  inventoried; shared entries/modules have exclusive integration ownership.
- UE-008 fixtures and an isolated constrained-volume environment are ready.

## Safe Intermediate States

1. **Contracts inert:** schemas and policy validate, but no live signer or
   consumer uses them; autonomous publication remains disabled.
2. **Shadow signing:** broker/verifier adapters sign duplicate observations to
   isolated evidence; live success still uses no new claim and shadow output
   cannot authorize.
3. **Checkpoint no-delete:** signed checkpoints and head advancement run, but
   raw evidence is never deleted and autonomous publication remains disabled.
4. **Reserve deny-only:** logical/physical reserves gate admission in fixtures;
   failure can only reduce autonomy and preserve candidate work.
5. **Compaction rehearsal:** verify/checkpoint/anchor runs against copied raw
   data; delete is disabled until every crash/pin/rollback fixture passes.
6. **Atomic activation:** signature verification, current monotonic head,
   reserve sufficiency, bounded retention, and dependent success/publication
   checks activate together.

## Prohibited Intermediate States

- unsigned and signed observations are both accepted for live success;
- a DB-local or Git head is treated as monotonic while the candidate can roll
  it back;
- logical capacity is live without fault-proven physical terminal reserve;
- raw deletion begins before independent checkpoint verification and durable
  anchor/receipt commit;
- candidate, broker, and verifier share or can access the same private key;
- a second canonical NDJSON/runtime_bus/replay-store truth survives beside the
  RP-03 operation model;
- missing evidence routes to false success, broader authority, or routine
  operator approval; or
- raw provider/model payloads are committed as a convenience bridge.

## Activation Sequence

1. Freeze dependency digests and ROD-001 policy.
2. Publish strict contracts/policies and validate all current/negative
   fixtures.
3. Provision separate protected identities and candidate-inaccessible anchor;
   retain public metadata only.
4. Allocate/verify physical reserve and bind RP-03 logical size classes.
5. Run shadow signatures, signed range/terminal checkpoints, and head advance.
6. Complete UE-008 forgery, rollback, compaction, pin, and low-space proof.
7. Activate all live gates atomically and disable unsigned success/publication.
8. Run a representative Class B dry-run with publication disabled, then hand
   the frozen contract to RP-08.
9. Remove duplicate writers/claims and begin bounded 30-day burden evidence.

## Completion Evidence

The activation receipt binds dependency digests, policy digest, public signer
identities/epochs, anchor identity/current head, reserve allocation/check,
quota/pin policy, proof results, retired paths, candidate preservation, and
rollback rehearsal. It contains no private key or sensitive raw payload.
