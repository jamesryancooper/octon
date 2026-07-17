# Executable Implementation Prompt

proposal_id: octon-rp00-owner-lane-runtime
reviewed_packet_digest: sha256:d714e3101fe81b5ee3dc2bd82511701764e3e472055b682d9dd66489224f46b8
route: run-packet-implementation
implementation_scope: inert-local-correction-only
provider_effects_authorized: no

## Objective

Implement the accepted staged RP-00 owner-lane correction in the existing
Octon runtime and authority boundary. Close the temporal-binding,
credential-binding, and post-PR-construction findings without weakening the
landed secret transport, fixed-tool verification, allowlist, authority-token,
journal, no-resend, or terminalization controls.

This prompt authorizes local durable edits only to the declared promotion
targets below and route-owned packet/evidence receipts. It does not authorize
credential issuance or capture, a provider request, Git push, pull request,
marker, ruleset, check, merge, revocation, generated publication, RP-00 retry,
or any other external effect.

## Entry Gates

Before editing promotion targets, require all of the following to pass at the
digest above:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/octon-rp00-owner-lane-runtime --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/octon-rp00-owner-lane-runtime/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/octon-rp00-owner-lane-runtime --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-rp00-owner-lane-runtime
```

Refuse implementation if the reviewed digest changes, any blocker reopens, or
the required change exceeds the exact promotion-target list.

## Promotion Targets

1. `.octon/framework/constitution/contracts/registry.yml`
2. `.octon/framework/constitution/contracts/authority/owner-lane-credential-admission-authorization-v1.schema.json`
3. `.octon/framework/constitution/contracts/authority/owner-lane-credential-capture-metadata-v1.schema.json`
4. `.octon/framework/constitution/contracts/authority/owner-lane-credential-issuance-outcome-receipt-v1.schema.json`
5. `.octon/framework/constitution/contracts/authority/owner-lane-credential-lifecycle-envelope-v1.schema.json`
6. `.octon/framework/constitution/contracts/authority/owner-lane-credential-admission-receipt-v1.schema.json`
7. `.octon/framework/constitution/contracts/authority/owner-lane-operation-plan-v1.schema.json`
8. `.octon/framework/constitution/contracts/authority/owner-lane-operation-manifest-v1.schema.json`
9. `.octon/framework/constitution/contracts/authority/owner-lane-attestation-v1.schema.json`
10. `.octon/framework/constitution/contracts/authority/owner-lane-completed-prefix-receipt-v1.schema.json`
11. `.octon/framework/constitution/contracts/authority/owner-lane-operation-construction-receipt-v1.schema.json`
12. `.octon/framework/constitution/contracts/authority/owner-lane-credential-retirement-receipt-v1.schema.json`
13. `.octon/framework/engine/runtime/spec/owner-lane-execution-v1.md`
14. `.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml`
15. `.octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml`
16. `.octon/framework/engine/runtime/crates/authorized_effects/src/lib.rs`
17. `.octon/framework/engine/runtime/crates/authority_engine/src/implementation.rs`
18. `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/effects.rs`
19. `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs`
20. `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/tests.rs`
21. `.octon/framework/engine/runtime/crates/kernel/src/main.rs`
22. `.octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs`
23. `.octon/framework/engine/runtime/crates/kernel/src/side_effects/mod.rs`
24. `.octon/framework/engine/runtime/crates/kernel/src/owner_lane.rs`
25. `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
26. `.octon/framework/execution-roles/_ops/scripts/git/git-owner-lane-askpass.sh`
27. `.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json`
28. `.octon/framework/execution-roles/practices/github-autonomy-runbook.md`
29. `.octon/instance/governance/support-target-admissions/live/github-repo-consequential-en.yml`
30. `.octon/instance/governance/support-dossiers/live/github-repo-consequential-en/dossier.yml`
31. `.octon/state/evidence/validation/support-targets/github-repo-consequential-en.yml`
32. `.octon/framework/assurance/runtime/_ops/tests/test-owner-lane-runtime.sh`

No other durable implementation path is authorized. Packet support receipts
and retained validation evidence are route-owned outputs, not promotion scope.

## Workstream 1 — Strict staged contracts

- Add and register strict closed schemas for nonsecret credential-capture
  metadata and the immutable operation plan.
- Make pre-issuance authorization bind the plan digest, exact candidate,
  principal, complete intended credential tuple, tools, evidence root, request
  budgets, one-attempt lock, and replacement lock. It must not bind admission,
  manifest, attestation, completed-prefix, or provider-response evidence.
- Extend issuance, lifecycle, admission, manifest, attestation,
  completed-prefix, construction, and retirement contracts with one-way staged
  lineage and exact digest domains.
