# Implementation Plan

This plan is inactive until the packet is accepted and its future
implementation gates pass.

## Preconditions

1. RP-04's design is accepted. Its implemented/verified broker interface gates
   RP-05 source entry rather than proposal authorization.
2. RP-03 operation/attempt transitions and RP-04 broker file ownership are
   frozen for this packet.
3. ED-003 is selected exactly by
   `resources/git-provider-design-and-dependency-receipt.yml`: sanitized Git
   Smart HTTP receive-pack, explicit force-with-lease old-value CAS,
   independent ancestry proof, GitHub App credential pipe, quarantined object
   import, and separated observation/attribution.
4. RP-06 exact verdict and route interface is known but not implemented by
   RP-05.
5. Exact Git/tool/provider/App/ruleset/TLS and disposable scratch preflight
   passes before source changes.
6. Rollback disables the route before any consequential transition.

## Workstream 1 — Freeze Contracts And Physical Ownership

- Reserve local_broker/src/adapters/git/ exclusively for RP-05.
- Define immutable request/result, object-transfer, allowlist, and observation
  types through authorized_effects and the adapter module.
- Bind the request to RP-03 operation and attempt identity without changing the
  store schema.
- Record that RP-04 owns broker core and credentials, RP-06 owns verifier and
  routing, and RP-08 owns outcome classification.

## Workstream 2 — Independent Object Import

- Create broker-owned minimal or bare Git state with pinned provider identity.
- Accept only the exact candidate commit and required object closure.
- Validate object format, reachability, size, and identity before use.
- Prove the import performs no checkout, hook, filter, attribute, submodule, or
  transport execution.
- Delete or quarantine malformed imports without touching candidate work.

## Workstream 3 — Closed Git Policy

- Use a minimal explicit environment and broker-selected binaries.
- Deny repository, global, system, command-line, and environment configuration
  sources except the closed adapter policy.
- Deny unapproved protocols and external programs.
- Make remote and ref identities immutable and provider-specific.
- Build the full hostile extension matrix before any scratch ref update.

## Workstream 4 — Expected-Old Fast-Forward Primitive

- Independently verify expected-old and proposed-new object identities.
- Prove proposed-new descends from expected-old.
- Execute only the selected closed force-with-lease ref shape after the
  independent ancestry gate; receive-pack compares the explicit old value
  atomically and stale values deny.
- Persist attempt intent through the RP-03/RP-04 interface before the call.
- Return normalized observations and authenticated provider receipt material
  when available.
- Never infer causal performance from target equality alone.

## Workstream 5 — Facade Cutover And Retirement

- Keep current hosted helpers non-production while the broker adapter is in
  shadow/fixture mode.
- Convert required callers to the broker adapter.
- Remove or hard-disable ambient mutation code only after positive and
  negative parity proof.
- Keep production publication disabled until RP-06, RP-07, and RP-08 gates
  pass; PR is not a technical compatibility fallback.
- Update material-side-effect inventory and authorization-boundary coverage so
  direct Git mutation outside the adapter is denied.

## Workstream 6 — Proof And Handoff

- Execute PO-FD-009 and UE-005.
- Produce the FD-010 Git-primitive interface receipt for RP-06.
- Retain adapter/policy digests, hostile fixtures, scratch effects, target
  races, lost responses, and writer-inventory results.
- Run packet conformance and drift/churn review.

## Parallelization

RP-06 may design verifier and route contracts while RP-05 is implemented, but
RP-06 cannot exit until the Git primitive passes. No agent may concurrently
modify the same broker Git module, current hosted landing scripts, or Git
contract files. RP-05 may not modify RP-03 transitions or RP-06 policy to make
its tests pass.

## Completion Refusal

Stop rather than broaden scope if no provider mechanism can supply atomic
expected-old plus fast-forward-only behavior, if object transfer requires
candidate execution, if RP-04 cannot provide exclusive credential custody, or
if implementation requires a durable non-.octon target. Such evidence triggers
architecture repair or an owning-packet decision, not a weaker adapter.

The effect workstream implements four sealed operations, not a generic client:
source-ref expected-absent/expected-tip create/update, target `O -> S` CAS,
conditional expected-tip delete, and fast-forward-only local mirror. Every
provider call commits a distinct RP-03 operation/attempt before send. RP-06
owns requests/PR policy; RP-08 owns result and cleanup lifecycle.
