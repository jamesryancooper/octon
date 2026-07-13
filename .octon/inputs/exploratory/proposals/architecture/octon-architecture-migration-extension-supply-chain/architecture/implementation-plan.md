# Implementation Plan

This plan describes later implementation. It does not authorize it.

## Workstream 0 — Encode Accepted ROD-004 And Freeze Dependencies

1. Record approved sources, signer/key profile and rotation/recovery,
   revocation, and capability/compatibility tolerance.
2. Verify exact RP-07 and RP-11 exit receipts/interfaces.
3. Inventory extension writers/readers and assign exact shared
   publisher/resolver symbols.
4. Keep all private/external imports denied until these gates pass.

Exit: one nonsecret trust-policy digest and no ownership ambiguity.

## Workstream 1 — Contracts and Templates

1. Add strict signed-envelope, verified-availability, import-receipt, and
   generation-transition/restore contracts.
2. Extend pack, desired config, active/quarantine, compatibility receipt,
   effective catalog, artifact map, and generation lock schemas with exact
   signer/source/payload/receipt bindings.
3. Update governance, publication handle/policy, templates, and evidence
   locations while preserving desired/actual/generated separation.
4. Make all private-origin signature/pin conditions strict and reject unknown
   fields.

Exit: schemas/templates align and unsigned external material cannot validate.

## Workstream 2 — Safe Explicit Import

1. Implement bounded staging and hostile archive rejection.
2. Canonicalize/verify envelope, source, signer, current revocation, manifest,
   payload tree, dependencies, compatibility, and requested capabilities.
3. Retain exact verified content addressably under the existing additive
   archive boundary.
4. Atomically update availability or quarantine and emit an RP-07-authentic
   import receipt.
5. Prove the import writer cannot reach desired, active/generated, Harness,
   route, capability, or execution writers.

Exit: hostile import and import-non-authority matrices pass.

## Workstream 3 — Desired Pins and Existing Publisher

1. Migrate private desired entries to exact source/version/payload pins.
2. Preserve bundled-first-party behavior behind its repository-integrity
   condition; do not grandfather external unsigned packs.
3. Extend the single existing publisher to resolve only verified available
   pins and independently signed dependency closure.
4. Recheck trust/revocation, compatibility, capabilities, and receipts at
   publication time.
5. Stage and atomically publish active/quarantine plus generated family with
   one transition receipt.

Exit: no floating selection, split generation, or second publisher.

## Workstream 4 — Resolver and Harness Binding

1. Bind source-envelope, trust-policy, payload, dependency, import,
   compatibility, and transition digests in the generation lock.
2. Make route/prompt and runtime resolvers reject stale/revoked or actual-state
   mismatches and raw-path inputs.
3. Supply the exact verified generation ref/digest to RP-11 without changing
   Harness compiler semantics.
4. Mutate every binding and prove resolution/compile/launch denies.

Exit: desired, actual, generated, resolver, and Harness identities agree.

## Workstream 5 — Revocation and Safe Restore

1. Reconcile signer/source/release/payload revocations into availability and
   quarantine with dependency-closure impact.
2. Block new resolution, compile, and launch for affected generations.
3. Implement restore as current revalidation plus a new atomic publication,
   never pointer/file rollback.
4. Test valid prior, revoked/corrupt/incompatible/capability-expanded prior,
   missing retention, and interruption at every transition.
5. Publish extension-disabled state when no prior release passes.

Exit: revoke/restore proof satisfies UE-012 without unsafe fallback.

## Workstream 6 — Export, UX, and Burden

1. Preserve exact envelope/payload/dependency identity in pack-bundle export
   while keeping transfer trust-agnostic.
2. Provide one import command and concise available/selected/active/quarantine
   status, revoke/repair, and restore output.
3. Hide internal schema, signer bytes, packet IDs, and generated-path machinery
   from the normal view.
4. Prove no marketplace, auto-update, arbitrary fetch, daemon, or new control
   plane exists.

Exit: round-trip and operator/burden criteria pass.

## Workstream 7 — Atomic Cutover and Evidence

1. Exercise contract-only, import-only, publisher-disabled, and
   Harness-disabled safe states.
2. Rehearse rollback to private-import-denied/bundled-only operation.
3. Activate exact private pins, publisher binding, resolvers, and Harness
   generation consumption as one atomic behavior.
4. Retire digest-only external authenticity, acknowledgement-only private
   admission, floating private selection, and raw restore paths.
5. Retain UE-012 evidence and run conformance/drift reviews.

## Stop Conditions

Stop and revise the proposal if implementation requires a public marketplace,
automatic extension selection/grant/update, arbitrary unapproved fetching, a
second publisher/service/store/authority, unbounded tracked payload retention,
or ownership from RP-07, RP-11, or RP-13.
