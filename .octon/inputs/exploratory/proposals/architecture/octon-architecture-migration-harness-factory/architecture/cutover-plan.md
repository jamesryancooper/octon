# Cutover Plan

## Cutover Profile

- release state: `pre-1.0`
- change profile: `atomic`
- atomic mode: clean break after bounded inert/shadow evidence stages

The evidence stages are not dual authority or dual dispatch. Legacy route and
executor inputs remain read-only comparison data while autonomous launch on the
new path stays disabled.

## Stage 0 — Admission and Freeze

Verify RP-01/RP-02/RP-10 exit receipts, inventory every compiler and provider
call path, bind exact shared symbol/entry ownership, and deny implementation if
the frozen authority, isolation, or project interface has drifted.

## Stage 1 — Inert Strict Contracts

Publish Harness/receipt/adapter schema and registry changes. Align live
manifests without changing dispatch. Run strict negative fixtures.

Safe resting point: authored contracts are coherent; existing runtime behavior
is unchanged and no new support claim exists.

## Stage 2 — Shadow Compiler

Compile complete source/effective manifests and deterministic receipt bodies
without supplying them to authorization or launch. Compare repeated bytes and
run the entire input invalidation matrix.

Safe resting point: the Factory is a pure inactive evidence producer; legacy
route inputs remain non-authoritative comparison data.

## Stage 3 — Bound but Launch-Disabled

Add exact compiler/source/effective/adapter binding fields to the RP-01
consumer and immediate-spawn preflight while keeping new provider launch
disabled. Exercise stale/wrong/race denials and rollback.

Safe resting point: exact binding is proven without a provider effect.

## Stage 4 — Generic Adapter Conformance

Register the real primary adapter and fake test adapters behind the generic
trait. Execute all six lifecycle operations while direct live dispatch remains
disabled. Remove or deactivate unclaimed secondary routing.

Safe resting point: component conformance is proved; no live provider can yet
launch through an incompletely migrated path.

## Stage 5 — Atomic Behavioral Cutover

Activate complete compile, authorization binding, immediate pre-spawn
revalidation, guard consumption, and generic primary-adapter dispatch as one
behavioral release. Simultaneously make executor-name matching and direct
provider calls unreachable.

Safe resting point: one compiler, one authorization binding, one guarded spawn,
and one generic dispatch seam govern every live primary launch.

## Stage 6 — Compatibility Retirement

Remove legacy direct dispatch and any claim that a global route bundle alone is
the effective per-run Harness. Retain route inputs only where declared as
digested compiler sources. Refresh projections and scan durable targets for
proposal-path backreferences.

## Prohibited States

- two compilers or manifests accepted as launch identity;
- authorization bound to one digest and spawn using another;
- provider-name dispatch and generic registry dispatch both live;
- a provider or generated projection bypassing canonical authority;
- an unclaimed secondary enabled by code presence;
- a new scheduler, policy engine, authority, runtime store, or direct fallback;
- RP-11 owning verifier/publication, effect/recovery, or child behavior; and
- deletion of candidate work or immutable source records during cutover.

## Promotion Handoff

After implementation proof, RP-11 supplies PO-FD-020 and its component receipt
for PO-FD-023 to the canonical promotion route. RP-14 must independently
reproduce integrated equivalence. Proposal prose and generated manifests are
never promoted as authority.
