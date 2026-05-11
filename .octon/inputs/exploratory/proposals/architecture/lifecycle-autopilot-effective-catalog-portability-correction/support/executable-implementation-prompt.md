# Executable Implementation Prompt

Implement the accepted proposal packet
`lifecycle-autopilot-effective-catalog-portability-correction`.

## Operating Contract

- Read and follow repository ingress before editing:
  `AGENTS.md` and `.octon/instance/ingress/AGENTS.md`.
- Treat this packet as implementation guidance only. It is not durable authority
  until implemented through the listed promotion targets and validated.
- Stay inside the approved promotion target set unless a validator proves a
  directly necessary adjacent edit and you record that reason in
  `support/implementation-conformance-review.md`.
- Do not claim promotion, closeout, archive, or live Lifecycle Autopilot
  correction until implementation conformance and post-implementation drift/churn
  receipts pass.

## Approved Promotion Targets

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/crates/runtime_resolver/src/lib.rs`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-runner.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-proposal-lifecycle-v1-acceptance.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-lifecycle-contracts.sh`
- `.octon/framework/product/features/lifecycle-autopilot.md`

## Required Workstreams

### 1. Preflight And Reproduction

Run the packet review gate before durable edits:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-autopilot-effective-catalog-portability-correction --require-implementation-authorization
```

Add or update a focused failing regression that proves
`octon lifecycle plan --lifecycle proposal-program --target <parent-program>`
is blocked when the effective catalog contains an unrelated pack with
`lifecycle_contracts: []` and no `lifecycle-contract` capability profile.

Add or update the corresponding negative tests proving that:

- a non-empty `lifecycle_contracts` declaration without `lifecycle-contract`
  still fails closed;
- a missing lifecycle contract projection still fails closed;
- registry drift is still detected by `generate-proposal-registry.sh --check`.

### 2. Runtime Lifecycle Discovery

Update lifecycle discovery so the effective extension catalog distinguishes
these cases:

- absent `lifecycle_contracts`: no lifecycle-contract profile required;
- empty `lifecycle_contracts: []`: treat as absent lifecycle contracts;
- non-empty `lifecycle_contracts`: require `lifecycle-contract` and validate the
  referenced contract projection.

Preserve denial for malformed non-empty lifecycle contract declarations,
missing projections, and non-empty lifecycle contracts without the
`lifecycle-contract` capability profile.

### 3. Proposal Registry Portability

Choose one implementation path and test it:

- make `.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh`
  portable across the repository-supported shell baseline; or
- enforce a clear Bash version requirement and make
  `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh`
  call the generator through that supported interpreter with an actionable
  diagnostic before misleading proposal errors.

The selected path must keep `generate-proposal-registry.sh --check` fail-closed
on real registry drift.

### 4. Evidence And Documentation

Declare the retained evidence surface for fallback/manual lifecycle creation.
The evidence must live under `.octon/state/evidence/runs/<run-id>/receipts/**`
or an equivalent validator-checked receipt contract before closeout.

Update `.octon/framework/product/features/lifecycle-autopilot.md` so support
claims match implemented behavior. Do not imply proposal-program route execution
unless runtime tests and retained evidence prove it.

## Required Validation

Run and record the outcome of at least:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-runner.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-proposal-lifecycle-v1-acceptance.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-lifecycle-contracts.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-autopilot-effective-catalog-portability-correction
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-autopilot-effective-catalog-portability-correction
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-autopilot-effective-catalog-portability-correction
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
```

Run affected Rust tests for lifecycle planning and runtime resolver behavior.
If a narrower Rust command is used, explain why it covers the touched runtime
surface in `support/implementation-conformance-review.md`.

After implementation, replace both proposal-owned receipts:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-autopilot-effective-catalog-portability-correction
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-autopilot-effective-catalog-portability-correction
cd .octon/inputs/exploratory/proposals/architecture/lifecycle-autopilot-effective-catalog-portability-correction && shasum -a 256 -c SHA256SUMS.txt
```

## Rollback Posture

Rollback by reverting runtime loader, runtime resolver, validator, tests, and
documentation changes if lifecycle discovery accepts unsafe non-empty lifecycle
contract declarations, if registry synchronization stops failing closed on real
drift, or if documentation claims behavior that tests and retained evidence do
not prove.

## Terminal Criteria

- Empty lifecycle contract arrays no longer block unrelated proposal-program
  planning.
- Non-empty invalid lifecycle contract declarations still fail closed.
- Registry validation is portable or fails early with an actionable supported
  Bash diagnostic.
- Fallback/manual lifecycle creation evidence has a durable, validator-visible
  surface.
- `support/implementation-conformance-review.md` and
  `support/post-implementation-drift-churn-review.md` both pass their validators.
- Closeout and archive remain blocked until all required receipts and validators
  pass.
