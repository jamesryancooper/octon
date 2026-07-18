# Implementation Plan

This plan describes later implementation. It does not authorize it.

## Workstream 0 — Freeze Entry Interfaces and Ownership

1. Verify exact exit receipts/digests for RP-01, RP-02, and RP-10.
2. Capture the current Harness/route/resolver/compiler, authorization consumer,
   adapter manifest/schema, and provider-dispatch call graph; freeze parity
   with all four RP-01 candidate-launch seams and the non-candidate utility
   partition.
3. Assign every shared registry entry and `lifecycle_executor` symbol to one
   packet owner; reserve child-specific additions for RP-13.
4. Record the compiler, schema set, precedence table, and adapter conformance
   identity/version plan.

Exit: no unresolved dependency interface or shared semantic owner.

## Workstream 1 — Complete Contracts

1. Extend runtime and constitutional Harness schemas to require the closed
   source graph and complete effective per-run envelope.
2. Extend compile-receipt schemas with compiler/schema/precedence identity,
   source-manifest root, effective digest, and launch binding.
3. Make adapter schemas strict and align every live model/host manifest.
4. Define adapter identity/version/schema/conformance refs and six lifecycle
   method/result contracts.
5. Update only RP-11-owned family, topology, and policy entries.

Exit: mirrors match, schemas reject unknown/authority-shaped fields, and live
manifests have no drift.

## Workstream 2 — Pure Harness Compiler

1. Replace implicit/default source collection with one typed compile request.
2. Enumerate the complete direct/transitive source graph, including explicit
   optional absence and parent edges.
3. Implement authority-first precedence and narrowing; reject conflicts and
   widening rather than guessing.
4. Normalize paths and scalar/list forms under versioned rules.
5. Canonically serialize source and effective manifests without ambient or
   time-dependent values.
6. Emit deterministic receipt body and evidence-owned observational envelope.

Exit: identical/golden compiles and complete each-input invalidation pass with
closed-graph coverage.

## Workstream 3 — Authorization and Spawn Binding

1. Add exact compiler/source/effective/adapter fields to the RP-01 consumer
   request and proof without changing RP-01 authority predicates.
2. Bind immutable RP-10 project/Profile and RP-02 isolation refs.
3. Revalidate every source digest, canonical bytes, adapter declaration, guard
   identity/expiry/consumption, and run/attempt identity immediately before
   spawn.
4. Eliminate re-resolution or discretionary defaults between check and spawn.
5. Deny any changed/stale/wrong/widened binding and require a fresh compile and
   authorization.
6. Record `consumed-no-confirmed-spawn` on failure after guard consumption and
   `unknown` on lost spawn response; never reuse, retry, or switch adapters.

Exit: the complete launch-denial and compile-to-spawn race matrix passes.

## Workstream 4 — Generic Adapter Seam

1. Replace `request.executor: String` dispatch semantics with typed exact
   adapter identity and registry lookup.
2. Implement generic prepared handle and typed results for `prepare`, `launch`,
   `observe`, `cancel`, `usage`, and `retire` in `adapter.rs`.
3. Route all provider-neutral observation through the generic seam.
4. Convert Codex to the real primary-provider implementation.
5. Create fake adapters for every lifecycle success/failure/unknown edge.
6. Remove hardcoded `mock`/`codex`/`claude`/`auto` match dispatch and every
   direct provider call. Keep Claude inactive unless separately admitted.

Exit: one generic dispatch seam exists and direct bypass tests deny.

## Workstream 5 — Component Conformance

1. Execute every lifecycle fixture against the real primary provider and fake
   adapters in disposable, credential-bounded test environments.
2. Compare provider-neutral identities, state transitions, cancellation truth,
   usage provenance, and retirement residue.
3. Prove adapter output cannot alter authority, mission status, verification,
   publication, recovery, effect, or child semantics.
4. Retain the RP-11 component receipt for later RP-14 independent reproduction.

Exit: the RP-11 portion of UE-011 passes without claiming live-secondary or
integrated equivalence.

## Workstream 6 — Atomic Cutover and Retirement

1. Exercise inert compiler, shadow comparison, and adapter-disabled safe states.
2. Rehearse rollback while preserving candidates, inputs, and receipts.
3. Activate complete compiler/digest binding/generic dispatch as one atomic
   behavioral cutover.
4. Retire legacy executor-name and direct provider paths; retain route inputs
   only as declared non-authoritative sources where needed.
5. Refresh generated projections through owners and scan for proposal
   backreferences.

Exit: no dual authority/dispatch, direct fallback, or proposal dependency.

## Workstream 7 — Evidence and Handoff

1. Retain compiler/source/manifest/receipt identities and all dynamic matrices.
2. Run implementation conformance and post-implementation drift/churn reviews.
3. Hand the adapter component receipt to RP-06/RP-08/RP-13 consumers and RP-14
   independent promotion owner without transferring source ownership.
4. Close only after the parent program accepts dependency, proof, and registry
   freshness receipts.

## Implementation Stop Conditions

Stop and revise the proposal if implementation requires a new scheduler,
runtime/store, policy or authority source, direct provider fallback, live
secondary claim, or semantic ownership from RP-06, RP-08, RP-13, or RP-14.
