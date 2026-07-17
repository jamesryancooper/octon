# Executable Implementation Prompt — RP-00 Owner-Lane Runtime Boundary

prompt_id: octon-rp00-owner-lane-runtime-implementation-20260717T113821Z
generated_at: 2026-07-17T11:38:21Z
generated_by_route: generate-packet-implementation-prompt
proposal_path: .octon/inputs/exploratory/proposals/architecture/octon-rp00-owner-lane-runtime
reviewed_packet_digest: sha256:efdbb050d9504783808c5cb1268540b70af2730f149355359c38dff109dbe991
artifact_class: operational-aid
authority: non-authoritative
next_lifecycle_route: run-packet-implementation

This prompt does not authorize a credential, provider call, Git push, PR,
ruleset/workflow/ref mutation, merge, terminalization, promotion, closeout, or
archive. It authorizes only the accepted packet's inert local implementation
after the review and architecture gates below pass at the exact digest.

## Preconditions

Run from the isolated clean worktree rooted at
`40fe9d0b4d1f41c69c4d2e3585c772c96a324023`. Preserve the dirty primary
worktree and frozen RP-00 candidate without modification.

Require:

```sh
PACKET=.octon/inputs/exploratory/proposals/architecture/octon-rp00-owner-lane-runtime
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package "$PACKET" --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package "$PACKET"
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt "$PACKET/support/pre-integration-architecture-review.yml" --package "$PACKET" --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package "$PACKET" --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package "$PACKET"
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package "$PACKET" --print-digest
```

The printed digest must equal the reviewed digest above. Stop on drift.

## Exact durable write scope

Only these promotion targets may receive durable implementation edits:

1. `.octon/framework/constitution/contracts/registry.yml`
2. `.octon/framework/constitution/contracts/authority/owner-lane-credential-admission-authorization-v1.schema.json`
3. `.octon/framework/constitution/contracts/authority/owner-lane-credential-issuance-outcome-receipt-v1.schema.json`
4. `.octon/framework/constitution/contracts/authority/owner-lane-credential-lifecycle-envelope-v1.schema.json`
5. `.octon/framework/constitution/contracts/authority/owner-lane-credential-admission-receipt-v1.schema.json`
6. `.octon/framework/constitution/contracts/authority/owner-lane-operation-manifest-v1.schema.json`
7. `.octon/framework/constitution/contracts/authority/owner-lane-attestation-v1.schema.json`
8. `.octon/framework/constitution/contracts/authority/owner-lane-completed-prefix-receipt-v1.schema.json`
9. `.octon/framework/constitution/contracts/authority/owner-lane-operation-construction-receipt-v1.schema.json`
10. `.octon/framework/constitution/contracts/authority/owner-lane-credential-retirement-receipt-v1.schema.json`
11. `.octon/framework/engine/runtime/spec/owner-lane-execution-v1.md`
12. `.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml`
13. `.octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml`
14. `.octon/framework/engine/runtime/crates/authorized_effects/src/lib.rs`
15. `.octon/framework/engine/runtime/crates/authority_engine/src/implementation.rs`
16. `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/effects.rs`
17. `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs`
18. `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/tests.rs`
19. `.octon/framework/engine/runtime/crates/kernel/src/main.rs`
20. `.octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs`
21. `.octon/framework/engine/runtime/crates/kernel/src/side_effects/mod.rs`
22. `.octon/framework/engine/runtime/crates/kernel/src/owner_lane.rs`
23. `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
24. `.octon/framework/execution-roles/_ops/scripts/git/git-owner-lane-askpass.sh`
25. `.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json`
26. `.octon/framework/execution-roles/practices/github-autonomy-runbook.md`
27. `.octon/instance/governance/support-target-admissions/live/github-repo-consequential-en.yml`
28. `.octon/instance/governance/support-dossiers/live/github-repo-consequential-en/dossier.yml`
29. `.octon/state/evidence/validation/support-targets/github-repo-consequential-en.yml`
30. `.octon/framework/assurance/runtime/_ops/tests/test-owner-lane-runtime.sh`

Packet-local support receipts and timestamped validation evidence are allowed
route-owned evidence, not durable promotion targets. Do not edit generated
outputs by hand.

## Workstreams

### WS1 — Artifact contracts

Implement and register the nine packet-named strict JSON Schemas. Deny unknown
fields and wrong versions. Bind accepted review, run, repository, base/head,
candidate tree, principal, intended credential tuple, one-attempt lock,
issuance outcome, nonce-salted handle/header/revocation-body digests, finite
probe/revoke budget, manifest/attestation/prefix/construction chain, actual
reached phase, terminal `401`, local destruction, and retirement state.

Use RFC 8785 JSON Canonicalization for artifact/request digests. Reject duplicate
keys, floats, non-interoperable integers, binding cycles, and self-reference.

### WS2 — Typed authority boundary

Add `ProviderRepositoryMutation` to authorized effects and authority issuance,
verification, bundle mapping, and tests. Grant it only for the exact
`rp00_owner_lane_cutover` action. Add material inventory and authorization
coverage rows. Every provider/Git mutation requires one verified single-use
token and retained consumption evidence. Preserve protected-CI auto-merge.

### WS3 — Closed executor and secret transport

Implement `owner_lane.rs` and the kernel CLI. Validate all artifacts and tool
bindings before reading the credential. Accept a fine-grained PAT only through
an inherited FD. Close the FD after one read. Remove ambient GitHub/Git
credential variables from children and never call `gh` or SSH.

Allow only fixed GitHub.com HTTPS origins and the closed RP-00 operation enum.
Resolve and hash canonical `curl`, `git`, `mkfifo`, and askpass paths before
credential capture; reverify before each launch. Send authenticated curl config
through stdin. Send the PAT to Git through one-use FIFO consumed by the fixed
askpass helper. Never put secret bytes in argv, environment, URL, config file,
durable file, log, evidence, or receipt.

Append and fsync a pre-send journal entry before each request; append the
terminal response digest afterward. A missing terminal response is
`outcome-unknown` and permanently blocks resend. Conditional operations must
bind the observed base/head/ruleset/marker/check tuple. Merge uses `sha=head`.

Terminalization submits the same exact PAT once and unauthenticated to
`POST https://api.github.com/credentials/revoke`, treats `202` as acceptance
only, waits the envelope interval, and uses only the remaining `/user` probe
budget. Require a genuine same-token `401`, buffer zeroization, FIFO removal,
empty scoped secret census, and retirement receipt.

