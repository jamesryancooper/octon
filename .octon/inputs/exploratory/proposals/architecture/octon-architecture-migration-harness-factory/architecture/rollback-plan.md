# Rollback Plan

## Prepared Before Cutover

- retain exact dependency interface versions and the last certified legacy
  route-input set as non-authoritative read-only data;
- retain every immutable project, mission, run, policy, extension, context,
  tool, validation, evidence, and rollback source referenced by an attempt;
- capture compiler/schema/precedence/adapter registry versions and digests;
- preserve candidate work and bounded compile/launch/conformance receipts;
- provide one disable control for the Factory/generic-adapter launch path that
  cannot enable direct provider dispatch; and
- prove existing canonical protected/manual recovery remains available without
  treating legacy executor selection as authority.

## Rollback by Stage

| Stage | Action | Preserved data |
| --- | --- | --- |
| Inert contracts | Stop schema activation or repair mirrors; no runtime dispatch changed. | Contract diff, live manifests, legacy read-only route inputs |
| Shadow compiler | Disable compile invocation and retain mismatch evidence. | All immutable sources, canonical bytes/digests, candidates |
| Bound/launch-disabled | Remove the new binding consumer only through the certified prior version; keep autonomous launch disabled. | Authorization/guard records, source manifests, receipts |
| Adapter conformance | Unregister test/primary launch capability and keep direct provider dispatch disabled. | Provider observations, fake/primary conformance evidence |
| Post-cutover defect | Disable all Factory/adapter launches; preserve candidates and require existing protected/manual route until repair-forward or certified rollback is installed. | Immutable inputs, candidates, exact attempted binding, unknown outcome evidence |

## Recovery Procedures

- On a compile mismatch, enumerate the first differing source identity/digest,
  preserve both manifests, and recompile only after the canonical source owner
  resolves the drift.
- On a source change after authorization, deny spawn, leave the one-shot guard
  unconsumed where RP-01 semantics permit, and require a fresh compile and
  authorization.
- On ambiguous guard consumption or provider launch, report unknown and defer
  reconciliation to existing/RP-08 recovery semantics; do not retry directly.
- On adapter schema/registry drift, disable only the affected adapter, preserve
  prepared/session identifiers, and revalidate before any fresh attempt.
- On cancel or retirement failure, retain the provider observation and residual
  handle, block reuse, and hand off to the owning reconciler.
- On missing generated route/effective data, regenerate from immutable sources
  through its canonical owner; never reconstruct authority from a receipt.

## No-Fallback Rule

Rollback can reduce automation to no autonomous launch and use the existing
protected/manual recovery route. It cannot restore provider-name matching,
call Codex/Claude directly, accept a partial/global route bundle as the full
Harness, create another runtime, or silently use an unclaimed secondary.

## Rollback Invariant

Rollback preserves candidate work, immutable inputs, authority/guard truth,
and honest unknown outcomes. It may disable compilation or provider execution;
it may not widen authority, rewrite evidence, duplicate dispatch, or absorb
RP-06/RP-08/RP-13 semantics.