- Reject unknown fields, floats, duplicate keys, noninteroperable integers,
  self-reference, observation-before-stage claims, and upstream backreferences.

## Workstream 2 — Staged executor

- Change `owner-lane execute` to accept only authorization, capture metadata,
  operation plan, evidence root, and one inherited credential FD.
- Validate independent inputs, canonical tool paths/digests, locks, time, and
  budgets before reading and closing the credential FD.
- Generate and durably write issuance and lifecycle artifacts before the first
  authenticated request.
- Journal and execute only the admitted identity, repository, and declared
  capability reads; generate admission from actual responses plus separately
  classified trusted capture facts.
- Generate the final manifest and realized attestation after admission. The
  manifest binds the plan and prior artifact digests but has no recursive or
  realized-attestation dependency.
- Execute the prefix, perform one authoritative pull-request reconciliation,
  and durably record canonical provider-assigned PR identity in the
  completed-prefix receipt.
- Resolve suffix requests only from strict typed bindings for manifest digest,
  attestation digest, completed-prefix digest, and canonical PR number. Emit a
  durable construction receipt after normalization reproduces the sealed
  template digest and before each send.
- Preserve create-only or exact-byte-idempotent artifacts, request journaling,
  outcome-unknown no-resend, fixed-origin allowlisting, fixed-tool integrity,
  inherited-FD/stdin/FIFO secret transport, secret census, same-token
  terminalization, and retirement evidence.

## Workstream 3 — Denial and recovery proof

Add positive and adversarial tests for:

- truthful stage order and every forbidden future-artifact backreference;
- complete credential tuple, capture/lifetime mismatch, expiry, deadline,
  budget, one-attempt, and replacement-lock failure;
- interruption/resume after each durable boundary and conflicting artifact
  bytes;
- zero, multiple, mismatched, substituted, or predicted PR identity and
  unknown PR-create outcome replay;
- unknown/recursive/arbitrary typed bindings, upstream substitution,
  normalization mismatch, and send-before-construction durability;
- tool/path substitution, allowlist escape, authority-token replay, request
  replay, and outcome-unknown denial;
- token leakage through argv, environment, URL, files, logs, evidence, child
  process state, helpers, SSH, `gh`, FIFO reuse, or residual census;
- unauthenticated at-most-once revocation, false terminal response, missing
  prior authenticated success, local destruction failure, and replacement
  denial.

The hermetic shell proof must use fake provider/tool fixtures and must never
read a real credential or reach the network.

## Workstream 4 — Contract and support alignment

- Update the runtime specification and GitHub control-plane/runbook contract
  with the stage order, complete credential tuple, trusted-capture limitation,
  PR reconciliation, typed construction, recovery, and no-resend semantics.
- Refresh material-side-effect inventory and authorization coverage only where
  the staged entrypoint changes the declared consumer path.
- Update the existing exact-operation admission, dossier, and support proof
  only after the retained staged hermetic proof passes; do not widen the
  support target or introduce a general GitHub capability.

## Validation and retained evidence

Run the packet validation plan, including JSON-schema parsing and registry
checks, formatting, targeted and full Rust tests, hermetic shell tests,
material-side-effect inventory, authorization coverage, support proof/live
claim, dossier parity/evidence depth, proposal gates, and `git diff --check`.

Retain exact commands, timestamps, exit codes, base and resulting tree,
promotion-target diff, staged artifact/request digests from redacted fixtures,
journal/no-resend lineage, secret census, and rollback result under:

`.octon/state/evidence/validation/proposals/octon-rp00-owner-lane-runtime/<run-id>/`

Never retain a token, Authorization header, revocation body, unredacted
provider payload, or reversible secret-derived value.

## Post-implementation receipts

Replace the superseded evidence with truthful current receipts:

- `support/implementation-run.md`;
- `support/implementation-conformance-review.md`;
- `support/post-implementation-drift-churn-review.md`;
- `support/validation.md`.

Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/octon-rp00-owner-lane-runtime
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/octon-rp00-owner-lane-runtime
```

## Rollback and terminal criteria

Rollback is a whole-correction revert before promotion. Preserve unknown-send
and no-resend evidence; never repair an uncertain run by replay. Do not alter
the frozen RP-00 candidate during this implementation route.

Report implementation complete only when every declared target is either
conformingly changed or explicitly proven unchanged, all acceptance criteria
have current local evidence, conformance and drift/churn receipts pass, no
provider effect occurred, and the packet remains `accepted`. Refuse closeout,
archive, promotion, landing, credential issuance, and DAG continuation until
their separate lifecycle routes are authorized and complete.