### WS4 — Lifecycle approval routing

Convert only an explicit provider-authority-required child blocker to
`approval-required`. Bind approval to child id, route id, run id, candidate,
and operation digest. Preserve ordinary `missing-evidence` behavior. Add
positive and non-conversion/replay/drift tests.

### WS5 — GitHub contract and support proof

Update the existing control-plane contract and runbook; do not create another
adapter or control plane. Execute a full retained owner-lane run against the
hermetic GitHub/Git fixture and all negative/recovery cases. Only after that
proof passes, update the existing GitHub repo-consequential admission, dossier,
and proof bundle to add the exact `rp00-owner-lane-cutover` operation. Continue
to exclude a general API client, arbitrary repository, connector, new pack,
new tuple, and recurring provider automation.

## Validation floor

Run at minimum:

```sh
jq empty .octon/framework/constitution/contracts/authority/owner-lane-*.schema.json
cargo fmt --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml --all -- --check
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_authorized_effects
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_authority_engine
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel owner_lane
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel lifecycle_program
bash .octon/framework/assurance/runtime/_ops/tests/test-owner-lane-runtime.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-material-side-effect-inventory.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-support-target-proofing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-support-target-live-claims.sh
bash .octon/framework/assurance/runtime/_ops/scripts/verify-support-dossier-parity.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-support-dossier-evidence-depth.sh
git diff --check
```

Exercise every negative control in the packet validation plan, including token
bypass/replay, manifest canonicalization/allowlist failures, tool substitution,
secret leakage, admission mismatch, timeout at every send boundary, duplicate
askpass/revoke, false terminal response, missing prior `200`, lifecycle blocker
misclassification, and approval tuple drift.

## Evidence and receipts

Retain exact commands, commit/tree, timestamps, exit codes, full-log digests,
redacted fixtures, journal transitions, secret census, support proof, rollback,
and target coverage under the packet evidence root. Never retain secret bytes,
Authorization header bytes, revocation body bytes, or unredacted provider data.

After implementation, replace the scaffolds with:

- `support/implementation-run.md`, truthfully `pass`, `fail`, or `blocked`;
- `support/implementation-conformance-review.md` with the required conformance
  sections and zero unresolved items only on direct proof; and
- `support/post-implementation-drift-churn-review.md` with a fresh conformance
  backreference and zero unresolved items only after the final tree is frozen.

Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package "$PACKET"
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package "$PACKET"
```

This route forbids closeout or archive claims, promotion, or RP-00
continuation until both receipts pass.

## Rollback and stop conditions

Before any live credential use, rollback is a file-level revert of this
packet's implementation. This prompt authorizes no live use. Stop on packet
digest drift, undeclared durable write, generated hand edit, missing current
support proof, secret leakage, external-tool drift, unclosed token path,
unknown outcome resend, failed validator, failed rollback drill, or pressure to
describe fixtures as provider execution.

After a genuinely passing inert implementation, stop and request the separate
promotion/landing route. After that precursor lands and RP-00 is regenerated,
the provider cutover still requires a fresh exact provider authorization.
