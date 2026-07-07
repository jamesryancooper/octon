# Executable Implementation Prompt: proposal-program-supersession-rescue-path

## Prompt Generation Gate Receipt

- Packet: `.octon/inputs/exploratory/proposals/architecture/proposal-program-supersession-rescue-path`
- Review receipt: `support/proposal-review.md`
- Review id: `review-proposal-program-supersession-rescue-path-20260707T124700Z`
- Reviewed packet digest: `sha256:0a12933eba0b70fd676beb81803507f63f0fcd35809bcb0c8a08dc825685bd25`
- Implementation authorization: `yes`
- Architecture receipt: `support/pre-integration-architecture-review.yml`

## Boundary

Implement or prove only polluted-run rescue behavior: freeze evidence with
non-authorizing classification, deliverable partitioning, child-owned receipt
carry-forward by ref and digest, clean successor-run routing, and normal Change
closeout routing for deliverables when lifecycle execution should not continue
from a polluted parent run.

Do not implement loop-control behavior, route write-lease ownership controls,
closeout-worktree partition reports, cleanup authority, archive authority,
parent closeout, or child closeout for any other packet.

## Approved Promotion Targets

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/`
- `.octon/framework/product/contracts/lifecycle-interaction-request-v1.schema.json`
- `.octon/framework/product/contracts/lifecycle-interaction-return-v1.schema.json`
- `.octon/framework/product/contracts/proposal-program-delivery-profile-v1.schema.json`
- `.octon/framework/product/contracts/proposal-program-delivery-receipt-v1.schema.json`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`

## Ordered Workstreams

1. Reconcile current code first. Prove whether polluted-run freeze semantics
   already exist under another name.
2. If semantics are present, record exact code, workflow, skill, contract, and
   validator evidence in `support/implementation-run.md`.
3. If semantics are absent or incomplete, patch only the approved promotion
   targets to add non-authorizing freeze evidence, child receipt carry-forward
   refs and digests, deliverable partitioning, successor-run routing, and
   normal Change closeout routing.
4. Prove missing or stale child receipts block carry-forward, and parent
   summaries cannot satisfy child-owned receipts.
5. Keep `proposal.yml#status` as `accepted` and produce the post-
   implementation receipts before any closeout claim.

## Required Evidence

`support/implementation-run.md` must include at least `verdict`,
`implemented_at`, and `promotion_evidence_count`, then document landed
semantics, changed files if any, child receipt refs and digests, and command
outcomes.

The conformance and drift/churn receipts must explicitly cover:

- polluted-run freeze evidence is retained evidence only and cannot authorize
  mutation, cleanup, delivery, publication, closeout, archive, or terminal truth;
- child-owned receipts are carried forward only by fresh refs and digests;
- missing or stale child receipts block carry-forward;
- deliverables are partitioned from foreign/manual residue;
- successor-run or normal Change closeout routing preserves rollback posture;
- exclusions for loop breaker, ownership, and closeout-worktree behavior.

## Validation

Run the proposal gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-supersession-rescue-path --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-supersession-rescue-path
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-supersession-rescue-path
```

Run supersession and delivery proof:

```sh
cargo test -p octon_kernel unfinished_selected_child_route_start_blocks_redispatch
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-proposal-program-delivery-evidence-index.sh
```

Run delivery validators against any profile, receipt, or workflow fixture
created or changed by the implementation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh --profile <profile>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh --receipt <receipt>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh
```

Then run the post-implementation gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-supersession-rescue-path
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-supersession-rescue-path
```

## Rollback

If a new supersession patch is required and fails validation, revert only this
child's changed promotion targets or supersede through this child packet's
correction route. Do not allow polluted-run freeze evidence to become cleanup,
delivery, publication, closeout, archive, or terminal authority.

## Closeout Refusal Criteria

Refuse implemented, closeout, archive-ready, or parent-program terminal claims
while polluted-run freeze semantics are absent, child receipt carry-forward is
ambiguous, or `support/implementation-run.md`,
`support/implementation-conformance-review.md`, or
`support/post-implementation-drift-churn-review.md` is missing, failing,
unresolved, stale, or replaced by parent-local evidence.
