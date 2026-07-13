# Validation Plan

All implementation validation is future work. Draft structural checks validate
packet form only and do not satisfy any target criterion.

## Layer 0 — Proposal and Ownership Gates

Run the canonical proposal-standard, architecture-proposal, program-child
readiness, implementation-readiness, and review-gate validators against the
exact packet digest. Independently compare all 38 promotion targets and every
shared entry/symbol against the parent program ownership matrix.

Required result: the packet is structurally valid, accepted through the proper
lifecycle before implementation, dependency receipts are exact, and no
RP-01/RP-06/RP-08/RP-10/RP-13/RP-14 semantic ownership overlaps.

## Layer 1 — Contract and Live-Manifest Validation

- Validate runtime/constitutional Harness and compile-receipt schema mirrors.
- Validate adapter, executor-profile, family, and topology registry entries.
- Validate every live model and host manifest against its exact strict schema.
- Reject missing identity/version/schema/conformance refs, unknown fields,
  type drift, unsupported lifecycle claims, authority-shaped fields, duplicate
  adapter IDs, and an unclaimed live-secondary admission.

Required result: all authored/live declarations validate and every negative
fixture rejects without a permissive fallback.

## Layer 2 — Closed Input Graph and Canonical Bytes

Construct fixtures covering two Workspace Projects and every input family.
For each fixture:

1. compile in two clean processes;
2. perturb locale, timezone, environment ordering, current directory, file
   discovery ordering, and irrelevant wall time;
3. compare source-manifest, effective-manifest, and deterministic receipt-body
   bytes and digests;
4. mutate each direct and transitive source exactly once; and
5. delete, duplicate, reorder, alias, cycle, or add one source.

Required result: identical complete input is byte-identical; every meaningful
change invalidates or denies; nondeterministic ambient state has no effect; and
the mutation receipt accounts for every graph node and edge.

## Layer 3 — Authorization and Immediate-Spawn Binding

Exercise valid launch plus stale, self-widened, wrong-project, wrong-mission,
wrong-run, wrong-attempt, wrong-adapter, wrong-compiler, changed-policy,
changed-extension, changed-context, and changed-rollback bindings. Inject a
source change at every point between compile, authorization, pre-spawn
revalidation, guard consumption, and provider process creation.

Required result: only one exact complete binding launches; every mismatch/race
denies before provider start and requires a fresh compile/authorization. Guard
consumption remains RP-01 semantics and no alternate dispatch path exists.

## Layer 4 — Generic Adapter Component Conformance

Execute the same provider-neutral fixture suite through:

- the one real primary-provider adapter;
- a deterministic success fake;
- failure-before-launch and failure-after-launch fakes;
- timeout/lost-response/unknown-observation fakes;
- cancel-acknowledged, cancel-race, and cancel-unsupported fakes;
- measured, estimated, malformed, and unsupported usage fakes; and
- successful and failed-retirement fakes.

Every fixture exercises `prepare`, `launch`, `observe`, `cancel`, `usage`, and
`retire`. Compare adapter/run/operation identities, typed state, observation
provenance, idempotency, unknown-outcome honesty, and residual state. Canonical
mission, authority, verification, publication, effect, recovery, and child
state must not change merely because an adapter reports a result.

Required result: primary and fake implementations satisfy one component
contract. This is the RP-11 contribution to PO-FD-023, not integrated promotion
proof and not a live-secondary claim.

## Layer 5 — Bypass and Architecture Negatives

- Scan for provider-name match dispatch, `request.executor` authority, and
  direct calls to provider launch functions outside the registry.
- Attempt unknown, drifted, disabled, fake, and unclaimed-secondary adapter IDs.
- Inject generated route/manifests/receipts as alleged canonical input.
- Inventory processes, stores, schedules, policy evaluators, writer surfaces,
  and control roots before/after implementation.
- Verify RP-06 verifier/publication, RP-08 effect/recovery, and RP-13 child
  semantics are absent from RP-11-owned symbols.

Required result: bypass attempts deny, projections cannot authorize, and no
new runtime/control plane or foreign specialization exists.

## Layer 6 — Failure, Rollback, and Operator Experience

Inject compiler interruption, corrupt receipt, missing source, schema drift,
prepare failure, launch failure, lost response, cancel race, malformed usage,
retirement failure, and rollback interruption at every cutover stage. Verify:

- candidate work and immutable sources remain available;
- only affected launches fail closed;
- no direct provider fallback appears;
- rollback returns to a declared safe state without dual dispatch; and
- the normal operator output names the affected run/project, preserved work,
  exact block, and shortest safe repair without exposing internal packet or
  adapter selection machinery.

## Planned Command Families

The implementation owner binds exact commands at the implementation commit.
The minimum floor includes:

```text
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-harness-factory
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-harness-factory
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-harness-factory
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-harness-factory
bash .octon/framework/assurance/runtime/_ops/scripts/validate-workflow-statechart-harness.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-agent-node-model-call-contract.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-executor-adapter.sh
cargo test --manifest-path .octon/framework/engine/runtime/crates/lifecycle_executor/Cargo.toml
cargo test --manifest-path .octon/framework/engine/runtime/crates/runtime_resolver/Cargo.toml
```

Additional purpose-built compiler determinism, invalidation, launch-race, and
adapter conformance tests are required; existing commands cannot be assumed to
cover new semantics.

## Retained Evidence Contract

Retain exact implementation commit, compiler/schema/precedence identities,
ordered source manifests, canonical bytes/digests, mutation coverage, launch
denials, adapter schemas/manifests, primary/fake conformance outputs, bypass
scan, cutover/rollback receipts, and validator versions under the declared
proposal-validation root. Secrets, raw provider payloads, and unbounded logs
remain outside project Git under their canonical evidence/retention owners.

## Promotion Gate

PO-FD-020 passes only when Layers 1 through 3, 5, and 6 pass at the same exact
implementation. RP-11's PO-FD-023 component receipt additionally requires
Layer 4. RP-14 must later reproduce integrated equivalence; these tests cannot
self-promote FD-023 or FD-024.
